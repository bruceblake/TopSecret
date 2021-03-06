//
//  ChatRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/10/21.
//

import Foundation
import Combine
import SwiftUI
import Firebase


class ChatRepository : ObservableObject {
    @Published var userList : [User] = []
    @Published var userIDList: [String] = []
    @Published var usersTypingList : [User] = []
    @Published var usersIdlingList : [User] = []
    @Published var group : Group = Group()
    @Published var pushText : Bool = false

    
    var colors: [String] = ["green","red","blue","orange","purple","teal"]

    
    
    
    //this is for chat info tab
    func getUsers(usersID: [String]){
        
        COLLECTION_USER.whereField("uid", in: usersID).getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.userList = documents.map({ (queryDocumentSnapshot) -> User in
                let data = queryDocumentSnapshot.data()
                return User(dictionary: data)
            })
        }
        
    }
    
    func getUsersIDList(users: [User]){
        
        self.userIDList = users.map({ i -> String in
            return i.id ?? ""
        })
        
    }
    
    
    
    //this is for fetching idle users from database
    func getUsersIdlingList(chatID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).addSnapshotListener { (snapshot, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            let data = snapshot!.data()
            let usersIdling = data?["usersIdlingList"] as? [String] ?? []
            
            
            if ((snapshot?.didChangeValue(forKey: "usersIdlingList")) != nil){

                self.usersIdlingList.removeAll()

                for user in usersIdling{
                    COLLECTION_USER.document(user).getDocument { (snapshot, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                            return
                        }


                        let data = snapshot!.data()
                        
                        self.usersIdlingList.append(User(dictionary:  data ?? [:]))
                        
                    }
                }
                
            }
            
        }
    }
    
    func getUsersTypingList(chatID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).addSnapshotListener { (snapshot, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            let data = snapshot!.data()
            let usersTyping = data?["usersTypingList"] as? [String] ?? []
            
            if ((snapshot?.didChangeValue(forKey: "usersTypingList")) != nil){
                self.usersTypingList.removeAll()

                for user in usersTyping{
                    COLLECTION_USER.document(user).getDocument { (snapshot, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                            return
                        }
                        
                        self.usersTypingList.append(User(dictionary: snapshot!.data()!))
                    }
                }
            }
            
          
            
           
            
           
           
        }
       
    }
    
    func startTyping(userID: String, chatID: String, chatType: String, groupID: String){
        if chatType == "groupChat" {
            COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["usersTypingList":FieldValue.arrayUnion([userID])])
        }else if chatType == "personal"{
            COLLECTION_USER.document(userID).collection("Personal Chats").document(chatID).updateData(["usersTypingList":FieldValue.arrayUnion([userID])])
        }
    }
    
    func stopTyping(userID: String, chatID: String, chatType: String, groupID: String){
        if chatType == "groupChat" {
            COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["usersTypingList":FieldValue.arrayRemove([userID])])
        }else if chatType == "personal"{
            COLLECTION_USER.document(userID).collection("Personal Chats").document(chatID).updateData(["usersTypingList":FieldValue.arrayRemove([userID])])
        }
    }
  
    
    func openChat(userID: String, chatID: String, chatType: String, groupID: String){
        if chatType == "groupChat"{
            COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["usersIdlingList":FieldValue.arrayUnion([userID])])
        }else if chatType == "personal"{
            COLLECTION_USER.document(userID).collection("Personal Chats").document(chatID).updateData(["usersIdlingList":FieldValue.arrayUnion([userID])])
        }
        
        
    }
    
    func exitChat(userID: String, chatID: String, chatType: String, groupID: String){
        if chatType == "groupChat"{
            COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["usersIdlingList":FieldValue.arrayRemove([userID])])
        }else if chatType == "personal"{
            COLLECTION_USER.document(userID).collection("Personal Chats").document(chatID).updateData(["usersIdlingList":FieldValue.arrayRemove([userID])])
        }
    }
    
    
    
    func getGroup(groupID: String){
        COLLECTION_GROUP.document(groupID).getDocument { (snapshot, err) in
            if err != nil{
                print("ERROR")
                return
            }
            let data = snapshot?.data() as [String:Any]
            self.group = Group(dictionary: data )
        }
    }
   
    
    func createGroupChat(name: String, users: [String], groupID: String, chatID: String){
        
        _ = UUID().uuidString
        
        
        let data = ["name": name,
                    "memberAmount":1,
                    "dateCreated":Date(),
                    "users":users, "id":chatID, "chatNameColors":[], "pickedColors":[], "nextColor":0,"groupID":groupID,"chatType":"groupChat"] as [String : Any]
        
        _ = ChatModel(dictionary: data)
        
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).setData(data) { (err) in
            if err != nil{
                print("Error")
                return
            }
        }
        
   
        
            for user in users {
                self.pickColor(chatID: chatID, picker: 0, userID: user, groupID: groupID)
            }

    }
    func createGroupChat(name: String, users: [String], groupID: String, chatID: String, completion: @escaping (ChatModel) -> ()) -> (){
        
        
        
        let data = ["name": name,
                    "memberAmount":1,
                    "dateCreated":Date(),
                    "users":users, "id":chatID, "chatNameColors":[], "pickedColors":[], "nextColor":0,"groupID":groupID,"chatType":"groupChat"] as [String : Any]
        
        let chat = ChatModel(dictionary: data)
        
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).setData(data) { (err) in
            if err != nil{
                print("Error")
                return
            }
        }
        
       
            for user in users {
                self.pickColor(chatID: chatID, picker: 0, userID: user, groupID: groupID)
            }
    
        return completion(chat)
    }
    
    
    
    func leaveChat(chatID: String, userID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["memberAmount":FieldValue.increment(Int64(-1))])
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["users":FieldValue.arrayRemove([userID])])
        
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).getDocument { (snapshot, err) in
            
            if err != nil {
                print("ERROR")
                return
            }
            
            let users = snapshot?.get("Users") as? [String] ?? []
      
            
            if users.count <= 0 {
                
                COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").getDocuments { (snapshot, err) in
                  
                    for document in snapshot!.documents{
                        let messageID = document.get("id") as! String
                        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).delete()
                    }
                }
                COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).delete() { err in
                    
                    if err != nil {
                        print("Unable to delete chat")
                    }else{
                        print("sucessfully deleted chat")
                    }
                    
                }
            }
            
            
            
            
            
        }
        
        
    }
    
    func pickColor(chatID: String,picker: Int,userID: String, groupID: String) -> String{
       
        var choice = 0
        
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            _ = snapshot?.get("nameColors") as? [[String:String]] ?? [["":""]]
            let nextColor = snapshot?.get("nextColor") as? Int ?? 0
            choice = nextColor
            COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["nameColors":FieldValue.arrayUnion([[userID:self.colors[nextColor]]])])
            COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["nextColor":FieldValue.increment(Int64(1))])
            
        }
        
        return self.colors[choice]
      
        
    }
    
    func joinChat(chatID: String, userID: String, groupID: String){
        
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["users":FieldValue.arrayUnion([userID])])
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["memberAmount":FieldValue.increment(Int64(1))])
        pickColor(chatID: chatID, picker: 0, userID: userID, groupID: groupID)
        
    }
    
}

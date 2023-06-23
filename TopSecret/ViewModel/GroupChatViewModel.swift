//
//  GroupChatViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import Foundation
import SwiftUI
import Firebase


class GroupChatViewModel : ObservableObject {
    @Published var messages : [Message] = []
    @Published var text: String = ""
    @Published var currentChatColor = "green"
    @Published var scrollToBottom = 0
    @Published var usersIdling : [User] = []
    @Published var usersTyping : [User] = []
    @Published var readAllMessagesListener : ListenerRegistration?
    @Published var chatListener : ListenerRegistration?
    @Published var usersIdlingListener : ListenerRegistration?
    @Published var chat : ChatModel = ChatModel()
    @Published var users: [User] = []
    
    
    
    func readLastMessage(chatID: String, userID: String){
        
        
        
        COLLECTION_PERSONAL_CHAT.document(chatID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var usersThatHaveSeen = data["usersThatHaveSeenLastMessage"] as? [String] ?? []
            if !usersThatHaveSeen.contains(userID){
                COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
                
                COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":FieldValue.arrayUnion([userID])])
             
                
                
                
            }
            
            
        }
        
        
        
        
    }
    
    func startTyping(userID: String, chatID: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersTypingID":FieldValue.arrayUnion([userID])])
       
        
    }
    
    func stopTyping(userID: String, chatID: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersTypingID":FieldValue.arrayRemove([userID])])
        
        
    }
  
    
    func openChat(userID: String, chatID: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("UsersIdling").document(userID).setData(["user":userID])
    }
    
    func exitChat(userID: String, chatID: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("UsersIdling").document(userID).delete()

        
    }
    
    
    
    
    func readAllMessages(chatID: String, groupID: String){
        
        
        readAllMessagesListener = COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp", descending: false).addSnapshotListener { snapshot, err in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            self.messages = snapshot!.documents.map{ snapshot -> Message in
                let data = snapshot.data()
                
                

                
                return Message(dictionary: data)
            }
        }
        
    }
    
    
    //action
    
    func sendTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String,messageType: String, chatID: String, groupID: String, messageColor: String){
        
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":timeStamp,
                               "nameColor":nameColor,
                               "id":messageID,
                               "profilePicture":user.profilePicture
                               ?? "",
                               "type":messageType,
                               "value":text,
                               "userID":user.id ?? " "] as! [String:Any]
        
        let dp = DispatchGroup()
        
        dp.enter()
        
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).setData(textMessageData)
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":messageID])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
            
            
            
        })
        
        
    }
    
    func editMessage(messageID: String, chatID: String, text: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).updateData(["messageValue":text])
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).updateData(["edited":true])
        self.scrollToBottom += 1

    }
    
    func sendImageMessage(name: String, timeStamp: Timestamp, nameColor: String, messageID: String, profilePicture: String, messageType: String ,chatID: String, imageURL: UIImage, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).setData(["name":name,"timeStamp":timeStamp, "nameColor":nameColor, "id":messageID,"profilePicture":profilePicture,"messageType":messageType,"messageValue":""])
        persistImageToStorage(image: imageURL, chatID: chatID, messageID: messageID, groupID: groupID)
        self.scrollToBottom += 1
        
    }
    
    func sendDeletedMessage(name: String, timeStamp: Timestamp, nameColor:String, messageID: String, messageType: String, chatID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).setData(
            //this is the message
            ["name":name,"timeStamp":timeStamp,"nameColor":nameColor,"id":messageID,"messageType":messageType]
        )
        
        self.scrollToBottom += 1
    }
    
    
    //fetching
    func listenToChat(chatID: String, groupID: String, completion: @escaping (Bool) -> ()) -> (){
        
        
        
        
        chatListener = COLLECTION_PERSONAL_CHAT.document(chatID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() ?? [:]
            let usersID = data["usersID"] as? [String] ?? []
            let groupD = DispatchGroup()
            
            
            //fetch all chat users
            groupD.enter()
            self.fetchChatUsers(users: usersID) { fetchedUsers in
                data["users"] = fetchedUsers
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute: {
                self.chat = ChatModel(dictionary: data)
                self.users = data["users"] as? [User] ?? []
                print("id count: \(usersID.count)")
                return completion(true)
            })
            
            
        }
    }
    
    func listenToUsersIdling(chatID: String, groupID: String){
        
    usersIdlingListener  = COLLECTION_PERSONAL_CHAT.document(chatID).collection("UsersIdling").addSnapshotListener({ snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let snapshot = snapshot else{
                print("ERROR")
                return
            }
        
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added{
                    var user = diff.document.get("user") as? String ?? " "
                    self.fetchChatUser(userID: user) { fetchedUser in
                        if !self.usersIdling.contains(fetchedUser){
                        self.usersIdling.append(fetchedUser)
                        }
                      
                    }
                }else if diff.type == .removed {
                    var user = diff.document.get("user") as? String ?? " "
                    self.fetchChatUser(userID: user) { fetchedUser in
                        self.usersIdling.removeAll { idleUser in
                            return idleUser == fetchedUser
                        }
                        
                      
                    }
                }
            }
            
        })
    }
    
    func fetchChatUser(userID: String,completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
        }
    }
    
    
    func getColor(userID: String, groupChat: ChatModel) -> String{
        var ans = ""
        for maps in groupChat.nameColors ?? []{
            for key in maps.keys{
                if key == userID{
                    ans = maps[userID] ?? ""
                }
            }
        }
        return ans
    }
    
    func checkIfUserIsIdling(userID: String) -> Bool {
     
        
        return self.chat.usersIdlingID.contains(userID) 
        
    }
    
    func fetchChatUsers(users: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        
        var groupD = DispatchGroup()
        
        for userID in users {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                usersToReturn.append(User(dictionary: data))
                groupD.leave()
            }
        }
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    

    
    func readLastMessage() -> Message {
        return self.messages.last ?? Message()
    }
    
    
    //persis to storage
    
    func persistImageToStorage(image: UIImage, chatID: String, messageID: String, groupID: String) {
        let fileName = "images/\(chatID)"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { (metadata, err) in
            if err != nil{
                print("ERROR")
                return
            }
            ref.downloadURL { (url, err) in
                if err != nil{
                    print("ERROR: Failed to retreive download URL")
                    return
                }
                print("Successfully stored image in database")
                let imageURL = url?.absoluteString ?? ""
                COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).updateData(["messageValue":imageURL])
            }
        }
        
    }
}

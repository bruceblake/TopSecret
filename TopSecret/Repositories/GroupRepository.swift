//
//  GroupRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/10/21.
//

import Foundation
import Combine
import SwiftUI
import Firebase

class GroupRepository : ObservableObject {
    
    @ObservedObject var chatRepository = ChatRepository()
    @ObservedObject var pollRepository = PollRepository()
    @Published var groupChat : ChatModel = ChatModel()
    @Published var usersProfilePictures : [String] = []
    @Published var countdowns : [CountdownModel] = []
    @Published var groupProfileImage = ""
    @Published var activeUsers : [User] = []
    @Published var followers : [User] = []

    
    
    let notificationSender = PushNotificationSender()
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()!
            
            print("Fetched User!")
            return completion(User(dictionary: data))
        }
    }

    
    
    
    
    
    func addToGroupStory(groupID: String, post: UIImage, creator: String){
        let id = UUID().uuidString
        COLLECTION_GROUP.document(groupID).collection("Story").document(id).setData(["groupID":groupID,"creator":creator,"id":id,"dateCreated":Timestamp()])
        COLLECTION_GROUP.document(groupID).updateData(["storyPosts":FieldValue.arrayUnion([id])])
        self.persistImageToStorage(groupID: groupID, image: post, storyID: id)
        print("added to story")
    }
    
    func seeStory(groupID: String, storyID: String, userID: String){
        COLLECTION_GROUP.document(groupID).collection("Story").document(storyID).updateData(["usersSeenStory":FieldValue.arrayUnion([userID])])
    }
    
    
    func loadActiveUsers(group: Group){
        COLLECTION_GROUP.document(group.id).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let users = snapshot?.get("users") as? [String] ?? []
            
            self.activeUsers.removeAll()
            for user in users {
                
                self.fetchUser(userID: user) { fetchedUser in
                    self.activeUsers.append(fetchedUser)
                }
                
            }
            
            
            
        }
    }
    
    func changeMOTD(motd: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["motd":motd])
    }
    
    func changeBio(bio: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["bio":bio])
    }
    
    
    func getUsersProfilePictures(groupID: String){
        self.usersProfilePictures = []
        COLLECTION_GROUP.document(groupID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            let data = snapshot!.data()
            
            let users = data?["users"] as? [String] ?? []
            
            for user in users{
                COLLECTION_USER.document(user).getDocument { (snapshot, err) in
                    if err != nil{
                        print("ERROR")
                        return
                    }
                    self.usersProfilePictures.append(snapshot?.get("profilePicture")as? String ?? "")
                }
            }
            
        }
    }
    
    
    
//
//    func pickQuoteOfTheDay(chatID: String){
//        COLLECTION_CHAT.document(chatID).collection("Messages").getDocuments { (snapshot, err) in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//            for document in snapshot!.documents{
//                document.get("text")
//            }
//        }
//    }
    
   

    
    func getChat(chatID: String){
        COLLECTION_CHAT.document(chatID).getDocument { (snapshot, err) in
            if err != nil{
                print("ERROR")
                return
            }
            let data = snapshot!.data()
            self.groupChat = ChatModel(dictionary: data ?? [:])
        }
    }
    
    
    func joinGroup(group: Group, user: User){
        COLLECTION_GROUP.document(group.id).updateData(["users":FieldValue.arrayUnion([user.id])])
        COLLECTION_GROUP.document(group.id).updateData(["memberAmount":FieldValue.increment(Int64(1))])
            
             
           
                 
        self.chatRepository.joinChat(chatID: group.chat?.id ?? " ", userID: user.id ?? " ", groupID: group.id)

             var notificationID = UUID().uuidString
             
             let notificationData = ["id":notificationID,
                                     "notificationName": "User Added",
                                     "notificationTime":Timestamp(),
                                     "notificationType":"userAdded", "notificationCreatorID":user.id,
                                     "usersThatHaveSeen":[]] as [String:Any]
        
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(notificationData)
             
        COLLECTION_GROUP.document(group.id).updateData(["notificationCount":FieldValue.increment((Int64(1)))])
        
        for user in group.realUsers ?? [] {
            notificationSender.sendPushNotification(to: user.fcmToken ?? " ", title: "\(group.groupName)", body: "\(user.nickName ?? " ") has joined \(group.groupName)")
        }
        
      
             
    }
    

    
 
    
    func leaveGroup(group: Group, user: User){
        COLLECTION_GROUP.document(group.id).updateData(["memberAmount": FieldValue.increment(Int64(-1))])
        COLLECTION_GROUP.document(group.id).updateData(["users":FieldValue.arrayRemove([user.id ?? " "])])
        
        COLLECTION_GROUP.document(group.id).getDocument { (snapshot, err) in
            if err != nil{
                print("ERROR")
                return
            }
            let groupChatID = snapshot?.get("chatID") as? String ?? " "
            COLLECTION_USER.document(user.id ?? " ").updateData(["groups":FieldValue.arrayRemove([groupChatID])])

            self.chatRepository.leaveChat(chatID: groupChatID, userID: user.id ?? " ", groupID: group.id)
            
            let users = snapshot?.get("users") as? [String] ?? []
            
            if users.count <= 0{

                
                COLLECTION_GROUP.document(group.id).delete() { err in
                    
                    if err != nil {
                        print("Unable to delete document")
                    }else{
                        print("sucessfully deleted document")
                    }
                    
                }
            }
            var notificationID = UUID().uuidString
            
            let notificationData = ["id":notificationID,
                                    "notificationName": "User Left",
                                    "notificationTime":Timestamp(),
                                    "notificationType":"userLeft", "notificationCreator9ID":user.id,
                                    "usersThatHaveSeen":[]] as [String:Any]
            COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(notificationData)
            
            COLLECTION_GROUP.document(group.id).updateData(["notificationCount":FieldValue.increment((Int64(1)))])
           
            for user in group.realUsers ?? []{
                self.notificationSender.sendPushNotification(to: user.fcmToken ?? " ", title: "\(group.groupName)", body: "\(user.nickName ?? " ") has left \(group.groupName)")
            }
            
        }
        

        

    }
    
    func createGroup(groupName: String, memberLimit: Int, dateCreated: Date, users: [String], image: UIImage, currentUser: String, id: String, password: String){
        
        
    
        
        let chatID = UUID().uuidString

        let data = ["groupName" : groupName,
                    "memberLimit" : memberLimit,
                    "users" : users ,
                    "memberAmount": 1, "id":id, "chatID": chatID, "dateCreated":Timestamp(), "groupProfileImage": " ","password":password
        ] as [String:Any]
                
        COLLECTION_GROUP.document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            self.persistImageToStorage(groupID: id,image: image)
        }
        COLLECTION_USER.document(currentUser).updateData(["groups":FieldValue.arrayUnion([id])])
    

        chatRepository.createGroupChat(name: groupName, users: users, groupID: id, chatID: chatID)
        
        
        
    }
    
    func createGroup(currentUser: String, groupName: String, memberLimit: Int, dateCreated: Date, users: [String], image: UIImage, completion: @escaping (ChatModel) -> ()) -> (){
        
        
        let id = UUID().uuidString
        let chatID = UUID().uuidString
        
       

        let data = ["groupName" : groupName,
                    "memberLimit" : memberLimit,
                    "users" : users ,
                    "memberAmount": 1, "id":id, "chatID": chatID, "dateCreated":Timestamp(), "groupProfileImage": " "
        ] as [String:Any]
                
        COLLECTION_GROUP.document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            self.persistImageToStorage(groupID: id,image: image)
        }
        COLLECTION_USER.document(currentUser).updateData(["groups":FieldValue.arrayUnion([id])])
        COLLECTION_USER.document(currentUser).updateData(["allGroupsToListenTo":FieldValue.arrayUnion([id])])

        chatRepository.createGroupChat(name: groupName, users: users, groupID: id, chatID: chatID ,completion: { chat in
            return completion(chat)
        })

        
        
    }
    
    
    
    
    func persistImageToStorage(groupID: String, image: UIImage) {
       let fileName = "groupImages/\(groupID)"
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
                COLLECTION_GROUP.document(groupID).updateData(["groupProfileImage":imageURL])
            }
        }
      
    }
    
    func persistImageToStorage(groupID: String, image: UIImage, storyID: String) {
       let fileName = "groupStories/\(groupID)"
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
                   COLLECTION_GROUP.document(groupID).collection("Story").document(storyID).updateData(["image":imageURL])
            }
        }
      
    }
    
    
    
    func isInGroup(user1: User, group: Group, completion: @escaping (Bool) -> () ) -> (){
        COLLECTION_GROUP.document(group.id).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            let users = snapshot?.get("users") as? [String] ?? []
            for user in users {
                return completion(user == user1.id)
            }
        }
    }
    
    func createCountdown(group: Group, countdownName: String, startDate: Timestamp, endDate: Date, user: User){

        
        COLLECTION_GROUP.document(group.id).collection("Countdowns").addDocument(data: ["id":UUID().uuidString,"countdownName":countdownName,"dateCreated":startDate, "endDate":endDate])
        
        
        let notificationID = UUID().uuidString
        
        let notificationData = ["id":notificationID,
                                "notificationName": "Countdown Created",
                                "notificationTime":Timestamp(),
                                "notificationType":"countdownCreated", "notificationCreatorID":user.id ?? "USER_ID",
                                "usersThatHaveSeen":[]] as [String:Any]
        
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(notificationData)
        
        COLLECTION_GROUP.document(group.id).updateData(["notificationCount":FieldValue.increment((Int64(1)))])
   
    }
    
    func giveBadge(group: Group, badge: Badge){
        COLLECTION_GROUP.document(group.id).collection("Badges").addDocument(data: ["id":badge.id,"badgeName":badge.badgeName,"badgeDescription":badge.badgeDescription,"badgeImage":badge.badgeImage])
    }
    
    func loadGroupFollowers(groupID: String){
        self.followers.removeAll()

        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let users = snapshot!.get("followers") as? [String] ?? []
            
            
            for user in users {
                self.fetchUser(userID: user) { fetchedUser in
                    self.followers.append(fetchedUser)
                }
            }
            
        }
    }
    
   
}

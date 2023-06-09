//
//  CreateGroupViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

import Firebase
import Combine



class GroupViewModel: ObservableObject {
    
    
    var userVM: UserViewModel?
    @ObservedObject var chatRepository = ChatRepository()
    @ObservedObject var chatVM = ChatViewModel()
    @Published var groupChat : ChatModel = ChatModel()
    @Published var usersProfilePictures : [String] = []
    @Published var groupProfileImage = ""
    @Published var activeUsers : [User] = []
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
    
   
    func sendGroupInvitation(group: Group, friend: User, userID: String){
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["pendingGroupInvitationID":FieldValue.arrayUnion([group.id])])
        
      
        let notificationID = UUID().uuidString
        
        let userNotificationData = ["id":notificationID,
            "name": "Group Invitation",
            "timeStamp":Timestamp(),
            "type":"sentGroupInvitation",
            "userID":userID,
            "hasSeen":false,
            "groupID":group.id] as [String:Any]
        
        COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
        COLLECTION_USER.document(friend.id ?? " ").updateData(["userNotificationCount":FieldValue.increment((Int64(1)))])
    }
    
    func acceptGroupInvitation(group: Group, user: User){
        
        let dp = DispatchGroup()
        dp.enter()
        COLLECTION_USER.document(user.id ?? " ").updateData(["pendingGroupInvitationID":FieldValue.arrayRemove([group.id])])
        
        joinGroup(group: group, user: user)
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "name": "acceptedGroupInvitation",
            "timeStamp":Timestamp(),
            "type":"acceptedGroupInvitation",
            "userID":user.id ?? "USER_ID",
            "hasSeen":false,
            "groupID":group.id] as [String:Any]
        
        dp.leave()
        dp.notify(queue: .main, execute: {
            for id in group.users{
                COLLECTION_USER.document(id).collection("Notifications").document(notificationID).setData(userNotificationData)
                COLLECTION_USER.document(id).updateData(["userNotificationCount":FieldValue.increment((Int64(1)))])
            }
        })
      
        

        
        
    }
    
    func denyGroupInvitation(group: Group, user: User){
        COLLECTION_USER.document(user.id ?? " ").updateData(["pendingGroupInvitationID":FieldValue.arrayRemove([group.id])])
        
        joinGroup(group: group, user: user)
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "name": "denyGroupInvitation",
            "timeStamp":Timestamp(),
            "type":"denyGroupInvitation",
            "userID":user.id ?? "USER_ID",
            "hasSeen":false,
            "groupID":group.id] as [String:Any]
        
        
        COLLECTION_USER.document(user.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
        COLLECTION_USER.document(user.id ?? " ").updateData(["userNotificationCount":FieldValue.increment((Int64(1)))])
        
        
    }
    
   
    
    func joinGroup(group: Group, user: User){
        COLLECTION_GROUP.document(group.id).updateData(["users":FieldValue.arrayUnion([user.id])])
        COLLECTION_GROUP.document(group.id).updateData(["memberAmount":FieldValue.increment(Int64(1))])
        COLLECTION_USER.document(user.id ?? "").updateData(["groupsID":FieldValue.arrayUnion([group.id])])
             
           
                 
        self.chatRepository.joinChat(chatID: group.chatID ?? " " , userID: user.id ?? " ", groupID: group.id)

             var notificationID = UUID().uuidString
             
             let notificationData = ["id":notificationID,
                                     "name": "User Added",
                                     "timeStamp":Timestamp(),
                                     "type":"userAdded", "userID":user.id,
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

        COLLECTION_USER.document(user.id ?? "").updateData(["groupsID":FieldValue.arrayRemove([group.id])])
        
        COLLECTION_GROUP.document(group.id).getDocument { (snapshot, err) in
            if err != nil{
                print("ERROR")
                return
            }
            let groupChatID = snapshot?.get("chatID") as? String ?? " "
            

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
    
    
    func createGroup(groupName: String, dateCreated: Date, users: [String], image: UIImage, id: String){
        
        
        for user in users{
            COLLECTION_USER.document(user).updateData(["groupsID":FieldValue.arrayUnion([id])])
        }
        
        let chatID = UUID().uuidString

        let data = ["groupName" : groupName,
                    "users" : users ,
                    "memberAmount": users.count, "id":id, "chatID": chatID, "dateCreated":Timestamp(), "groupProfileImage": " "
        ] as [String:Any]
                
        COLLECTION_GROUP.document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            self.persistImageToStorage(groupID: id,image: image, completion: { fetchedImageString in
                self.chatRepository.createGroupChat(name: groupName, users: users, groupID: id, chatID: chatID, profileImage: fetchedImageString)
            })
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
    
    func changeBio(bio: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["bio":bio])
    }
    
    
    
 
    
    func persistImageToStorage(groupID: String, image: UIImage, completion: @escaping (String) -> ()) -> (){
       let fileName = "groupImages/\(groupID)"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
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
                return completion(imageURL)
            }
        }
      
    }

    
    
    
  

    
}







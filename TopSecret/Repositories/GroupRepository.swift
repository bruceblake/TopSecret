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
    @ObservedObject var notificationRepository = NotificationRepository()
    @Published var groupChat : ChatModel = ChatModel()
    @Published var usersProfilePictures : [String] = []
    @Published var countdowns : [CountdownModel] = []
    @Published var groupProfileImage = ""
    @Published var activeUsers : [User] = []
    @Published var followers : [User] = []

    
    
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
    
    
    func loadGroupCountdowns(group: Group){
        COLLECTION_GROUP.document(group.id).collection("Countdowns").getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            self.countdowns = documents.map({ (queryDocumentSnapshot) -> CountdownModel in
                let data = queryDocumentSnapshot.data()
                
                return CountdownModel(dictionary: data)
            })
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
    
    func inviteToGroup(user1: User, user2: User, group: Group){
        notificationRepository.sendInvitedToGroupNotification(user1: user1, user2: user2, group: group, users: group.users ?? [])
    }
    
    func joinGroup(groupID: String, username: String){
        
        
        let userQuery = COLLECTION_USER.whereField("username", isEqualTo: username)
          
        userQuery.getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            if snapshot!.documents.isEmpty {
                print("There are no usernames with this text!")
            }else{
                for document in snapshot!.documents{
                    print("Username: \(document.get("username") as? String ?? "")")
                }
            }
            
            for document in snapshot!.documents{
                let data = document.data()
                let id = data["uid"] as? String ?? ""
                COLLECTION_GROUP.document(groupID).updateData(["users":FieldValue.arrayUnion([id])])
                COLLECTION_GROUP.document(groupID).updateData(["memberAmount":FieldValue.increment(Int64(1))])
                COLLECTION_USER.document(id).updateData(["groups":FieldValue.arrayUnion([groupID])])
                
                COLLECTION_GROUP.document(groupID).getDocument { (snapshot, err) in
                    
                    let data = snapshot?.data()
                    let chatID = data?["chatID"] as? String ?? ""
                    let users = data?["users"] as? [String] ?? []
                    
                    self.chatRepository.joinChat(chatID: chatID, userID: id)
                    COLLECTION_USER.document(id).updateData(["allGroupsToListenTo":FieldValue.arrayUnion([groupID])])
                    self.notificationRepository.sendAcceptedGroupInviteNotification(group: Group(dictionary: data ?? [:]), user1: User(dictionary: data ?? [:]), users: users)
                }
                
               
                
            }
        }
            
       

       
    }
    
    func leaveGroup(groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["memberAmount": FieldValue.increment(Int64(-1))])
        COLLECTION_GROUP.document(groupID).updateData(["users":FieldValue.arrayRemove([userID])])
        
        COLLECTION_GROUP.document(groupID).getDocument { (snapshot, err) in
            if err != nil{
                print("ERROR")
                return
            }
            let groupChatID = snapshot?.get("chatID") as? String ?? " "
            COLLECTION_USER.document(userID).updateData(["groups":FieldValue.arrayRemove([groupChatID])])

            self.chatRepository.leaveChat(chatID: groupChatID, userID: userID)
            
            let users = snapshot?.get("users") as? [String] ?? []
            
            if users.count <= 0{

                
                COLLECTION_GROUP.document(groupID).collection("Polls").getDocuments { (snapshot, err) in
                    for document in snapshot!.documents{
                        let pollID = document.get("id") as! String
                        COLLECTION_GROUP.document(groupID).collection("Polls").document(pollID).delete()
                    }
                }
                COLLECTION_GROUP.document(groupID).delete() { err in
                    
                    if err != nil {
                        print("Unable to delete document")
                    }else{
                        print("sucessfully deleted document")
                    }
                    
                }
            }
        }
        

        

    }
    
    func createGroup(groupName: String, memberLimit: Int, dateCreated: Date, users: [String], image: UIImage, currentUser: String, id: String, password: String){
        
        
    
        
       

        let data = ["groupName" : groupName,
                    "memberLimit" : memberLimit,
                    "users" : users ,
                    "memberAmount": 1, "id":id, "chatID": " ", "dateCreated":Timestamp(), "groupProfileImage": " ","password":password
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

        chatRepository.createGroupChat(name: groupName, users: users, groupID: id)
        
        
        
    }
    
    func createGroup(currentUser: String, groupName: String, memberLimit: Int, dateCreated: Date, users: [String], image: UIImage, completion: @escaping (ChatModel) -> ()) -> (){
        
        
        let id = UUID().uuidString
        
       

        let data = ["groupName" : groupName,
                    "memberLimit" : memberLimit,
                    "users" : users ,
                    "memberAmount": 1, "id":id, "chatID": " ", "dateCreated":Timestamp(), "groupProfileImage": " "
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

        chatRepository.createGroupChat(name: groupName, users: users, groupID: id,completion: { chat in
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
    
    func createCountdown(group: Group, countdownName: String, startDate: Timestamp, endDate: Date){

        
        COLLECTION_GROUP.document(group.id).collection("Countdowns").addDocument(data: ["id":UUID().uuidString,"countdownName":countdownName,"dateCreated":startDate, "endDate":endDate])
    }
    
    func giveBadge(group: Group, badge: Badge){
        COLLECTION_GROUP.document(group.id).collection("Badges").addDocument(data: ["id":badge.id,"badgeName":badge.badgeName,"badgeDescription":badge.badgeDescription,"badgeImage":badge.badgeImage])
        print("gave \(badge.badgeName ?? "") badge to \(group.groupName)")
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
    
   
//    func loadGroupProfileImage(groupID: String){
//        COLLECTION_GROUP.document(groupID).getDocument { (snapshot, err) in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//            let image = snapshot?.get("groupProfileImage") as! String
//        }
//    }
}

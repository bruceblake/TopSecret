//
//  SelectedGroupViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import Foundation
import SwiftUI
import Firebase

class SelectedGroupViewModel : ObservableObject {
    
    @Published var group: Group = Group()
    @Published var finishedFetchingGroupEvents : Bool = false
    @Published var finishedFetchingGroup : Bool = false
    @Published var listeners : [ListenerRegistration] = []
    @Published var groupFeed : [Any] = []
    
   
    
    
    func fetchGroupFeed(groupID: String, events: [EventModel], polls: [PollModel]){
        self.groupFeed = (events + polls)
    }
    
    func readGroupNotifications(groupID: String, userID: String, notification: GroupNotificationModel){
        
        COLLECTION_GROUP.document(groupID).collection("Notifications").document(notification.id).updateData(["usersThatHaveSeen":FieldValue.arrayUnion([userID])])
        
    
    }
    
    
    func changeMOTD(groupID: String, motd: String){
        COLLECTION_GROUP.document(groupID).updateData(["motd":motd])
    }
    

    
    
    func listenToGroup(userID: String, groupID: String, completion: @escaping (Bool) -> ()) -> (){
        let listener = COLLECTION_GROUP.document(groupID).addSnapshotListener { snapshot, err in
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            let groupD = DispatchGroup()
          
                
            groupD.enter()
            self.fetchGroupEvents(groupID: groupID) { fetchedEvents in
                data["events"] = fetchedEvents
                groupD.leave()
                self.finishedFetchingGroupEvents = true
            }
            
            groupD.enter()
            self.fetchGroupNotifications(groupID: groupID) { fetchedNotifications in
                data["groupNotifications"] = fetchedNotifications
                groupD.leave()
            }
            
            
            groupD.enter()
            
            self.fetchGroupUnreadNotifications(userID: userID, groupID: groupID) { fetchedNotifications in
                data["unreadGroupNotifications"] = fetchedNotifications
                groupD.leave()
            }


            groupD.enter()
            self.fetchGroupChat(groupID: groupID) { fetchedChat in
                data["chat"] = fetchedChat
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroupStories(groupID: groupID) { fetchedStories in
                data["storyPosts"] = fetchedStories
                groupD.leave()
            }
            
            groupD.enter()
                self.fetchGroupUsers(usersID: data["users"] as? [String] ?? [] ,groupID: groupID) { fetchedUsers in
                    data["realUsers"] = fetchedUsers
                    groupD.leave()
                }
           
       
            groupD.enter()
            self.fetchGroupPolls(groupID: groupID) { fetchedPolls in
                data["polls"] = fetchedPolls
                groupD.leave()
            }
            
//            self.fetchGroupPosts(groupID: groupID)
//

                

                

            

           
            
            groupD.notify(queue: .main, execute: {
                self.finishedFetchingGroup = true
                self.group = Group(dictionary: data )
                
                self.fetchGroupFeed(groupID: groupID, events: self.group.events, polls: self.group.polls)
                return completion(true)
            })
            
          
        }
    }
    
//    func fetchGroupPosts(groupID: String) {
//
//
//        COLLECTION_GROUP.document(groupID).collection("Posts").getDocuments { snapshot, err in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//
//                    var groupD = DispatchGroup()
//
//            guard let documents = snapshot?.documents else {return}
//
//            var paths = [String]()
//
//            for doc in documents {
//                groupD.enter()
//                let data = doc.data()
//                var path = data["urlPath"] as? String ?? ""
//                var id = data["id"] as? String ?? ""
//                var timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
//                var description = data["description"] as? String ?? ""
//                var creatorID = data["creatorID"] as? String ?? ""
//                let storageRef = Storage.storage().reference()
//                let fileRef = storageRef.child(path)
//
//                fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
//
//                    if err != nil {
//                        print("ERROR: \(err!.localizedDescription)")
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        guard let image = UIImage(data: data!) else {return}
//
//
//                                let postImageData = ["id":id, "urlPath":path,"image":image,"creatorID":creatorID,"timeStamp":timeStamp,"description":"test"] as [String:Any]
//                        groupD.leave()
//                        groupD.notify(queue: .main, execute:{
//                                                self.posts.append(GroupPostModel(dictionary: postImageData))
//
//                        })
//                    }
//
//
//
//
//
//
//
//                }
//
//            }
//
//
//
//
//        }
//
//    }
    
    func fetchGroupUsers(usersID: [String], groupID: String, completion: @escaping ([User]) -> ()) -> () {
        var users : [User] = []
        
        var groupD = DispatchGroup()
        
        
        
        for userID in usersID {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                users.append(User(dictionary: data))
                groupD.leave()
                
            }
        }
        
        groupD.notify(queue: .main, execute: {
            return completion(users)
        })
        
        
    }
    
    
    func fetchGroupStories(groupID: String, completion: @escaping ([StoryModel]) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Stories").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            
            return completion(documents.map({ queryDocumentSnapshot -> StoryModel in
                let data = queryDocumentSnapshot.data()
                
                return StoryModel(dictionary: data)
            }))
            
            
           
            
        }
    }
    
    
    func fetchGroupChat(groupID: String, completion: @escaping (ChatModel) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Chat").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            for document in documents {
                let data =  document.data() as? [String:Any]
                
                return completion(ChatModel(dictionary: data ?? [:]))
            }
            
           
            
        }
    }
    
    func fetchGroupNotificationCreator(notificationCreatorID: String, completion: @escaping (User) -> ()) -> (){
        
        COLLECTION_USER.document(notificationCreatorID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
            
        }
        
    }
    
    
   
    
    func fetchGroupNotifications(groupID: String, completion: @escaping ([GroupNotificationModel]) -> ()) -> () {
        
        
        var notificationsToReturn : [GroupNotificationModel] = []
        COLLECTION_GROUP.document(groupID).collection("Notifications").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                
                
                groupD.enter()
                
                self.fetchGroupNotificationCreator(notificationCreatorID: data["notificationCreatorID"] as? String ?? " ") { fetchedUser in
                    data["notificationCreator"] = fetchedUser
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    notificationsToReturn.append(GroupNotificationModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(notificationsToReturn)
            })
            
            
          
            
        }
    }
    
    func fetchGroupUnreadNotifications(userID: String, groupID: String, completion: @escaping ([GroupNotificationModel]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("Notifications").getDocuments { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents.filter({ (($0.get("usersThatHaveSeen") as? [String] ?? []).contains(userID) == false)})
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> GroupNotificationModel in
                let data = queryDocumentSnapshot.data()
                
                return GroupNotificationModel(dictionary: data)
            }))
            
        }
    }
    
   

    
    
    func fetchGroupCountdown(groupID: String,completion: @escaping ([CountdownModel]) -> () ) -> (){
        COLLECTION_GROUP.document(groupID).collection("Countdowns").getDocuments { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> CountdownModel in
                let data = queryDocumentSnapshot.data()
                
                return CountdownModel(dictionary: data)
            }))
            
        }
    }
    
    func fetchEventUsersAttending(usersAttendingID: [String], eventID: String , groupID: String, completion: @escaping ([User]) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).getDocument { snapshot, err in
            
            if err != nil {
                print("ERROR")
                return
            }
            var usersToReturn : [User] = []
            
            
            let groupD = DispatchGroup()
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            let users = data["usersAttendingID"] as? [String] ?? []
            
            for user in users {
                groupD.enter()
                COLLECTION_USER.document(user).getDocument { userSnapshot, err in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    let userData = userSnapshot?.data() as? [String:Any] ?? [:]
                    
                    usersToReturn.append(User(dictionary: userData))
                    groupD.leave()
                }
            }
            
            groupD.notify(queue: .main, execute: {
                return completion(usersToReturn)
            })
            
        }
        
        
    }
    
    
    func fetchGroupEvents(groupID: String,completion: @escaping ([EventModel]) -> () ) -> (){
        
        var eventsToReturn : [EventModel] = []
        COLLECTION_GROUP.document(groupID).collection("Events").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                var id = data["id"] as? String ?? " "
                var usersAttendingID = data["usersAttendingID"] as? [String] ?? []
                var creatorID = data["creatorID"] as? String ?? " "
                groupD.enter()
                
                self.fetchEventUsersAttending(usersAttendingID: usersAttendingID, eventID: id, groupID: groupID) { fetchedUsers in
                    data["usersAttending"] = fetchedUsers
                
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUser (userID: creatorID){ fetchedUser in
                    data["creator"] = fetchedUser
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    eventsToReturn.append(EventModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(eventsToReturn)
            })
            
            
          
            
        }
    }
    
    func fetchGroupPolls(groupID: String,completion: @escaping ([PollModel]) -> () ) -> (){
        
        var pollsToReturn : [PollModel] = []
        COLLECTION_GROUP.document(groupID).collection("Polls").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                
                groupD.enter()
                self.fetchPollOptions(pollID: data["id"] as? String ?? " ", groupID: groupID) { fetchedChoices in
                    data["pollOptions"] = fetchedChoices
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUser(userID: data["creatorID"] as? String ?? " ") { fetchedUser in
                    data["creator"] = fetchedUser
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUsersAnswered(usersID: data["usersAnsweredID"] as? [String] ?? []){ fetchedUsers in
                    data["usersAnswered"] = fetchedUsers
                    
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    pollsToReturn.append(PollModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(pollsToReturn)
            })
            
            
          
            
        }
    }
    
    func fetchUsersAnswered(usersID: [String], completion: @escaping ([User]) -> ()) -> () {
        var usersToReturn : [User] = []
        let groupD = DispatchGroup()
        groupD.enter()
        for userID in usersID{
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                
                usersToReturn.append(User(dictionary: data))
                
            }
        }
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
        }
    }
    
    func fetchPollOptions(pollID: String, groupID: String, completion: @escaping ([PollOptionModel]) -> () ) -> () {
        var choicesToReturn : [PollOptionModel] = []

        COLLECTION_GROUP.document(groupID).collection("Polls").document(pollID).collection("Options").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                
              
                
                    choicesToReturn.append(PollOptionModel(dictionary: data))
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(choicesToReturn)
            })
            
            
        }
    }
    
}

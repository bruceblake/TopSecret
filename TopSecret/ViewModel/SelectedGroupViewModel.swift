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
    @Published var events: [EventModel] = []
    @Published var polls: [PollModel] = []
    @Published var posts: [GroupPostModel] = []
    @Published var notifications : [GroupNotificationModel] = []
    @Published var groupChat : ChatModel = ChatModel()
    @Published var groupListener : ListenerRegistration?
   
    
    
    
    func readGroupNotifications(groupID: String, userID: String, notification: GroupNotificationModel){
        
        COLLECTION_GROUP.document(groupID).collection("Notifications").document(notification.id).updateData(["usersThatHaveSeen":FieldValue.arrayUnion([userID])])
        
    
    }
    
    
    func changeMOTD(groupID: String, motd: String){
        COLLECTION_GROUP.document(groupID).updateData(["motd":motd])
    }
    
    
    func fetchGroup(groupID: String, completion: @escaping (Group) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(Group(dictionary: data))
        }
    }
    
    func fetchMedia(urlPath: String, completion: @escaping (UIImage) -> ()) -> (){
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(urlPath)
        
        DispatchQueue.global(qos: .userInteractive).async{
            fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
                if err != nil {
                    print("ERROR")
                }
                
                if let image = UIImage(data: data ?? Data())  {
                        return completion(image)
                }
            }
        }
      
        
    }

    func listenToGroupPosts(){
        listeners.append(
        COLLECTION_GROUP.document(group.id).collection("Posts").addSnapshotListener({ snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var postsToReturn : [GroupPostModel] = []
            
            let groupD = DispatchGroup()
            
            
            let documents = snapshot!.documents
            
            groupD.enter()
            for document in documents{
                var data = document.data() as? [String:Any] ?? [:]
                var creatorID = data["creatorID"] as? String ?? " "
                var groupID = data["groupID"] as? String ?? " "
                var urlPath = data["urlPath"] as? String ?? ""
                data["group"] = self.group
                groupD.enter()
                self.fetchUser(userID: creatorID) { fetchedUser in
                    data["creator"] = fetchedUser
                    groupD.leave()
                }
                
              
                
                groupD.enter()
                self.fetchMedia(urlPath: urlPath) { fetchedImage in
                    data["image"] = fetchedImage
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute:{
                    postsToReturn.append(GroupPostModel(dictionary: data))
                })
           
            }
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                self.posts = postsToReturn
            })
        })
    
    )
    }
    
    
    func listenToGroupEvents(){
        var eventsToReturn : [EventModel] = []
        
        self.listeners.append(
            COLLECTION_GROUP.document(group.id).collection("Events").addSnapshotListener({ snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let documents = snapshot!.documents
                
                let groupD = DispatchGroup()
                
                groupD.enter()
           
                for document in documents {
                    var data = document.data()
                    var groupID = data["groupID"] as? String ?? ""
                    var creatorID = data["creatorID"] as? String ?? " "
                    var urlPath = data["urlPath"] as? String ?? ""
                    data["group"] = self.group

                    groupD.enter()
                    self.fetchUser(userID: creatorID) { fetchedUser in
                        data["creator"] = fetchedUser
                        groupD.leave()
                    }
                    
                  
                    
                    groupD.enter()
                    self.fetchMedia(urlPath: urlPath) { fetchedImage in
                        data["image"] = fetchedImage
                        groupD.leave()
                    }
                   
                    
                    groupD.notify(queue: .main, execute: {
                        eventsToReturn.append(EventModel(dictionary: data))
                    })
                }
                
                groupD.leave()
                
                groupD.notify(queue: .main, execute: {
                    self.events = eventsToReturn
                })
            })
        )
    }
    
    func fetchPollOptions(pollID: String, groupID: String, completion: @escaping ([PollOptionModel]) -> () ) -> () {
        var choicesToReturn : [PollOptionModel] = []

        COLLECTION_POLLS.document(pollID).collection("Options").getDocuments { snapshot, err in
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
    
    
    
    func listenToGroupPolls(){
        var pollsToReturn : [PollModel] = []

        self.listeners.append( COLLECTION_GROUP.document(group.id).collection("Polls").addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()
            
            groupD.enter()
       
            for document in documents {
                var data = document.data()
                var groupID = data["groupID"] as? String ?? ""
                groupD.enter()
                data["group"] = self.group

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
                self.polls = pollsToReturn
            })
            
        })
    }
    
    
    func changeCurrentGroup(groupID: String, completion: @escaping (Bool) ->()) -> (){
        self.groupListener = nil
        self.listenToGroup(groupID: groupID) { fetchedGroup in
            self.finishedFetchingGroup = fetchedGroup
            return completion(true)
        }
    }
    
    func listenToGroup(groupID: String, completion: @escaping (Bool) -> ()) -> (){
        let dp = DispatchGroup()
        dp.enter()
        self.groupListener = COLLECTION_GROUP.document(groupID).addSnapshotListener { snapshot, err in
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            let groupD = DispatchGroup()
          

            groupD.enter()
                self.fetchGroupUsers(usersID: data["users"] as? [String] ?? [] ,groupID: groupID) { fetchedUsers in
                    data["realUsers"] = fetchedUsers
                    groupD.leave()
                }
           

            
            groupD.notify(queue: .main, execute: {
                self.finishedFetchingGroup = true
                self.group = Group(dictionary: data )
            })
            
          
        }
        dp.leave()
        dp.notify(queue: .main, execute:{
        return completion(true)
        })

    }

    
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
    
    
    func listenToGroupChat(groupID: String, completion: @escaping (ChatModel) -> ()) -> (){
        self.listeners.append(COLLECTION_GROUP.document(groupID).collection("Chat").document(group.chatID ?? " ").addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
        
            let data =  snapshot?.data() as? [String:Any] ?? [:]
                
              
            self.groupChat = ChatModel(dictionary: data)
           
            
        })
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
    
  
    
}

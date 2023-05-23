//
//  FeedViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/11/22.
//

import Foundation
import Firebase
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var posts: [GroupPostModel] = []
    @Published var polls: [PollModel] = []
    @Published var events: [EventModel] = []
    @Published var feed: [FeedItemObjectModel]?
    @Published var stories: [StoryModel] = []
    @Published var isLoading : Bool = false
    @Published var hasFetched: Bool = false
    @Published var firestoreListener : [ListenerRegistration] = []
    
    init(){
        self.fetchAll(userID: UserViewModel.shared.user?.id ?? " ")
    }
 
    func feedIsEmpty() -> Bool{
        feed?.isEmpty ?? false
    }
    
    func parseIntoFeedObject(feedItem: Any) -> FeedItemObjectModel? {
        if let event = feedItem as? EventModel  {
            let data = ["id": event.id,
                        "timeStamp": event.timeStamp ?? Timestamp(),
                        "event": event,
                        "itemType":FeedItemObjectModel.ItemType.event,
                        "groupID":event.groupID ?? ""] as [String: Any]
            return FeedItemObjectModel(dictionary: data)
        } else if let poll = feedItem as? PollModel  {
            let data = ["id": poll.id ?? "",
                        "timeStamp": poll.timeStamp ?? Timestamp(),
                        "poll": poll,
                        "itemType":FeedItemObjectModel.ItemType.poll,
                        "groupID":poll.groupID ?? ""] as [String: Any]
            return FeedItemObjectModel(dictionary: data)
        } else if let groupPost = feedItem as? GroupPostModel  {
            let data = ["id": groupPost.id ?? "",
                        "timeStamp": groupPost.timeStamp ?? Timestamp(),
                        "post": groupPost,
                        "itemType":FeedItemObjectModel.ItemType.post,
                        "groupID":groupPost.groupID ?? ""] as [String: Any]
            return FeedItemObjectModel(dictionary: data)
        } else {
            // Return nil if feedItem is not of any of the expected types
            return nil
        }
    }
    
    
    func fetchAll(userID: String){
        DispatchQueue.main.async{
            self.isLoading = true
        }
        let dp = DispatchGroup()
        dp.enter()
        self.fetchGroupPosts(completion: { fetchedPosts in
            self.posts = fetchedPosts
            dp.leave()
        })
        dp.enter()
        self.fetchGroupPolls(completion: { fetchedPolls in
            self.polls = fetchedPolls
            dp.leave()
        })
        dp.enter()
        self.fetchGroupEvents(completion: { fetchedEvents in
            self.events = fetchedEvents
            dp.leave()
        })
        
//        dp.enter()
//        func fetchStories(userID: String, completion: { fetchedStories in
//            self.stories = fetchedStories
//            dp.leave()
//        })
       
        
        dp.notify(queue: .main, execute: {
            var sortedFeed: [FeedItemObjectModel] {
            
                let feed : [Any] = (self.posts + self.polls + self.events)
                var arrayToReturn : [FeedItemObjectModel] = []
                for item in feed{
                    arrayToReturn.append(self.parseIntoFeedObject(feedItem: item) ?? FeedItemObjectModel())
                }
          
                
                return arrayToReturn.sorted {($0.timeStamp?.dateValue() ?? Date()) > ($1.timeStamp?.dateValue() ?? Date())}
            }
            
            self.feed = sortedFeed.uniqued()
            self.isLoading = false
            self.hasFetched = true
        })
        
    
    }
    
   
    
    func removeListeners(){
        for listener in self.firestoreListener{
            listener.remove()
        }
    }
    
    func fetchStories(userID: String, completion: @escaping ([StoryModel]) -> ()) -> () {
       
    }
    
    func fetchMedia(urlPath: String, completion: @escaping (UIImage) -> ()) -> (){
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(urlPath)
        
        DispatchQueue.global(qos: .background).async{
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
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            
            
                return completion(User(dictionary: data))
            
            
        }
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
    
    func fetchTopGroupPostComment(postID: String, completion: @escaping (GroupPostCommentModel) -> ()) -> (){
        COLLECTION_POSTS.document(postID).collection("Comments").getDocuments { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
        }
    }
    
    func fetchGroupPosts(completion: @escaping ([GroupPostModel]) -> ()) -> (){
            
                
        COLLECTION_POSTS.getDocuments(completion: { snapshot, err in
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
                        groupD.enter()
                        self.fetchUser(userID: creatorID) { fetchedUser in
                            data["creator"] = fetchedUser
                            groupD.leave()
                        }
                        
                        groupD.enter()
                        self.fetchGroup(groupID: groupID) { fetchedGroup in
                            data["group"] = fetchedGroup
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
                        return completion(postsToReturn)
                    })
                })
            
            
        
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
    
    
    func fetchGroupEvents(completion: @escaping ([EventModel]) -> ()) -> (){
        var eventsToReturn : [EventModel] = []
        
        COLLECTION_EVENTS.getDocuments(completion: { snapshot, err in
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

                    groupD.enter()
                    self.fetchUser(userID: creatorID) { fetchedUser in
                        data["creator"] = fetchedUser
                        groupD.leave()
                    }
                    
                    groupD.enter()
                    self.fetchGroup(groupID: groupID) { fetchedGroup in
                        data["group"] = fetchedGroup
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
                    return completion(eventsToReturn)
                })
            })
        
    }
    
    
    func fetchGroupPolls(completion: @escaping ([PollModel]) -> ()) -> (){
        var pollsToReturn : [PollModel] = []

     COLLECTION_POLLS.getDocuments { snapshot, err in
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
                self.fetchGroup(groupID: groupID) { fetchedGroup in
                    data["group"] = fetchedGroup
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
    
}

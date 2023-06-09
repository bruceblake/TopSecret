//
//  EventsTabViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/20/23.
//

import Foundation
import Firebase

class EventsTabViewModel: ObservableObject {
    @Published var openToFriendsEvents: [EventModel] = []
    @Published var inviteOnlyEvents: [EventModel] = []
    @Published var isLoadingOpenToFriends: Bool = false
    @Published var isLoadingInviteOnlyEvents: Bool = false
    @Published var radius: Int = 1
    
    func fetchUserEvents(eventsID: [String], completion: @escaping ([EventModel]) -> ()) -> (){
        let dp = DispatchGroup()
        var eventsToReturn : [EventModel] = []
        for id in eventsID{
            dp.enter()
            COLLECTION_EVENTS.document(id).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                var data = snapshot?.data() as? [String:Any] ?? [:]

                eventsToReturn.append(EventModel(dictionary: data))
                dp.leave()

            }
            
        }
        
        dp.notify(queue: .main, execute: {
            return completion(eventsToReturn)
        })
                
    }
    
    func fetchEventCreator(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil{
                print("Error")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(User(dictionary: data))
        }
    }
    
    
    func fetchOpenToFriendsEvents(user: User) {
        let dp = DispatchGroup()
        self.isLoadingOpenToFriends = true
        var eventsToReturn: [EventModel] = []
        
        user.friendsListID?.forEach({ id in
            dp.enter()
            COLLECTION_EVENTS.whereField("invitationType", isEqualTo: "Open to Friends").whereField("creatorID", isEqualTo: id).getDocuments { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                for document in snapshot?.documents ?? [] {
                    var data = document.data()
                    var userID = data["creatorID"] as? String ?? " "
                    dp.enter()
                    self.fetchEventCreator(userID: id) { fetchedCreator in
                        data["creator"] = fetchedCreator
                        dp.leave()
                    }
                    dp.notify(queue: .main, execute: {
                        eventsToReturn.append(EventModel(dictionary: data))
                    })
                }
                dp.leave()
            }
        })
        
        dp.notify(queue: .main, execute: {
            self.openToFriendsEvents = eventsToReturn
            self.isLoadingOpenToFriends = false
        })
        
    }
    
    func fetchInvitedToEvents(user: User){
        isLoadingInviteOnlyEvents = true
        var eventsToReturn: [EventModel] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        COLLECTION_EVENTS.whereField("usersInvitedIDS", arrayContains: user.id ?? " ").getDocuments { snapshot, err in
            if let err = err {
                print("Fetch events error: \(err.localizedDescription)")
            }
            
            snapshot?.documents.forEach { document in
                var data = document.data()
                eventsToReturn.append(EventModel(dictionary: data))
            }
        }
        
//        self.fetchUserEvents(eventsID: user.eventsID) { fetchedEvents in
//            eventsToReturn.append(contentsOf: fetchedEvents)
//            dispatchGroup.leave()
//        }
        
        dispatchGroup.leave()
        
        
        
        dispatchGroup.notify(queue: .main) {
            self.inviteOnlyEvents = eventsToReturn
            self.isLoadingInviteOnlyEvents = false
        }
        
    }
    
 
    
    func rsvpForEvent(userID: String) {
        // TODO: Implement RSVP for event
    }
    
    func leaveEvent(userID: String) {
        // TODO: Implement leave event
    }
}

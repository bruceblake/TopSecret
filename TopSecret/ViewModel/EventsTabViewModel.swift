//
//  EventsTabViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/20/23.
//

import Foundation
import Firebase

class EventsTabViewModel: ObservableObject {
    @Published var events: [EventModel] = []
    @Published var invitationType: String = "Open to Friends"
    @Published var isLoading: Bool = false
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
//                var locationID = data["locationID"] as? String ?? ""
//                COLLECTION_EVENTS.document(id).collection("Location").document(locationID).getDocument { snapshot, err in
//                    if err != nil {
//                        print("ERROR")
//                        return
//                    }
//
//
//                }
                    eventsToReturn.append(EventModel(dictionary: data))
                dp.leave()

            }
            
        }
        dp.notify(queue: .main, execute: {
            return completion(eventsToReturn)
        })
                
    }
    
    
    func fetchOpenToFriendsEvents(user: User) {
        isLoading = true
        var eventsToReturn: [EventModel] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        user.friendsList?.forEach { friend in
            dispatchGroup.enter()
            let query = COLLECTION_EVENTS.whereField("invitationType", isEqualTo: invitationType)
                .whereField("creatorID", isEqualTo: friend.id ?? "")
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("Fetch events error: \(error.localizedDescription)")
                }
                
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    eventsToReturn.append(EventModel(dictionary: data))
                }
                dispatchGroup.leave()
            }
        }
        
        self.fetchUserEvents(eventsID: user.eventsID) { fetchedEvents in
            eventsToReturn.append(contentsOf: fetchedEvents)
            dispatchGroup.leave()
        }
        
        
        
        
        dispatchGroup.notify(queue: .main) {
            self.events = eventsToReturn
            self.isLoading = false
        }
    }
    
    func rsvpForEvent(userID: String) {
        // TODO: Implement RSVP for event
    }
    
    func leaveEvent(userID: String) {
        // TODO: Implement leave event
    }
}

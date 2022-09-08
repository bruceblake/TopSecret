//
//  UserCalendarViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/20/22.
//

import Combine
import SwiftUI
import Foundation

class UserCalendarViewModel : ObservableObject {
    
    
    @Published var eventsResults : [EventModel] = []
    @Published var selectedOption : String = ""

    
   
    private var cancellables = Set<AnyCancellable>()
    
    func startSearch(userID: String, startDay: Date, endDay: Date){
        self.fetchEvents(userID: userID, startDay: startDay, endDay: endDay)
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
    
    func fetchEvents(userID: String, startDay: Date, endDay: Date) {
        COLLECTION_EVENTS.whereField("usersVisibleTo", arrayContains: userID).getDocuments { snapshot, err in
         
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            var eventsToReturn : [EventModel] = []
            
            var groupD = DispatchGroup()
            
           
            groupD.enter()
            
            for document in documents {
                groupD.enter()

                var data = document.data()
                var startTime = data["eventStartTime"] as? Date ?? Date()
                let users = data["usersAttendingID"] as? [String] ?? []
//                self.fetchEventUsersAttending(usersAttendingID: users, eventID: data["id"] as? String ?? " ", groupID: groupID) { fetchedUsers in
//                    data["usersAttending"] = fetchedUsers
//                    groupD.leave()
//                }
                groupD.leave()
                
                groupD.notify(queue: .main, execute: {
                    eventsToReturn.append(EventModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
         
            
            groupD.notify(queue: .main, execute: {
                self.eventsResults = eventsToReturn
            })
            
        }
        
      
            
        
    }
    
    
}






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
    @Published var isLoading: Bool = false

    
   
    private var cancellables = Set<AnyCancellable>()
    
    func startSearch(eventsID: [String]){
        self.fetchEvents(eventsID: eventsID)
        print("fuck")
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
    
    func fetchEvents(eventsID: [String]) {
        self.isLoading = true
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
//                    var startTime = data["eventStartTime"] as? Date ?? Date()
//                    let users = data["usersAttendingID"] as? [String] ?? []
//    //                self.fetchEventUsersAttending(usersAttendingID: users, eventID: data["id"] as? String ?? " ", groupID: groupID) { fetchedUsers in
//    //                    data["usersAttending"] = fetchedUsers
//    //                    groupD.leave()
//    //                }
            
                        eventsToReturn.append(EventModel(dictionary: data))
                    dp.leave()

            }
        }
        
       
      
        dp.notify(queue: .main, execute: {
            self.eventsResults = eventsToReturn
            self.isLoading = false
        })
        
    }
    
    
}






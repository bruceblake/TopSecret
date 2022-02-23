//
//  EventRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase
import Combine

class EventRepository : ObservableObject {
    
    
    func createEvent(eventName: String, eventLocation: String,eventTime: Date, usersVisibleTo: [String],userID: String){
        //TODO
        let id = UUID().uuidString
        
       

        let data = ["eventName" : eventName,
                    "eventLocation" : eventLocation,
                    "eventTime": eventTime,
                    "usersVisibleTo" : usersVisibleTo, "id":id] as [String:Any]
        
                
        COLLECTION_EVENTS.document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
        }
        addUserToVisibilityList(eventID: id, userID: userID)
    }
    
    func deleteEvent(eventID: String){
        //TODO
    }
    
    func editEvent(){
        //TODO
    }
    
    func addUserToVisibilityList(eventID: String, userID: String){
        //TODO
        COLLECTION_EVENTS.document(eventID).updateData(["usersVisibleTo" : FieldValue.arrayUnion([userID])])
    }
    
}


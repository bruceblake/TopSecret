//
//  EventModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase

struct EventModel : Identifiable{
    var id: String = UUID().uuidString
    var eventName : String?
    var eventLocation : String?
    var eventStartTime : Timestamp?
    var eventEndTime : Timestamp?
    var usersVisibleTo : [String]?
    var usersAttendingID : [String]?
    var usersAttending : [User]?
  
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.eventName = dictionary["eventName"] as? String ?? "EVENT_NAME"
        self.eventLocation = dictionary["eventLocation"] as? String ?? "EVENT_LOCATION"
        self.eventStartTime = dictionary["eventStartTime"] as? Timestamp ?? Timestamp()
        self.eventEndTime = dictionary["eventEndTime"] as? Timestamp ?? Timestamp()
        self.usersVisibleTo = dictionary["usersVisibleTo"] as? [String] ?? []
        self.usersAttendingID = dictionary["usersAttendingID"] as? [String] ?? []
        self.usersAttending = dictionary["usersAttending"] as? [User] ?? []
        
    }
    
   
    init(){
        self.id = UUID().uuidString
    }
    
}



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
    var eventTime : Timestamp?
    var usersVisibleTo : [String]?
  
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.eventName = dictionary["eventName"] as? String ?? "EVENT_NAME"
        self.eventLocation = dictionary["eventLocation"] as? String ?? "EVENT_LOCATION"
        self.eventTime = dictionary["eventTime"] as? Timestamp ?? Timestamp()
        self.usersVisibleTo = dictionary["usersVisibleTo"] as? [String] ?? []
        
    }
    
   
    init(){
        self.id = UUID().uuidString
    }
    
}



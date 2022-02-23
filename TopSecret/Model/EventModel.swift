//
//  EventModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase

struct EventModel : Identifiable {
    var id: String?
    var eventName : String?
    var eventLocation : String?
    var eventTime : Timestamp?
    var usersVisibleTo : [String]?
    
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? " "
        self.eventName = dictionary["eventName"] as? String ?? ""
        self.eventLocation = dictionary["eventLocation"] as? String ?? ""
        self.eventTime = dictionary["eventTime"] as? Timestamp ?? Timestamp()
        self.usersVisibleTo = dictionary["usersVisibleTo"] as? [String] ?? []
        
    }
    
    init(){
        self.id = UUID().uuidString
    }
    
}



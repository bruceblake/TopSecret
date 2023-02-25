//
//  EventModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase

struct EventModel : Identifiable, Hashable{
    
    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    var id: String = UUID().uuidString
    var eventName : String?
    var eventLocation : String?
    var eventStartTime : Timestamp?
    var eventEndTime : Timestamp?
    var usersVisibleTo : [String]?
    var usersAttendingID : [String]?
    var usersAttending : [User]?
    var creatorID: String?
    var creator : User?
    var groupID: String?
    var group: Group?
    var timeStamp: Timestamp?
    var image: UIImage?
    var urlPath: String?
    var likedListID: [String]?
    var likedList: [User]?
    var dislikedListID: [String]?
    var dislikedList: [User]?
  
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.eventName = dictionary["eventName"] as? String ?? "EVENT_NAME"
        self.eventLocation = dictionary["eventLocation"] as? String ?? "EVENT_LOCATION"
        self.eventStartTime = dictionary["eventStartTime"] as? Timestamp ?? Timestamp()
        self.eventEndTime = dictionary["eventEndTime"] as? Timestamp ?? Timestamp()
        self.usersVisibleTo = dictionary["usersVisibleTo"] as? [String] ?? []
        self.usersAttendingID = dictionary["usersAttendingID"] as? [String] ?? []
        self.usersAttending = dictionary["usersAttending"] as? [User] ?? []
        self.creatorID = dictionary["creatorID"] as? String ?? " "
        self.creator = dictionary["creator"] as? User ?? User()
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.group = dictionary["group"] as? Group ?? Group()
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.image = dictionary["image"] as? UIImage ?? UIImage()
        self.urlPath = dictionary["urlPath"] as? String ?? ""
        self.likedListID = dictionary["likedListID"] as? [String] ?? []
        self.likedList = dictionary["likedList"] as? [User] ?? []
        self.dislikedListID = dictionary["dislikedListID"] as? [String] ?? []
        self.dislikedList = dictionary["dislikedList"] as? [User] ?? []

    }
    
   
    init(){
        self.id = UUID().uuidString
    }
    
}



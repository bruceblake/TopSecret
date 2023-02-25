//
//  UserNotificationModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/24/22.
//

import Foundation
import Firebase
import Combine
import SwiftUI



struct UserNotificationModel : Identifiable {
    
    
    
    //User Notifications
    // - User accepted friend request
    // - User denied friend request
    // - You have been sent a group invitation
    // - You have been sent a event invitation
    // - User has sent you a message
    // - You have been kicked from group
    
    
    
    
    
    var id: String = UUID().uuidString
    var name : String?
    var timeStamp : Timestamp?
    var type: String?
    var hasSeen : Bool?
    var finished: Bool?
    var user: User?
    var userID: String?
    var event: EventModel?
    var eventID: String?
    var poll: PollModel?
    var pollID: String?
    var group: Group?
    var groupID: String?
    var post: GroupPostModel?
    var postID: String?
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "NOTIFICATION_ID"
        self.name = dictionary["name"] as? String ?? "NOTIFICATION_NAME"
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.type = dictionary["type"] as? String ?? "NOTIFICATION_TYPE"
        self.hasSeen = dictionary["hasSeen"] as? Bool ?? false
        self.finished = dictionary["finished"] as? Bool ?? false
        self.user = dictionary["user"] as? User ?? User()
        self.userID = dictionary["userID"] as? String ?? ""
        self.event = dictionary["event"] as? EventModel ?? EventModel()
        self.eventID = dictionary["eventID"] as? String ?? ""
        self.poll = dictionary["poll"] as? PollModel ?? PollModel()
        self.pollID = dictionary["pollID"] as? String ?? ""
        self.group = dictionary["group"] as? Group ?? Group()
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.post = dictionary["post"] as? GroupPostModel ?? GroupPostModel()
        self.postID = dictionary["postID"] as? String ?? ""
    }
    
    init(){
        //TEST DATA
        self.id = UUID().uuidString
    }
}

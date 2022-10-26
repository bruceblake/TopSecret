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
    var notificationName : String?
    var notificationTime : Timestamp?
    var notificationType: String?
    var notificationCreatorID: String?
    var notificationCreator : Any?
    var hasSeen : Bool?
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.notificationName = dictionary["notificationName"] as? String ?? "NOTIFICATION_NAME"
        self.notificationTime = dictionary["notificationTime"] as? Timestamp ?? Timestamp()
        self.notificationType = dictionary["notificationType"] as? String ?? "NOTIFICATION_TYPE"
        self.notificationCreatorID = dictionary["notificationCreatorID"] as? String ?? "NOTIFICATION_CREATOR"
        self.notificationCreator = dictionary["notificationCreator"] ?? (Any).self
        self.hasSeen = dictionary["hasSeen"] as? Bool ?? false
    }
    
    init(){
        //TEST DATA
        self.notificationName = "Event Created"
        self.notificationTime = Timestamp()
        self.notificationType = " "
    }
}

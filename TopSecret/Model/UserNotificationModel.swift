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
    
    
    
    
    //User:
    
    //you have been invited to a group
    //you have been private messaged
    //you have been blocked
    //your friend request has been accepted
    //your friend request has been denied
    //you are being private called
    //you have been kicked from a group
    
    
    //Groups:
    
    
    var id: String = UUID().uuidString
    var notificationName : String?
    var notificationTime : Timestamp?
    var notificationType: String?
    var notificationCreatorID: String?
    var notificationCreator : Any?
    var actionTypeID : String?
    var actionType : Any?
    var group: Group?
    var groupID: String?
    var hasSeen : Bool?
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.notificationName = dictionary["notificationName"] as? String ?? "NOTIFICATION_NAME"
        self.notificationTime = dictionary["notificationTime"] as? Timestamp ?? Timestamp()
        self.notificationType = dictionary["notificationType"] as? String ?? "NOTIFICATION_TYPE"
        self.notificationCreatorID = dictionary["notificationCreatorID"] as? String ?? "NOTIFICATION_CREATOR"
        self.notificationCreator = dictionary["notificationCreator"] ?? (Any).self
        self.hasSeen = dictionary["hasSeen"] as? Bool ?? false
        self.group = dictionary["group"] as? Group ?? Group()
        self.groupID = dictionary["groupID"] as? String ?? " "
        self.actionTypeID = dictionary["actionTypeID"] as? String ?? " "
        self.actionType = dictionary["actionType"] ?? (Any).self
    }
    
    init(){
        //TEST DATA
        self.notificationName = "Event Created"
        self.notificationTime = Timestamp()
        self.notificationType = " "
    }
}

//
//  GroupNotificationModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import Foundation
import SwiftUI
import Firebase


struct GroupNotificationModel : Identifiable {
    var id: String = UUID().uuidString
    var notificationName : String?
    var notificationTime : Timestamp?
    var notificationType: String?
    var notificationCreatorID: String?
    var notificationCreator : Any?
    var usersThatHaveSeen : [String]?
    var actionTypeID: String?
    var actionType: Any?
    
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.notificationName = dictionary["notificationName"] as? String ?? "NOTIFICATION_NAME"
        self.notificationTime = dictionary["notificationTime"] as? Timestamp ?? Timestamp()
        self.notificationType = dictionary["notificationType"] as? String ?? "NOTIFICATION_TYPE"
        self.notificationCreatorID = dictionary["notificationCreatorID"] as? String ?? "NOTIFICATION_CREATOR"
        self.usersThatHaveSeen = dictionary["usersThatHaveSeen"] as? [String] ?? []
        self.notificationCreator = dictionary["notificationCreator"] as? Any ?? User()
        self.actionTypeID = dictionary["actionTypeID"] as? String ?? " "
        self.actionType = dictionary["actionType"] ?? (Any).self
        
    }
    
    
    
   
    init(){
        self.id = UUID().uuidString
    }
    
}

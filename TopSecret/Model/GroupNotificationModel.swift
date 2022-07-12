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
    var notificationCreator: String?
    
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.notificationName = dictionary["notificationName"] as? String ?? "NOTIFICATION_NAME"
        self.notificationTime = dictionary["notificationTime"] as? Timestamp ?? Timestamp()
        self.notificationType = dictionary["notificationType"] as? String ?? "NOTIFICATION_TYPE"
        self.notificationCreator = dictionary["notificationCreator"] as? String ?? "NOTIFICATION_CREATOR"
        
    }
    
    
    
   
    init(){
        self.id = UUID().uuidString
    }
    
}

//
//  NotificationModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/10/22.
//

import Foundation
import Firebase


struct NotificationModel : Identifiable {
    var id: String = UUID().uuidString
    var notificationType : String? //either group or user
    var value: String?
    var subjectID: String
    var notificationTime : Timestamp?
    var actionType: String?
    var actionUsed: Bool?

    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? " "
        self.notificationType = dictionary["notificationType"] as? String ?? ""
        self.value = dictionary["value"] as? String ?? ""
        self.subjectID = dictionary["subjectID"] as? String ?? ""
        self.notificationTime = dictionary["notificationTime"] as? Timestamp ?? Timestamp()
        self.actionType = dictionary["actionType"] as? String ?? ""
        self.actionUsed = dictionary["actionUsed"] as? Bool ?? false

     }
    
  
    
}

//
//  GroupNotificationViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import Foundation
import SwiftUI


class GroupNotificationViewModel : ObservableObject {
    
    @Published var notificationCreator : User = User()
    
    
    func fetchNotificationCreator(notification: GroupNotificationModel){
        switch notification.notificationType ?? " "{
            
        case "eventCreated",  "countdownCreated":
            COLLECTION_USER.document(notification.notificationCreatorID ?? " ").getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any]
                
                self.notificationCreator = User(dictionary: data ?? [:])
                
            }
            
            
        
        default:
            return
        }
    }
    
}

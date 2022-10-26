//
//  EventViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import Foundation
import Firebase
import SwiftUI
import Combine


class EventViewModel: ObservableObject {
    

    let shared = UserViewModel.shared

    let notificationSender = PushNotificationSender()

    func createEvent(group: Group, eventName: String, eventLocation: String,eventStartTime: Date, eventEndTime: Date, usersVisibleTo: [User],user: User){
        //TODO
        let id = UUID().uuidString
        
        
        
        let data = ["groupID": group.id, "eventName" : eventName,
                    "eventLocation" : eventLocation,
                    "eventStartTime": eventStartTime,
                    "eventEndTime":eventEndTime,
                    "usersVisibleTo" : usersVisibleTo.map({ user in
            return user.id ?? " "
        }), "id":id, "usersAttendingID":[user.id ?? " "],
                    "creatorID":user.id ?? " "] as [String:Any]
        
        COLLECTION_EVENTS.document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
        }
        
        COLLECTION_GROUP.document(group.id).collection("Events").document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
        }
        
        var notificationID = UUID().uuidString
        
        let notificationData = ["id":notificationID,
                                "notificationName": "Event Created",
                                "notificationTime":Timestamp(),
                                "notificationType":"eventCreated", "notificationCreatorID":user.id ?? "USER_ID",
                                "usersThatHaveSeen":[], "actionTypeID":id] as [String:Any]
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(notificationData)
        
        COLLECTION_GROUP.document(group.id).updateData(["notificationCount":FieldValue.increment((Int64(1)))])
        
        let userNotificationData = ["id":notificationID,
                                    "notificationName": "Event Created",
                                    "notificationTime":Timestamp(),
                                    "notificationType":"eventCreated", "notificationCreatorID":id,
                                    "hasSeen":false] as [String:Any]
        
        for user in usersVisibleTo {
            COLLECTION_USER.document(user.id ?? " ").updateData(["events":FieldValue.arrayUnion([id])])
            COLLECTION_USER.document(user.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
            COLLECTION_USER.document(user.id ?? " ").updateData(["userNotificationCount":FieldValue.increment((Int64(1)))])
            notificationSender.sendPushNotification(to: user.fcmToken ?? " ", title: "\(group.groupName)", body: "\(user.nickName ?? " ") created an event!")
        }
        
        
    }
    
    
    
    func joinEvent(eventID: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).updateData(["usersAttendingID":FieldValue.arrayUnion([userID])])
        print("user joined event: \(eventID)")
    }
    
    func leaveEvent(eventID: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
        print("user left event: \(eventID)")
    }
    
  
    
    func addUserToVisibilityList(eventID: String, userID: String){
        //TODO
        COLLECTION_EVENTS.document(eventID).updateData(["usersVisibleTo" : FieldValue.arrayUnion([userID])])
    }
    
    func fetchEvent(eventID: String, completion: @escaping (EventModel) -> () ) -> (){
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(EventModel(dictionary: data ?? [:]))
            
        }
    }

}

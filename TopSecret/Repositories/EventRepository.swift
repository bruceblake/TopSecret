//
//  EventRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase
import Combine

class EventRepository : ObservableObject {
    
    
    func createEvent(groupID: String, eventName: String, eventLocation: String,eventTime: Date, usersVisibleTo: [String],user: User){
        //TODO
        let id = UUID().uuidString
        
       

        let data = ["groupID": groupID, "eventName" : eventName,
                    "eventLocation" : eventLocation,
                    "eventTime": eventTime,
                    "usersVisibleTo" : usersVisibleTo, "id":id, "usersAttendingID":[user.id ?? " "]] as [String:Any]
        
                
        COLLECTION_GROUP.document(groupID).collection("Events").document(id).setData(data) { (err) in
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
                                "usersThatHaveSeen":[]] as [String:Any]
        COLLECTION_GROUP.document(groupID).collection("Notifications").document(notificationID).setData(notificationData)
        
        COLLECTION_GROUP.document(groupID).updateData(["notificationCount":FieldValue.increment((Int64(1)))])
        

        
//        addUserToVisibilityList(eventID: id, userID: user.id ?? "USER_USERNAME")
        COLLECTION_GROUP.document(groupID).updateData(["events":FieldValue.arrayUnion([id])])
    }
    
    
    func joinEvent(eventID: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).updateData(["usersAttendingID":FieldValue.arrayUnion([userID])])
        print("user joined event: \(eventID)")
    }
    
    func leaveEvent(eventID: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
        print("user left event: \(eventID)")
    }
    
    func deleteEvent(eventID: String){
        //TODO
    }
    
    func editEvent(){
        //TODO
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


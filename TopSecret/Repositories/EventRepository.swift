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
                    "usersVisibleTo" : usersVisibleTo, "id":id] as [String:Any]
        
                
        COLLECTION_GROUP.document(groupID).collection("Events").document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
        }
        
        let notificationData = ["id":UUID().uuidString,
                                "notificationName": "Event Created",
                                "notificationTime":Timestamp(),
                                "notificationType":"eventCreated", "notificationCreator":user.id ?? "USER_ID"] as [String:Any]
        COLLECTION_GROUP.document(groupID).collection("Notifications").addDocument(data: notificationData)
        COLLECTION_GROUP.document(groupID).collection("UnreadNotifications").addDocument(data: notificationData)
        
        addUserToVisibilityList(eventID: id, userID: user.id ?? "USER_USERNAME")
        COLLECTION_GROUP.document(groupID).updateData(["events":FieldValue.arrayUnion([id])])
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


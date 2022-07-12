//
//  SelectedGroupViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import Foundation
import SwiftUI
import Firebase

class SelectedGroupViewModel : ObservableObject {
    
    @Published var group: Group = Group()
    
    
    
    
    
    
    func readGroupNotifications(groupID: String){
        
        
        
        COLLECTION_GROUP.document(groupID).collection("UnreadNotifications").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
           
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
           
        }
    }
    
    
    func fetchGroup(groupID: String){
        COLLECTION_GROUP.document(groupID).addSnapshotListener { snapshot, err in
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            self.fetchGroupCountdown(groupID: groupID) { fetchedCountdowns in
                data["countdowns"] = fetchedCountdowns
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroupEvents(groupID: groupID) { fetchedEvents in
                data["events"] = fetchedEvents
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroupNotifications(groupID: groupID) { fetchedNotifications in
                data["groupNotifications"] = fetchedNotifications
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroupUnreadNotifications(groupID: groupID) { fetchedNotifications in
                data["unreadGroupNotifications"] = fetchedNotifications
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroupChat(groupID: groupID) { fetchedChat in
                data["chat"] = fetchedChat
                groupD.leave()
            }
            
            
            groupD.notify(queue: .main, execute: {
                self.group = Group(dictionary: data )
            })
            
          
        }
    }
    
    
    func fetchGroupChat(groupID: String, completion: @escaping (ChatModel) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Chat").whereField("id", isEqualTo: groupID).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            for document in documents {
                let data =  document.data() as? [String:Any]
                
                return completion(ChatModel(dictionary: data ?? [:]))
            }
            
           
            
        }
    }
    
    
    func fetchGroupNotifications(groupID: String, completion: @escaping ([GroupNotificationModel]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("Notifications").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> GroupNotificationModel in
                let data = queryDocumentSnapshot.data()
                
                return GroupNotificationModel(dictionary: data)
            }))
            
        }
    }
    
    func fetchGroupUnreadNotifications(groupID: String, completion: @escaping ([GroupNotificationModel]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("UnreadNotifications").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> GroupNotificationModel in
                let data = queryDocumentSnapshot.data()
                
                return GroupNotificationModel(dictionary: data)
            }))
            
        }
    }
    
    
    func fetchGroupCountdown(groupID: String,completion: @escaping ([CountdownModel]) -> () ) -> (){
        COLLECTION_GROUP.document(groupID).collection("Countdowns").getDocuments { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> CountdownModel in
                let data = queryDocumentSnapshot.data()
                
                return CountdownModel(dictionary: data)
            }))
            
        }
    }
    
    func fetchGroupEvents(groupID: String,completion: @escaping ([EventModel]) -> () ) -> (){
        COLLECTION_GROUP.document(groupID).collection("Events").getDocuments { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> EventModel in
                let data = queryDocumentSnapshot.data()
                
                return EventModel(dictionary: data)
            }))
            
        }
    }
    
}

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
import CoreLocation


class EventViewModel: ObservableObject {
    @Published var description: String = ""

    let shared = UserViewModel.shared
    @ObservedObject var chatRepository = ChatRepository()

    let notificationSender = PushNotificationSender()

    func createEvent(group: Group, eventName: String, eventLocation: String,eventStartTime: Date, eventEndTime: Date, usersVisibleTo: [User],user: User, image: UIImage, invitationType: String, location: EventModel.Location, membersCanInviteGuests: Bool, invitedMembers: [User], excludedMembers: [User], description: String, createEventChat: Bool, createGroupFromEvent: Bool){
        //TODO
        
        
        let id = UUID().uuidString
        let dp = DispatchGroup()
        dp.enter()
               
                var data = ["groupID": group.id, "eventName" : eventName,
                            "eventLocation" : eventLocation,
                            "eventStartTime": eventStartTime,
                            "eventEndTime":eventEndTime,
                            "usersInvitedIDS":invitedMembers.map({ user in
                    return user.id ?? ""
                }),
                            "usersExcludedIDS":excludedMembers.map({ user in
                    return user.id ?? ""
                }),"id":id, "usersAttendingID":[user.id ?? " "],
                            "creatorID":user.id ?? " ", "timeStamp":Timestamp(), "invitationType":invitationType, "location":location.toDictionary(), "membersCanInviteGuests":membersCanInviteGuests,
                            "description":description] as [String:Any]
                
                let locationData = ["id": location.id ?? " ",
                                    "name":location.name,
                                    "address":location.address,
                                    "latitude":location.latitude,
                                    "longitude":location.longitude] as [String:Any]
        self.persistImageToEventStorage(eventID: id, image: image) { fetchedImageURL in
            data["eventImage"] = fetchedImageURL
            dp.leave()
        }
        
        dp.notify(queue: .main, execute:{
            COLLECTION_EVENTS.document(id).collection("Location").document(location.id ?? " ").setData(locationData)
            
            COLLECTION_EVENTS.document(id).setData(data) { (err) in
                if err != nil {
                    print("ERROR \(err!.localizedDescription)")
                    return
                }
                if createEventChat{
                    self.createEventChat(eventChatID: id, users: invitedMembers, eventID: id, name: eventName)
                }
                
                if createGroupFromEvent{
                    self.createGroupFromEvent(groupName: eventName, image: image , users: invitedMembers)
                }
            }
        })
                
              
                
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
        
        for user in invitedMembers {
            COLLECTION_USER.document(user.id ?? " ").updateData(["eventsID":FieldValue.arrayUnion([id])])
            COLLECTION_USER.document(user.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
            COLLECTION_USER.document(user.id ?? " ").updateData(["userNotificationCount":FieldValue.increment((Int64(1)))])
            self.notificationSender.sendPushNotification(to: user.fcmToken ?? " ", title: "\(group.groupName)", body: "\(user.nickName ?? " ") created an event!")
        }
        
       
            
        }
        
      
  
        
    
    
    func createGroupFromEvent(groupName: String, image: UIImage, users: [User]){
        
        let id = UUID().uuidString
        let chatID = UUID().uuidString

        for user in users{
            COLLECTION_USER.document(user.id ?? " ").updateData(["groupsID":FieldValue.arrayUnion([id])])
  
        }
        
        let data = ["groupName" : groupName,
                    "users" : users ,
                    "memberAmount": users.count, "id":id, "chatID": chatID, "dateCreated":Timestamp(), "groupProfileImage": " "
        ] as [String:Any]
        
        COLLECTION_GROUP.document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            self.persistImageToStorage(groupID: id,image: image, completion: { fetchedImageString in
                self.chatRepository.createGroupChat(name: groupName, users: users.map({$0.id ?? " "}), groupID: id, chatID: chatID, profileImage: fetchedImageString)
            })
        }
    }
    
    func persistImageToStorage(groupID: String, image: UIImage, completion: @escaping (String) -> ()) -> (){
       let fileName = "groupImages/\(groupID)"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { (metadata, err) in
            if err != nil{
                print("ERROR")
                return
            }
               ref.downloadURL { (url, err) in
                if err != nil{
                    print("ERROR: Failed to retreive download URL")
                    return
                }
                print("Successfully stored image in database")
                let imageURL = url?.absoluteString ?? ""
                COLLECTION_GROUP.document(groupID).updateData(["groupProfileImage":imageURL])
                return completion(imageURL)
            }
        }
      
    }
    
    func persistImageToEventStorage(eventID: String, image: UIImage, completion: @escaping (String) -> ()) -> (){
       let fileName = "eventImages/\(eventID)"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        ref.putData(imageData, metadata: nil) { (metadata, err) in
            if err != nil{
                print("ERROR")
                return
            }
               ref.downloadURL { (url, err) in
                if err != nil{
                    print("ERROR: Failed to retreive download URL")
                    return
                }
                print("Successfully stored image in database")
                let imageURL = url?.absoluteString ?? ""
                return completion(imageURL)
            }
        }
      
    }
    
    
    func createEventChat(eventChatID: String, users: [User], eventID: String, name: String){
        let data = ["name":name,
                    "usersID":users.map({return $0.id ?? " "}),
                    "id":eventChatID,
                    "eventID":eventID, "chatType":"groupChat"] as [String:Any]
        for user in users{
            COLLECTION_USER.document(user.id ?? " ").updateData(["personalChatsID":FieldValue.arrayUnion([eventChatID])])
        }
        
        COLLECTION_EVENTS.document(eventID).updateData(["eventChatID":eventChatID])
        
        COLLECTION_PERSONAL_CHAT.document(eventChatID).setData(data){ err in
            if err != nil {
                print("ERROR")
                return
            }
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

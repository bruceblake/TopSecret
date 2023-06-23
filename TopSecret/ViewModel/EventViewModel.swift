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
    @Published var event: EventModel = EventModel()
    @Published var eventIsLoading : Bool = false
    
    let shared = UserViewModel.shared
    @ObservedObject var chatRepository = ChatRepository()
    
    let notificationSender = PushNotificationSender()
    
    func acceptEventInvitation(event: EventModel, userID: String){
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "name": "acceptedEventInvitation",
            "timeStamp":Timestamp(),
            "type":"acceptedEventInvitation",
            "eventID": event.id,
            "userID": event.creatorID ?? " ",
            "hasSeen":false] as [String:Any]
        
        for userID in event.usersAttendingID ?? [] {
            COLLECTION_USER.document(userID).collection("Notifications").document(notificationID).setData(userNotificationData)
        }
        
        COLLECTION_EVENTS.document(event.id).updateData(["usersAttendingID":FieldValue.arrayUnion([userID])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersInvitedIDS":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersDeclinedID":FieldValue.arrayRemove([userID])])
        COLLECTION_USER.document(userID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([event.id])])
        COLLECTION_USER.document(userID).updateData(["eventsID":FieldValue.arrayUnion([event.id])])
    }
    
    func declineEventInvitation(event: EventModel, userID: String){
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "name": "declinedEventInvitation",
            "timeStamp":Timestamp(),
            "type":"declinedEventInvitation",
            "eventID": event.id,
            "userID": event.creatorID ?? " ",
            "hasSeen":false] as [String:Any]
        
        for userID in event.usersAttendingID ?? [] {
            COLLECTION_USER.document(userID).collection("Notifications").document(notificationID).setData(userNotificationData)
        }
        
        COLLECTION_EVENTS.document(event.id).updateData(["usersInvitedIDS":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersDeclinedID":FieldValue.arrayUnion([userID])])
        COLLECTION_USER.document(userID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([event.id])])
        COLLECTION_USER.document(userID).updateData(["eventsID":FieldValue.arrayRemove([event.id])])
    }
    
    
    func editEvent(event: EventModel, name: String, startTime: Date, endTime: Date, user: User, image: UIImage, invitationType: String, location: EventModel.Location, membersCanInviteGuests: Bool, invitedMembers: [User], excludedMembers: [User], description: String, createEventChat: Bool, createGroupFromEvent: Bool){
        let dp = DispatchGroup()
        dp.enter()
        COLLECTION_EVENTS.document(event.id).updateData(["eventName":name])
        COLLECTION_EVENTS.document(event.id).updateData(["eventStartTime":startTime])
        COLLECTION_EVENTS.document(event.id).updateData(["eventEndTime":endTime])
        COLLECTION_EVENTS.document(event.id).updateData(["invitationType":invitationType])
        COLLECTION_EVENTS.document(event.id).updateData(["usersInvitedIDS":invitedMembers.map({$0.id ?? " "})])
        COLLECTION_EVENTS.document(event.id).updateData(["usersExcludedIDS":excludedMembers.map({$0.id ?? " "})])
        COLLECTION_EVENTS.document(event.id).updateData(["description":description])
        COLLECTION_EVENTS.document(event.id).updateData(["location":location.toDictionary()])
        
        let locationData = ["id": location.id ?? " ",
                            "name":location.name,
                            "address":location.address,
                            "latitude":location.latitude,
                            "longitude":location.longitude] as [String:Any]
        
        self.persistImageToEventStorage(eventID: event.id, image: image) { fetchedImageURL in
            COLLECTION_EVENTS.document(event.id).updateData(["eventImage":fetchedImageURL])
            dp.leave()
        }
        
        
        dp.notify(queue: .main, execute:{
            COLLECTION_EVENTS.document(event.id).collection("Location").document(location.id ?? " ").setData(locationData)
            
            
            if createEventChat{
                let chatID = UUID().uuidString
                self.createEventChat(eventChatID: chatID, users: invitedMembers, eventID: event.id, name: name)
            }
            
            if createGroupFromEvent{
                self.createGroupFromEvent(groupName: name, image: image , users: invitedMembers)
            }
            
        })
        
        
        var notificationID = UUID().uuidString
        
        
        
        let userNotificationData = ["id":notificationID,
                                    "name": "Invite To Event",
                                    "timeStamp":Timestamp(),
                                    "userID": user.id ?? " ",
                                    "eventID": event.id,
                                    "hasSeen":false,
                                    "type":"invitedToEvent"] as [String:Any]
        
        for invitedMember in invitedMembers {
            if invitedMember.id ?? " " != user.id ?? " "{
                COLLECTION_USER.document(invitedMember.id ?? " ").updateData(["pendingEventInvitationID":FieldValue.arrayUnion([event.id])])
                COLLECTION_USER.document(invitedMember.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
                COLLECTION_EVENTS.document(event.id).updateData(["usersUndecidedID":FieldValue.arrayUnion([invitedMember.id ?? " "])])
                COLLECTION_EVENTS.document(event.id).updateData(["usersInvitedIDS":FieldValue.arrayUnion([invitedMember.id ?? " "])])
                //                self.notificationSender.sendPushNotification(to: invitedMember.fcmToken ?? " ", title: "\(group.groupName)", body: "\(invitedMember.nickName ?? " ") created an event!")
            }
            
        }
        
        
        
    }
    
    func createEvent(group: Group?, eventName: String, eventStartTime: Date, eventEndTime: Date, user: User, image: UIImage, invitationType: String, location: EventModel.Location, membersCanInviteGuests: Bool, invitedMembers: [User], excludedMembers: [User], description: String, createEventChat: Bool, createGroupFromEvent: Bool) {
        let id = UUID().uuidString
        let dp = DispatchGroup()
        dp.enter()

        var data: [String: Any] = [
            "eventName" : eventName,
            "eventStartTime": eventStartTime,
            "eventEndTime": eventEndTime,
            "usersInvitedIDS": invitedMembers.map({ user in
                return user.id ?? ""
            }),
            "usersExcludedIDS": excludedMembers.map({ user in
                return user.id ?? ""
            }),
            "id": id,
            "usersAttendingID": [user.id ?? ""],
            "creatorID": user.id ?? "",
            "timeStamp": Timestamp(),
            "invitationType": invitationType,
            "location": location.toDictionary(),
            "membersCanInviteGuests": membersCanInviteGuests,
            "description": description,
            "groupID":" "
        ]
        
        if let group = group {
            data["groupID"] = group.id
            COLLECTION_GROUP.document(group.id).collection("Events").document(id).setData(data) { (err) in
                if let err = err {
                    print("ERROR \(err.localizedDescription)")
                    return
                }
                
            }
            COLLECTION_GROUP.document(group.id).updateData(["eventsID":FieldValue.arrayUnion([id])])
        }
            
        

        let locationData: [String: Any] = [
            "id": location.id ?? " ",
            "name": location.name,
            "address": location.address,
            "latitude": location.latitude,
            "longitude": location.longitude
        ]

        self.persistImageToEventStorage(eventID: id, image: image) { fetchedImageURL in
            data["eventImage"] = fetchedImageURL
            dp.leave()
        }

        dp.notify(queue: .main) {
            
    
            COLLECTION_EVENTS.document(id).collection("Location").document(location.id ?? " ").setData(locationData)

            COLLECTION_EVENTS.document(id).setData(data) { (err) in
                if let err = err {
                    print("ERROR \(err.localizedDescription)")
                    return
                }
                if createEventChat {
                    let chatID = UUID().uuidString
                    self.createEventChat(eventChatID: chatID, users: invitedMembers, eventID: id, name: eventName)
                }

                if createGroupFromEvent {
                    self.createGroupFromEvent(groupName: eventName, image: image , users: invitedMembers)
                }
            }
        }

        for invitedMember in invitedMembers {
            if invitedMember.id ?? "" != user.id ?? "" {
                let notificationID = UUID().uuidString
                let userNotificationData: [String: Any] = [
                    "id": notificationID,
                    "name": "Invite To Event",
                    "timeStamp": Timestamp(),
                    "senderID": USER_ID,
                    "receiverID": invitedMember.id ?? "",
                    "eventID": id,
                    "hasSeen": false,
                    "type": "invitedToEvent"
                ]
                COLLECTION_USER.document(invitedMember.id ?? "").updateData(["pendingEventInvitationID": FieldValue.arrayUnion([id])])
                COLLECTION_USER.document(invitedMember.id ?? "").collection("Notifications").document(notificationID).setData(userNotificationData)
                COLLECTION_EVENTS.document(id).updateData(["usersInvitedIDS": FieldValue.arrayUnion([invitedMember.id ?? ""])])
                COLLECTION_EVENTS.document(id).updateData(["usersUndecidedID": FieldValue.arrayUnion([invitedMember.id ?? ""])])
                self.notificationSender.sendPushNotification(to: invitedMember.fcmToken ?? "", title: "\(group?.groupName ?? "")", body: "\(invitedMember.nickName ?? "") created an event!")
            }
        }
        COLLECTION_USER.document(USER_ID).updateData(["eventsID":FieldValue.arrayUnion([id])])

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
    }
    
    func leaveEvent(eventID: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
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
    
    func fetchEvent(eventID: String) {
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            self.event = EventModel(dictionary: data ?? [:])
            
        }
    }
    
}

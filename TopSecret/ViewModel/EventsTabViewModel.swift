//
//  EventsTabViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/20/23.
//

import Foundation
import Firebase

class EventsTabViewModel: ObservableObject {
    @Published var openToFriendsEvents: [EventModel] = []
    @Published var inviteOnlyEvents: [EventModel] = []
    @Published var attendingEvents: [EventModel] = []
    @Published var isLoadingOpenToFriends: Bool = true
    @Published var isLoadingInviteOnlyEvents: Bool = true
    @Published var isLoadingAttendingEvents: Bool = true
    @Published var radius: Int = 1
    
    
    
    
    
    func fetchUsers(usersID: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        let dp = DispatchGroup()
        dp.enter()
        for id in usersID {
            dp.enter()
            COLLECTION_USER.document(id).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                usersToReturn.append(User(dictionary: data))
                dp.leave()
            }
        }
        dp.leave()
        
        dp.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }

    
    func getFriendsAttending(event: EventModel, user: User) -> [User]{
        var friendsToReturn : [User] = []
        for attendingID in event.usersAttendingID ?? [] {
            for friend in user.friendsList ?? [] {
                if attendingID == friend.id ?? " "{
                    friendsToReturn.append(friend)
                }
            }
        }
        return friendsToReturn
    }
    func fetchUserEvents(eventsID: [String], completion: @escaping ([EventModel]) -> ()) -> (){
        let dp = DispatchGroup()
        var eventsToReturn : [EventModel] = []
        for id in eventsID{
            dp.enter()
            COLLECTION_EVENTS.document(id).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]

                eventsToReturn.append(EventModel(dictionary: data))
                dp.leave()

            }
            
        }
        
        dp.notify(queue: .main, execute: {
            return completion(eventsToReturn)
        })
                
    }
    
    func fetchEventCreator(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil{
                print("Error")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(User(dictionary: data))
        }
    }
    
    func fetchAttendingEvents(user: User){
        let dp = DispatchGroup()
        var eventsToReturn: [EventModel] = []
        dp.enter()
        self.isLoadingAttendingEvents = true


        COLLECTION_EVENTS.whereField("usersAttendingID", arrayContains: user.id ?? " ").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            

            for document in snapshot?.documents ?? [] {
                var data = document.data()
                var userID = data["creatorID"] as? String ?? " "
                var usersInvitedID = data["usersInvitedIDS"] as? [String] ?? []
                dp.enter()
                self.fetchEventCreator(userID: userID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dp.leave()
                }
                dp.enter()
                self.fetchUsers(usersID: usersInvitedID) { fetchedUsersInvitedd in
                    data["usersInvited"] = fetchedUsersInvitedd
                    dp.leave()
                }
                dp.notify(queue: .main, execute: {
                    eventsToReturn.append(EventModel(dictionary: data))
                })
                
            }
            
            dp.leave()
            dp.notify(queue: .main, execute: {
                self.attendingEvents = eventsToReturn
                self.isLoadingAttendingEvents = false
            })
        }
        
    }
    
    func fetchOpenToFriendsEvents(user: User) {
        let dp = DispatchGroup()
        var eventsToReturn: [EventModel] = []
        dp.enter()
        self.isLoadingOpenToFriends = true

        user.friendsListID?.forEach({ id in
            COLLECTION_EVENTS.whereField("invitationType", isEqualTo: "Open to Friends").whereField("creatorID", isEqualTo: id).getDocuments { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }

                for document in snapshot?.documents ?? [] {
                    var data = document.data()
                    var userID = data["creatorID"] as? String ?? " "
                    var usersInvitedID = data["usersInvitedIDS"] as? [String] ?? []
                    dp.enter()
                    self.fetchEventCreator(userID: id) { fetchedCreator in
                        data["creator"] = fetchedCreator
                        dp.leave()
                    }
                    dp.enter()
                    self.fetchUsers(usersID: usersInvitedID) { fetchedUsersInvitedd in
                        data["usersInvited"] = fetchedUsersInvitedd
                        dp.leave()
                    }
                    dp.notify(queue: .main, execute: {
                        eventsToReturn.append(EventModel(dictionary: data))
                    })
                    
                }
                
               
            }
        })
        dp.leave()
        dp.notify(queue: .main, execute: {
            self.openToFriendsEvents = eventsToReturn
            self.isLoadingOpenToFriends = false
        })
       
        
    }
    
    func fetchInvitedToEvents(user: User){
        var eventsToReturn: [EventModel] = []
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        COLLECTION_EVENTS.whereField("usersInvitedIDS", arrayContains: user.id ?? " ").getDocuments { snapshot, err in
            if let err = err {
                print("Fetch events error: \(err.localizedDescription)")
            }
            self.isLoadingInviteOnlyEvents = true

            snapshot?.documents.forEach { document in
                var data = document.data()
                var userID = data["creatorID"] as? String ?? " "
                var usersInvitedID = data["usersInvitedIDS"] as? [String] ?? []
                dispatchGroup.enter()
                self.fetchEventCreator(userID: userID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dispatchGroup.leave()
                }
                dispatchGroup.enter()
                self.fetchUsers(usersID: usersInvitedID) { fetchedUsersInvitedd in
                    data["usersInvited"] = fetchedUsersInvitedd
                    dispatchGroup.leave()
                }
                dispatchGroup.notify(queue: .main, execute: {
                    eventsToReturn.append(EventModel(dictionary: data))
                })
                
            }
           
            dispatchGroup.leave()

            dispatchGroup.notify(queue: .main) {
                self.inviteOnlyEvents = eventsToReturn
                self.isLoadingInviteOnlyEvents = false
            }
        }
        
        

    }
    
    
    func inviteToEvent(userID: String, invitedIDS: [User], event: EventModel){

        for invitedMember in invitedIDS {
            if invitedMember.id ?? " " != userID{
                COLLECTION_USER.document(invitedMember.id ?? " ").updateData(["pendingEventInvitationID":FieldValue.arrayUnion([event.id])])
                COLLECTION_EVENTS.document(event.id).updateData(["usersInvitedIDS":FieldValue.arrayUnion([invitedMember.id ?? " "])])
                COLLECTION_EVENTS.document(event.id).updateData(["usersUndecidedID":FieldValue.arrayUnion([invitedMember.id ?? " "])])
                var notificationID = UUID().uuidString
               
                
                
                var userNotificationData = ["id":notificationID,
                    "name": "Invite To Event",
                    "timeStamp":Timestamp(),
                    "senderID":USER_ID,
                    "receiverID": invitedMember.id ?? " ",
                    "eventID": event.id,
                    "hasSeen":false,
                    "type":"invitedToEvent"] as [String:Any]
                COLLECTION_USER.document(invitedMember.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
//                self.notificationSender.sendPushNotification(to: invitedMember.fcmToken ?? " ", title: "\(group.groupName)", body: "\(invitedMember.nickName ?? " ") created an event!")
            }
            
        }
    }
    
 
    
    func attendEvent(userID: String, event: EventModel) {
        
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
        COLLECTION_EVENTS.document(event.id).updateData(["usersDeclinedID":FieldValue.arrayRemove([userID])])
        COLLECTION_USER.document(userID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([event.id])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersUndecidedID":FieldValue.arrayRemove([userID])])
        COLLECTION_USER.document(userID).updateData(["eventsID":FieldValue.arrayUnion([event.id])])
    }
    
    func chooseUndecidedOnEvent(userID: String, event: EventModel){
        COLLECTION_EVENTS.document(event.id).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersDeclinedID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersUndecidedID":FieldValue.arrayUnion([userID])])
        COLLECTION_USER.document(userID).updateData(["pendingEventInvitationID":FieldValue.arrayUnion([event.id])])
        COLLECTION_USER.document(userID).updateData(["eventsID":FieldValue.arrayRemove([event.id])])

    }
    
    func declineEvent(userID: String, event: EventModel) {
        // TODO: Implement leave event
        
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
        COLLECTION_EVENTS.document(event.id).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersDeclinedID":FieldValue.arrayUnion([userID])])
        COLLECTION_USER.document(userID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([event.id])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersUndecidedID":FieldValue.arrayRemove([userID])])
        COLLECTION_USER.document(userID).updateData(["eventsID":FieldValue.arrayRemove([event.id])])
    }
    
    
    func fetchEvent(eventID: String, completion: @escaping (EventModel) -> ()) -> (){
        let dp = DispatchGroup()
        
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            dp.enter()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var creatorID = data["creatorID"] as? String ?? ""
            self.fetchEventCreator(userID: creatorID) { fetchedUser in
                data["creator"] = fetchedUser
                dp.leave()
            }
            dp.notify(queue: .main, execute:{
                return completion(EventModel(dictionary: data))
            })
        }
    }
    
    func deleteEvent(eventID: String){
        COLLECTION_EVENTS.document(eventID).delete()
    }
    
    
}

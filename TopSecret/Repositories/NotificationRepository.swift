//
//  NotificationRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/10/22.
//

import Foundation
import SwiftUI
import Firebase


class NotificationRepository : ObservableObject {
    

    func getGroupNotificationCount(group: Group, maps :[[String:Int]]) -> Int {
        var count = 0
        for map in maps {
            if map[group.id] != .none {
               count = map[group.id] ?? 0
            }
        }
        print("count: \(count)")
        return count
    }
  
    func sendInvitedToGroupNotification(user1: User, user2: User, group: Group, users: [String]){
       
        
            let id = UUID().uuidString
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(id).setData(["notificationType":"groupInvite","value":"\(user1.nickName ?? "") invited @\(user2.username ?? "") to \(group.groupName)","subjectID":group.id,"notificationTime":Timestamp(),"actionType":"none","id":id])
        for user in users {
            COLLECTION_USER.document(user).getDocument { (snapshot, err) in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let map = snapshot?.get("groupNotificationCount") as? [[String:Int]] ?? []
                var count = self.getGroupNotificationCount(group: group, maps: map)
                count = count + 1
                COLLECTION_USER.document(user).updateData(["groupNotificationCount":FieldValue.arrayUnion([[group.id:count]])])
            }
     
            
            
        }
        
    
        let uid2 = UUID().uuidString

        COLLECTION_USER.document(user2.id ?? " ")       .collection("Notifications").document(uid2).setData(["notificationType":"groupInvite","value":"@\(user1.username ?? "") has invited you to \(group.groupName)","subjectID":group.id,"notificationTime":Timestamp(),"actionType":"groupInvite","id":uid2])
        COLLECTION_USER.document(user2.id ?? " ").updateData(["userNotificationCount":FieldValue.increment(Int64(1))])


    }
    
    func sendAcceptedGroupInviteNotification(group: Group, user1: User, users: [String]){
        let id = UUID().uuidString
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(id).setData(["notificationType":"groupInvite","value":"@\(user1.username ?? "") has joined \(group.groupName)", "subjectID":user1.id ?? "","notificationTime":Timestamp(),"actionType":"none","id":id])
            
        
        self.updateGroupNotificationCount(users: users, group: group)

        
      
   
    }
    
    func sendLeftGroupNotification(user: String, group: Group, users: [String]){
        
    }
    
    func sendCreatedEventNotification(user: User, event: EventModel, users: [String], group: Group){
        let id = UUID().uuidString
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(id).setData(["notificationType":"createdEvent","value":"@\(user.username ?? "") has created an event", "subjectID":event.id ?? "","notificationTime":Timestamp(),"actionType":"none","id":id])
        
        self.updateGroupNotificationCount(users: users, group: group)
    }
    
    func sendEndedEventNotification(user: String, completionType: String, event: EventModel, users: [String]){
        
    }
    
    func sendChatMessageNotification(user: String, chat: ChatModel, action: String, users: [String]){
        
    }
    
    func sendCreatedPollNotification(user: User, pollID: String, users: [String], group: Group){
        let id = UUID().uuidString
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(id).setData(["notificationType":"createdPoll","value":"@\(user.username ?? "") has created a poll", "subjectID":pollID,"notificationTime":Timestamp(),"actionType":"none","id":id])
        
        self.updateGroupNotificationCount(users: users, group: group)
        
      
    }
    
    func updateGroupNotificationCount(users: [String], group: Group){
        for user in users{
            COLLECTION_USER.document(user).getDocument { (snapshot, err) in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let map = snapshot?.get("groupNotificationCount") as? [[String:Int]] ?? []
                var count = self.getGroupNotificationCount(group: group, maps: map)
                count = count + 1
                COLLECTION_USER.document(user).updateData(["groupNotificationCount":FieldValue.arrayUnion([[group.id:count]])])
            }
        }
    }
    
    func sendEndedPollNotification(user: String, completionType: String, poll: PollModel, users: [String]){
    
    }
    
    
    func sendFriendRequestNotification(user1: User, user2: String){

        let id = UUID().uuidString
        COLLECTION_USER.document(user2).collection("Notifications").document(id).setData(["notificationType":"friendRequest","value":"@\(user1.username ?? "") has sent you a friend request","notificationTime":Timestamp(),"actionType":"friendRequest","subjectID":user1.id ?? "","id":id])
        COLLECTION_USER.document(user2).updateData(["userNotificationCount":FieldValue.increment(Int64(1))])
        COLLECTION_USER.document(user2).updateData(["pendingFriendsList":FieldValue.arrayUnion([user1.id ?? ""])])
    }
    
    func sendAcceptedFriendRequestNotification(user1: User, user2: String){
        let id = UUID().uuidString
        COLLECTION_USER.document(user2).collection("Notifications").document(id).setData(["notificationType":"friendRequest","value":"@\(user1.username ?? "") has accepted your friend request!","notificationTime":Timestamp(),"actionType":"none","subjectID":user1.id ?? "","id":id])
        COLLECTION_USER.document(user2).updateData(["userNotificationCount":FieldValue.increment(Int64(1))])
  
    }
    
    func sendDeclinedFriendRequestNotification(user1: User, user2: String){
        let id = UUID().uuidString
        COLLECTION_USER.document(user2).collection("Notifications").document(id).setData(["notificationType":"friendRequest","value":"@\(user1.username ?? "") has declined your friend request!","notificationTime":Timestamp(),"actionType":"none","subjectID":user1.id ?? "","id":id])
        COLLECTION_USER.document(user2).updateData(["userNotificationCount":FieldValue.increment(Int64(1))])
    }
    
    
    //Top Secret will not allow you to see texts unless you actually open it
    func sendPersonalChatNotification(user1: User, user2: String){
        let id = UUID().uuidString
        COLLECTION_USER.document(user2).collection("Notifications").document(id).setData(["notificationType":"personalMessage","value":"@\(user1.username ?? "") sent you a message","actionType":"personalMessage","subjectID":user1.id ?? "","notificationTime":Timestamp(),"id":id])
        COLLECTION_USER.document(user2).updateData(["userNotificationCount":FieldValue.increment(Int64(1))])
    }
    
    
}

//
//  MessageRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/10/21.
//

import Foundation
import Combine
import Firebase
import SwiftUI


class MessageRepository : ObservableObject {
    
    @Published var messages : [Message] = []
    @Published var lastMessage : Message?
    @Published var pinnedMessage : PinnedMessageModel = PinnedMessageModel()
    @Published var scrollToBottom = 0 //used for scrolling based on published changes
    @Published var pushText = 0
    
    func readAllMessages(chatID: String, chatType: String, userID: String, groupID: String){
        
        if chatType == "groupChat"{ COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").order(by: "timeStamp",descending: false).addSnapshotListener { (snapshot, err) in
            
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            self.messages = snapshot!.documents.map{ snapshot -> Message in
                let name = snapshot.get("name") as? String ?? ""
                let nameColor = snapshot.get("nameColor") as? String ?? ""
                let timeStamp = snapshot.get("timeStamp") as? Timestamp ?? Timestamp()
                let messageTimeStamp = snapshot.get("messageTimeStamp") as? Timestamp ?? Timestamp()
                let id = snapshot.get("id") as? String ?? ""
                let profilePicture = snapshot.get("profilePicture") as? String ?? ""
                let messageType = snapshot.get("messageType") as? String ?? ""
                let messageValue = snapshot.get("messageValue") as? String ?? ""
                let repliedMessageValue = snapshot.get("repliedMessageValue") as? String ?? ""
                let repliedMessageName = snapshot.get("repliedMessageName") as? String ?? ""
                let repliedMessageProfilePicture = snapshot.get("repliedMessageProfilePicture") as? String ?? ""
                let repliedMessageNameColor = snapshot.get("repliedMessageNameColor") as? String ?? ""
                let edited = snapshot.get("edited") as? Bool ?? false

                
                return Message(dictionary: ["name":name,"timeStamp":timeStamp,"messageTimeStamp":messageTimeStamp,"id":id, "nameColor":nameColor,"profilePicture":profilePicture,"messageType":messageType,"messageValue":messageValue,"repliedMessageValue":repliedMessageValue,"repliedMessageName":repliedMessageName,"repliedMessageProfilePicture":repliedMessageProfilePicture,
                                            "repliedMessageNameColor":repliedMessageNameColor,"edited":edited])
            }
            
        }
        }
        else if chatType == "personal"{
            COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp",descending: false).addSnapshotListener { (snapshot, err) in
                
                if err != nil {
                    print(err!.localizedDescription)
                    return
                }
                
                self.messages = snapshot!.documents.map{ snapshot -> Message in
                    let name = snapshot.get("name") as? String ?? ""
                    let nameColor = snapshot.get("nameColor") as! String
                    let timeStamp = snapshot.get("timeStamp") as? Timestamp ?? Timestamp()
                    let id = snapshot.get("id") as? String ?? ""
                    let profilePicture = snapshot.get("profilePicture") as? String ?? ""
                    let messageType = snapshot.get("messageType") as? String ?? ""
                    let messageValue = snapshot.get("messageValue") as? String ?? ""
                    let repliedMessageValue = snapshot.get("repliedMessageValue") as? String ?? ""
                    let repliedMessageName = snapshot.get("repliedMessageName") as? String ?? ""
                    let repliedMessageProfilePicture = snapshot.get("repliedMessageProfilePicture") as? String ?? ""
                    let repliedMessageNameColor = snapshot.get("repliedMessageNameColor") as? String ?? ""
                    let repliedMessageTimestamp = snapshot.get("repliedMessageTimestamp") as? Timestamp ?? Timestamp()
                    
                    return Message(dictionary:
                        ["name":name,
                         "timeStamp":timeStamp,
                         "id":id,
                         "nameColor":nameColor,
                         "profilePicture":profilePicture,
                         "messageType":messageType,
                         "messageValue":messageValue,
                         "repliedMessageValue":repliedMessageValue,
                         "repliedMessageName":repliedMessageName,
                         "repliedMessageProfilePicture":repliedMessageProfilePicture,
                         "repliedMessageNameColor":repliedMessageNameColor,
                         "repliedMessageTimestamp":repliedMessageTimestamp])
                }
                
            }
        }
    }
    
    func getPinnedMessage(chatID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).addSnapshotListener { (snapshot, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            let pinnedMessage = snapshot?.get("pinnedMessage")
            
            COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").whereField("id", isEqualTo: pinnedMessage as Any).getDocuments { (querySnapshot, err) in
                if err != nil {
                    print(err!.localizedDescription)
                    return
                }
                
                for document in querySnapshot!.documents{
                    let data = document.data()
                    let message = data["text"] as? String ?? ""
                    let timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
                    let profilePicture = data["profilePicture"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let id = data["id"] as? String ?? ""
                    
                    self.pinnedMessage = PinnedMessageModel(id: id, message: message, name: name, userProfilePicture: profilePicture, timestamp: timeStamp, pinnedTime: "4")
                    
                }
                
            }
        }
    }
    
    func pinMessage(chatID: String, messageID: String, userID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).updateData(["pinnedMessage":messageID])
    }
    
    func readLastMessage() -> Message{
        return messages.last ?? Message()
    }
    
  
    
    
    func sendGroupChatTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String,messageType: String, chatID: String, chatType: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).setData(["name":user.nickName ?? "","timeStamp":timeStamp, "nameColor":nameColor, "id":messageID,"profilePicture":user.profilePicture ?? "","messageType":messageType,"messageValue":text])
        
        
        var notificationID = UUID().uuidString
        
        let notificationData = ["id":notificationID,
                                "notificationName": "User Sent A Text",
                                "notificationTime":Timestamp(),
                                "notificationType":"userSentAText", "notificationCreatorID":user.id ?? "USER_ID",
                                "usersThatHaveSeen":[]] as [String:Any]
        COLLECTION_GROUP.document(groupID).collection("Notifications").document(notificationID).setData(notificationData)
        
        COLLECTION_GROUP.document(groupID).updateData(["notificationCount":FieldValue.increment((Int64(1)))])
        
        
    }
    
    func sendPersonalTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chat: ChatModel, chatType: String){
        
        //user 1
        COLLECTION_PERSONAL_CHAT.document(chat.id).collection("Messages").document(messageID).setData(["name":user.nickName ?? "","timeStamp":timeStamp, "nameColor":nameColor, "id":messageID,"profilePicture":user.profilePicture ?? "","messageType":messageType,"messageValue":text])
        
        
        
        self.scrollToBottom += 1
    }
    
    
    
    func sendImageMessage(name: String, timeStamp: Timestamp, nameColor: String, messageID: String, profilePicture: String, messageType: String ,chatID: String, imageURL: UIImage, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).setData(["name":name,"timeStamp":timeStamp, "nameColor":nameColor, "id":messageID,"profilePicture":profilePicture,"messageType":messageType,"messageValue":""])
        persistImageToStorage(image: imageURL, chatID: chatID, messageID: messageID, groupID: groupID)
        self.scrollToBottom += 1
        
    }
    
    func sendDeletedMessage(name: String, timeStamp: Timestamp, nameColor:String, messageID: String, messageType: String, chatID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).setData(
            //this is the message
            ["name":name,"timeStamp":timeStamp,"nameColor":nameColor,"id":messageID,"messageType":messageType]
        )
        
        self.scrollToBottom += 1
    }
    
    func sendReplyMessage(replyMessage: Message, chatID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(replyMessage.id ?? "").setData(
            
            ["name":replyMessage.name ?? "",
             "messageTimeStamp":replyMessage.messageTimeStamp ?? Timestamp(),
             "timeStamp":replyMessage.timeStamp ?? Timestamp(),
             "nameColor":replyMessage.nameColor ?? "",
             "id":replyMessage.id ,
             "profilePicture":replyMessage.profilePicture ?? "",
             "messageType":"replyMessage",
             "messageValue":replyMessage.messageValue ?? "",
            ]
            
        )
        self.scrollToBottom += 1

    }
    
 
    
    func editMessage(messageID: String, chatID: String, text: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).updateData(["messageValue":text])
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).updateData(["edited":true])
        self.scrollToBottom += 1

    }
    
    
    
    
    func deleteMessage(chatID: String, message: Message, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(message.id).delete { (err) in
            if err != nil {
                print("ERROR DELETING MESSAGE, ERROR CODE: \(String(describing: err?.localizedDescription))")
                return
            }
            
            self.sendDeletedMessage(name: message.name ?? "", timeStamp: message.timeStamp ?? Timestamp(), nameColor: message.nameColor ?? "", messageID: message.id, messageType: "deletedMessage", chatID: chatID, groupID: groupID)
            
        }
        
        
    }
    
    func persistImageToStorage(image: UIImage, chatID: String, messageID: String, groupID: String) {
        let fileName = "images/\(chatID)"
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
                COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).updateData(["messageValue":imageURL])
            }
        }
        
    }
    
    
    
    
    
}

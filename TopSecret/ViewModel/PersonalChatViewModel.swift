//
//  PersonalChatViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/16/22.
//

import Foundation
import Firebase
import SwiftUI



class PersonalChatViewModel : ObservableObject {
    @Published var chat : ChatModel = ChatModel()
    @Published var messages : [Message] = []
    @Published var scrollToBottom : Int = 0
    @Published var text: String = ""
    @Published var currentChatColor = "green"
    @Published var chatListener : ListenerRegistration?
    @Published var personalChatListener : ListenerRegistration?
    @Published var personalChats: [ChatModel] = []
    @Published var coverMessages : [Message] = []
    @Published var lastMessageListener : ListenerRegistration?
    let notificationSender = PushNotificationSender()
    var colors : [String] = ["red","green","teal","purple"]
    
//    func setChatColors(chatID: String){
//        var i = 0
//        for user in chat.users {
//            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["chatColors":[[user:self.colors[i]]])
//            i += 1
//        }
//    }
    
    
    func startTyping(userID: String, chatID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersTypingID":FieldValue.arrayUnion([userID])])
    }
    
    func stopTyping(userID: String, chatID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersTypingID":FieldValue.arrayRemove([userID])])
    }
    
    func openChat(userID: String, chatID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersIdlingID":FieldValue.arrayUnion([userID])])
    }
    
    func exitChat(userID: String, chatID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersIdlingID":FieldValue.arrayRemove([userID])])
    }
    
    
    func getPersonalChatUser(chat: ChatModel, userID: String) -> User{
        for user in chat.users{
            if user.id != userID{
                return user
            }
        }
        return User()
    }
    
    func removeListeners(){
        personalChatListener?.remove()
    }
    
    
    func listenToPersonalChats(userID: String){
        
     
      personalChatListener =  COLLECTION_PERSONAL_CHAT.whereField("usersID", arrayContains: userID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var chatsToReturn : [ChatModel] = []
            let groupD = DispatchGroup()
            
            
            let documents = snapshot!.documents
         
            groupD.enter()
            for document in documents{
                var data = document.data()
                let usersID = data["usersID"] as? [String] ?? []
                let lastMessageID = data["lastMessageID"] as? String ?? " "
                let usersTypingID = data["usersTypingID"] as? [String] ?? []
                let id = data["id"] as? String ?? " "
                groupD.enter()
                  self.fetchChatUsers(users: usersID) { fetchedUsers in
                data["users"] = fetchedUsers
                groupD.leave()
            }
                groupD.enter()
                self.fetchLastMessage(chatID: id, messageID: lastMessageID) { fetchedMessage in
                    data["lastMessage"] = fetchedMessage
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUsersTyping(chatID: id, usersTypingID: usersTypingID){ fetchedUsers in
                   data["usersTyping"] = fetchedUsers
                    groupD.leave()
                }
                
                groupD.enter()
                COLLECTION_USER.document(userID).updateData(["personalChatNotificationCount":self.getTotalNotifications(userID: userID)])
                groupD.leave()
              
                groupD.notify(queue: .main, execute:{
                    chatsToReturn.append(ChatModel(dictionary: data))
                })
                
            }
            groupD.leave()
            
            groupD.notify(queue: .main, execute:{
                self.personalChats = chatsToReturn
            })
            
        }
    }
    
    func getTotalNotifications(userID: String) -> Int {
        var sum = 0
        for chat in self.personalChats{
            if !(chat.usersThatHaveSeenLastMessage?.contains(userID) ?? false ){
                sum += 1
            }
        }
        return sum
    }

    func fetchUsersTyping(chatID: String, usersTypingID: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        var groupD = DispatchGroup()
        
        for userID in usersTypingID {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                   print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                usersToReturn.append(User(dictionary: data))
                groupD.leave()
            }
        }
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    
    func fetchChatUsers(users: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        
        var groupD = DispatchGroup()
        
        for userID in users {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                usersToReturn.append(User(dictionary: data))
                groupD.leave()
            }
        }
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    

    
    func fetchAllMessages(chatID: String, userID: String){
        
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp", descending: false).addSnapshotListener { snapshot, err in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            self.messages = snapshot!.documents.map{ snapshot -> Message in
                let data = snapshot.data()
                
                

                
                return Message(dictionary: data)
            }
            
    
        }
    }
    
 

    
    
 
    func sendTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chatID: String, messageColor: String){
        
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":timeStamp,
                               "nameColor":nameColor,
                               "id":messageID,
                               "profilePicture":user.profilePicture
                                ?? "",
                               "messageType":messageType,
                               "messageValue":text,
                               "userID":user.id ?? " ",
                               "messageColor":messageColor] as! [String:Any]
        
        let dp = DispatchGroup()
        
        dp.enter()
                COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).setData(textMessageData)
        dp.leave()
        
        dp.notify(queue: .main, execute:{
         
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":messageID])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
          
            self.notificationSender.sendPushNotification(to: self.getPersonalChatUser(chat: self.chat, userID: user.id ?? " ").fcmToken ?? " ", title: self.getPersonalChatUser(chat: self.chat, userID: user.id ?? " ").nickName ?? " ", body: text)
        })
        

        
 
    }
    
    func getLastMessage() -> Message{
        return self.messages.last ?? Message()
    }
    
   
    
   
  
    func readLastMessage(chatID: String, userID: String){
        
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":FieldValue.arrayUnion([userID])])
        
       
          
        
    }
    
    
    func listenToChat(chatID: String){
        chatListener?.remove()
        print("Chat Removed!")
        
        chatListener = COLLECTION_PERSONAL_CHAT.document(chatID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() ?? [:]
            let users = data["usersID"] as? [String] ?? []
            let lastMessageID = data["lastMessageID"] as? String ?? " "
            let usersTypingID = data["usersTypingID"] as? [String] ?? []
            let id = data["id"] as? String ?? ""
            let groupD = DispatchGroup()
            
            
            //fetch all chat users
            groupD.enter()
            self.fetchChatUsers(users: users) { fetchedUsers in
                data["users"] = fetchedUsers
                groupD.leave()
            }
            
            groupD.enter()
            
            self.fetchLastMessage(chatID: chatID, messageID: lastMessageID){ fetchedMessage in
                data["lastMessage"] = fetchedMessage
                groupD.leave()
            }
            
            
                groupD.enter()
                self.fetchUsersTyping(chatID: id, usersTypingID: usersTypingID){ fetchedUsers in
                   data["usersTyping"] = fetchedUsers
                    groupD.leave()
                }
            
            groupD.notify(queue: .main, execute:{
                self.chat = ChatModel(dictionary: data)
            })
            
        }
    }
    
    
    
    
    func fetchLastMessage(chatID: String, messageID: String, completion: @escaping (Message) -> ()) -> () {
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data() as? [String:Any] ?? [:]
            return completion(Message(dictionary: data))
            
        }
    }
    
    
    
}

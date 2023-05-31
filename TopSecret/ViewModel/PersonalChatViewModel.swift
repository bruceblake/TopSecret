//
//  PersonalChatViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/16/22.
//

import Foundation
import Firebase
import SwiftUI
import Combine



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
    @Published var lastSnapshot : QueryDocumentSnapshot?
    @Published var isLoading : Bool = false
    @Published var hasMoreMessages: Bool = true
    let notificationSender = PushNotificationSender()
    var colors : [String] = ["red","green","teal","purple"]
    var cancellables = Set<AnyCancellable>()
    
      
    
    
    
    
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
        if chatListener != nil{
            chatListener?.remove()
        }
    }
    
    
    func getPersonalChatUser(chat: ChatModel, userID: String) -> User{
        for user in chat.users ?? []{
            if user.id != userID{
                return user
            }
        }
        return User()
    }
    
    func removeListeners(){
        personalChatListener?.remove()
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
    
    
   
    
    func fetchChatUsers(users: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        
        var groupD = DispatchGroup()
        
        groupD.enter()
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
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    
    
    func fetchReplyMessages(chatID: String, messageID: String, completion: @escaping (ReplyMessageModel) -> ()) -> (){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").whereField("id",isEqualTo: messageID).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot?.documents ?? []
            
            
            if documents.isEmpty{
                var replyMessageData = ["id":UUID().uuidString,
                                        "value":"Message Has Been Deleted",
                                        "type":"deletedMessage"] as! [String:Any]
                return completion(ReplyMessageModel(dictionary: replyMessageData))
                
            }else{
                for document in documents{
                    var messageData = document.data() as [String:Any]
                    return completion(ReplyMessageModel(dictionary: messageData))
                    
                }
            }
            
        }
    }
    
    
    
    
     func loadMoreMessages(chatID: String) {
         
        guard !isLoading, hasMoreMessages else { return }
         DispatchQueue.main.async{
             self.isLoading = true
         }
         
        print("added listener")
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 20).addSnapshotListener { (snapshot, error) in
            
            if let error = error {
                print("Error fetching messages: \(error)")
                self.isLoading = false
                return
            }
            
            var messagesToAppend : [Message] = []
            let dp = DispatchGroup()
            dp.enter()
            if self.messages.count > 0 {
                
                snapshot?.documentChanges.forEach({ doc in
                    dp.enter()
                    var data = doc.document.data()
                    let id = data["id"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    let value = data["value"] as? String ?? ""
                    let repliedMessageID = data["repliedMessageID"] as? String ?? ""
                    if type == "repliedMessage"{
                        dp.enter()
                        self.fetchReplyMessages(chatID: chatID, messageID: repliedMessageID) { fetchedReplyMessage in
                            data["repliedMessage"] = fetchedReplyMessage
                            dp.leave()
                        }
                    }
                    if type == "postMessage"{
                        dp.enter()
                        self.fetchPost(postID: value){ fetchedPost in
                            data["post"] = fetchedPost
                            dp.leave()
                        }
                    }
                    if type == "pollMessage"{
                        dp.enter()
                        
                        self.fetchPoll(pollID: value){ fetchedPoll in
                            data["poll"] = fetchedPoll
                            dp.leave()
                        }
                    }
                    if type == "eventMessage"{
                        dp.enter()
                        
                        self.fetchEvent(eventID: value){ fetchedEvent in
                            data["event"] = fetchedEvent
                            dp.leave()
                        }
                    }
                    dp.leave()
                    dp.notify(queue: .main, execute:{
                        if doc.type == .added {
                            if !messagesToAppend.contains(where: {$0.id == id}){
                                messagesToAppend.append(Message(dictionary: data))
                            }
                        }else if doc.type == .removed{
                            messagesToAppend.removeAll(where: {$0.id == id})
                        }else if let index = messagesToAppend.firstIndex(where: {$0.id == id}) {
                            messagesToAppend[index] = Message(dictionary: data)
                        }
                       
                    })
                })
            }
               
            
            dp.leave()
            dp.notify(queue: .main, execute: {
              
                self.messages.insert(contentsOf: messagesToAppend.reversed(), at: 0)
                    self.isLoading = false
             

               
            })
        }
    }
    
    
    
    
    
    func fetchAllMessages(chatID: String, userID: String){
        //how to paginate
        //1. listen to newest 20 messages [20,19,18,17,...,0]
        //2. fetch 20 starting after the 20th
        self.chatListener = COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp", descending: true).limit(to: 20).addSnapshotListener { snapshot, err in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            var messagesToReturn : [Message] = []
            let dp = DispatchGroup()
            
            
            if self.messages.count > 0 {
                snapshot?.documentChanges.forEach({ doc in
                    dp.enter()
                    var data = doc.document.data()
                    let id = data["id"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    let value = data["value"] as? String ?? ""
                    let repliedMessageID = data["repliedMessageID"] as? String ?? ""
                    if type == "repliedMessage"{
                        dp.enter()
                        self.fetchReplyMessages(chatID: chatID, messageID: repliedMessageID) { fetchedReplyMessage in
                            data["repliedMessage"] = fetchedReplyMessage
                            dp.leave()
                        }
                    }
                    if type == "postMessage"{
                        dp.enter()
                        self.fetchPost(postID: value){ fetchedPost in
                            data["post"] = fetchedPost
                            dp.leave()
                        }
                    }
                    if type == "pollMessage"{
                        dp.enter()
                        
                        self.fetchPoll(pollID: value){ fetchedPoll in
                            data["poll"] = fetchedPoll
                            dp.leave()
                        }
                    }
                    if type == "eventMessage"{
                        dp.enter()
                        
                        self.fetchEvent(eventID: value){ fetchedEvent in
                            data["event"] = fetchedEvent
                            dp.leave()
                        }
                    }
                    dp.leave()
                    dp.notify(queue: .main, execute:{
                        
                        if doc.type == .added {
                            if !self.messages.contains(where: {$0.id == id}){
                                self.messages.append(Message(dictionary: data))
                            }
                        }else if doc.type == .removed{
                            self.messages.removeAll(where: {$0.id == id})
                        }else if let index = self.messages.firstIndex(where: {$0.id == id}) {
                            self.messages[index] = Message(dictionary: data)
                        }
                    })
                    
                    
                    //end of foreach document changes
                })
            }else{
                var messagesToReturn : [Message] = []
                dp.enter()
                for document in snapshot!.documents{
                    dp.enter()
                    var data = document.data()
                    let id = data["id"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    let value = data["value"] as? String ?? ""
                    let repliedMessageID = data["repliedMessageID"] as? String ?? ""
                    if type == "repliedMessage"{
                        dp.enter()
                        self.fetchReplyMessages(chatID: chatID, messageID: repliedMessageID) { fetchedReplyMessage in
                            data["repliedMessage"] = fetchedReplyMessage
                            dp.leave()
                        }
                    }
                    if type == "postMessage"{
                        dp.enter()
                        self.fetchPost(postID: value){ fetchedPost in
                            data["post"] = fetchedPost
                            dp.leave()
                        }
                    }
                    if type == "pollMessage"{
                        dp.enter()
                        
                        self.fetchPoll(pollID: value){ fetchedPoll in
                            data["poll"] = fetchedPoll
                            dp.leave()
                        }
                    }
                    if type == "eventMessage"{
                        dp.enter()
                        
                        self.fetchEvent(eventID: value){ fetchedEvent in
                            data["event"] = fetchedEvent
                            dp.leave()
                        }
                    }
                    dp.leave()
                    dp.notify(queue: .main, execute:{
                        //oldest messages right (last in the array), newest messages left (first in the array)
                        //[0,1,2,3,..19] <- this is how they get fetched
                        messagesToReturn.append(Message(dictionary: data))
                    })
                }
                dp.leave()
                dp.notify(queue: .main, execute:{
                    //oldest messages left (first in the array) , newest messages right (last in the array)
                    //we flip the array -> [19,18,17,..0]
                    //proper order
                    self.messages = messagesToReturn.reversed()
                })
            }
            
            
            
            
            
            
            self.lastSnapshot = snapshot!.documents.last
            
         
            
        }
        $text
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink{value in
                if value != "" {
                    self.startTyping(userID: userID, chatID: chatID)
                }else{
                    self.stopTyping(userID: userID, chatID: chatID)
                }
                COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["draftText":value])
            }
            .store(in: &cancellables)
        
    }
    
    func fetchEvent(eventID: String, completion: @escaping (EventModel) -> ()) -> () {
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let groupD = DispatchGroup()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var groupID = data["groupID"] as? String ?? ""
            var creatorID = data["creatorID"] as? String ?? " "
            var urlPath = data["urlPath"] as? String ?? ""
            
            groupD.enter()
            self.fetchUser(userID: creatorID) { fetchedUser in
                data["creator"] = fetchedUser
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroup(groupID: groupID) { fetchedGroup in
                data["group"] = fetchedGroup
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchMedia(urlPath: urlPath) { fetchedImage in
                data["image"] = fetchedImage
                groupD.leave()
            }
            
            
            groupD.notify(queue: .main, execute: {
                return completion(EventModel(dictionary: data))
            })
        }
        
    }
    
    func fetchMedia(urlPath: String, completion: @escaping (UIImage) -> ()) -> (){
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(urlPath)
        
        DispatchQueue.global(qos: .userInteractive).async{
            fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
                if err != nil {
                    print("ERROR: \(err?.localizedDescription ?? "")")
                }
                
                if let image = UIImage(data: data ?? Data())  {
                    return completion(image)
                }
            }
        }
        
        
    }
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            
            
            return completion(User(dictionary: data))
            
            
        }
    }
    
    
    func fetchGroup(groupID: String, completion: @escaping (Group) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(Group(dictionary: data))
        }
    }
    
    func fetchUsersAnswered(usersID: [String], completion: @escaping ([User]) -> ()) -> () {
        var usersToReturn : [User] = []
        let groupD = DispatchGroup()
        groupD.enter()
        for userID in usersID{
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                
                usersToReturn.append(User(dictionary: data))
                
            }
        }
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    
    func fetchPollOptions(pollID: String, groupID: String, completion: @escaping ([PollOptionModel]) -> () ) -> () {
        var choicesToReturn : [PollOptionModel] = []
        
        COLLECTION_POLLS.document(pollID).collection("Options").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            for document in documents {
                var data = document.data()
                
                
                
                choicesToReturn.append(PollOptionModel(dictionary: data))
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(choicesToReturn)
            })
            
            
        }
    }
    
    func fetchPoll(pollID: String, completion: @escaping (PollModel) ->() ) -> () {
        COLLECTION_POLLS.document(pollID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let groupD = DispatchGroup()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            var groupID = data["groupID"] as? String ?? ""
            groupD.enter()
            self.fetchPollOptions(pollID: data["id"] as? String ?? " ", groupID: groupID) { fetchedChoices in
                data["pollOptions"] = fetchedChoices
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchUser(userID: data["creatorID"] as? String ?? " ") { fetchedUser in
                data["creator"] = fetchedUser
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroup(groupID: groupID) { fetchedGroup in
                data["group"] = fetchedGroup
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchUsersAnswered(usersID: data["usersAnsweredID"] as? [String] ?? []){ fetchedUsers in
                data["usersAnswered"] = fetchedUsers
                
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute:{
                return completion(PollModel(dictionary: data))
            })
        }
    }
    
    func fetchPost(postID: String, completion: @escaping (GroupPostModel) ->() ) -> (){
        COLLECTION_POSTS.document(postID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let groupD = DispatchGroup()
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var id = data["id"] as? String ?? "deleted"
            if id == "deleted"{
                let deletedPostData = ["id":id] as! [String:Any]
                return completion(GroupPostModel(dictionary: deletedPostData))
            }
            var creatorID = data["creatorID"] as? String ?? " "
            var groupID = data["groupID"] as? String ?? " "
            var urlPath = data["urlPath"] as? String ?? " "
            groupD.enter()
            self.fetchUser(userID: creatorID) { fetchedUser in
                data["creator"] = fetchedUser
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroup(groupID: groupID) { fetchedGroup in
                data["group"] = fetchedGroup
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchMedia(urlPath: urlPath) { fetchedImage in
                data["image"] = fetchedImage
                groupD.leave()
            }
            groupD.notify(queue: .main, execute:{
                return completion(GroupPostModel(dictionary: data))
            })
            
        }
    }
    
    func sendReplyTextMessage(text: String, user: User, nameColor: String, repliedMessageID: String, messageType: String, chatID: String){
        let id = UUID().uuidString
        
        
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":Timestamp(),
                               "nameColor":nameColor,
                               "id":id,
                               "profilePicture":user.profilePicture
                               ?? "",
                               "type":"repliedMessage",
                               "value":text,
                               "userID":user.id ?? " ",
                               "repliedMessageID":repliedMessageID] as! [String:Any]
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(id).setData(textMessageData)
        
    }
    
    func editMessage(messageID: String, chatID: String, text: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).updateData(["value":text])
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).updateData(["edited":true])
    }
    
    func deleteMessage(messageID: String, chatID: String, user: User){
        let dp = DispatchGroup()
        dp.enter()
        let id = UUID().uuidString
        let messageText = "\(user.nickName ?? "") deleted a chat!"
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":id])
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":Timestamp(),
                               "id":id,
                               "type":"delete",
                               "value":messageText] as! [String:Any]
        dp.leave()
        dp.notify(queue: .main, execute:{
            COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(id).setData(textMessageData)
            COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).delete()
        })
        
    }
    
    
    
    func sendTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chatID: String){
        
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":timeStamp,
                               "nameColor":nameColor,
                               "id":messageID,
                               "profilePicture":user.profilePicture
                               ?? "",
                               "type":messageType,
                               "value":text,
                               "userID":user.id ?? " "] as! [String:Any]
        
        let dp = DispatchGroup()
        
        dp.enter()
        
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).setData(textMessageData)
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":messageID])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
            
            
            
        })
        
        
        
        
    }
    
    func getLastMessage() -> Message{
        return self.messages.last ?? Message()
    }
    
    
    
    
    
    func readLastMessage(chatID: String, userID: String){
        
        
        
        COLLECTION_PERSONAL_CHAT.document(chatID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var usersThatHaveSeen = data["usersThatHaveSeenLastMessage"] as? [String] ?? []
            if !usersThatHaveSeen.contains(userID){
                COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
                
                COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":FieldValue.arrayUnion([userID])])
             
                
                
                
            }
            
            
        }
        
        
        
        
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
            let usersIdlingID = data["usersIdlingID"] as? [String] ?? []
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
            self.fetchChatUsers(users: usersIdlingID){ fetchedUsers in
                data["usersIdling"] = fetchedUsers
                groupD.leave()
            }
            
            
            groupD.enter()
            self.fetchChatUsers(users: usersTypingID){ fetchedUsers in
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

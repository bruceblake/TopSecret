//
//  MessageViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/10/21.
//

import Foundation
import Firebase
import Combine
import SwiftUI

class MessageViewModel : ObservableObject {
    @Published var messages : [Message] = []
    @Published var pinnedMessage : PinnedMessageModel = PinnedMessageModel()
    @Published var scrollToBottom : Int = 0
    
    
    @Published var messageRepository = MessageRepository()
    private var cancellables : Set<AnyCancellable> = []
    
    init(){
        messageRepository.$messages
            .assign(to: \.messages, on: self)
            .store(in: &cancellables)
        messageRepository.$pinnedMessage
            .assign(to: \.pinnedMessage, on: self)
            .store(in: &cancellables)
        messageRepository.$scrollToBottom
            .assign(to: \.scrollToBottom, on: self)
            .store(in: &cancellables)
        
    }
    
    func readLastMessage() -> Message{
        return messageRepository.readLastMessage()
    }
    
    func readAllMessages(chatID: String, userID: String, chatType: String, groupID: String){
        messageRepository.readAllMessages(chatID: chatID, chatType: chatType, userID: userID, groupID: groupID)
    }
    
    func sendGroupChatTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chatID: String, chatType: String, groupID: String){
        
        messageRepository.sendGroupChatTextMessage(text: text, user: user, timeStamp: timeStamp, nameColor: nameColor, messageID: messageID, messageType: messageType, chatID: chatID, chatType: chatType, groupID: groupID)
    }
    
    func sendPersonalChatTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chat: ChatModel, chatType: String){
        messageRepository.sendPersonalTextMessage(text: text, user: user, timeStamp: timeStamp, nameColor: nameColor, messageID: messageID, messageType: messageType, chat: chat, chatType: chatType)
    }
    
    func sendImageMessage(name: String, timeStamp: Timestamp, nameColor: String, messageID: String, profilePicture: String, messageType: String, chatID: String, imageURL: UIImage, groupID: String){
        
        messageRepository.sendImageMessage(name: name, timeStamp: timeStamp, nameColor: nameColor, messageID: messageID, profilePicture: profilePicture, messageType: messageType, chatID: chatID, imageURL: imageURL, groupID: groupID)
    }
    
    func sendDeleteMessage(name: String, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chatID: String, groupID: String){
        messageRepository.sendDeletedMessage(name: name, timeStamp: timeStamp, nameColor: nameColor, messageID: messageID, messageType: messageType, chatID: chatID, groupID: groupID)
        
    }
    
    
    
    func deleteMessage(chatID: String, message: Message, groupID: String){
        messageRepository.deleteMessage(chatID: chatID, message: message, groupID: groupID)
    }
    
    func getPinnedMessage(chatID: String, groupID: String){
        messageRepository.getPinnedMessage(chatID: chatID, groupID: groupID)
    }
    
    func pinMessage(chatID: String, messageID: String, userID: String, groupID: String){
        messageRepository.pinMessage(chatID: chatID, messageID: messageID, userID: userID, groupID: groupID)
    }
    
    func persistImageToStorage(image: UIImage, chatID: String, messageID: String, groupID: String){
        messageRepository.persistImageToStorage(image: image, chatID: chatID, messageID: messageID, groupID: groupID)
    }
    
    func sendReplyMessage(replyMessage: Message, chatID: String, groupID: String){
        messageRepository.sendReplyMessage(replyMessage: replyMessage, chatID: chatID, groupID: groupID)
    }
    
    func editMessage(messageID: String, chatID: String, text: String, groupID: String){
        messageRepository.editMessage(messageID: messageID, chatID: chatID, text: text, groupID: groupID)
    }
    
    
}

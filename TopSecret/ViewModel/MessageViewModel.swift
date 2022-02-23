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
    
    func readAllMessages(chatID: String, userID: String, chatType: String){
        messageRepository.readAllMessages(chatID: chatID, chatType: chatType, userID: userID)
    }
    
    func sendGroupChatTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chat: ChatModel, chatType: String){
        
        messageRepository.sendGroupChatTextMessage(text: text, user: user, timeStamp: timeStamp, nameColor: nameColor, messageID: messageID, messageType: messageType, chat: chat, chatType: chatType)
    }
    
    func sendPersonalChatTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chat: ChatModel, chatType: String){
        messageRepository.sendPersonalTextMessage(text: text, user: user, timeStamp: timeStamp, nameColor: nameColor, messageID: messageID, messageType: messageType, chat: chat, chatType: chatType)
    }
    
    func sendImageMessage(name: String, timeStamp: Timestamp, nameColor: String, messageID: String, profilePicture: String, messageType: String, chatID: String, imageURL: UIImage){
        
        messageRepository.sendImageMessage(name: name, timeStamp: timeStamp, nameColor: nameColor, messageID: messageID, profilePicture: profilePicture, messageType: messageType, chatID: chatID, imageURL: imageURL)
    }
    
    func sendDeleteMessage(name: String, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chatID: String){
        messageRepository.sendDeletedMessage(name: name, timeStamp: timeStamp, nameColor: nameColor, messageID: messageID, messageType: messageType, chatID: chatID)
        
    }
    
    
    
    func deleteMessage(chatID: String, message: Message){
        messageRepository.deleteMessage(chatID: chatID, message: message)
    }
    
    func getPinnedMessage(chatID: String){
        messageRepository.getPinnedMessage(chatID: chatID)
    }
    
    func pinMessage(chatID: String, messageID: String, userID: String){
        messageRepository.pinMessage(chatID: chatID, messageID: messageID, userID: userID)
    }
    
    func persistImageToStorage(image: UIImage, chatID: String, messageID: String){
        messageRepository.persistImageToStorage(image: image, chatID: chatID, messageID: messageID)
    }
    
    func sendReplyMessage(replyMessage: Message, chatID: String){
        messageRepository.sendReplyMessage(replyMessage: replyMessage, chatID: chatID)
    }
    
    func editMessage(messageID: String, chatID: String, text: String){
        messageRepository.editMessage(messageID: messageID, chatID: chatID, text: text)
    }
    
    
}

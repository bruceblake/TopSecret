//
//  GroupModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import Foundation
import SwiftUI
import Firebase



struct Group: Identifiable{
    
   
    
    
    var groupName: String = ""
    var motd: String = ""
    var id: String = UUID().uuidString
    var dateCreated: Date?
    var memberAmount: Int = 0
    var memberLimit: Int?
    var users: [String]?
    var realUsers: [User]?
    var polls : [PollModel] = []
    var posts: [GroupPostModel] = []
    var chatID: String?
    var chat: ChatModel?
    var groupProfileImage: String?
    var quoteOfTheDay: String?
    var followers: [String]?
    var following: [String]?
    var bio : String?
    var storyPosts: [StoryModel]?
    var events : [EventModel]?
    var countdowns: [CountdownModel]?
    var groupNotifications: [GroupNotificationModel]?
    var unreadGroupNotifications: [GroupNotificationModel]?
    var notificationsCount : Int?
    var ping: Bool?
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? UUID().uuidString
        self.groupName = dictionary["groupName"] as? String ?? "GROUP_NAME"
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.memberAmount = dictionary["memberAmount"] as? Int ?? 0
        self.posts = dictionary["posts"] as? [GroupPostModel] ?? []
        self.memberLimit = dictionary["memberLimit"] as? Int ?? 0
        self.users = dictionary["users"] as? [String] ?? []
        self.realUsers = dictionary["realUsers"] as? [User] ?? []
        self.chatID = dictionary["chatID"] as? String ?? " "
        self.chat = dictionary["chat"] as? ChatModel ?? ChatModel()
        self.polls = dictionary["polls"] as? [PollModel] ?? []
        self.groupProfileImage = dictionary["groupProfileImage"] as? String ?? " "
        self.motd = dictionary["motd"] as? String ?? "Welcome to the group!"
        self.quoteOfTheDay = dictionary["quoteOfTheDay"] as? String ?? ""
        self.followers = dictionary["followers"] as? [String] ?? []
  
        self.following = dictionary["following"] as? [String] ?? []
        self.bio = dictionary["bio"] as? String ?? ""
        self.events = dictionary["events"] as? [EventModel] ?? []
        self.countdowns = dictionary["countdowns"] as? [CountdownModel] ?? []
        self.groupNotifications = dictionary["groupNotifications"] as? [GroupNotificationModel] ?? []
        self.unreadGroupNotifications = dictionary["unreadGroupNotifications"] as? [GroupNotificationModel] ?? []
        self.storyPosts = dictionary["storyPosts"] as? [StoryModel] ?? []
        self.notificationsCount = dictionary["notificationsCount"] as? Int ?? 0
        self.ping = dictionary["ping"] as? Bool ?? false
    }
    
    
    init(){
        self.id = UUID().uuidString
    }
    
    
    
    
}

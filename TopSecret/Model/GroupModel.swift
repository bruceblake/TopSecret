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
    var dateCreated: Date = Date()
    var memberAmount: Int = 0
    var memberLimit: Int = 0
    var users: [String] = []
    var realUsers: [User] = []
    var polls : [PollModel] = []
    var chat: ChatModel = ChatModel()
    var groupProfileImage: String = ""
    var quoteOfTheDay: String = ""
    var bio : String = ""
    var storyPosts: [StoryModel] = []
    var events : [EventModel] = []
    var groupNotifications: [GroupNotificationModel] = []
    var unreadGroupNotification: [GroupNotificationModel] = []
    var notificationsCount : Int = 0
    var followersID: [String]?
    var followers: [User]?
    

    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? UUID().uuidString
        self.groupName = dictionary["groupName"] as? String ?? "GROUP_NAME"
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.memberAmount = dictionary["memberAmount"] as? Int ?? 0
        self.users = dictionary["users"] as? [String] ?? []
        self.realUsers = dictionary["realUsers"] as? [User] ?? []
        self.chat = dictionary["chat"] as? ChatModel ?? ChatModel()
        self.polls = dictionary["polls"] as? [PollModel] ?? []
        self.groupProfileImage = dictionary["groupProfileImage"] as? String ?? " "
        self.motd = dictionary["motd"] as? String ?? "Welcome to the group!"
        self.quoteOfTheDay = dictionary["quoteOfTheDay"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.events = dictionary["events"] as? [EventModel] ?? []
        self.groupNotifications = dictionary["groupNotifications"] as? [GroupNotificationModel] ?? []
        self.storyPosts = dictionary["storyPosts"] as? [StoryModel] ?? []
        self.notificationsCount = dictionary["notificationsCount"] as? Int ?? 0
        self.followersID = dictionary["followersID"] as? [String] ?? []
        self.followers = dictionary["followers"] as? [User] ?? []
    }
    
    
    init(){
        self.id = UUID().uuidString
    }
    
    
    
    
}

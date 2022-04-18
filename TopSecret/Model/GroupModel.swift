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
    var polls : [PollModel]?
    var chatID: String?
    var groupProfileImage: String?
    var quoteOfTheDay: String?
    var followers: [String]?
    var following: [String]?
    var bio : String?
    var storyPosts: [StoryModel]?
    var sharedInterests: [String]?
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.groupName = dictionary["groupName"] as? String ?? ""
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.memberAmount = dictionary["memberAmount"] as? Int ?? 0
        self.memberLimit = dictionary["memberLimit"] as? Int ?? 0
        self.users = dictionary["users"] as? [String] ?? []
        self.chatID = dictionary["chatID"] as? String ?? " "
        self.polls = dictionary["polls"] as? [PollModel] ?? []
        self.groupProfileImage = dictionary["groupProfileImage"] as? String ?? " "
        self.motd = dictionary["motd"] as? String ?? "Welcome to the group!"
        self.quoteOfTheDay = dictionary["quoteOfTheDay"] as? String ?? ""
        self.followers = dictionary["followers"] as? [String] ?? []
        self.sharedInterests = dictionary["sharedInterests"] as? [String] ?? []
        self.following = dictionary["following"] as? [String] ?? []
        self.bio = dictionary["bio"] as? String ?? ""
      

    }
    
    func hasUserSeenAllStories(userID: String) -> Bool{
        
        var hasSeenAll : Bool = true
        
        for storyPost in storyPosts!{
            let usersSeenStory = storyPost.usersSeenStory ?? []
            if !usersSeenStory.contains(userID){
                hasSeenAll = false
            }
        }
        
        return hasSeenAll
    }
    
    init(){
        self.id = UUID().uuidString
    }
    
    
    
    
}

//
//  UserModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 4/3/21.
//

import Foundation
import Firebase
import SwiftUI
import MapKit
import CoreLocation

struct User : Identifiable, Hashable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id : String?
    var username: String?
    var email: String?
    var password: String?
    var nickName: String?
    var birthday: Date?
    var bio: String?
    var profilePicture: String?
    var friendsList : [User]?
    var friendsListID : [String]?
    var blockedAccountsID : [String]?
    var blockedAccounts : [User]?
    var userNotificationCount : Int?
    var pendingFriendsList : [User]?
    var pendingFriendsListID : [String]?
    var pendingGroupInvitationID : [String]?
    var isActive: Bool?
    var lastActive: Timestamp?
    var latitude : Double?
    var longitude : Double?
    var notifications : [UserNotificationModel]?
    var fcmToken : String?
    var groupsID : [String]?
    var recentSearches : [String]?
    var personalChatsID : [String]
    var personalChats : [ChatModel]
    var personalChatNotificationCount : Int?
    var dateCreated : Timestamp?
    var groupsFollowingID: [String]?
    var groupsFollowing: [Group]?
    var hasUnreadMessages : Bool?
    var appIconBadgeNumber : Int?
    var interests: [String]?
    var usersLoggedInCount: Int?

init(dictionary: [String:Any]) {
    self.appIconBadgeNumber = dictionary["appIconBadgeNumber"] as? Int ?? 0
    self.id = dictionary["uid"] as? String ?? " "
    self.username = dictionary["username"] as? String ?? " "
    self.email = dictionary["email"] as? String ?? " "
    self.password = dictionary["password"] as? String ?? ""
    self.nickName = dictionary["nickName"] as? String ?? " "
    self.birthday = dictionary["birthday"] as? Date ?? Date()
    self.profilePicture = dictionary["profilePicture"] as? String ?? ""
    self.bio = dictionary["bio"] as? String ?? "This is my bio"
    self.friendsList = dictionary["friendsList"] as? [User] ?? []
    self.friendsListID = dictionary["friendsListID"] as? [String] ?? []
    self.pendingFriendsList = dictionary["pendingFriendsList"] as? [User] ?? []
    self.pendingFriendsListID = dictionary["pendingFriendsListID"] as? [String] ?? []
    self.blockedAccountsID = dictionary["blockedAccountsID"] as? [String] ?? []
    self.blockedAccounts = dictionary["blockedAccounts"] as? [User] ?? []
    self.userNotificationCount = dictionary["userNotificationCount"] as? Int ?? 0

    self.isActive = dictionary["isActive"] as? Bool ?? false
    self.lastActive = dictionary["lastActive"] as? Timestamp ?? Timestamp()

    self.latitude = dictionary["latitude"] as? Double ?? 0
    self.longitude = dictionary["longitude"] as? Double ?? 0
    self.notifications = dictionary["notifications"] as? [UserNotificationModel] ?? []
    self.fcmToken = dictionary["fcmToken"] as? String ?? " "
    self.groupsID = dictionary["groupsID"] as? [String] ?? []
    self.recentSearches = dictionary["recentSearches"] as? [String] ?? []
    self.personalChatsID = dictionary["personalChatsID"] as? [String] ?? []
    self.personalChats = dictionary["personalChats"] as? [ChatModel] ?? []
    self.personalChatNotificationCount = dictionary["personalChatNotificationCount"] as? Int ?? 0
    self.pendingGroupInvitationID = dictionary["pendingGroupInvitationID"] as? [String] ?? []
    self.dateCreated = dictionary["dateCreated"] as? Timestamp ?? Timestamp()
    self.groupsFollowingID = dictionary["groupsFollowingID"] as? [String] ?? []
    self.groupsFollowing = dictionary["groupsFollowing"] as? [Group] ?? []
    self.hasUnreadMessages = dictionary["hasUnreadMessages"] as? Bool ?? false
    self.interests = dictionary["interests"] as? [String] ?? []
    self.usersLoggedInCount = dictionary["usersLoggedInCount"] as? Int ?? 0
 
}

    init(){
        self.id = UUID().uuidString
        self.username = "username"
        self.nickName = "nickName" 
        self.personalChatsID = []
        self.personalChats = []
    }
    
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
}

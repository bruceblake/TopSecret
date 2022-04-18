//
//  UserModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 4/3/21.
//

import Foundation
import Firebase
import SwiftUI

struct User : Identifiable, Hashable{
    var id : String?
    var username: String?
    var email: String?
    var password: String?
    var nickName: String?
    var birthday: Date?
    var bio: String?
    var profilePicture: String?
    var friendsList : [String]?
    var blockedAccounts : [String]?
    var userNotificationCount : Int?
    var pendingFriendsList : [String]?
    var followedGroups : [String]?
    var isActive: Bool?
    var lastActive: Timestamp?
    var groups: [String]?
    var selectedGroup : String?
    var allGroupsToListenTo : [String]?
    


init(dictionary: [String:Any]) {
    self.id = dictionary["uid"] as? String ?? " "
    self.username = dictionary["username"] as? String ?? ""
    self.email = dictionary["email"] as? String ?? ""
    self.password = dictionary["password"] as? String ?? ""
    self.nickName = dictionary["nickName"] as? String ?? ""
    self.birthday = dictionary["birthday"] as? Date ?? Date()
    self.profilePicture = dictionary["profilePicture"] as? String ?? ""
    self.bio = dictionary["bio"] as? String ?? "This is my bio"
    self.friendsList = dictionary["friendsList"] as? [String] ?? []
    self.blockedAccounts = dictionary["blockedAccounts"] as? [String] ?? []
    self.userNotificationCount = dictionary["userNotificationCount"] as? Int ?? 0
    self.pendingFriendsList = dictionary["pendingFriendsList"] as? [String] ?? []
    self.followedGroups = dictionary["followedGroups"] as? [String] ?? [" "]
    self.isActive = dictionary["isActive"] as? Bool ?? false
    self.lastActive = dictionary["lastActive"] as? Timestamp ?? Timestamp()
    self.groups = dictionary["groups"] as? [String] ?? [" "]
    self.selectedGroup = dictionary["selectedGroup"] as? String ?? " "
    self.allGroupsToListenTo = dictionary["allGroupsToListenTo"] as? [String] ?? []
    
 
 }

    init(){
        self.id = UUID().uuidString
        self.followedGroups = [" "]
        self.groups = [" "]

    }
    
}

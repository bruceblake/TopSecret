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
    var blockedAccounts : [String]?
    var userNotificationCount : Int?
    var pendingFriendsList : [String]?
    var isActive: Bool?
    var lastActive: Timestamp?
    var latitude : Double?
    var longitude : Double?
    var notifications : [UserNotificationModel]?
    var fcmToken : String?


init(dictionary: [String:Any]) {
    self.id = dictionary["uid"] as? String ?? " "
    self.username = dictionary["username"] as? String ?? ""
    self.email = dictionary["email"] as? String ?? ""
    self.password = dictionary["password"] as? String ?? ""
    self.nickName = dictionary["nickName"] as? String ?? ""
    self.birthday = dictionary["birthday"] as? Date ?? Date()
    self.profilePicture = dictionary["profilePicture"] as? String ?? ""
    self.bio = dictionary["bio"] as? String ?? "This is my bio"
    self.friendsList = dictionary["friendsList"] as? [User] ?? []
    self.blockedAccounts = dictionary["blockedAccounts"] as? [String] ?? []
    self.userNotificationCount = dictionary["userNotificationCount"] as? Int ?? 0

    self.isActive = dictionary["isActive"] as? Bool ?? false
    self.lastActive = dictionary["lastActive"] as? Timestamp ?? Timestamp()

    self.latitude = dictionary["latitude"] as? Double ?? 0
    self.longitude = dictionary["longitude"] as? Double ?? 0
    self.notifications = dictionary["notifications"] as? [UserNotificationModel] ?? []
    self.fcmToken = dictionary["fcmToken"] as? String ?? " "
 
 }

    init(){
        self.id = UUID().uuidString
      

    }
    
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
}

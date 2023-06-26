//
//   MessageModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/5/21.
//

import Foundation
import SwiftUI
import Firebase


struct Message : Identifiable{
    var id: String
    var nameColor: String?
    var userID : String
    var user: User?
    var timeStamp : Timestamp?
    var name : String?
    var value : String?
    var profilePicture: String?
    var type: String?
    var edited: Bool?
    var usersThatHaveSeen : [String]?
    var repliedMessageID: String?
    var repliedMessage: ReplyMessageModel?
    var event: EventModel?
    var post: GroupPostModel?
    var poll: PollModel?
    var urls: [String]?
    
    
    init(dictionary: [String:Any]){
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.name = dictionary["name"] as? String ?? " "
        self.profilePicture = dictionary["profilePicture"] as? String ?? " "
        self.id = dictionary["id"] as? String ?? " "
        self.nameColor = dictionary["nameColor"] as? String ?? " "
        self.value = dictionary["value"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.userID = dictionary["userID"] as? String ?? " "
        self.user = dictionary["user"] as? User ?? User()
        self.edited = dictionary["edited"] as? Bool ?? false
        self.usersThatHaveSeen = dictionary["usersThatHaveSeen"] as? [String] ?? []
        self.repliedMessageID = dictionary["repliedMessageID"] as? String ?? ""
        self.repliedMessage = dictionary["repliedMessage"] as? ReplyMessageModel ?? ReplyMessageModel()
        self.event = dictionary["event"] as? EventModel ?? EventModel()
        self.post = dictionary["post"] as? GroupPostModel ?? GroupPostModel()
        self.poll = dictionary["poll"] as? PollModel ?? PollModel()
        self.urls = dictionary["urls"] as? [String] ?? []
    }
    
    
    init(){
        self.id = UUID().uuidString
        self.userID = UUID().uuidString
    }
  
    
   
    
}



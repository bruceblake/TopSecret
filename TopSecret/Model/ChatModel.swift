//
//  ChatModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/8/21.
//

import Foundation
import SwiftUI

struct ChatModel : Identifiable {
    var id: String = UUID().uuidString
    var name: String = ""
    var memberAmount: Int = 1
    var usersID : [String] = []
    var usersTypingID : [String] = []
    var usersIdlingID : [String] = []
    var users: [User] = []
    var usersTyping : [User] = []
    var usersIdling : [User] = []
    var dateCreated: Date = Date()
    var messages : [Message] = [ ]
    var groupID : String = ""
    var chatType : String = ""
    var nameColors : [[String:String]] = [[:]] //first string is the userID, second is the color picked
    var colorPicker : Int?
    
    
    init(dictionary:[String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.name = dictionary["name"] as? String ?? " "
        self.memberAmount = dictionary["memberAmount"] as? Int ?? 1
        self.users = dictionary["users"] as? [User] ?? []
        self.usersTyping = dictionary["usersTypingList"] as? [User] ?? []
        self.usersIdling = dictionary["usersIdlingList"] as? [User] ?? []
        self.usersID = dictionary["usersID"] as? [String] ?? []
        self.usersTypingID = dictionary["usersTypingListID"] as? [String] ?? []
        self.usersIdlingID = dictionary["usersIdlingListID"] as? [String] ?? []
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.messages = dictionary["messages"] as? [Message] ?? [ ]
        self.groupID = dictionary["groupID"] as? String ?? " "
        self.chatType = dictionary["chatType"] as? String ?? " "
        self.nameColors = dictionary["nameColors"] as? [[String:String]] ?? [["":""]]
        self.colorPicker = dictionary["colorPicker"] as? Int ?? 0
    }
    init(){
        self.id = UUID().uuidString
    }
   
   
}

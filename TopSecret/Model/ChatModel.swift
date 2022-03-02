//
//  ChatModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/8/21.
//

import Foundation
import SwiftUI

struct ChatModel : Identifiable {
    var id: String
    var name: String?
    var memberAmount: Int = 1
    var users : [String] = []
    var usersTyping : [String] = []
    var usersIdling : [String] = []
    var dateCreated: Date?
    var messages : [Message] = [ ]
    var pinnedMessage : String? //key value pair of messageID and pinnedByUserID
    var groupID : String?
    var chatType : String?
    var nameColors : [[String:String]]? //first string is the userID, second is the color picked
    var colorPicker : Int?
    
    
    init(dictionary:[String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.name = dictionary["name"] as? String ?? " "
        self.memberAmount = dictionary["memberAmount"] as? Int ?? 1
        self.users = dictionary["users"] as? [String] ?? []
        self.usersTyping = dictionary["usersTypingList"] as? [String] ?? []
        self.usersIdling = dictionary["usersIdlingList"] as? [String] ?? []
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.messages = dictionary["messages"] as? [Message] ?? [ ]
        self.pinnedMessage = dictionary["pinnedMessage"] as? String ?? ""
        self.groupID = dictionary["groupID"] as? String ?? " "
        self.chatType = dictionary["chatType"] as? String ?? " "
        self.nameColors = dictionary["nameColors"] as? [[String:String]] ?? [["":""]]
        self.colorPicker = dictionary["colorPicker"] as? Int ?? 0
    }
    init(){
        self.id = UUID().uuidString
    }
   
   
}

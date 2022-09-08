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
    var timeStamp : Timestamp?
    var messageTimeStamp: Timestamp?
    var name : String?
    var messageValue : String?
    var profilePicture: String?
    var messageType: String?
    var repliedMessageName : String?
    var repliedMessageValue: String?
    var repliedMessageProfilePicture: String?
    var repliedMessageNameColor: String?
    var repliedMessageTimestamp: Timestamp?
    var edited: Bool?
    
    enum MessageType {
        case text
        case followUpUserText
        case image
        case deletedMessage
        case savedMessage
    }
  
    
    
    init(dictionary: [String:Any]){
        self.messageTimeStamp = dictionary["messageTimeStamp"] as? Timestamp ?? Timestamp()
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.name = dictionary["name"] as? String ?? " "
        self.profilePicture = dictionary["profilePicture"] as? String ?? " "
        self.id = dictionary["id"] as? String ?? " "
        self.nameColor = dictionary["nameColor"] as? String ?? " "
        self.messageValue = dictionary["messageValue"] as? String ?? ""
        self.messageType = dictionary["messageType"] as? String ?? ""
        self.repliedMessageName = dictionary["repliedMessageName"] as? String ?? ""
        self.repliedMessageValue = dictionary["repliedMessageValue"] as? String ?? ""
        self.repliedMessageProfilePicture = dictionary["repliedMessageProfilePicture"] as? String ?? ""
        self.repliedMessageNameColor = dictionary["repliedMessageNameColor"] as? String ?? ""
        self.repliedMessageTimestamp = dictionary["repliedMessageTimestamp"] as? Timestamp ?? Timestamp()
        self.edited = dictionary["edited"] as? Bool ?? false
    }
    
    
    init(){
        self.id = UUID().uuidString
        
    }
  
    
   
    
}



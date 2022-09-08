//
//  PollModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 10/4/21.
//

import Firebase

struct PollModel : Identifiable {
    var id : String?
    var creatorID : String?
    var creator: User?
    var startDate : Timestamp?
    var endDate : Timestamp?
    var pollOptions : [PollOptionModel] = []
    var finished: Bool?
    var groupID: String?
    var group: Group?
    var question: String?
    var usersAnsweredID: [String]?
    var usersAnswered: [User]?
    var usersVisibleToID: [String]?
    var usersVisibleTo: [User]?
   
   
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.creatorID = dictionary["creatorID"] as? String ?? ""
        self.creator = dictionary["creator"] as? User ?? User()
        self.startDate = dictionary["startDate"] as? Timestamp ?? Timestamp()
        self.endDate = dictionary["endDate"] as? Timestamp ?? Timestamp()
        self.pollOptions = dictionary["pollOptions"] as? [PollOptionModel] ?? []
        self.finished = dictionary["finished"] as? Bool ?? false
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.group = dictionary["group"] as? Group ?? Group()
        self.question = dictionary["question"] as? String ?? ""
        self.usersAnsweredID = dictionary["usersAnsweredID"] as? [String] ?? []
        self.usersAnswered = dictionary["usersAnswered"] as? [User] ?? []
        self.usersVisibleToID = dictionary["usersVisibleToID"] as? [String] ?? []
        self.usersVisibleTo = dictionary["usersVisibleTo"] as? [User] ?? []
    }
    
    init(){
        self.id = UUID().uuidString
    }
   
}
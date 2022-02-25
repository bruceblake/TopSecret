//
//  PollModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 10/4/21.
//

import Firebase

struct PollModel : Identifiable {
    var id : String?
    var creator : String?
    var dateCreated : Timestamp?
    var question: String?
    var groupID : String?
    var groupName: String?
    var pollType: String?
    var totalUsers: Int?
    var usersAnswered: [[String:String]]? // key is userID, value is answer
    var completionType: String? //either all users voted or countdown timer
    var countdownTime : Int? //this is how much countdown the poll has (if it is a countdown completion) in seconds
    var timeRemaining : Int?
    var choices : [String]? //list of up to 4 choices
    var finished: Bool?
    var endDate: Timestamp?
    var users: [String]?
   
    
    
    init(dictionary: [String:Any]){
        self.creator = dictionary["creator"] as? String ?? ""
        self.dateCreated = dictionary["dateCreated"] as? Timestamp ?? Timestamp()
        self.endDate = dictionary["endDate"] as? Timestamp ?? Timestamp()
        self.question = dictionary["question"] as? String ?? ""
        self.groupID = dictionary["groupID"] as? String ?? " "
        self.groupName = dictionary["groupName"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.pollType = dictionary["pollType"] as? String ?? ""
        self.totalUsers = dictionary["totalUsers"] as? Int ?? 0
        self.usersAnswered = dictionary["usersAnswered"] as? [[String:String]] ?? [[:]]
        self.completionType = dictionary["completionType"] as? String ?? ""
        self.countdownTime = dictionary["countdownTime"] as? Int ?? 0
        self.timeRemaining = dictionary["timeRemaining"] as? Int ?? 0
        self.choices = dictionary["choices"] as? [String] ?? ["","","",""]
        self.finished = dictionary["finished"] as? Bool ?? false
        self.users = dictionary["users"] as? [String] ?? [""]
    }
    
    init(){
        self.id = UUID().uuidString
    }
   
}

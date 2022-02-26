//
//  StoryModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/26/22.
//

import Foundation
import Photos


struct StoryModel : Identifiable {
    var id : String = UUID().uuidString
    var image: String?
    var groupID: String?
    var creatorID: String?
    var usersSeenStory : [String]?
    
    
    init(dictionary: [String:Any]){
        self.image = dictionary["image"] as? String ?? ""
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.creatorID = dictionary["creatorID"] as? String ?? ""
        self.usersSeenStory = dictionary["usersSeenStory"] as? [String] ?? []
        self.id = dictionary["id"] as? String ?? ""
    }
    
    init(){
        self.id = UUID().uuidString
    }
}

//
//  GalleryPostModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/23/22.
//

import Foundation
import SwiftUI
import Firebase

struct GalleryPostModel : Identifiable {
    var id: String?
    var viewers : [String]?
    var groupID: String?
    var posts : [String]?
    var taggedUsers : [String]?
    var description : String?
    var creatorID : String?
    var isPrivate : Bool?
    var dateCreated: Timestamp?
    var commentsIDS: [String]? //id of comment models
    var group: Group?
    var creator : User?
    var isInGroup : Bool?
    var isFollowingGroup : Bool?
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.viewers = dictionary["viewers"] as? [String] ?? []
        self.groupID = dictionary["groupID"] as? String ?? " "
        self.posts = dictionary["posts"] as? [String] ?? []
        self.taggedUsers = dictionary["taggedUsers"] as? [String] ?? []
        self.description = dictionary["description"] as? String ?? ""
        self.creatorID = dictionary["creatorID"] as? String ?? " "
        self.isPrivate = dictionary["isPrivate"] as? Bool ?? false
        self.dateCreated = dictionary["dateCreated"] as? Timestamp ?? Timestamp()
        self.commentsIDS = dictionary["commentsIDS"] as? [String] ?? []
        self.group = dictionary["group"] as? Group ?? Group()
        self.creator = dictionary["creator"] as? User ?? User()
        self.isInGroup = dictionary["isInGroup"] as? Bool ?? false
        self.isFollowingGroup = dictionary["isFollowingGroup"] as? Bool ?? true
    }
    
    init(){
        self.id = " "
        self.viewers = []
        self.groupID = " "
        self.posts = []
        self.taggedUsers = []
        self.description = ""
       
        self.isPrivate = false
    }
    
}

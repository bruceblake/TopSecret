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
    var likes : [String]?
    var groupID: String?
    var posts : [String]?
    var taggedUsers : [String]?
    var description : String?
    var creator : String?
    var isPrivate : Bool?
    var dateCreated: Timestamp?
    var comments : [String]? //id of comment models
    
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.viewers = dictionary["viewers"] as? [String] ?? []
        self.groupID = dictionary["groupID"] as? String ?? " "
        self.posts = dictionary["posts"] as? [String] ?? [""]
        self.taggedUsers = dictionary["taggedUsers"] as? [String] ?? []
        self.description = dictionary["description"] as? String ?? ""
        self.creator = dictionary["creator"] as? String ?? " "
        self.isPrivate = dictionary["isPrivate"] as? Bool ?? false
        self.dateCreated = dictionary["dateCreated"] as? Timestamp ?? Timestamp()
        self.likes = dictionary["likes"] as? [String] ?? []
        self.comments = dictionary["comments"] as? [String] ?? []
    }
    
    init(){
        self.id = " "
        self.viewers = []
        self.groupID = " "
        self.posts = [""]
        self.taggedUsers = []
        self.description = ""
        self.creator = " "
        self.isPrivate = false
    }
    
}

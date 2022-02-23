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
    var post : String?
    var taggedUsers : [String]?
    var description : String?
    var creator : String?
    var isPrivate : Bool?
    
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.viewers = dictionary["viewers"] as? [String] ?? []
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.post = dictionary["post"] as? String ?? ""
        self.taggedUsers = dictionary["taggedUsers"] as? [String] ?? []
        self.description = dictionary["description"] as? String ?? ""
        self.creator = dictionary["creator"] as? String ?? ""
        self.isPrivate = dictionary["isPrivate"] as? Bool ?? false
    }
    
}

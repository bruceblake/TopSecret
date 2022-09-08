//
//  GalleryPostCommentModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/1/22.
//

import Foundation
import Firebase

struct GalleryPostCommentModel : Identifiable,Hashable {
   var id: String?
    var text: String?
    var dateCreated: Timestamp?
    var usersLiked : [String]?
    var likes : Int?
    var creator : String?
    var user: User?
    var galleryPostID: String?
    var groupID: String?
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.text = dictionary["text"] as? String ?? ""
        self.dateCreated = dictionary["dateCreated"] as? Timestamp ?? Timestamp()
        self.creator = dictionary["creator"] as? String ?? " "
        self.usersLiked = dictionary["usersLiked"] as? [String] ?? []
        self.likes = dictionary["likes"] as? Int ?? 0
        self.galleryPostID = dictionary["galleryPostID"] as? String ?? " "
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.user = dictionary["user"] as? User ?? User()
    }
 }



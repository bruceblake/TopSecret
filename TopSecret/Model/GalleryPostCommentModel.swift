//
//  GalleryPostCommentModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/1/22.
//

import Foundation
import Firebase

struct GroupPostCommentModel : Identifiable {
    var id: String?
    var text: String?
    var timeStamp: Timestamp?
    var usersLikedID: [String]?
    var usersLiked : [User]?
    var usersDislikedID: [User]?
    var usersDisliked: [String]?
    var creatorID: String?
    var creator: User?
    var postID: String?
    var post: GroupPostModel?

    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.text = dictionary["text"] as? String ?? ""
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.creatorID = dictionary["creatorID"] as? String ?? " "
        self.creator = dictionary["creator"] as? User ?? User()
        self.usersLiked = dictionary["usersLiked"] as? [User] ?? []
        self.usersLikedID = dictionary["usersLikedID"] as? [String] ?? []
        self.usersDisliked = dictionary["usersDisliked"] as? [String] ?? []
        self.usersDislikedID = dictionary["usersDislikedID"] as? [User] ?? []
        self.postID = dictionary["postID"] as? String ?? " "
        self.post = dictionary["post"] as? GroupPostModel ?? GroupPostModel()

    }
    
    init(){
        self.id = UUID().uuidString
    }
 }



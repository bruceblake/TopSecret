//
//  GalleryPostCommentModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/1/22.
//

import Foundation
import Firebase


struct GalleryPostCommentModel : Identifiable {
    var id: String?
    var text: String?
    var dateCreated: Timestamp?
    var likes: [String]?
    var creator : String?
    var user: User?
    
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.text = dictionary["text"] as? String ?? ""
        self.dateCreated = dictionary["dateCreated"] as? Timestamp ?? Timestamp()
        self.likes = dictionary["likes"] as? [String] ?? []
        self.creator = dictionary["creator"] as? String ?? " "
    }
}

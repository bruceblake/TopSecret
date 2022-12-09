//
//  GroupPostModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 9/6/22.
//

import Foundation
import SwiftUI
import Firebase


struct GroupPostModel : Identifiable {
    var id: String?
    var description: String?
    var image: UIImage?
    var urlPath: String?
    var creatorID: String?
    var creator: User?
    var groupID: String?
    var group: Group?
    var timeStamp : Timestamp?
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? "FUCK"
        self.description = dictionary["description"] as? String ?? ""
        self.image = dictionary["image"] as? UIImage ?? UIImage()
        self.urlPath = dictionary["urlPath"] as? String ?? ""
        self.creatorID = dictionary["creatorID"] as? String ?? ""
        self.creator = dictionary["creator"] as? User ?? User()
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.group = dictionary["group"] as? Group ?? Group()
    }
    
    init(){
        self.id = UUID().uuidString
    }
}

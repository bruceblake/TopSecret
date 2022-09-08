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
    var id: String
    var description: String
    var image: UIImage
    var urlPath: String
    var creatorID: String
    var timeStamp : Timestamp
    
    
    init(dictionary: [String:Any]){
        self.id = ["id"] as? String ?? "FUCK"
        self.description = ["description"] as? String ?? ""
        self.image = ["image"] as? UIImage ?? UIImage()
        self.urlPath = ["urlPath"] as? String ?? ""
        self.creatorID = ["creatorID"] as? String ?? ""
        self.timeStamp = ["timeStamp"] as? Timestamp ?? Timestamp()
    }
}

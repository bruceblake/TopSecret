//
//  CreateGroupPostViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 9/6/22.
//

import Foundation
import SwiftUI
import Firebase

class CreateGroupPostViewModel : ObservableObject {
    
    enum UploadStatus {
        case notStartedUpload
        case startedUpload
        case finishedUpload
    }
    
    @Published var uploadStatus = UploadStatus.startedUpload
    
    func createPost(image: UIImage, userID: String, group: Group){
        let storageRef = Storage.storage().reference()
        let postID = UUID().uuidString
        
        
        let imageData = image.jpegData(compressionQuality: 0.1)
        
        guard imageData != nil else {return}
        
        let path = "GroupPostImages/\(group.groupName)/\(postID).jpg"
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, err in
            if err == nil && metadata != nil {
                let data = ["id":postID,"urlPath":path,"creatorID":userID,"timeStamp":Timestamp()] as? [String : Any] ?? [:]
                COLLECTION_GROUP.document(group.id).collection("Posts").document(postID).setData(data) { err in
                    if err == nil {
                        DispatchQueue.main.async{
                            print("Uploaded Post!")
                            self.uploadStatus = .finishedUpload
                        }
                    }
                    
                }
            }
        }
    }
}

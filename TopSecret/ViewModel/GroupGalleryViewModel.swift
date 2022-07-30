//
//  GroupGalleryViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/30/22.
//

import Foundation
import Firebase
import SwiftUI
import UIKit

class GroupGalleryViewModel : ObservableObject {
    
    @Published var retrievedImages = [GroupGalleryImageModel]()
    @Published var isLoading : Bool = true
    
    
    func uploadPhoto(image: UIImage, userID: String, group: Group){
        
      
        
        let storageRef = Storage.storage().reference()
        
        let imageData = image.jpegData(compressionQuality: 0.1)
        
        guard imageData != nil else {
            return
        }
        let path = "\(group.groupName)/GroupGalleryImages/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata , err in
            if err == nil && metadata != nil {
                let id = UUID().uuidString
                let data = ["id":id,"url":path, "creatorID":userID, "timeStamp":Timestamp(),"isPrivate":false] as [String:Any]
                COLLECTION_GROUP.document(group.id).collection("Gallery").document(id).setData(data) { err in
                    if err == nil {
                        
                        DispatchQueue.main.async{
                            let galleryImageData = ["id":id, "url":path,"image":image,"creatorID":userID,"timeStamp":Timestamp(),"isPrivate":false] as [String:Any]
                            self.retrievedImages.append(GroupGalleryImageModel(dictionary: galleryImageData))
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    func fetchPhotos(userID: String, groupID: String){
        
        self.isLoading = true
        var groupD = DispatchGroup()
        
        groupD.enter()
        self.retrievedImages.removeAll()
        COLLECTION_GROUP.document(groupID).collection("Gallery").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var paths = [String]()
            
           var documents = snapshot!.documents
            
            
            for doc in documents{
                var path = doc["url"] as? String ?? " "
                var id = doc["id"] as? String ?? " "
                var timeStamp = doc["timeStamp"] as? Timestamp ?? Timestamp()
                let storageRef = Storage.storage().reference()
                
                let fileRef = storageRef.child(path)
                
                fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
                    
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    if let image = UIImage(data: data!){
                        DispatchQueue.main.async {
                            let galleryImageData = ["id":id, "url":path,"image":image,"creatorID":userID,"timeStamp":timeStamp,"isPrivate":false] as [String:Any]
                            self.retrievedImages.append(GroupGalleryImageModel(dictionary: galleryImageData))
                        }
                    }
                    
                }
            }
            
            
            
        }
        groupD.leave()
        
        groupD.notify(queue: .main, execute:{
            self.isLoading = false
        })
    }
    
    

  
    
    
}


class ImageSaver : NSObject {
    
    func writeToPhotoAlbum(image: UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        print("Save Finished!")
    }
}

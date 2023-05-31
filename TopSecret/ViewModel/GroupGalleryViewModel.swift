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
    
    
    func uploadPhoto(image: UIImage, userID: String, group: Group, isPrivate: Bool){
        
      
        
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
                            let galleryImageData = ["id":id, "url":path,"image":image,"creatorID":userID,"timeStamp":Timestamp(),"isPrivate":isPrivate] as [String:Any]
                            self.retrievedImages.append(GroupGalleryImageModel(dictionary: galleryImageData))
                        }
                        
                        
                    }
                }
            }
            
            self.fetchPhotos(userID: userID, groupID: group.id)
        }
    }
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
        }
    }
    
    func fetchPhotos(userID: String, groupID: String){
        
        self.isLoading = true
        var groupD = DispatchGroup()
        
        groupD.enter()
        COLLECTION_GROUP.document(groupID).collection("Gallery").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            
           var documents = snapshot!.documents
            
            
            for doc in documents{
                var docData = doc.data() as? [String:Any] ?? [:]
                var path = doc["url"] as? String ?? " "
                var creatorID = doc["creatorID"] as? String ?? ""
                let storageRef = Storage.storage().reference()
                
                let fileRef = storageRef.child(path)
                
                fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
                    
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    if let image = UIImage(data: data!){
                        let dp = DispatchGroup()
                        dp.enter()
                        docData["image"] = image
                        
                        self.fetchUser(userID: creatorID) { fetchedUser in
                            docData["creator"] = fetchedUser
                            dp.leave()
                        }
                        
                        dp.notify(queue: .main, execute:{
                            self.retrievedImages.append(GroupGalleryImageModel(dictionary: docData))
                        })
                           
                        
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

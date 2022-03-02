//
//  GalleryRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/1/22.
//

import Foundation
import Firebase
import SwiftUI


class GalleryRepository : ObservableObject {
    
    @Published var galleryPosts : [GalleryPostModel] = []

    
    
    func createGalleryPost(groupID: String, posts: [UIImage], description: String, creator: String, isPrivate: Bool, taggedUsers: [String]){
        var id = UUID().uuidString
        COLLECTION_GROUP.document(groupID).collection("Gallery Posts").document(id).setData(["id":id,"viewers":
    [],"groupID":groupID,"taggedUsers":taggedUsers,"description":description,"creator":creator,"isPrivate":isPrivate,"dateCreated":Timestamp()])
        id = UUID().uuidString
        COLLECTION_GALLERY_POSTS.document(id).setData(["id":id,"viewers":
                                                        [],"groupID":groupID,"taggedUsers":taggedUsers,"description":description,"creator":creator,"isPrivate":isPrivate,"dateCreated":Timestamp()])
        self.persistImageToStorage(galleryID: id, images: posts)
        
    }
    
    
    func deleteGalleryPost(galleryPostID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Gallery Posts").document(galleryPostID).delete()
    }
    
    
    func fetchGroupGalleryPosts(groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Gallery Posts").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            self.galleryPosts = snapshot!.documents.map({ queryDocumentSnapshot -> GalleryPostModel in
                let data = queryDocumentSnapshot.data()
                
                return GalleryPostModel(dictionary: data)
            })
        }
    }
    
    
    func persistImageToStorage(galleryID: String, images: [UIImage]) {
       let fileName = "galleryPosts/\(galleryID)"
        let ref = Storage.storage().reference(withPath: fileName)
        
        for image in images{
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            
            ref.putData(imageData, metadata: nil) { (metadata, err) in
                if err != nil{
                    print("ERROR")
                    return
                }
                   ref.downloadURL { (url, err) in
                    if err != nil{
                        print("ERROR: Failed to retreive download URL")
                        return
                    }
                    print("Successfully stored image in database")
                    let imageURL = url?.absoluteString ?? ""
                       COLLECTION_GALLERY_POSTS.document(galleryID).updateData(["posts":FieldValue.arrayUnion([imageURL])])
                }
            }
        }
      
        
      
    }
    
    func addComment(galleryID: String, groupID: String, userID: String, text: String){
        let id = UUID().uuidString
        let data = ["id":id,"text":text,"dateCreated":Timestamp(),"creator":userID] as [String:Any]
        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").document(id).setData(data)
        COLLECTION_GALLERY_POSTS.document(galleryID).updateData(["comments":FieldValue.arrayUnion([id])])
        print("\(userID) added comment")
    }
    
    
    
    
    func likePost(galleryID: String, groupID: String, userID: String){
        COLLECTION_GALLERY_POSTS.document(galleryID).updateData(["likes":FieldValue.arrayUnion([userID])])
        
    }
    
    func unlikePost(galleryID: String, groupID: String, userID: String){
        COLLECTION_GALLERY_POSTS.document(galleryID).updateData(["likes":FieldValue.arrayRemove([userID])])
    }
    
    func likeComment(galleryID: String, groupID: String, userID: String, commentID: String){
        COLLECTION_GALLERY_POSTS.document(galleryID).collection(commentID).document(commentID).updateData(["likes":FieldValue.arrayUnion([userID])])
    }
    
    func userHasAlreadyLikedPost(userID: String, likes: [String]) -> Bool{
        return likes.contains(userID)
    }
    
    func fetchPostComments(galleryID: String, groupID: String, completion: @escaping ([GalleryPostCommentModel]) -> ()) -> (){
        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
           return completion(documents.map({ queryDocumentSnapshot -> GalleryPostCommentModel in
                let data = queryDocumentSnapshot.data()
                let id = data["id"] as? String ?? " "
                let text = data["text"] as? String ?? ""
                let dateCreated = data["dateCreated"] as? Timestamp ?? Timestamp()
                let likes = data["likes"] as? [String] ?? []
                let creator = data["creator"] as? String ?? " "
               var user : User = User()
               self.fetchUser(userID: creator) { fetchedUser in
                  user = fetchedUser
               }
                   print("user: \(user.username ?? "cock")")
                    
                   return GalleryPostCommentModel(dictionary: ["id":id,"text":text,"dateCreated":dateCreated,"likes":likes,"creator":creator,"user":user])
               
           
            }))
            
           
            
        }
    }
    
    func fetchGalleryPost(galleryPostID: String, completion: @escaping (GalleryPostModel) -> ()) -> (){
        COLLECTION_GALLERY_POSTS.document(galleryPostID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(GalleryPostModel(dictionary: data ?? [:]))
            
        }
    }
    
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(User(dictionary: data ?? [:]))
        }
    }

 
    
}

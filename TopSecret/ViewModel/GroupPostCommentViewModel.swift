//
//  GroupPostCommentViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/15/22.
//

import Foundation
import Firebase



class GroupPostCommentViewModel : ObservableObject {
    
    @Published var comments: [GroupPostCommentModel] = []
    @Published var hasLoaded: Bool = false
    
    
    
    func fetchComments(postID: String){
        COLLECTION_POSTS.document(postID).collection("Comments").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var commentsToReturn : [GroupPostCommentModel] = []
            let dp = DispatchGroup()
            
            let documents = snapshot!.documents
            dp.enter()
            for document in documents {
                var data = document.data()
                var usersLikedID = data["usersLikedID"] as? [String] ?? []
                var creatorID = data["creatorID"] as? String ?? " "
                
                dp.enter()
                self.fetchUsersLiked(usersLikedID: usersLikedID) { fetchedUsers in
                    data["usersLiked"] = fetchedUsers
                    dp.leave()
                }
                
                dp.enter()
                self.fetchCreator(creatorID: creatorID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dp.leave()
                }
                
                dp.notify(queue: .main, execute:{
                    commentsToReturn.append(GroupPostCommentModel(dictionary: data))
                })
                
            }
            dp.leave()
            dp.notify(queue: .main, execute: {
                self.comments = commentsToReturn
                self.hasLoaded = true
            })
        }
    }
    
    func fetchCreator(creatorID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(creatorID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(User(dictionary: data))
        }
    }
    
    func fetchUsersLiked(usersLikedID: [String], completion: @escaping ([User]) -> () ) -> () {
        let dp = DispatchGroup()
        var usersToReturn: [User] = []
        dp.enter()
        for user in usersLikedID{
            COLLECTION_USER.document(user).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                usersToReturn.append(User(dictionary: data))
            }
        }
        dp.leave()
        dp.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    func addComment(postID: String, userID: String, text: String){
        let id = UUID().uuidString
        let data = ["id":id,
                    "text":text,
                    "timeStamp":Timestamp(),
                    "creatorID":userID,
                    "postID":postID] as [String:Any]
        
        COLLECTION_POSTS.document(postID).collection("Comments").document(id).setData(data)
        COLLECTION_POSTS.document(postID).updateData(["commentsCount":FieldValue.increment(Int64(1))])
    }
}

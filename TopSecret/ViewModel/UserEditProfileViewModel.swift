//
//  UserEditProfileViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/3/22.
//

import Foundation
import Combine
import FirebaseFirestore



class UserEditProfileViewModel : ObservableObject {
    @Published var username = ""
    @Published var bio = ""
    @Published var nickname = ""
    @Published var didChangeUsername : Bool = false
    @Published var didChangeBio : Bool = false
    @Published var didChangeNickName : Bool = false

    
    
    
    init(){
        
    }
    
    
    func changeUsername(userID: String, username: String){
        COLLECTION_USER.document(userID).updateData(["username":username])
    }
    
    func changeBio(userID: String, bio: String){
        
        COLLECTION_USER.document(userID).updateData(["bio":bio])
    }
    
    
    
    func changeNickname(userID: String, nickName: String){
        COLLECTION_USER.document(userID).updateData(["nickName":nickName])
    }
    
    
    
    
    
  
}

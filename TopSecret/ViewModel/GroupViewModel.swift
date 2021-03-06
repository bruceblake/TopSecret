//
//  CreateGroupViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

import Firebase
import Combine



class GroupViewModel: ObservableObject {
    
    
    var userVM: UserViewModel?
    @ObservedObject var chatVM = ChatViewModel()
    @ObservedObject var groupRepository = GroupRepository()
    @Published var groupChat : ChatModel = ChatModel()
    @Published var usersProfilePictures : [String] = []
    @Published var countdowns : [CountdownModel] = []
    @Published var groupProfileImage = ""
    @Published var activeUsers : [User] = []
    @Published var followers : [User] = []


    
    private var cancellables : Set<AnyCancellable> = []

    
    init(){
        groupRepository.$usersProfilePictures
            .assign(to: \.usersProfilePictures, on: self)
            .store(in: &cancellables)
        groupRepository.$groupChat
            .assign(to: \.groupChat, on: self)
            .store(in: &cancellables)
        groupRepository.$groupProfileImage
            .assign(to: \.groupProfileImage, on: self)
            .store(in: &cancellables)
        groupRepository.$countdowns
            .assign(to: \.countdowns, on: self)
            .store(in: &cancellables)
        groupRepository.$activeUsers
            .assign(to: \.activeUsers, on: self)
            .store(in: &cancellables)
        groupRepository.$followers
            .assign(to: \.followers, on: self)
            .store(in: &cancellables)

     
     
     
        
            
    }
    

    
    
    func addToGroupStory(groupID: String, post: UIImage, creator: String){
        groupRepository.addToGroupStory(groupID: groupID, post: post, creator: creator)
    }
    
    
    
 
    
    func seeStory(groupID: String, storyID: String, userID: String){
        groupRepository.seeStory(groupID: groupID, storyID: storyID, userID: userID)
    }
  
    
    func loadGroupFollowers(groupID: String){
        groupRepository.loadGroupFollowers(groupID: groupID)
    }
    
    func loadActiveUsers(group: Group){
        groupRepository.loadActiveUsers(group: group)
    }
    
  
    
    func changeMOTD(motd: String, groupID: String, userID: String){
        groupRepository.changeMOTD(motd: motd, groupID: groupID, userID: userID)
        
    }
    
    func getUsersProfilePictures(groupID: String){
        groupRepository.getUsersProfilePictures(groupID: groupID)
    }
    
    func getChat(chatID: String){
        groupRepository.getChat(chatID: chatID)
    }
    
   
    
    func setupUserVM(userVM: UserViewModel){
        self.userVM = userVM
    }
    
    
    func joinGroup(groupID: String, username: String){
        
        groupRepository.joinGroup(groupID: groupID, username: username)
        
        
    }
    
    
    
    
    func leaveGroup(group: Group, user: User){
        
        groupRepository.leaveGroup(group: group, user: user)
        
        
    }
    
    
    
    func createGroup(groupName: String, memberLimit: Int, dateCreated: Date, users: [String], image: UIImage, currentUser: String, id: String, password: String){
        
        groupRepository.createGroup(groupName: groupName, memberLimit: memberLimit, dateCreated: dateCreated, users: users, image: image, currentUser: currentUser, id: id, password: password)
        
    }
    func createGroup(currentUser: String, groupName: String, memberLimit: Int, dateCreated: Date, users: [String], image: UIImage, completion: @escaping (ChatModel) -> ()) -> (){
        
        groupRepository.createGroup(currentUser: currentUser, groupName: groupName, memberLimit: memberLimit, dateCreated: dateCreated, users: users, image: image) { chat in
            return completion(chat)
        }
        
    }
    
    func isInGroup(user1: User, group: Group, completion: @escaping (Bool) -> () ) -> (){
        groupRepository.isInGroup(user1: user1, group: group) { isInGroup in
            return completion(isInGroup)
        }
    }
    
    func changeBio(bio: String, groupID: String, userID: String){
        groupRepository.changeBio(bio: bio, groupID: groupID, userID: userID)
    }
    
    
    func createCountdown(group: Group, countdownName: String, startDate: Timestamp, endDate: Date, user: User){

        groupRepository.createCountdown(group: group, countdownName: countdownName, startDate: startDate, endDate: endDate, user: user)
    }
    func giveBadge(group: Group, badge: Badge){
        groupRepository.giveBadge(group: group, badge: badge)
    }
    
    
    
  

    
}







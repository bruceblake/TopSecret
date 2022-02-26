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
    @Published var galleryPosts : [GalleryPostModel] = []


    
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
        groupRepository.$galleryPosts
            .assign(to: \.galleryPosts, on: self)
            .store(in: &cancellables)
     
     
     
        
            
    }
    
    func fetchGroupGalleryPosts(groupID: String){
        groupRepository.fetchGroupGalleryPosts(groupID: groupID)
    }
    
    
    func addToGroupStory(groupID: String, post: Binding<UIImage>, creator: String){
        groupRepository.addToGroupStory(groupID: groupID, post: $post, creator: creator)
    }
    
    
    
    func createGalleryPost(groupID: String, posts: [UIImage], description: String, creator: String, isPrivate: Bool, taggedUsers: [String]){
        groupRepository.createGalleryPost(groupID: groupID, posts: posts, description: description, creator: creator, isPrivate: isPrivate, taggedUsers: taggedUsers)
    }
    
    func seeStory(groupID: String, storyID: String, userID: String){
        groupRepository.seeStory(groupID: groupID, storyID: storyID, userID: userID)
    }
    
    func deleteGalleryPost(galleryPostID: String, groupID: String){
        groupRepository.deleteGalleryPost(galleryPostID: galleryPostID, groupID: groupID)
    }
    
    func loadGroupFollowers(groupID: String){
        groupRepository.loadGroupFollowers(groupID: groupID)
    }
    
    func loadActiveUsers(group: Group){
        groupRepository.loadActiveUsers(group: group)
    }
    
    func loadGroupCountdowns(group: Group){
        groupRepository.loadGroupCountdowns(group: group)
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
    
    func inviteToGroup(user1: User, user2: User, group: Group){
        groupRepository.inviteToGroup(user1: user1, user2: user2, group: group)
    }
    
    
    
    func leaveGroup(groupID: String, userID: String){
        
        groupRepository.leaveGroup(groupID: groupID, userID: userID)
        
        
    }
    
    
    
    func createGroup(groupName: String, memberLimit: Int, dateCreated: Date, users: [String], image: UIImage, currentUser: String){
        
        groupRepository.createGroup(groupName: groupName, memberLimit: memberLimit, dateCreated: dateCreated, users: users, image: image, currentUser: currentUser)
        
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
    
    
    func createCountdown(group: Group, countdownName: String, startDate: Timestamp, endDate: Date){

        groupRepository.createCountdown(group: group, countdownName: countdownName, startDate: startDate, endDate: endDate)
    }
    func giveBadge(group: Group, badge: Badge){
        groupRepository.giveBadge(group: group, badge: badge)
    }
    
    
    
  

    
}







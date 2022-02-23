//
//  UserViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/9/21.
//

import Foundation
import Firebase
import SwiftUI
import Combine


class UserViewModel : ObservableObject {
    

    @Published var user : User?
    @Published var userSession : FirebaseAuth.User?
    @Published var userRepository = UserRepository()
    @Published var loginErrorMessage = ""
    @Published var email = ""
    @Published var username = ""
    @Published var nickName = ""
    @Published var password = ""
    @Published var birthday = Date()
    @Published var userProfileImage : UIImage = UIImage()
    @Published var groups: [Group] = []
    @Published var groupChats: [ChatModel] = []
    @Published var personalChats: [ChatModel] = []
    @Published var polls: [PollModel] = []
    @Published var events: [EventModel] = []
    @Published var isConnected : Bool = false
    @Published var firestoreListener : [ListenerRegistration] = []
    @Published var notifications : [NotificationModel] = []
    @Published var followedGroups : [Group] = []
    @Published var userNotificationCount : Int = 0
    @Published var groupNotificationCount : [[String:Int]] = []
    @Published var pollDurationTimer : Int = 0
    @Published var countdownDurationTimer : Int = 0
    @Published var timeToFetchPolls: Int = 0
    @Published var showNotification : Int = 0 //on value change, send notification
    @Published var currentNotification : NotificationModel?
    @Published var homescreenPosts : ([EventModel],[PollModel],[GalleryPostModel]) = ([],[],[])




    
    private var cancellables : Set<AnyCancellable> = []
    
    init(){
        userRepository.$user
            .assign(to: \.user, on: self)
            .store(in: &cancellables)
        userRepository.$userSession
            .assign(to: \.userSession, on: self)
            .store(in: &cancellables)
        userRepository.$groups
            .assign(to: \.groups, on: self)
            .store(in: &cancellables)
        userRepository.$groupChats
            .assign(to: \.groupChats, on: self)
            .store(in: &cancellables)
        userRepository.$polls
            .assign(to: \.polls, on: self)
            .store(in: &cancellables)
        userRepository.$events
            .assign(to: \.events, on: self)
            .store(in: &cancellables)
        userRepository.$isConnected
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
        userRepository.$loginErrorMessage
            .assign(to: \.loginErrorMessage, on: self)
            .store(in: &cancellables)
        userRepository.$firestoreListener
            .assign(to: \.firestoreListener, on: self)
            .store(in: &cancellables)
        userRepository.$personalChats
            .assign(to: \.personalChats, on: self)
            .store(in: &cancellables)
        userRepository.$userNotificationCount
            .assign(to: \.userNotificationCount, on: self)
            .store(in: &cancellables)
        userRepository.$groupNotificationCount
            .assign(to: \.groupNotificationCount, on: self)
            .store(in: &cancellables)
        userRepository.$notifications
            .assign(to: \.notifications, on: self)
            .store(in: &cancellables)
        userRepository.$showNotification
            .assign(to: \.showNotification, on: self)
            .store(in: &cancellables)
        userRepository.$currentNotification
            .assign(to: \.currentNotification, on: self)
            .store(in: &cancellables)
        userRepository.$followedGroups
            .assign(to: \.followedGroups, on: self)
            .store(in: &cancellables)
        userRepository.$homescreenPosts
            .assign(to: \.homescreenPosts, on: self)
            .store(in: &cancellables)
        
        
     
    }
    
    func setUserActivity(isActive: Bool, userID: String, completion: @escaping (User) -> ()) -> (){
        userRepository.setUserActivity(isActive: isActive, userID: userID, completion: { user in
            return completion(user)
        })
    }
    
    func fetchUserChats(){
        userRepository.fetchUserChats()
    }
    
    func fetchUserGroups() {
        userRepository.fetchUserGroups()
    }
    
    func fetchUserPolls() {
        userRepository.fetchUserPolls()
    }
    
    func fetchAll(){
        userRepository.fetchAll()
    }
    
    func listenToUserGroups(){
        userRepository.listenToUserGroups(uid: userSession!.uid)
    }
    func listenToUserChats(){
        userRepository.listenToUserChats(uid: userSession!.uid)
    }
    
    func listenToUserPolls(){
        userRepository.listenToUserPolls(uid: userSession!.uid)
    }
    func listenToUserEvents(){
        userRepository.listenToUserEvents(uid: userSession!.uid)
    }
    
    func listenToUserFriends(){
        userRepository.listenToUserFriends(uid: userSession!.uid)
    }
    func listenToNetworkChanges(){
        userRepository.listenToNetworkChanges(uid: userSession!.uid)
    }
    func listenToAll(uid: String){
        userRepository.listenToAll(uid: uid)
    }
    
    func createUser(email: String, password: String, username: String, nickName: String, birthday: Date,image: UIImage){
        userRepository.createUser(email: email, password: password, username: username, nickName: nickName, birthday: birthday, image: image)
    }
    
    func resetPassword(email: String){
        userRepository.resetPassword(email: email)
    }
    
    
    func signIn(withEmail email: String, password: String){
        
        userRepository.signIn(withEmail: email, password: password)
        
    }
    
    func signOut(){
        userRepository.signOut()
    }
    
    func fetchUser(){
        userRepository.fetchUser()
    }
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> (){
        userRepository.fetchUser(userID: userID, completion: { user in
            return completion(user)
        })
    }
    
    func fetchGroup(groupID: String, completion: @escaping (Group) -> ()) -> (){
        userRepository.fetchGroup(groupID: groupID) { fetchedGroup in
            return completion(fetchedGroup)
        }
    }
    
    func fetchGroupBadges(groupID: String, completion: @escaping ([Badge]) -> ()) -> () {
        userRepository.fetchGroupBadges(groupID: groupID) { fetchedBadges in
            return completion(fetchedBadges)
        }
    }
    
    
  
    
    func getUserFriendsList(user: User, completion: @escaping ([User]) -> () ) -> (){
        let friendsList = user.friendsList ?? []
        if !friendsList.isEmpty{
           COLLECTION_USER.whereField("uid", in: user.friendsList ?? [" "]).addSnapshotListener{ (snapshot, err) in
                if err != nil {
                    print("ERROR")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No documents!")
                    return
                    
                }
            
          
                return completion(documents.map { (queryDocumentSnapshot) -> User in
                    let data = queryDocumentSnapshot.data()
                    return User(dictionary: data)
                })
                
                
                
            }
            
       


        }else{
            print("User has no friends!")
        }
     
        
    }
    
   
   
    
  
    
    func persistImageToStorage(userID: String, image: UIImage){
        userRepository.persistImageToStorage(userID: userID, image: image)
    }
    
    func addFriend(user: User, friendID: String){
        userRepository.addFriend(friendID: friendID, user: user)
    }
    
    func declineFriendRequest(friendID: String, user: User){
        userRepository.declineFriendRequest(friendID: friendID, user: user)
    }
    
    func removeFriend(userID: String, friendID: String){
        userRepository.removeFriend(friendID: friendID, userID: userID)
    }
    
    func changeBio(userID: String, bio: String){
        userRepository.changeBio(userID: userID, bio: bio)
    }
    
    func getRemainingTime(startDate: Date, countdownTime: Int, currentDate: Date) -> Int {
        
        //converting startDate to seconds
        let startDateComponents = Calendar.current.dateComponents([.day,.hour, .minute,.second], from: startDate)
        let startDay = startDateComponents.day ?? 0
        let startHour = startDateComponents.hour ?? 0
        let startMinute = startDateComponents.minute ?? 0
        let startSecond = startDateComponents.second ?? 0

        let totalStartSeconds = ((startDay * 86400) + (startHour * 3600) + (startMinute * 60) + startSecond)
        
        
        //converting currentDate to seconds
        let currentDateComponents = Calendar.current.dateComponents([.day,.hour, .minute,.second], from: currentDate)
        let currentDay = currentDateComponents.day ?? 0
        let currentHour = currentDateComponents.hour ?? 0
        let currentMinute = currentDateComponents.minute ?? 0
        let currentSecond = currentDateComponents.second ?? 0

        let totalCurrentSeconds = ((currentDay * 86400) + (currentHour * 3600) + (currentMinute * 60) + currentSecond)
        
        
        let secondsPassed = totalCurrentSeconds - totalStartSeconds
        
        
        return countdownTime - secondsPassed

    }
    
    
    func blockUser(blocker: String, blockee: String){
        userRepository.blockUser(blocker: blocker, blockee: blockee)
    }
    func changeNickname(userID: String, nickName: String){
        userRepository.changeNickname(userID: userID, nickName: nickName)
    }
    func changeUsername(userID: String, username: String){
        userRepository.changeUsername(userID: userID, username: username)
    }
    
    func readAllUserNotifications(uid: String){
        userRepository.readAllUserNotifications(uid: uid)
    }
    
    func readAllGroupNotifications(uid: String, group: Group){
        userRepository.readAllGroupNotifications(uid: uid, group: group)
    }
    
    func getPersonalChat(user1: User, user2: String, completion: @escaping (ChatModel) -> ()) -> (){
        userRepository.getPersonalChat(user1: user1, user2: user2) { chat in
            return completion(chat)
        }
    }
    
    func followGroup(group: Group, user: User){
        userRepository.followGroup(group: group, user: user)
    }
    
    func unFollowGroup(group: Group, user: User){
        userRepository.unFollowGroup(group: group, user: user)
    }
    
    func isFollowingGroup(user: User, group: Group, completion: @escaping (Bool) -> () ) -> () {
        userRepository.isFollowingGroup(user: user, group: group, completion: { isFollowing in
            return completion(isFollowing)
        })
    }
  
}

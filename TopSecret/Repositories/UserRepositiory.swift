//
//  UserRepositiory.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/9/21.
//

import Foundation
import Firebase
import Combine
import SwiftUI
import SCSDKLoginKit

class UserRepository : ObservableObject {
    
    @Published var user : User?
    @Published var loginErrorMessage = ""
    @Published var userSession : FirebaseAuth.User?
    @Published var profilePicture : UIImage = UIImage()
    @Published var groups: [Group] = []
    @Published var groupChats: [ChatModel] = []
    @Published var polls: [PollModel] = []
    @Published var events: [EventModel] = []
    @Published var personalChats: [ChatModel] = []
    @Published var notifications : [NotificationModel] = []
    @Published var homescreenPosts : [String:String] = [" ":" "] //postType, id
    @Published var homescreenGalleryPosts: [GalleryPostModel] = []
    @Published var followedGroups : [Group] = []
    @Published var allUserGroups : [Group] = []
    @Published var isConnected : Bool = false
    @Published var firestoreListener : [ListenerRegistration] = []
    @Published var userNotificationCount : Int = 0
    @Published var groupNotificationCount : [[String:Int]] = []
    @Published var currentNotification : NotificationModel?
    @Published var showNotification : Int = 0 //on value change, send notification
    @Published var userSelectedGroup : Group = Group()
    @Published var finishedFetchingGroups : Bool = false
    
    private var cancellables : Set<AnyCancellable> = []
    let store = Firestore.firestore()
    let path = "Users"
    
    static var shared = UserViewModel()
   
    

    
    func readUserNotification(userNotification: UserNotificationModel, userID: String){
        COLLECTION_USER.document(userID).collection("Notifications").document(userNotification.id).updateData(["hasSeen":true])
        COLLECTION_USER.document(userID).updateData(["userNotificationCount":0])
    }
    
    func changeUserSelectedGroup(groupID: String, userID: String){
        COLLECTION_USER.document(userID).updateData(["selectedGroup":groupID])
        self.fetchUser(userID: userID) { fetchedUser in
            self.user = fetchedUser
        }
    }
    
    func setUserActivity(isActive: Bool, userID: String, completion: @escaping (User) ->()) -> (){
        COLLECTION_USER.document(userID).updateData(["isActive":isActive])
        if !isActive{
            COLLECTION_USER.document(userID).updateData(["lastActive":Timestamp()])
        }
       
       
        COLLECTION_USER.document(userID).getDocument(completion: { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(User(dictionary: data ?? [:] ))
            
        })
       
       
    }
    
    
    
    func readAllUserNotifications(uid: String){
        COLLECTION_USER.document(uid).updateData(["userNotificationCount":0])
        self.userNotificationCount = 0
    }
    
    func readAllGroupNotifications(uid: String, group: Group){
        COLLECTION_USER.document(uid).updateData(["groupNotificationCount":FieldValue.arrayUnion([[group.id:0]])])
        
    }
    
    func persistImageToStorage(userID: String, image: UIImage) {
        let fileName = "userProfileImages/\(userID)"
        let ref = Storage.storage().reference(withPath: fileName)
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
                COLLECTION_USER.document(userID).updateData(["profilePicture":imageURL])
                self.fetchUser()
            }
        }
        
    }
    

    
    func listenToUserFollowedGroups(uid: String){
        let listener = COLLECTION_USER.document(uid).addSnapshotListener{ (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            let followedGroups = snapshot?.get("followedGroups") as? [String] ?? []
            self.followedGroups.removeAll()
            for followedGroup in followedGroups {
                COLLECTION_GROUP.document(followedGroup).getDocument{ (snapshot, err) in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    let data = snapshot!.data()
                    
                    self.followedGroups.append(Group(dictionary: data ?? [:]))
                    
                }
            }
 
            
            
            

        }
        
        firestoreListener.append(listener)

        

    }

    func listenToUser(uid: String){
        let listener =  COLLECTION_USER.document(uid).addSnapshotListener { (snapshot, err) in
            if err != nil {
                print("ERROR - User Not Being Fetched")
                return
            }
            

            
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
        
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            //fetch user friends list
            self.fetchUserFriendsList(friendsList: data["friendsList"] as? [String] ?? []) { fetchedFriends in
                data["friendsList"] = fetchedFriends
                groupD.leave()
            }
            
            groupD.enter()
            
            //fetch user notifications
            self.fetchUserNotifications(userID: data["uid"] as? String ?? " ") { fetchedNotifications in
                data["notifications"] = fetchedNotifications
                groupD.leave()
            }
            
            
            groupD.notify(queue: .main, execute:{
                self.user = User(dictionary: data)
            })
            
            
            
        }
        
        firestoreListener.append(listener)
        
    }
    
    
    func fetchUserNotifications(userID: String, completion: @escaping ([UserNotificationModel]) -> ()) -> () {
        
        var notificationsToReturn : [UserNotificationModel] = []
        COLLECTION_USER.document(userID).collection("Notifications").order(by: "notificationTime", descending: true).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            for document in documents {
                var data = document.data() as? [String:Any] ?? [:]
                let notificationType = data["notificationType"] as? String ?? ""
                let notificationGroupID = data["groupID"] as? String ?? ""
                groupD.enter()
                
                self.fetchUserNotificationCreator(notificationCreatorType: notificationType, notificationCreatorID: data["notificationCreatorID"] as! String) { fetchedCreator in
                    data["notificationCreator"] = fetchedCreator
                    groupD.leave()
                
                }
                
                
                
                groupD.enter()
                
                self.fetchUserNotificationGroup(notificationGroupID: notificationGroupID){ fetchedGroup in
                    data["group"] = fetchedGroup
                    groupD.leave()
                }
                
                groupD.enter()
                
                self.fetchUserNotificationAction(notificationType: notificationType, groupID: notificationGroupID, userID: userID,notificationActionID: data["actionTypeID"] as? String ?? " "){ fetchedAction in
                    data["actionType"] = fetchedAction
                    groupD.leave()
                }
                
                
                
                groupD.notify(queue: .main, execute: {
                    notificationsToReturn.append(UserNotificationModel(dictionary: data))
                } )
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(notificationsToReturn)
            })
            
        }
    }
    
    func fetchUserNotificationAction(notificationType: String, groupID: String, userID: String, notificationActionID: String, completion: @escaping (Any) -> ()) -> (){
        switch notificationType {
            case "eventCreated":
            COLLECTION_GROUP.document(groupID).collection("Events").document(notificationActionID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                var data = snapshot?.data() as? [String:Any] ?? [:]
                
                let dp = DispatchGroup()
                
                dp.enter()
                self.fetchEventUsersAttending(usersAttendingID: data["usersAttendingID"] as? [String] ?? [], eventID: notificationActionID, groupID: groupID) { fetchedUsers in
                    data["usersAttending"] = fetchedUsers
                    dp.leave()
                }
                
                dp.notify(queue: .main, execute:{
                    return completion(EventModel(dictionary: data))
                })
            }
            
        default: break
            
        }
    }
    
    
    func fetchEventUsersAttending(usersAttendingID: [String], eventID: String , groupID: String, completion: @escaping ([User]) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).getDocument { snapshot, err in
            
            if err != nil {
                print("ERROR")
                return
            }
            var usersToReturn : [User] = []
            
            
            let groupD = DispatchGroup()
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            let users = data["usersAttendingID"] as? [String] ?? []
            
            for user in users {
                groupD.enter()
                COLLECTION_USER.document(user).getDocument { userSnapshot, err in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    let userData = userSnapshot?.data() as? [String:Any] ?? [:]
                    
                    usersToReturn.append(User(dictionary: userData))
                    groupD.leave()
                }
            }
            
            groupD.notify(queue: .main, execute: {
                return completion(usersToReturn)
            })
            
        }
        
        
    }
    
    
    func fetchUserNotificationGroup(notificationGroupID: String, completion: @escaping (Group) ->()) -> () {
        
        COLLECTION_GROUP.document(notificationGroupID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(Group(dictionary: data))
            
        }
    }
    
    func fetchUserNotificationCreator(notificationCreatorType: String, notificationCreatorID: String, completion: @escaping (Any) -> ()) -> (){
        
        if notificationCreatorType == "eventCreated"{
            COLLECTION_USER.document(notificationCreatorID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                return completion(User(dictionary: data))
                
            }
        }
    }
    

 
 
    
   

    func fetchGroupBadges(groupID: String, completion: @escaping ([Badge]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("Badges").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            return completion(documents.map({ queryDocumentSnapshot -> Badge in
                let data = queryDocumentSnapshot.data()
                return Badge(dictionary: data)
            }))
            
            
        }
    }
 
    func fetchGroupPolls(groupID: String, completion: @escaping ([PollModel]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("Polls").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            return completion(documents.map({ queryDocumentSnapshot -> PollModel in
                let data = queryDocumentSnapshot.data()
                
                return PollModel(dictionary: data)
            }))
        }
    }
    
    

  
    func fetchGroupStories(groupID: String, completion: @escaping ([StoryModel]) -> ()){
        
        
        COLLECTION_GROUP.document(groupID).collection("Story").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            return completion(snapshot!.documents.map({ queryDocumentSnapshot -> StoryModel in
                let data = queryDocumentSnapshot.data()
                
                return StoryModel(dictionary: data)
            }))
            
        }
        
       
    }
    
    func fetchGroupUnreadNotifications(userID: String, groupID: String, completion: @escaping ([GroupNotificationModel]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("Notifications").getDocuments { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents.filter({ (($0.get("usersThatHaveSeen") as? [String] ?? []).contains(userID) == false)})
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> GroupNotificationModel in
                let data = queryDocumentSnapshot.data()
                
                return GroupNotificationModel(dictionary: data)
            }))
            
        }
    }
    
    func fetchGroupNotificationCreator(notificationCreatorID: String, completion: @escaping (User) -> ()) -> (){
        
        COLLECTION_USER.document(notificationCreatorID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
            
        }
        
    }
    
    func fetchGroupNotifications(groupID: String, completion: @escaping ([GroupNotificationModel]) -> ()) -> () {
        
        
        var notificationsToReturn : [GroupNotificationModel] = []
        COLLECTION_GROUP.document(groupID).collection("Notifications").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                
                
                groupD.enter()
                
                self.fetchGroupNotificationCreator(notificationCreatorID: data["notificationCreatorID"] as? String ?? " ") { fetchedUser in
                    data["notificationCreator"] = fetchedUser
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    notificationsToReturn.append(GroupNotificationModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(notificationsToReturn)
            })
            
            
          
            
        }
    }
    
    func listenToUserGroups(uid: String){
        
        let listener = COLLECTION_GROUP.whereField("users", arrayContains: uid).addSnapshotListener { (snapshot, err) in
            

            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            var groupsToReturn : [Group] = []

            //fetching notifications
            
            
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            for document in documents {
                groupD.enter()
                var data = document.data()
                self.fetchGroupNotifications(groupID: document.documentID) { fetchedNotifications in
                    data["groupNotifications"] = fetchedNotifications
                    groupD.leave()
                }
                
                groupD.enter()
                
                self.fetchGroupUnreadNotifications(userID: uid, groupID: data["id"] as? String ?? " ") { fetchedUnreadNotifications in
                    data["unreadGroupNotifications"] = fetchedUnreadNotifications
                    groupD.leave()
                }
                    
                groupD.notify(queue: .main, execute: {
                    groupsToReturn.append(Group(dictionary: data))
                })
                    
                }
            
            groupD.leave()
    
            
            groupD.notify(queue: .main, execute: {
                self.groups = groupsToReturn
                self.finishedFetchingGroups = true
            })
            
            }
            
            
            
            
    
        firestoreListener.append(listener)

            
        }
 
 


    func listenToNetworkChanges(uid: String){
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                self.isConnected = true
                print("You are connected!")
            }else{
                self.isConnected = false
                print("You are not connected!")
            }
        })
    }
    
    func listenToPersonalChats(uid: String){
        COLLECTION_PERSONAL_CHAT.whereField("users", arrayContains: uid).addSnapshotListener { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.personalChats = documents.map({ (snapshot) -> ChatModel in
                let data = snapshot.data()
                return ChatModel(dictionary: data)
            })
            
        }
    }
    func listenToAll(uid: String){
        self.listenToUserGroups(uid: uid)
        self.listenToUser(uid: uid)
        self.listenToNetworkChanges(uid: uid)
        self.listenToPersonalChats(uid: uid)

        
    }
    

    func fetchUserGroups(){
        //TODO
        COLLECTION_GROUP.whereField("users", arrayContains: user?.id ?? "").getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.groups = documents.map{ queryDocumentSnapshot -> Group in
                let data = queryDocumentSnapshot.data() as? [String:Any] ?? [:]
      
                
                
                
                return Group(dictionary: data)
                
            }
            
            print("Fetched User Groups!")
            
            
        }
    }
   
   
    func fetchAll(){
        fetchUserGroups()
    }
    func createUser(email: String, password: String, username: String, nickName: String, birthday: Date, image:UIImage){
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if let err = err{
                print("DEBUG: ERROR: \(err.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {return}
            
            let data = ["email": email,
                        "username": username,
                        "nickName": nickName,
                        "uid": user.uid,
                        "birthday": birthday,"profilePicture":"", "bio":"","isActive":true
                        
            ] as [String : Any]
            
            COLLECTION_USER.document(user.uid).setData(data)
            
            
            self.persistImageToStorage(userID: user.uid, image: image)
            
            print("DEBUG: Succesfully uploaded user data!")
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.userSession = user
                self.fetchUser()
                self.listenToAll(uid: user.uid)
            }
            Auth.auth().currentUser?.sendEmailVerification(completion: { (err) in
                
            })
            
            
        }
    }
    func signIn(withEmail email: String, password: String, completion: @escaping (User) -> ()) -> (){
        
        Auth.auth().signIn(withEmail: email, password: password) { [self] (result,err) in
            
            if let x = err {
                let error = x as NSError
                switch error.code {
                case AuthErrorCode.networkError.rawValue:
                    loginErrorMessage = "There was a network error"
                case AuthErrorCode.internalError.rawValue:
                    loginErrorMessage = "There was an internal error"
                case AuthErrorCode.invalidEmail.rawValue:
                    loginErrorMessage = "This email address is invalid"
                case AuthErrorCode.missingEmail.rawValue:
                    loginErrorMessage = "You must include an email address"
                case AuthErrorCode.rejectedCredential.rawValue:
                    loginErrorMessage = "The email or password is incorrect"
                    
                default:
                    loginErrorMessage = "There was an error, try again later"
                }
            }
            
      
            
           
            
            
            self.userSession = result?.user
            self.listenToAll(uid: userSession?.uid ?? " ")
            self.fetchUser(userID: userSession?.uid ?? " ") { fetchedUser in
                return completion(fetchedUser)
            }
            
        }
        
    }
    func signOut(){
        
        for listener in firestoreListener  {
            listener.remove()
            print("Removed listener!")
        }
        
        userSession = nil
        self.loginErrorMessage = ""
        try? Auth.auth().signOut()
        homescreenPosts.removeAll()
    }
    func fetchUser(){
        
        guard let uid = userSession?.uid else {return}
        
        store.collection(path).document(uid).getDocument { (snapshot, _) in
            guard let data = snapshot?.data() else {return}
            let user = User(dictionary: data)
          
            self.user = user
            
        }
    }
    func resetPassword(email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
        }
    }
    func addFriend(friendID: String, user: User){
        COLLECTION_USER.document(user.id ?? " ").updateData(["pendingFriendsList":FieldValue.arrayRemove([friendID])])
        
        COLLECTION_USER.document(user.id ?? " ").updateData(["friendsList":FieldValue.arrayUnion([friendID])])
        COLLECTION_USER.document(friendID).updateData(["friendsList":FieldValue.arrayUnion([user.id ?? ""])])
        
       
        
        
    }
    
    func declineFriendRequest(friendID: String, user: User){
        
        COLLECTION_USER.document(user.id ?? " ").updateData(["pendingFriendsList":FieldValue.arrayRemove([friendID])])
        
       
    }
    
    
    func removeFriend(friendID: String, userID: String){
        COLLECTION_USER.document(userID).updateData(["pendingFriendsList":FieldValue.arrayRemove([friendID])])
        
        COLLECTION_USER.document(userID).updateData(["friendsList":FieldValue.arrayRemove([friendID])])
        COLLECTION_USER.document(friendID).updateData(["friendsList":FieldValue.arrayRemove([userID])])
        
        
    }
    func changeBio(userID: String, bio: String){
        COLLECTION_USER.document(userID).updateData(["bio":bio])
    }
    
    func changeNickname(userID: String, nickName: String){
        COLLECTION_USER.document(userID).updateData(["nickName":nickName])
    }
    
    func changeUsername(userID: String, username: String){
        COLLECTION_USER.document(userID).updateData(["username":username])
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
        
        print("Remaining Time: \(countdownTime - secondsPassed)")
        
        return countdownTime - secondsPassed
        
    }
    
    
    func blockUser(blocker: String, blockee: String){
        COLLECTION_USER.document(blocker).updateData(["blockedAccounts":FieldValue.arrayUnion([blockee])])
        COLLECTION_USER.document(blockee).updateData(["blockedAccounts":FieldValue.arrayUnion([blocker])])
        print("\(blocker) blocked \(blockee)")
    }
    
    func getPersonalChat(user1: User, user2: String, completion: @escaping (ChatModel) -> ()) -> (){
        COLLECTION_PERSONAL_CHAT.whereField("users", isEqualTo: [user1.id ?? "", user2]).getDocuments { (snapshot1, err1) in
            if err1 != nil {
                print("ERROR")
                return
            }
            
            if snapshot1!.isEmpty {
                COLLECTION_PERSONAL_CHAT.whereField("users", isEqualTo: [user2,user1.id ?? ""]).getDocuments { (snapshot2, err2) in
                    if err2 != nil {
                        print("ERROR")
                        return
                    }
                    
                    for document in snapshot2!.documents {
                        let data = document.data()
                        
                        return completion(ChatModel(dictionary: data))
                    }
                    
                }
            }else{
                for document in snapshot1!.documents {
                    let data = document.data()
                    
                    return completion(ChatModel(dictionary: data))
                }
            }
            
            
           
            
        }
    }
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
           
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            self.fetchUserFriendsList(friendsList: data["friendsList"] as? [String] ?? []) { fetchedFriends in
                data["friendsList"] = fetchedFriends
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute:{
                return completion(User(dictionary: data))
            })
            
           
        }
    }
    
    func fetchUserFriendsList(friendsList: [String], completion: @escaping ([User]) -> ()) -> (){
        var users : [User] = []
        
        var groupD = DispatchGroup()
        
        
        
        for userID in friendsList {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                users.append(User(dictionary: data))
                groupD.leave()
                
            }
        }
        
        groupD.notify(queue: .main, execute: {
            return completion(users)
        })
        
    }
    
    func fetchChat(chatID: String, completion: @escaping (ChatModel) -> ()) -> (){
        COLLECTION_CHAT.document(chatID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            return completion(ChatModel(dictionary: data ?? [:]))
            
        }
    }
    
    
    
    func fetchGroup(groupID: String, completion: @escaping (Group) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(Group(dictionary: data ?? [:]))
            
        }
    }
    
    
    func followGroup(group: Group, user: User){
        COLLECTION_USER.document(user.id ?? " ").updateData(["followedGroups":FieldValue.arrayUnion([group.id])])
        COLLECTION_GROUP.document(group.id).updateData(["followers":FieldValue.arrayUnion([user.id ?? ""])])
        COLLECTION_USER.document(user.id ?? " ").updateData(["allGroupsToListenTo":FieldValue.arrayUnion([group.id])])

        print("Followed Group: \(group.groupName)!")
    }
    
    func unFollowGroup(group: Group, user: User){
        COLLECTION_USER.document(user.id ?? " ").updateData(["followedGroups":FieldValue.arrayRemove([group.id])])
        COLLECTION_GROUP.document(group.id).updateData(["followers":FieldValue.arrayRemove([user.id ?? ""])])
        COLLECTION_USER.document(user.id ?? " ").updateData(["allGroupsToListenTo":FieldValue.arrayRemove([group.id])])

        
        print("Unfollowed Group: \(group.groupName)!")
    }
    
    func isFollowingGroup(user: User, group: Group, completion: @escaping (Bool) -> () ) -> (){
   
        COLLECTION_USER.document(user.id ?? " ").getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            let followedGroups = snapshot?.get("followedGroups") as? [String] ?? []
            
            for followedGroup in followedGroups {
                return completion(followedGroup == group.id)
            }
        }
    }
    

    
    
    func addFriend(friend: User){
        
        
        
        
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["friendsList":FieldValue.arrayUnion([friend.id ?? " "])])
        
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["friendsList":FieldValue.arrayUnion([user?.id ?? " "])])
        
        
    }

}

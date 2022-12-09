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
import SCSDKLoginKit

class UserViewModel : ObservableObject {
    
    
    let notificationSender = PushNotificationSender()
    //firebase
    @Published var userSession : FirebaseAuth.User?
    @Published var isConnected : Bool = false
    @Published var firestoreListener : [ListenerRegistration] = []
    
    @Published var user : User?
    @Published var loginErrorMessage = ""
    
    @Published var groups: [Group] = []
    @Published var personalChats: [ChatModel] = []
    @Published var notifications : [UserNotificationModel] = []
    @Published var feed : [Any] = []
    
    
    @Published var userNotificationCount : Int = 0
    @Published var showNotification : Int = 0 //on value change, send notification
    @Published var fcmToken : String?
    @Published var hideTabButtons : Bool = false
    @Published var showAddContent : Bool = false
    @Published var finishedFetchingGroups : Bool = false
    @Published var timedOut : Bool = false
    @Published var startFetch : Bool = false
    @Published var showWarning: Bool = false
    @Published var hasUnreadMessages : Bool = false
    
    
    static let shared = UserViewModel()
    
    
    
    let store = Firestore.firestore()
    let path = "Users"
    
    
    private var cancellables : Set<AnyCancellable> = []
    
    init(){
        
        
        //please work
        let dp = DispatchGroup()
        dp.enter()
        self.removeListeners()
        self.userSession = Auth.auth().currentUser
        dp.leave()
        dp.notify(queue: .main, execute: {
            self.listenToAll(uid: self.userSession?.uid ?? " ")
        })
        
    }
    
    func followGroup(groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["followersID":FieldValue.arrayUnion([userID])])
        COLLECTION_USER.document(userID).updateData(["groupsFollowingID":FieldValue.arrayUnion([groupID])])
    }
    
    func unfollowGroup(groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["followersID":FieldValue.arrayRemove([userID])])
        COLLECTION_USER.document(userID).updateData(["groupsFollowingID":FieldValue.arrayRemove([groupID])])
    }
    
    
    
    func refresh(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !self.finishedFetchingGroups && !self.timedOut{
                self.timedOut = true
                self.startFetch = false
            }
        }
    }
    
    //listeners
    
    
    func getTotalNotifications(userID: String) -> Int {
        var sum = 0
        for chat in self.personalChats{
            if !(chat.usersThatHaveSeenLastMessage?.contains(userID) ?? false ){
                sum += 1
            }
        }
        return sum
    }
    
    func fetchGroup(groupID: String, completion: @escaping (Group) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(Group(dictionary: data))
        }
    }
    
    func fetchMedia(urlPath: String, completion: @escaping (UIImage) -> ()) -> (){
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(urlPath)
        
        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
            if err != nil {
                print("ERROR")
            }
            
            if let image = UIImage(data: data!){
                return completion(image)
            }
        }
    }
    
    func listenToFeed(){
        self.firestoreListener.append(
            COLLECTION_POSTS.addSnapshotListener({ snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                var feedToReturn : [Any] = []
                
                let groupD = DispatchGroup()
                
                
                let documents = snapshot!.documents
                
                groupD.enter()
                for document in documents{
                    var data = document.data() as? [String:Any] ?? [:]
                    var creatorID = data["creatorID"] as? String ?? " "
                    var groupID = data["groupID"] as? String ?? " "
                    var urlPath = data["urlPath"] as? String ?? ""
                    groupD.enter()
                    self.fetchUser(userID: creatorID) { fetchedUser in
                        data["creator"] = fetchedUser
                        groupD.leave()
                    }
                    
                    groupD.enter()
                    self.fetchGroup(groupID: groupID) { fetchedGroup in
                        data["group"] = fetchedGroup
                        groupD.leave()
                    }
                    
                    groupD.enter()
                    self.fetchMedia(urlPath: urlPath) { fetchedImage in
                        data["image"] = fetchedImage
                        groupD.leave()
                    }
                    
                    groupD.notify(queue: .main, execute:{
                        feedToReturn.append(GroupPostModel(dictionary: data))
                    })
               
                }
                groupD.leave()
                
                groupD.notify(queue: .main, execute: {
                    self.feed = feedToReturn
                })
            })
            
        
        
        )
    }
    
    func listenToNotifications(userID: String){
        self.firestoreListener.append(
        
            COLLECTION_USER.document(userID).collection("Notifications").order(by: "notificationTime", descending: true).addSnapshotListener({ snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                var notificationsToReturn : [UserNotificationModel] = []
                let groupD = DispatchGroup()
                
                
                let documents = snapshot!.documents
             
                groupD.enter()
                for document in documents{
                    var data = document.data() as? [String:Any] ?? [:]
                    var notificationType = data["notificationType"] as? String ?? " "
                    var actionID = data["actionID"] as? String ?? " "
                    var actionType = data["actionType"] as? String ?? ""
                    
                    
                    
                    groupD.enter()
                    self.fetchUserNotificationCreator(notificationType: notificationType, notificationCreatorID: data["notificationCreatorID"] as? String ?? " ") { fetchedCreator in
                        data["notificationCreator"] = fetchedCreator
                        groupD.leave()

                    }
                    
                    groupD.enter()
                    self.fetchUserNotificationAction(notificationActionType: actionType, notificationActionID: actionID) { fetchedAction in
                        data["action"] = fetchedAction
                        groupD.leave()
                    }
                  
                  
                    groupD.notify(queue: .main, execute:{
                        notificationsToReturn.append(UserNotificationModel(dictionary: data))
                    })
                    
                }
                groupD.leave()
                
                groupD.notify(queue: .main, execute:{
                    self.notifications = notificationsToReturn
                })
                
            })
        
        
        
        )
    }
    
    func listenToPersonalChats(userID: String){
        
        self.firestoreListener.append( COLLECTION_PERSONAL_CHAT.whereField("usersID", arrayContains: userID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var chatsToReturn : [ChatModel] = []
            let groupD = DispatchGroup()
            
            
            let documents = snapshot!.documents
         
            groupD.enter()
            for document in documents{
                var data = document.data()
                let usersID = data["usersID"] as? [String] ?? []
                let lastMessageID = data["lastMessageID"] as? String ?? " "
                let usersTypingID = data["usersTypingID"] as? [String] ?? []
                let usersThatHaveSeenLastMessage = data["usersThatHaveSeenLastMessage"] as? [String] ?? []
                let id = data["id"] as? String ?? " "
                groupD.enter()
                  self.fetchChatUsers(users: usersID) { fetchedUsers in
                data["users"] = fetchedUsers
                groupD.leave()
            }
                groupD.enter()
                self.fetchLastMessage(chatID: id, messageID: lastMessageID) { fetchedMessage in
                    data["lastMessage"] = fetchedMessage
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUsersTyping(chatID: id, usersTypingID: usersTypingID){ fetchedUsers in
                   data["usersTyping"] = fetchedUsers
                    groupD.leave()
                }
                
              
              
                groupD.notify(queue: .main, execute:{
                    chatsToReturn.append(ChatModel(dictionary: data))
                })
                
            }
            groupD.leave()
            
            groupD.notify(queue: .main, execute:{
                    self.personalChats = chatsToReturn
                
            })
            
        }
                                       )
    }
   
    func fetchLastMessage(chatID: String, messageID: String, completion: @escaping (Message) -> ()) -> () {
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data() as? [String:Any] ?? [:]
            return completion(Message(dictionary: data))
            
        }
    }

    func fetchUsersTyping(chatID: String, usersTypingID: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        var groupD = DispatchGroup()
        
        for userID in usersTypingID {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                   print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                usersToReturn.append(User(dictionary: data))
                groupD.leave()
            }
        }
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    
    func fetchChatUsers(users: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        
        var groupD = DispatchGroup()
        
        for userID in users {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                usersToReturn.append(User(dictionary: data))
                groupD.leave()
            }
        }
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
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
            self.fetchUserFriendsList(friendsList: data["friendsListID"] as? [String] ?? []) { fetchedFriends in
                data["friendsList"] = fetchedFriends
                groupD.leave()
            }

          
            
            groupD.enter()
            self.fetchUserPersonalChats(personalChats: data["personalChatsID"] as? [String] ?? []) { fetchedChats in
                data["personalChats"] = fetchedChats
                groupD.leave()
            }
            
            groupD.enter()
            print("testing")
            groupD.leave()
            
            groupD.notify(queue: .main, execute:{
                self.user = User(dictionary: data)
            })
            
            
            
        }
        
        
    }
    
    
      func listenToUserGroups(uid: String){
          
          self.firestoreListener.append( COLLECTION_GROUP.whereField("users", arrayContains: uid).addSnapshotListener { (snapshot, err) in
              
              if err != nil {
                  print("ERROR! find")
                  return
              }
              
              
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
              
          })
          
          
          
          
          
          
          
      }
      
    
    //auth
    
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
                    loginErrorMessage = "\(error.localizedDescription)"
                }
            }
            
            
            
            
            let dp = DispatchGroup()
            dp.enter()
            withAnimation(.spring()){
                self.userSession = result?.user
                dp.leave()
            }
            
            dp.notify(queue: .main, execute:{
                self.listenToUser(uid: self.userSession?.uid ?? " ")
                print("user: \(self.user?.username ?? " ")")
            })

            
        }
        
    }

    
    
    func createUser(email:String,username:String,nickName:String,birthday: Date, password: String, profilePicture: UIImage, completion: @escaping (Bool) -> ()) -> (){
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if let err = err{
                    print("DEBUG: ERROR: \(err.localizedDescription)")
                    return completion(false)
                }
                
                
                
                guard let user = result?.user else {return completion(false)}
                
                let data = ["email": email,
                            "username": username,
                            "nickName": nickName,
                            "uid": user.uid,
                            "birthday": birthday,"profilePicture":"", "bio":"","isActive":true,"dateCreated":Timestamp()
                            
                ] as [String : Any]
                
                
                COLLECTION_USER.document(user.uid).setData(data)
                
                
                self.persistImageToStorage(userID: user.uid, image: profilePicture)
               
                print("DEBUG: Succesfully uploaded user data!")
                
                
                let dp = DispatchGroup()
                dp.enter()
                withAnimation {
                    self.userSession = user
                }
                dp.leave()
                dp.notify(queue: .main, execute:{
                    self.listenToAll(uid: self.userSession?.uid ?? " ")
                })
                
                
                Auth.auth().currentUser?.sendEmailVerification(completion: { (err) in
                    
                })
                
                return completion(true)
                
            }
        }
    
    func removeListeners(){
        for listener in firestoreListener{
            listener.remove()
        }
    }
    
    func signOut(){
        
        
        self.loginErrorMessage = ""
        userSession = nil
        try? Auth.auth().signOut()
        self.removeListeners()
    }
    
    
    //fetch
    
    
    
    
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
            }
        }
        
    }
    
    func fetchUserBlockedList(blockedList: [String], completion: @escaping ([User]) -> ()) -> (){
        var users : [User] = []
        
        var groupD = DispatchGroup()
        
        
        groupD.enter()
        
        for userID in blockedList {
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
        
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(users)
        })
        
    }
    
    func fetchUserPersonalChats(personalChats: [String], completion: @escaping ([ChatModel]) -> ()) -> () {
        var personalChatsToReturn : [ChatModel] = []
        var groupD = DispatchGroup()
        
        groupD.enter()
        for chat in personalChats {
            COLLECTION_PERSONAL_CHAT.document(chat).getDocument { snapshot , err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                personalChatsToReturn.append(ChatModel(dictionary: data))
            
                
            }
        }
        
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(personalChatsToReturn)
        })
    }
    
    func fetchUserFriendsList(friendsList: [String], completion: @escaping ([User]) -> ()) -> (){
        var users : [User] = []
        
        var groupD = DispatchGroup()
        
        
        groupD.enter()
        
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
        
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(users)
        })
        
    }
    
    func fetchUserNotifications(userID: String, completion: @escaping ([UserNotificationModel]) -> ()) -> () {
        
        var notificationsToReturn : [UserNotificationModel] = []
        COLLECTION_USER.document(userID).collection("Notifications").order(by: "notificationTime", descending: true).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else{
                return
            }
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            for document in documents {
                var data = document.data() as? [String:Any] ?? [:]
                var notificationType = data["notificationType"] as? String ?? " "
                var actionTypeID = data["actionTypeID"] as? String ?? " "
                var actionType = data["actionType"] as? String ?? " "
                
                
                
                groupD.enter()
                self.fetchUserNotificationCreator(notificationType: notificationType, notificationCreatorID: data["notificationCreatorID"] as? String ?? " ") { fetchedCreator in
                    data["notificationCreator"] = fetchedCreator
                    groupD.leave()

                }
                
                groupD.enter()
                self.fetchUserNotificationAction(notificationActionType: actionType, notificationActionID: actionTypeID) { fetchedAction in
                    data["action"] = fetchedAction
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
    

  
    func fetchNotificationEvent(eventID: String, completion: @escaping (EventModel) -> ()) -> (){
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
                
            }
            
            var groupD = DispatchGroup()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var creatorID = data["creatorID"] as? String ?? " "
            
            groupD.enter()
            self.fetchUser(userID: creatorID) { fetchedUser in
                data["creator"] = fetchedUser
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute: {
            return completion(EventModel(dictionary: data))
            })
        }
    }
    
    func fetchNotificationUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
        }
    }
    
    
   
    
    func fetchUserNotificationCreator(notificationType: String, notificationCreatorID: String, completion: @escaping (Any) -> ()) -> (){
        
    switch notificationType {
        case "eventCreated":
            self.fetchNotificationEvent(eventID: notificationCreatorID){ fetchedEvent in
                return completion(fetchedEvent)
            }
    case "sentFriendRequest", "acceptedFriendRequest","sentGroupInvitation":
            self.fetchNotificationUser(userID: notificationCreatorID){ fetchedUser in
                return completion(fetchedUser)
            }
    case "acceptedGroupInvitation":
        self.fetchNotificationGroup(groupID: notificationCreatorID){ fetchedGroup in
            return completion(fetchedGroup)
        }
    default:
        return completion("not a valid notification yet")
    }
        
        
        
    }
    
    func fetchUserNotificationAction(notificationActionType: String, notificationActionID: String, completion: @escaping (Any) -> ()) -> (){
        
    switch notificationActionType {
        case "openGroup":
        self.fetchNotificationGroup(groupID: notificationActionID){ fetchedGroup in
            return completion(fetchedGroup)
        }
    case "acceptedFriendRequest":
        self.fetchNotificationUser(userID: notificationActionID) { fetchedUser in
            return completion(fetchedUser)
        }
    default:
        return completion("not a valid notification yet")
    }
        
        
        
    }
    
    
    func fetchNotificationGroup(groupID: String, completion: @escaping (Group) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(Group(dictionary: data))
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
    
    
    
    
    
    
    func readUserNotification(userNotification: UserNotificationModel, userID: String){
        COLLECTION_USER.document(userID).collection("Notifications").document(userNotification.id).updateData(["hasSeen":true])
        COLLECTION_USER.document(userID).updateData(["userNotificationCount":0])
    }
    
    
    func concatenate(followedGroups: [Group], groups: [Group]) -> [Group]{
        var arr1 : [Group] = []
        arr1 = groups
        arr1.append(contentsOf: followedGroups)
        return arr1
    }
    
    func getIDS(userGroups: [Group]) -> [String]{
        var arr : [String] = [""]
        for group in userGroups{
            arr.append(group.id)
        }
        return arr
    }
    
 
    
    func setUserActivity(isActive: Bool, userID: String, completion: @escaping (User) -> ()) -> (){
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
    
    
    func listenToNetworkChanges(uid: String){
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                self.isConnected = true
                self.showWarning = true
            }else{
                self.isConnected = false
                self.showWarning = false
            }
        })
    }
    
    func listenToAll(uid: String){
        self.listenToUserGroups(uid: uid)
        self.listenToNetworkChanges(uid: uid)
        self.listenToUser(uid: uid)
        self.listenToPersonalChats(userID: uid)
        self.listenToNotifications(userID: uid)
        self.listenToFeed()
    }
    
    
    func resetPassword(email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if err != nil {
                print("ERROR: \(err?.localizedDescription)")
            }
            
        }
       
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
   
    func fetchUser(){
        
        guard let uid = userSession?.uid else {return}
        
        store.collection(path).document(uid).getDocument { (snapshot, _) in
            guard let data = snapshot?.data() else {return}
            let user = User(dictionary: data)
          
            self.user = user
            
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
    

    func sendFriendRequest(friend: User, completion: @escaping (Bool) -> ()) -> () {
        
        let dp = DispatchGroup()
        dp.enter()
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayUnion([friend.id ?? " "])])
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayUnion([user?.id ?? " "])])
        
        notificationSender.sendPushNotification(to: friend.fcmToken ?? " ", title: "\(friend.username ?? "")", body: "\(friend.nickName ?? "") sent a friend request")
        

        
        let notificationID = UUID().uuidString
        
        let userNotificationData = ["id":notificationID,
            "notificationName": "Friend Request",
            "notificationTime":Timestamp(),
                                    "notificationType":"sentFriendRequest","notificationCreatorID":self.user?.id ?? "USER_ID",
            "hasSeen":false,
                                    "actionID": self.user?.id ?? " ", "actionType":"openGroup"] as [String:Any]
        
        
        COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
        COLLECTION_USER.document(friend.id ?? " ").updateData(["userNotificationCount":FieldValue.increment((Int64(1)))])
        
        dp.leave()
        dp.notify(queue: .main, execute:{
            return completion(true)
            print("\(self.user?.username ?? " ") sent a friend request to \(friend.username ?? " ")")
        })
    }
    
    func unsendFriendRequest(friend: User, completion: @escaping (Bool) -> ()) -> (){
        let dp = DispatchGroup()
        dp.enter()
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayRemove([friend.id ?? " "])])
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayRemove([user?.id ?? " "])])
        dp.leave()
        dp.notify(queue: .main, execute: {
            return completion(true)
        })
    }
    
    
    func acceptFriendRequest(friend: User){
        
        
        //Removing from eachothers pending friends list
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayRemove([friend.id ?? " "])])
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayRemove([self.user?.id ?? " "])])
        //END
        
        
        
        self.addFriend(friendID: friend.id ?? " "){ finished in
            print("Added Friend!")
        }
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = ["id":notificationID,
                                    "notificationName": "Friend Request",
                                    "notificationTime":Timestamp(),
                                    "notificationType":"acceptedFriendRequest", "notificationCreatorID":self.user?.id ?? "USER_ID",
                                    "hasSeen":false,
                                    "actionID": self.user?.id ?? " "] as [String:Any]
        
        
        COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
        COLLECTION_USER.document(friend.id ?? " ").updateData(["userNotificationCount":FieldValue.increment((Int64(1)))])
        
        notificationSender.sendPushNotification(to: friend.fcmToken ?? " ", title: "\(friend.username ?? "")", body: "\(friend.nickName ?? "") accepted your friend request")
    }
    
    func denyFriendRequest(friend: User){
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayRemove([friend.id ?? " "])])
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayRemove([user?.id ?? " "])])
        
        
        notificationSender.sendPushNotification(to: friend.fcmToken ?? " ", title: "\(friend.username ?? "")", body: "\(friend.nickName ?? "") denied your friend request")
    }
    
    func checkIfUsersHavePersonalChats(user1: String, user2: String, completion: @escaping (Bool) -> ()) -> (){
        COLLECTION_PERSONAL_CHAT.whereField("usersID", arrayContains: [user1,user2]).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            if snapshot?.documents.isEmpty ?? false{
                COLLECTION_PERSONAL_CHAT.whereField("usersID", arrayContains: [user2,user1]).getDocuments { snapshot, err in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    return completion(snapshot?.documents.isEmpty ?? false)

                }
            }else{
                return completion(true)
            }
            
        }
    }
    
    func addFriend(friendID: String, completion: @escaping (Bool) -> ()) -> (){
        
        let dp = DispatchGroup()
        
        dp.enter()
        //add to eachothers friend list
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["friendsListID":FieldValue.arrayUnion([friendID])])
        
        
        COLLECTION_USER.document(friendID ).updateData(["friendsListID":FieldValue.arrayUnion([user?.id ?? " "])])
        //END
        
        
         self.checkIfUsersHavePersonalChats(user1: self.user?.id ?? " ", user2: friendID, completion: { usersHaveChat in
             if usersHaveChat{
                 
                 print("Creating new personal chat!")
                 let id = UUID().uuidString
                 let chatData = ["dateCreated":Date(),
                                 "usersID":[friendID,self.user?.id ?? " "],
                                 "id":id,
                                 "chatType":"personal"] as [String:Any]
                 //create personal chat
                 COLLECTION_PERSONAL_CHAT.document(id).setData(chatData){ err in
                     if err != nil {
                         print("ERROR")
                         return
                     }
                 }
                 //picks colors
        
                 
                 COLLECTION_USER.document(self.user?.id ?? " ").updateData(["personalChatsID":FieldValue.arrayUnion([id])])
                 
                 COLLECTION_USER.document(friendID).updateData(["personalChatsID":FieldValue.arrayUnion([id])])
             }
        })
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            return completion(true)
        })
    }
    
    
    
    func removeFriend(friendID: String, completion: @escaping (Bool) -> ()) -> () {
 
        
        //friends list
        let dp = DispatchGroup()
        
        dp.enter()
        
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["friendsListID":FieldValue.arrayRemove([friendID])])
        COLLECTION_USER.document(friendID).updateData(["friendsListID":FieldValue.arrayRemove([self.user?.id ?? " "])])
        
        //pending friends list
        
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["pendingFriendsListID":FieldValue.arrayRemove([friendID])])
        COLLECTION_USER.document(friendID).updateData(["pendingFriendsListID":FieldValue.arrayRemove([self.user?.id ?? " "])])
        
        COLLECTION_PERSONAL_CHAT.whereField("usersID", isEqualTo: [friendID,self.user?.id ?? " "]).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            print("got here")
            
            let documents = snapshot!.documents
            if documents.isEmpty{
                COLLECTION_PERSONAL_CHAT.whereField("usersID", isEqualTo: [self.user?.id ?? " ",friendID]).getDocuments { snapshot, err in
                    let documents = snapshot!.documents
                    for document in documents {
                        let id = document.get("id") as? String ?? " "
                        COLLECTION_PERSONAL_CHAT.document(id).delete()
                        print("Chat Deleted")
                    }
                }
            }else{
                for document in documents {
                    let id = document.get("id") as? String ?? " "
                    COLLECTION_PERSONAL_CHAT.document(id).delete()
                    print("Chat Deleted")
                }
            }
           
        }
        
        dp.leave()
        
        dp.notify(queue: .main, execute: {
            return completion(true)
        })
        
    }
    
    
    
    
    
    func unblockUser(unblocker: String, blockee: String){
        COLLECTION_USER.document(unblocker).updateData(["blockedAccountsID":FieldValue.arrayRemove([blockee])])
        COLLECTION_USER.document(blockee).updateData(["blockedAccountsID":FieldValue.arrayRemove([unblocker])])
    }
    
    
    func blockUser(blocker: String, blockee: String){
        COLLECTION_USER.document(blocker).updateData(["blockedAccountsID":FieldValue.arrayUnion([blockee])])
        COLLECTION_USER.document(blockee).updateData(["blockedAccountsID":FieldValue.arrayUnion([blocker])])
        

        self.removeFriend(friendID: blockee){ finished in
            print("removed friend")
        }
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
    
 
    

   
 
 


  
    

  
    
    
}


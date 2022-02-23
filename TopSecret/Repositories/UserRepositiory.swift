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
    @Published var homescreenPosts : ([EventModel],[PollModel],[GalleryPostModel]) = ([],[],[])
    @Published var followedGroups : [Group] = []
    @Published var isConnected : Bool = false
    @Published var firestoreListener : [ListenerRegistration] = []
    @Published var userNotificationCount : Int = 0
    @Published var groupNotificationCount : [[String:Int]] = []
    @ObservedObject var notificationRepository = NotificationRepository()
    @Published var currentNotification : NotificationModel?
    @Published var showNotification : Int = 0 //on value change, send notification
    
    
    private var cancellables : Set<AnyCancellable> = []
    let store = Firestore.firestore()
    let path = "Users"
    
    
    init(){
        
        userSession = Auth.auth().currentUser
        fetchUser()
        if userSession != nil{
            self.listenToAll(uid: userSession?.uid ?? " ")
        }
        
    }
    
    
    func setUserActivity(isActive: Bool, userID: String, completion: @escaping (User) ->()) -> (){
        COLLECTION_USER.document(userID).updateData(["isActive":isActive])
        if !isActive{
            COLLECTION_USER.document(userID).updateData(["lastActive":Timestamp()])
        }
        print("user: \(userID) \(isActive ? "is active" : "is inactive")")
       
       
        COLLECTION_USER.document(userID).getDocument(completion: { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()!
            
            return completion(User(dictionary: data))
            
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
        let listener = COLLECTION_USER.document(uid).addSnapshotListener { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            
            let groups = snapshot?.get("followedGroups") as? [String] ?? []
            self.followedGroups.removeAll()
            for group in groups {
                COLLECTION_GROUP.document(group).getDocument { (snapshot1, err) in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    let data = snapshot1?.data()
                    
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
            
            
            guard let data = snapshot!.data() else {
                print("NO USER")
                return
            }
            
            
            self.user = User(dictionary: data)
            
            
            
        }
        
        firestoreListener.append(listener)
        
    }
    
    
    
    
    func listenToUserNotifications(uid: String){
        
        let listener = COLLECTION_USER.document(uid).collection("Notifications").order(by: "notificationTime",descending: true).addSnapshotListener { (snapshot, err) in
            
        
            
            for doc in snapshot!.documentChanges {
                if doc.type == .added {
                    
                    
                    //getting userNotificationsCount
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        COLLECTION_USER.document(uid).getDocument { (snapshot, err) in
                            if err != nil {
                                print("ERROR")
                                return
                            }
                            
                            self.userNotificationCount = snapshot?.get("userNotificationCount") as? Int ?? 0
                            self.groupNotificationCount = snapshot?.get("groupNotificationCount") as? [[String:Int]] ?? []
                        }
                    }
                   
                    
                    self.currentNotification = NotificationModel(dictionary: doc.document.data())
               
                }
            }
            
            self.notifications = snapshot!.documents.map({ queryDocumentSnapshot -> NotificationModel in
                let data = queryDocumentSnapshot.data()
                print("notification: \(queryDocumentSnapshot.get("id") as? String ?? "")")
               

                return NotificationModel(dictionary: data)
            })
            
            
            
            
        }
        firestoreListener.append(listener)
    }
    
    func listenToUserChats(uid: String){
        
        
        let listener = COLLECTION_CHAT.whereField("users", arrayContains: uid).addSnapshotListener { (snapshot, err) in
            
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            
            
            self.groupChats = documents.map{ queryDocumentSnapshot -> ChatModel in
                let data = queryDocumentSnapshot.data()
         
                print("Fetched Chats!")
                
                return ChatModel(dictionary: data)
                
                
            }
            
        }
        
        firestoreListener.append(listener)
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
   
    
    func listenToUserGroups(uid: String){
        
        let listener = COLLECTION_GROUP.whereField("users", arrayContains: uid).addSnapshotListener { (snapshot, err) in
            
            
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.groups = documents.map{ queryDocumentSnapshot -> Group in
                var data = queryDocumentSnapshot.data()
                var polls = data["polls"] as? [PollModel] ?? []
                
                self.fetchGroupPolls(groupID: data["id"] as? String ?? "") { fetchedPolls in
                    polls = fetchedPolls
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    for poll in data["polls"] as? [PollModel] ?? []{
                        print("poll: \(poll.creator ?? "")")
                    }
                }
                
            
                
    
                
                print("Fetched Groups!")
                
                
                return Group(dictionary: data)
                
                
            }
            
            
            
        }
        firestoreListener.append(listener)
        
        
        for group in self.groups {
            for poll in group.polls ?? [] {
                print("poll2: \(poll.creator ?? "")")
            }
        }
        
    }
    func listenToUserPolls(uid: String){
        
        let listener = COLLECTION_POLLS.whereField("users", arrayContains: uid).addSnapshotListener { (snapshot, err) in
            
            
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            self.polls = documents.map{ queryDocumentSnapshot -> PollModel in
                
                
                
                let data = queryDocumentSnapshot.data()
                let question = data["question"] as? String ?? ""
                let creator = data["creator"] as? String ?? ""
                let dateCreated = data["dateCreated"] as? Timestamp ?? Timestamp()
                let groupID = data["groupID"] as? String ?? ""
                let groupName = data["groupName"] as? String ?? ""
                let totalUsers = data["totalUsers"] as? Int ?? 0
                let users = data["users"] as? [String] ?? []
                let choices = data["choices"] as? [String] ?? ["","","",""]
                let pollType = data["pollType"] as? String ?? ""
                let usersAnswered = data["usersAnswered"] as? [[String:String]] ?? []
                let completionType = data["completionType"] as? String ?? ""
                let endDate = data["endDate"] as? Timestamp ?? Timestamp()
                let finished = data["finished"] as? Bool ?? false
                let id = data["id"] as? String ?? ""
                
                
                
                print("Fetched Polls!")
                
                
                
                return PollModel(dictionary: ["question":question,"creator":creator,"dateCreated":dateCreated,"groupID":groupID,"groupName":groupName,"id":id,"totalUsers":totalUsers,"choices":choices,"pollType":pollType,"usersAnswered":usersAnswered,"completionType":completionType,"endDate":endDate,"finished":finished,"users":users])
                
                
            }
            
            
        }
        
        
        firestoreListener.append(listener)
        
        
        
    }
    func listenToUserEvents(uid: String){
        
        let listener = COLLECTION_EVENTS.whereField("usersVisibleTo", arrayContains: uid).addSnapshotListener { (snapshot, err) in
            
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.events = documents.map{ queryDocumentSnapshot -> EventModel in
                let data = queryDocumentSnapshot.data()
                let eventName = data["eventName"] as? String ?? ""
                let eventLocation = data["eventLocation"] as? String ?? ""
                let eventTime = data["eventTime"] as? Timestamp ?? Timestamp()
                let usersVisibleTo = data["usersVisibleTo"] as? [String] ?? []
                let id = data["id"] as? String ?? ""
                print("Fetched Events!")
                
                return EventModel(dictionary: ["eventName":eventName,"eventLocation":eventLocation, "eventTime":eventTime, "usersVisibleTo":usersVisibleTo,"id":id])
                
                
            }
            
        }
        
        
        firestoreListener.append(listener)
        
        
        
    }
    func listenToUserFriends(uid: String){
        
        
        let listener = COLLECTION_USER.whereField("friendsList", arrayContains: uid).addSnapshotListener { (snapshot, err) in
            
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            self.user?.friendsList = documents.map{ queryDocumentSnapshot -> String in
                
                let data = queryDocumentSnapshot.data()
                let uid = data["uid"] as? String ?? ""
                return uid
                
                
            }
            
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
        self.listenToUserChats(uid: uid)
        self.listenToUserGroups(uid: uid)
        self.listenToUserPolls(uid: uid)
        self.listenToUserEvents(uid: uid)
        self.listenToUserFriends(uid: uid)
        self.listenToUser(uid: uid)
        self.listenToNetworkChanges(uid: uid)
        self.listenToPersonalChats(uid: uid)
        self.listenToUserNotifications(uid: uid)
        self.listenToUserFollowedGroups(uid: uid)
        
        
        
    }
    func fetchUserChats(){
        //TODO
        COLLECTION_CHAT.whereField("users", arrayContains: user?.id ?? "").getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.groupChats = documents.map{ queryDocumentSnapshot -> ChatModel in
                let data = queryDocumentSnapshot.data()
                
                
                
                
                
                return ChatModel(dictionary: data)
                
            }
            
            print("Fetched User Chats!")
            
            
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
                let data = queryDocumentSnapshot.data()
                let chatID = data["chatID"] as? String ?? ""
                let groupName = data["groupName"] as? String ?? ""
                let memberAmount = data["memberAmount"] as? Int ?? 0
                let memberLimit = data["memberLimit"] as? Int ?? 0
                let users = data["users"] as? [User.ID] ?? []
                let id = data["id"] as? String ?? ""
                let groupProfileImage = data["groupProfileImage"] as? String ?? ""
                let motd = data["motd"] as? String ?? "Welcome to the group!"
                let quoteOfTheDay = data["quoteOfTheDay"] as? String ?? ""
                
                
                
                
                return Group(dictionary: ["chatID":chatID,"groupName":groupName,"memberAmount":memberAmount,"memberLimit":memberLimit,"users":users,"id":id,"groupProfileImage":groupProfileImage,"motd":motd,"quoteOfTheDay":quoteOfTheDay])
                
            }
            
            print("Fetched User Groups!")
            
            
        }
    }
    func fetchUserPolls(){
        //TODO
        //TODO
        COLLECTION_POLLS.whereField("users", arrayContains: user?.id ?? "").getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.polls = documents.map{ queryDocumentSnapshot -> PollModel in
                let data = queryDocumentSnapshot.data()
                
                
                
                
                
                return PollModel(dictionary: data)
                
            }
            
            print("Fetched User Polls!")
            
            
        }
    }
    func fetchUserEvents(){
        //TODO
        //TODO
        COLLECTION_EVENTS.whereField("usersVisibleTo", arrayContains: user?.id ?? "").getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.events = documents.map{ queryDocumentSnapshot -> EventModel in
                let data = queryDocumentSnapshot.data()
                
                
                
                
                
                return EventModel(dictionary: data)
                
            }
            
            print("Fetched User Events!")
            
            
        }
    }
    func fetchAll(){
        fetchUserChats()
        fetchUserGroups()
        fetchUserPolls()
        fetchUserEvents()
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
                        "birthday": birthday,"profilePicture":"", "friendsList": [], "bio":""
                        
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
    func signIn(withEmail email: String, password: String){
        
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
                    loginErrorMessage = "The e"
                }
            }
            
            self.userSession = result?.user
            self.fetchUser()
            self.listenToAll(uid: userSession?.uid ?? " ")
            
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
        COLLECTION_USER.document(user.id ?? "").updateData(["pendingFriendsList":FieldValue.arrayRemove([friendID])])
        
        COLLECTION_USER.document(user.id ?? "").updateData(["friendsList":FieldValue.arrayUnion([friendID])])
        COLLECTION_USER.document(friendID).updateData(["friendsList":FieldValue.arrayUnion([user.id ?? ""])])
        
        notificationRepository.sendAcceptedFriendRequestNotification(user1: user, user2: friendID)
        
        
    }
    
    func declineFriendRequest(friendID: String, user: User){
        
        COLLECTION_USER.document(user.id ?? "").updateData(["pendingFriendsList":FieldValue.arrayRemove([friendID])])
        
        notificationRepository.sendDeclinedFriendRequestNotification(user1: user, user2: friendID)
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
           
            
            let data = snapshot!.data()
            
            return completion(User(dictionary: data ?? [:]))
        }
    }
    
    func fetchGroup(groupID: String, completion: @escaping (Group) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(Group(dictionary: data))
            
        }
    }
    
    
    func followGroup(group: Group, user: User){
        COLLECTION_USER.document(user.id ?? "").updateData(["followedGroups":FieldValue.arrayUnion([group.id])])
        COLLECTION_GROUP.document(group.id).updateData(["followers":FieldValue.arrayUnion([user.id ?? ""])])
        print("Followed Group: \(group.groupName)!")
    }
    
    func unFollowGroup(group: Group, user: User){
        COLLECTION_USER.document(user.id ?? "").updateData(["followedGroups":FieldValue.arrayRemove([group.id])])
        COLLECTION_GROUP.document(group.id).updateData(["followers":FieldValue.arrayRemove([user.id ?? ""])])
        
        print("Unfollowed Group: \(group.groupName)!")
    }
    
    func isFollowingGroup(user: User, group: Group, completion: @escaping (Bool) -> () ) -> (){
   
        COLLECTION_USER.document(user.id ?? "").getDocument { (snapshot, err) in
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

}

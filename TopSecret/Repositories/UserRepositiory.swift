////
////  UserRepositiory.swift
////  TopSecret
////
////  Created by Bruce Blake on 11/9/21.
////
//
//import Foundation
//import Firebase
//import Combine
//import SwiftUI
//import SCSDKLoginKit
//
//class UserRepository : ObservableObject {
//
//    @Published var user : User?
//    @Published var loginErrorMessage = ""
//    @Published var userSession : FirebaseAuth.User?
//    @Published var profilePicture : UIImage = UIImage()
//    @Published var groups: [Group] = []
//    @Published var groupChats: [ChatModel] = []
//    @Published var polls: [PollModel] = []
//    @Published var events: [EventModel] = []
//    @Published var personalChats: [ChatModel] = []
//    @Published var notifications : [NotificationModel] = []
//    @Published var homescreenPosts : [String:String] = [" ":" "] //postType, id
//    @Published var homescreenGalleryPosts: [GalleryPostModel] = []
//    @Published var followedGroups : [Group] = []
//    @Published var isConnected : Bool = false
//    @Published var firestoreListener : [ListenerRegistration] = []
//    @Published var userNotificationCount : Int = 0
//    @Published var groupNotificationCount : [[String:Int]] = []
//    @Published var currentNotification : NotificationModel?
//    @Published var showNotification : Int = 0 //on value change, send notification
//    @Published var userSelectedGroup : Group = Group()
//    @Published var finishedFetchingGroups : Bool = false
//
//    private var cancellables : Set<AnyCancellable> = []
//
//    static var shared = UserViewModel()
//
//
//
//}

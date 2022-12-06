//
//  HomeScreenView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/30/21.
//

import SwiftUI
import UIKit
import SCSDKLoginKit
import SDWebImageSwiftUI
import CoreData




struct ContentView: View {
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var tabVM : TabViewModel
    @StateObject var pollVM = PollViewModel()
    @State var tabIndex : Tab = .home
    @State var showNotification : Bool = false
    @State var selectedGroup : Group = Group()

    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    
    
    var body: some View {
        
        //if there is a user signed in then go to the Tab View else go to the register view
        
        
        ZStack(alignment: .top){
            if userVM.userSession != nil{
                NavigationView{
                    Tabs(tabIndex: $tabIndex, selectedGroup: $selectedGroup)
                }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).navigationViewStyle(.stack)
                
                
                
                
                
                
                
                if userVM.isConnected == false && userVM.showWarning{
                    HStack{
                        HStack{
                            
                        Image(systemName: "exclamationmark.triangle").foregroundColor(FOREGROUNDCOLOR)
                        Text("You are not connected!").foregroundColor(Color("AccentColor"))
                        }
                        Spacer()
                        Button(action:{
                            userVM.showWarning.toggle()
                        },label:{
                            Text("Dismiss")
                        })
                    }.padding().background(Color("Color")).cornerRadius(16).shadow(color: Color.black,radius: 3).animation(.easeIn, value: userVM.isConnected).padding(.top,50).padding(.horizontal,10)
                }
                
            }else {
                LoginView()
            }
            
        }
        .edgesIgnoringSafeArea(.all).navigationBarHidden(true).onReceive(userVM.$userNotificationCount) { count in
            if count != 0{
                self.showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    withAnimation(.easeOut(duration: 1)){
                        self.showNotification = false
                    }
                })
            }
            
        }.onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if userVM.userSession != nil{
                    userVM.setUserActivity(isActive: true, userID: userVM.user?.id ?? " ", completion: { fetchedUser in
                        userVM.user = fetchedUser
                    })
                }
            }else if newPhase == .background{
                if userVM.userSession != nil{
                    userVM.setUserActivity(isActive: false, userID: userVM.user?.id ?? " ", completion: { fetchedUser in
                        userVM.user = fetchedUser
                    })
                }
            }
        }
    }
}










enum Tab {
    case discover, friends, home, groups, notifications
}


struct Tabs : View {
    @Binding var tabIndex : Tab
    @Binding var selectedGroup : Group
    @State var showTabButtons : Bool = true
    @State var showSearch: Bool = false
    @StateObject var personalChatVM = PersonalChatViewModel()
    @EnvironmentObject var userVM: UserViewModel
    
    func checkIfUserHasUnreadChats() -> Bool {
        let chats = userVM.personalChats
        for chat in chats {
            if chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? " ") ?? false {
                return true
            }
        }
        return false
    }
    
    var body: some View {
        ZStack{
            if showSearch {
                ExplorePage(showSearch: $showSearch)
            } else {
                ZStack{
                    Color("Background")
                    VStack(){
                        TopBar(showSearch: $showSearch, tabIndex: tabIndex)

                    if tabIndex == .home{
                        HomeScreen()
                    }else if tabIndex == .friends{
                        FriendsView(personalChatVM: personalChatVM)
                    }else if tabIndex == .groups{
//                        ScheduleView(calendar: Calendar(identifier: .gregorian))
                        GroupsView()
                    }else if tabIndex == .notifications{
                        UserNotificationView()
                    }else if tabIndex == .discover {
                        VStack{
                            Spacer()
                            Text("Coming Soon")
                            Spacer()
                        }
                    }
                }
                }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).opacity(userVM.showAddContent ? 0.2 : 1).disabled(userVM.showAddContent).onTapGesture {
                    if userVM.showAddContent {
                        userVM.showAddContent.toggle()
                        userVM.hideTabButtons.toggle()
                    }
                }
            }
          
            
         
            
                
                VStack{
                    Spacer()
                    
                    HStack(alignment: .center){
                        
                        
                       
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .discover
                            },label:{
                                VStack(spacing: 5){
                                    
                                    
                                    Image(systemName: self.tabIndex == .discover ?  "safari.fill" : "safari").font(.system(size: 20))
                                    
                                    Text("Discover").font(.system(size: 12)).foregroundColor(.gray)

                                }
                                
                                
                            }).foregroundColor(self.tabIndex == .discover ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.horizontal,10)
                            
                        
                    
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .friends
                                userVM.removeListeners()
                                userVM.listenToPersonalChats(userID: userVM.user?.id ?? " ")
                            },label:{
                                
                                VStack(spacing: 5){
                                    
                                    
                                    ZStack{
                                        Image(systemName: self.tabIndex == .friends ? "message.fill" : "message").font(.system(size: 20))
                                        
                                        if !checkIfUserHasUnreadChats() {
                                            Circle().foregroundColor(Color("AccentColor")).frame(width: 14, height: 14)
                                        .offset(x: 13, y: -10)
                                        }
                                              
                                        
                                        
                                        
                                    }
                                    Text("Friends").font(.system(size: 12)).foregroundColor(.gray)

                                }
                                
                                
                                
                                
                            }).foregroundColor(self.tabIndex == .friends ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.horizontal,10)

                        
                    
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .home
                                userVM.removeListeners()
                            },label:{
                                VStack(spacing: 5){
                                    
                                    
                                    Image(systemName: self.tabIndex == .home ?  "house.fill" : "house").font(.system(size: 20))
                                    
                                    Text("Home").font(.system(size: 12)).foregroundColor(.gray)

                                }
                                
                            }).foregroundColor(self.tabIndex == .home ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.horizontal)
                            
                        
                      
                     
                   
                    
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .groups
                                userVM.removeListeners()
                                userVM.listenToUserGroups(uid: userVM.user?.id ?? " ")
                            },label:{
                                VStack(spacing: 5){
                                    
                                    Image(systemName: self.tabIndex == .groups ?  "person.3.fill" : "person.3").font(.system(size: 20))
                                    Text("Groups").foregroundColor(.gray).font(.system(size: 12))
                                    }
                                

                            }).foregroundColor(self.tabIndex == .groups ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.horizontal,10)
                            
                            
                     
                        
                       
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .notifications
                                userVM.removeListeners()
                                userVM.listenToNotifications(userID: userVM.user?.id ?? " ")
                            },label:{
                                VStack(spacing: 5){
                                    Image(systemName: self.tabIndex == .notifications ?  "envelope.fill" : "envelope").font(.system(size: 20))
                                    Text("Notifications").foregroundColor(.gray).font(.system(size: 12))
                                }

                                
                            }).foregroundColor(self.tabIndex == .notifications ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.horizontal,10)
                            
                       
                        
                        
                    }.frame(width: UIScreen.main.bounds.width).padding().padding(.bottom).background(Color("Color"))
                }.opacity(userVM.hideTabButtons ? 0 : 1)
            
         
            
           BottomSheetView(isOpen: Binding(get: {userVM.showAddContent}, set: {userVM.showAddContent = $0}), maxHeight: UIScreen.main.bounds.height / 3){
               HomescreenAddContentView()
            }
            
            
        }.edgesIgnoringSafeArea(.all)
    }
}


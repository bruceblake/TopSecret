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
        .edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        .onChange(of: scenePhase) { newPhase in
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
    @StateObject var feedVM = FeedViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var shareVM: ShareViewModel
    @State var selectedPost: GroupPostModel = GroupPostModel()
    @State var selectedPoll: PollModel = PollModel()
    @State var selectedEvent: EventModel = EventModel()
    @State var shareType : String = ""
    
   
    
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
                        HomeScreen(feedVM: feedVM,selectedPost: $selectedPost, selectedPoll: $selectedPoll, selectedEvent: $selectedEvent, shareType: $shareType)
                    }else if tabIndex == .friends{
                        FriendsView(personalChatVM: personalChatVM)
                    }else if tabIndex == .groups{
                        GroupsView()
                    }else if tabIndex == .notifications{
                        UserNotificationView()
                    }else if tabIndex == .discover {
                        DiscoverView()
                    }
                }
                }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).opacity(userVM.hideBackground ? 0.2 : 1).disabled(userVM.hideBackground)
                    .overlay{
                        if shareVM.showShareMenu{
                      

                        VStack{
                            Spacer()
                            ShowShareMenu(selectedPost: $selectedPost, selectedPoll: $selectedPoll, selectedEvent: $selectedEvent, shareType: $shareType)
                        }
                         
                        
                    }



        }
                    .onTapGesture {
                        
                        if userVM.hideBackground{
                            withAnimation{
                                userVM.hideBackground.toggle()
                                if userVM.hideTabButtons{
                                    userVM.hideTabButtons.toggle()
                                }
                            }
                           
                        }
                        if shareVM.showShareMenu{
                            withAnimation{
                                shareVM.showShareMenu.toggle()
                            }
                        }
                        if userVM.showAddContent{
                            self.userVM.showAddContent.toggle()
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
                            },label:{
                                
                                VStack(spacing: 5){
                                    
                                    
                                    ZStack{
                                        Image(systemName: self.tabIndex == .friends ? "message.fill" : "message").font(.system(size: 20))
                                        
                                        if userVM.unreadChatsCount >= 1{
                                            ZStack{
                                                Circle().foregroundColor(Color.red).frame(width: 18, height: 18)
                                                Text("\(userVM.getUnreadChatCount())").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                                            }
                                           
                                        .offset(x: 13, y: -10)
                                        }
                                              
                                        
                                        
                                        
                                    }
                                    Text("Friends").font(.system(size: 12)).foregroundColor(.gray)

                                }
                                
                                
                                
                                
                            }).foregroundColor(self.tabIndex == .friends ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.horizontal,10).buttonStyle(.plain)

                        
                    
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .home
                            },label:{
                                VStack(spacing: 5){
                                    
                                    
                                    Image(systemName: self.tabIndex == .home ?  "house.fill" : "house").font(.system(size: 20))
                                    
                                    Text("Home").font(.system(size: 12)).foregroundColor(.gray)

                                }
                                
                            }).foregroundColor(self.tabIndex == .home ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.horizontal)
                            
                        
                      
                     
                   
                    
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .groups
                            },label:{
                                VStack(spacing: 5){
                                    
                                    Image(systemName: self.tabIndex == .groups ?  "person.3.fill" : "person.3").font(.system(size: 20))
                                    Text("Groups").foregroundColor(.gray).font(.system(size: 12))
                                    }
                                

                            }).foregroundColor(self.tabIndex == .groups ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.horizontal,10)
                            
                            
                     
                        
                       
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .notifications
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
            
            
        }.edgesIgnoringSafeArea(.all).onReceive(userVM.$showAddContent) { output in
            if !output && userVM.hideBackground{
                userVM.hideBackground.toggle()
                userVM.hideTabButtons.toggle()
            }
        }
    }
}


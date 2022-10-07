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
    @EnvironmentObject var navigationHelper : NavigationHelper
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
    case home, friends, create, schedule, user
}


struct Tabs : View {
    @Binding var tabIndex : Tab
    @Binding var selectedGroup : Group
    @State var showTabButtons : Bool = true
    
    @EnvironmentObject var userVM: UserViewModel
    
    
    
    var body: some View {
        ZStack{
            
            ZStack{
                if tabIndex == .home{
                    HomeScreen()
                }else if tabIndex == .friends{
                   FriendsView()
                }else if tabIndex == .schedule{
                    ScheduleView(calendar: Calendar(identifier: .gregorian))
                }else if tabIndex == .user{
                    CurrentUserProfilePage()
                }
            }.opacity(userVM.showAddContent ? 0.2 : 1).disabled(userVM.showAddContent).onTapGesture {
                if userVM.showAddContent {
                    userVM.showAddContent.toggle()
                    userVM.hideTabButtons.toggle()
                }
            }
            
         
            
                
                VStack{
                    Spacer()
                    
                    HStack(spacing: 40){
                        Button(action:{
                            UIDevice.vibrate()
                            
                            self.tabIndex = .home
                        },label:{
                                
                            Image(systemName: self.tabIndex == .home ? "house.fill" : "house").font(.title)
                             
                            
                            
                        }).foregroundColor(self.tabIndex == .home ? Color("AccentColor") : FOREGROUNDCOLOR)
                        Button(action:{
                            UIDevice.vibrate()
                            
                            self.tabIndex = .friends
                        },label:{
                            
                            ZStack{
                                Image(systemName: self.tabIndex == .friends ? "person.3.fill" : "person.3").font(.title2)
                                
                                if self.userVM.user?.userNotificationCount ?? 0 != 0 {
                                    ZStack{
                                        Circle().foregroundColor(Color("AccentColor")).frame(width: 22, height: 22)
                                        Text("\(self.userVM.user?.userNotificationCount ?? 0)").foregroundColor(Color.yellow).font(.body)
                                    }.offset(x: 13, y: -15)
                                }
                                
                                
                            }
                            
                            
                        }).foregroundColor(self.tabIndex == .friends ? Color("AccentColor") : FOREGROUNDCOLOR)

                        
                            Button(action:{
                                userVM.hideTabButtons.toggle()
                                userVM.showAddContent.toggle()
                            },label:{
                                
                            ZStack{
                                Circle().frame(width: 50, height: 50).foregroundColor(Color("AccentColor"))
                                Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 30))

                            }
                            
                            })
                        
                                
                        
                        Button(action:{
                            UIDevice.vibrate()
                            
                            self.tabIndex = .schedule
                        },label:{
                            Image(systemName: self.tabIndex == .schedule ?  "text.book.closed.fill" : "text.book.closed").font(.title2)
                            
                        }).foregroundColor(self.tabIndex == .schedule ? Color("AccentColor") : FOREGROUNDCOLOR)
                        
                        
                        Button(action:{
                            UIDevice.vibrate()
                            
                            self.tabIndex = .user
                        },label:{
                            WebImage(url: URL(string: userVM.user?.profilePicture ?? " "))
                                .resizable()
                                .scaledToFill()
                                .frame(width:30,height:30)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color("AccentColor"), lineWidth: self.tabIndex == .user ? 3 : 1))
                            
                        }).foregroundColor(self.tabIndex == .user ? Color("AccentColor") : FOREGROUNDCOLOR)
                        
                        
                    }.frame(width: UIScreen.main.bounds.width).padding().padding(.bottom).background(Color("Color"))
                }.opacity(userVM.hideTabButtons ? 0 : 1)
            
         
            
           BottomSheetView(isOpen: Binding(get: {userVM.showAddContent}, set: {userVM.showAddContent = $0}), maxHeight: UIScreen.main.bounds.height / 3){
               HomescreenAddContentView()
            }
            
            
        }.edgesIgnoringSafeArea(.all)
    }
}


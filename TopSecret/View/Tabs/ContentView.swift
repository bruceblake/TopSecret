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
    
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    
    
    var body: some View {
        
        //if there is a user signed in then go to the Tab View else go to the register view
        
        
        ZStack(alignment: .top){
            if userVM.userSession != nil{
                NavigationView{
                    Tabs(tabIndex: $tabIndex, selectedGroup: $selectedGroup)
                }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).navigationViewStyle(.stack)
                
                
                
                
                
                
                
                if userVM.isConnected == false{
                    HStack{
                        Text("You are not connected!").foregroundColor(Color("AccentColor"))
                    }.padding().background(Color("Color")).cornerRadius(16).shadow(color: Color.black,radius: 3).animation(.easeIn, value: userVM.isConnected).padding(.top,30)
                }else if showNotification{
                    HStack{
                        Text("\(userVM.currentNotification?.value ?? " ")").foregroundColor(Color("AccentColor"))
                    }.padding().background(Color("Color")).cornerRadius(16).shadow(color: Color.black,radius: 3).animation(.easeIn, value: showNotification).padding(.top,40)
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().colorScheme(.dark)
    }
}







enum Tab {
    case search, notifications, home, schedule, user
}

struct EmptyGroupHomescreen : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var groupVM = GroupViewModel()
    @State var goToCreateGroupView : Bool = false
    
    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                Spacer()
                
                VStack{
                    Text("You are not in any groups.")
                    
                    
                    HStack{
                        Spacer()
                        
                        Button(action:{
                            self.goToCreateGroupView.toggle()
                        },label:{
                            Text("Create a group")
                        }).foregroundColor(Color("Foreground"))
                            .padding(.vertical,10)
                            .frame(width: UIScreen.main.bounds.width/3).background(Color("AccentColor")).cornerRadius(15).fullScreenCover(isPresented: $goToCreateGroupView, content: {
                                CreateGroupView()
                            })
                        
                        
                        
                        
                        
                        Spacer()
                    }
                    
                }
                
                
                Spacer()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct Tabs : View {
    
    @Binding var tabIndex : Tab
    @Binding var selectedGroup : Group
    @State var showTabButtons : Bool = true
    
    @EnvironmentObject var userVM: UserViewModel
    
    
    
    var body: some View {
        ZStack{
            
            if tabIndex == .search{
                Text("Search")
            }else if tabIndex == .notifications{
                UserNotificationView()
            }else if tabIndex == .home{
                HomeScreen()
                
            }else if tabIndex == .schedule{
                ScheduleView()
            }else if tabIndex == .user{
                UserProfilePage(user: Binding(get: {userVM.user ?? User()}, set: {_ in}), isCurrentUser: true)
            }
            
            if showTabButtons {
                
                VStack{
                    Spacer()
                    
                    HStack(spacing: 50){
                        Spacer()
                        Button(action:{
                            UIDevice.vibrate()
                            self.tabIndex = .search
                        },label:{
                            Image(systemName: "magnifyingglass").font(.title2)
                            
                        }).foregroundColor(self.tabIndex == .search ? Color("AccentColor") : FOREGROUNDCOLOR)
                        
                        Button(action:{
                            UIDevice.vibrate()
                            
                            self.tabIndex = .notifications
                        },label:{
                            
                            ZStack{
                                Image(systemName: self.tabIndex == .notifications ? "heart.fill" : "heart").font(.title2)
                                
                                if self.userVM.user?.userNotificationCount ?? 0 != 0 {
                                    ZStack{
                                        Circle().foregroundColor(Color("AccentColor")).frame(width: 22, height: 22)
                                        Text("\(self.userVM.user?.userNotificationCount ?? 0)").foregroundColor(Color.yellow).font(.body)
                                    }.offset(x: 13, y: -15)
                                }
                                
                                
                            }
                            
                            
                        }).foregroundColor(self.tabIndex == .notifications ? Color("AccentColor") : FOREGROUNDCOLOR)
                        
                        
                        
                        ZStack{
                            
                            
                            
                            
                            Button(action:{
                                UIDevice.vibrate()
                                
                                self.tabIndex = .home
                            },label:{
                                Image(systemName: self.tabIndex == .home ? "house.fill" : "house").font(.title)
                                
                            }).foregroundColor(self.tabIndex == .home ? Color("AccentColor") : FOREGROUNDCOLOR)
                            
                            
                        }
                        
                        
                        
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
                            WebImage(url: URL(string: userVM.user?.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:35,height:35)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color("AccentColor"), lineWidth: self.tabIndex == .user ? 3 : 1))
                            
                        }).foregroundColor(self.tabIndex == .user ? Color("AccentColor") : FOREGROUNDCOLOR)
                        
                        
                        Spacer()
                    }.padding([.bottom,.horizontal],35).padding(.top,30).background(Color("Color"))
                }
                
            }
            
        }.edgesIgnoringSafeArea(.all)
    }
}

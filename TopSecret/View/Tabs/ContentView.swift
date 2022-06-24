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



struct ContentView: View {
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    @EnvironmentObject var tabVM : TabViewModel
    @StateObject var pollVM = PollViewModel()
    @State var tabIndex : Tab = .home
    @State var showNotification : Bool = false
    @State var selectedGroup : Group = Group()

    @Environment(\.scenePhase) var scenePhase
    
    
    
    
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
                userVM.setUserActivity(isActive: false, userID: userVM.user?.id ?? " ", completion: { fetchedUser in
                    userVM.user = fetchedUser
                })
            }
        }.onAppear{
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                userVM.fetchGroup(groupID: userVM.user?.selectedGroup ?? " ") { fetchedGroup in
                    self.selectedGroup = fetchedGroup
                }
            }
            
          
                
                

             
                
               
             
            
           
            
        }.onReceive(userVM.$userSelectedGroup) { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                userVM.fetchGroup(groupID: userVM.user?.selectedGroup ?? " ") { fetchedGroup in
                    self.selectedGroup = fetchedGroup
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
    case games, voting, home, schedule, groups
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
            
            if tabIndex == .games{
                GameView()
            }else if tabIndex == .voting{
                VotingView()
            }else if tabIndex == .home{
                HomeScreen()
         
            }else if tabIndex == .schedule{
                ScheduleView()
            }else if tabIndex == .groups{
                if userVM.groups.isEmpty{
                    EmptyGroupHomescreen()
                }else{
                    GroupHomeScreenView(showTabButtons: $showTabButtons, group: $selectedGroup)
                }
            }
            
            if showTabButtons {
            
            VStack{
                Spacer()
            
                HStack(spacing: 50){
                    Spacer()
                    Button(action:{
                        UIDevice.vibrate()
                        self.tabIndex = .games
                    },label:{
                        Image(systemName: self.tabIndex == .games ? "gamecontroller.fill" : "gamecontroller").font(.title2)
                        
                    }).foregroundColor(self.tabIndex == .games ? Color("AccentColor") : FOREGROUNDCOLOR)
                    
                    Button(action:{
                        UIDevice.vibrate()

                        self.tabIndex = .voting
                    },label:{
                        Image(self.tabIndex == .voting ? "Poll Icon Colored" : "Poll Icon").resizable().frame(width: 30, height: 40)
                        
                    })
                    
                    
                    ZStack{
                        
                      
                        
                        
                        Button(action:{
                            UIDevice.vibrate()

                            self.tabIndex = .home
                        },label:{
                            Image(systemName: self.tabIndex == .home ? "house.fill" : "house").font(.title)
                            
                        }).foregroundColor(self.tabIndex == .home ? Color("AccentColor") : FOREGROUNDCOLOR)
                        
                        Button(action:{
                            
                        },label:{
                            Image(systemName: "plus")
                        }).offset(y: -30).foregroundColor(Color.orange)
                    }
                
                    
                    
                    Button(action:{
                        UIDevice.vibrate()

                        self.tabIndex = .schedule
                    },label:{
                        Image(systemName: self.tabIndex == .schedule ?  "calendar.circle.fill" : "calendar.circle").font(.title2)
                        
                    }).foregroundColor(self.tabIndex == .schedule ? Color("AccentColor") : FOREGROUNDCOLOR)
                    
                    Button(action:{
                        UIDevice.vibrate()

                        self.tabIndex = .groups
                    },label:{
                        Image(systemName: self.tabIndex == .groups ? "person.3.fill" : "person.3").font(.title2)
                        
                    }).foregroundColor(self.tabIndex == .groups ? Color("AccentColor") : FOREGROUNDCOLOR)
                    
                    
                    Spacer()
                }.padding([.bottom,.horizontal],35).padding(.top,30).background(Color("Color"))
            }
            
        }
            
        }.edgesIgnoringSafeArea(.all)
    }
}

//
//  HomeScreenView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/30/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    @EnvironmentObject var tabVM : TabViewModel
    @StateObject var pollVM = PollViewModel()
    @State var tabIndex : Tab = .home
    @State var showNotification : Bool = false
    @Environment(\.scenePhase) var scenePhase
    
    
    var body: some View {
        
        //if there is a user signed in then go to the Tab View else go to the register view
        
        
        ZStack(alignment: .top){
            if userVM.userSession != nil{
                    NavigationView{
                        TabView(tabIndex: $tabIndex)
                    }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).navigationViewStyle(.stack)
                    
                    
                    
                
               
                
                
                if userVM.isConnected == false{
                    HStack{
                        Text("You are not connected!").foregroundColor(Color("AccentColor"))
                    }.padding().background(Color("Color")).cornerRadius(16).shadow(color: Color.black,radius: 3).animation(.easeIn, value: userVM.isConnected).padding(.top,30)
                }else if showNotification{
                    HStack{
                        Text("\(userVM.currentNotification?.value ?? "")").foregroundColor(Color("AccentColor"))
                    }.padding().background(Color("Color")).cornerRadius(16).shadow(color: Color.black,radius: 3).animation(.easeIn, value: showNotification).padding(.top,40)
                }
                
            }else {
                LoginView()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onReceive(userVM.$userNotificationCount) { count in
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
                    userVM.setUserActivity(isActive: true, userID: userVM.user?.id ?? "", completion: { fetchedUser in
                        userVM.user = fetchedUser
                    })
                }
            }else if newPhase == .background{
                userVM.setUserActivity(isActive: false, userID: userVM.user?.id ?? "", completion: { fetchedUser in
                    userVM.user = fetchedUser
                })
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
    case voting, groups, home, schedule, map
}

struct TabView : View {
    @Binding var tabIndex : Tab
    
    var body: some View {
        ZStack{
            
            if tabIndex == .voting{
                VotingView()
            }else if tabIndex == .groups{
                GroupView()
            }else if tabIndex == .home{
                HomeScreenView()
            }else if tabIndex == .schedule{
                ScheduleView()
            }else if tabIndex == .map{
                MapView()
            }
            
            VStack{
                Spacer()
                
                HStack(spacing: 50){
                    Spacer()
                    Button(action:{
                        self.tabIndex = .voting
                    },label:{
                        Image(systemName: "checkmark").font(.title2)
                        
                    }).foregroundColor(self.tabIndex == .voting ? Color("AccentColor") : FOREGROUNDCOLOR)
                    Button(action:{
                        self.tabIndex = .groups
                    },label:{
                        Image(systemName: "person.3.fill").font(.title2)
                        
                    }).foregroundColor(self.tabIndex == .groups ? Color("AccentColor") : FOREGROUNDCOLOR)
                    Button(action:{
                        self.tabIndex = .home
                    },label:{
                        Image(systemName: "house").font(.title)
                        
                    }).foregroundColor(self.tabIndex == .home ? Color("AccentColor") : FOREGROUNDCOLOR)
                    Button(action:{
                        self.tabIndex = .schedule
                    },label:{
                        Image(systemName: "text.book.closed").font(.title2)
                        
                    }).foregroundColor(self.tabIndex == .schedule ? Color("AccentColor") : FOREGROUNDCOLOR)
                    Button(action:{
                        self.tabIndex = .map
                    },label:{
                        Image(systemName: "map").font(.title2)
                        
                    }).foregroundColor(self.tabIndex == .map ? Color("AccentColor") : FOREGROUNDCOLOR)
                    Spacer()
                }.padding([.bottom,.horizontal],35).padding(.top,30).background(Color("Color"))
            }
            
        }.edgesIgnoringSafeArea(.all)
    }
}


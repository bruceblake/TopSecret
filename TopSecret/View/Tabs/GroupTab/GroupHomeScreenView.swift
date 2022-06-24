//
//  GroupProfileView.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/23/21.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct GroupHomeScreenView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    @StateObject var groupVM = GroupViewModel()
    @StateObject var messageVM = MessageViewModel()
    @State var _user: User = User()
    @State var goToUserProfile: Bool = false
    @State var text: String = ""
    @State var countdownName: String = ""
    @State var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @State var showAddContentView : Bool = false
    @State var timer : Timer? = nil
    @State var offset : CGSize = .zero
    @State var showMapView : Bool = false
    @Binding var showTabButtons : Bool
    
    @Binding var group : Group
    
    @Environment(\.presentationMode) var dismiss

    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    
                    HStack{
                        Button(action:{
                                dismiss.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: "house")
                                    .resizable()
                                    .frame(width: 22, height: 22).foregroundColor(Color("Foreground"))
                                
                            }
                        })
                        
                        NavigationLink(destination: EmptyView()) {
                            Text("Cash").foregroundColor(FOREGROUNDCOLOR)
                        }
                        
                    }.padding(.leading)
                  
                    
                    Spacer()
                    
                    VStack{
                        
                        Button(action:{
                            //TODO
                        },label:{
                            WebImage(url: URL(string: group.groupProfileImage ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                        })
                       
                        
                        Text("\(group.groupName)")
                            .fontWeight(.bold)
                            .font(.headline)
                        
                        Text("\(groupVM.activeUsers.count) \(groupVM.activeUsers.count == 1 ? "member active" : "members active")")
                    }.padding(10).background(Color("Color")).cornerRadius(12)
                   
                    
                    Spacer()
                    
                
                    HStack(spacing: 10){
                        
                        Button(action:{
                            withAnimation{ self.showAddContentView.toggle()
                          
                            }
                           
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                
                            }
                        })
                        
                        NavigationLink(
                            destination: GroupProfileView(group: $group),
                            label: {
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                    Image(systemName: "person.3.fill")
                                        .resizable()
                                        .frame(width: 24, height: 16).foregroundColor(Color("Foreground"))
                                    
                                }
                            })
                    }.padding(.trailing)
                    
                    
                    
                }.padding(.top,50)
                
                Divider()
                
                Countdowns(group: group, action: {
                    //TODO
                })
                
                Divider()
                
              
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        
                        NavigationLink(destination: ChatView(uid: userVM.user?.id ?? " ", chat: groupVM.groupChat), label: {
                            GroupChatCell(message: messageVM.readLastMessage(), chat: groupVM.groupChat)

                        }).frame(width: UIScreen.main.bounds.width)
                        
                        
                        Text("Calendar!").frame(width: UIScreen.main.bounds.width)
                    }
                }
//
//                ScrollView{
//                    VStack{
//                        ForEach(){ notification in
//
//                        }
//                    }
//                }
                 
                    
                   
                   
                
//
//
//                SearchBar(text: $searchRepository.searchText, placeholder: "Search").padding()
//
//                ScrollView(){
//                    VStack(alignment: .leading){
//                        VStack(alignment: .leading){
//                            if !searchRepository.searchText.isEmpty{
//                                Text("Users").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
//                            }
//                            VStack{
//                                ForEach(searchRepository.userReturnedResults) { user in
//                                    Button(action: {
//                                        _user = user
//                                    },label:{
//                                        UserSearchCell(user: user)
//                                    })
//
//                                }
//                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
//                        }
//
//
//
//                    }
//
//
//                }
//
//                Button(action:{
//
//                    groupVM.inviteToGroup(user1: userVM.user ?? User(), user2: _user, group: group)
//                },label:{
//                    Text("Add User")
//                }).padding(.bottom,50)
                
                
              
//
                Spacer()
                
            
                
                
                
            }
            
         
            
            if showMapView{
                VStack{
                    MapView(showMapView: $showMapView, showTabButtons: $showTabButtons)
                }
              
            }
            
           
            if showAddContentView {
                ZStack{
                    Color("Background")
                    AddContentView(showAddContentView: $showAddContentView, group: $group).padding().frame(width: UIScreen.main.bounds.width/2).background(Color("Color")).cornerRadius(16).padding(.top,30)
                }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).onTapGesture {
                    showAddContentView.toggle()
                }
                  
            }
            
                
        }.gesture(
        
            DragGesture()
                .onChanged({ value in
                    offset = value.translation
                    if !showMapView {
                        if offset.height <= -150{
                            withAnimation(.spring()){
                                showMapView.toggle()
                                showTabButtons.toggle()
                            }
                        }
                    }
              
                    
                })
                .onEnded({ value in
                    if !showMapView{
                        offset = .zero
                    }
                })
        
        ).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            groupVM.getChat(chatID: group.chatID ?? "")
            messageVM.readAllMessages(chatID: group.chatID ?? "", userID: userVM.user?.id ?? "", chatType: "groupChat")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                groupVM.loadActiveUsers(group: group)
            })
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
                userVM.countdownDurationTimer += 1
            }
            
        }
            
    .onDisappear{
            timer?.invalidate()
            timer = nil
    }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

struct Countdowns : View {
    
    
    @State var index = 0
    @State var isChanging: Bool = true
    @State var group: Group
    @State var countdowns : [CountdownModel] = []
    @State var timer : Timer? = nil
    @StateObject var groupVM = GroupViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @State var timeRemaining = ""
    var action : () -> Void
    
    func getCountdown(index: Int, countdowns: [CountdownModel]) -> Text {
        if countdowns.isEmpty{
            return Text("Countdowns!")
        }else{
            return
                Text(countdowns[index].countdownName ?? "")
            
        }
    }
    
    
    func convertComponentsToDate(days: Int, hours: Int, minutes: Int, seconds: Int) -> String {
        var ans = ""
    
    
        
        let noDays = (days <= 0)
        let noHours = (hours <= 0)
        let noMinutes = (minutes <= 0)
        let noSeconds = (seconds <= 0)
        
        if(noDays && noHours && noMinutes && noSeconds){
            ans = "Finished!"
                     
        }else if(noDays && noHours && noMinutes && !noSeconds){
            ans = "\(seconds) secs"
        }else if(noDays && noHours && !noMinutes){
            ans = "\(minutes) mins"
        }else if (noDays && !noHours && noMinutes){
            ans = "\(hours) hrs"
        }else if (!noDays && noHours && noMinutes){
            ans = "\(days) days"
        }else if (!noDays && !noHours && !noMinutes){
            ans = "\(days) days \(hours) hrs \(minutes) mins"
        }else if (!noDays && !noHours && noMinutes){
            ans = "\(days) days \(hours) hrs"
        }else if (!noDays && noHours && !noMinutes){
            ans = "\(days) days \(hours) hrs"
        }else if (noDays && !noHours && !noMinutes){
            ans = "\(hours) hrs \(minutes) mins"
        }else if (noDays && noHours && !noMinutes && !noSeconds){
            ans = "\(minutes) mins \(seconds) secs"
        }
        
        return ans
        
    }
    
    
    
    
   
    
    var body: some View {
            
            Button(action:{
                //TODO
            },label:{
                VStack{
                    getCountdown(index: index, countdowns: countdowns).fontWeight(.bold)
                    Text(timeRemaining).foregroundColor(.green)
                }
            }).foregroundColor(FOREGROUNDCOLOR)

        .onAppear{
            groupVM.loadGroupCountdowns(group: group)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                countdowns = groupVM.countdowns
            }


            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true){ tempTimer in
                if index != countdowns.count - 1 {
                    withAnimation(.easeOut){
                        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: (countdowns.isEmpty ? Date() : countdowns[index].endDate?.dateValue() ?? Date()))

                        let daysRemaining = components.day ?? 0
                        let hoursRemaining = components.hour ?? 0
                        let minutesRemaining = components.minute ?? 0
                        let secondsRemaining = components.second ?? 0
                        
                        self.timeRemaining = self.convertComponentsToDate(days: daysRemaining, hours: hoursRemaining, minutes: minutesRemaining, seconds: secondsRemaining)
                        index = index + 1
                    }
                }else{
                    
                    withAnimation(.easeOut){
                        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: (countdowns.isEmpty ? Date() : countdowns[index].endDate?.dateValue() ?? Date()))

                        let daysRemaining = components.day ?? 0
                        let hoursRemaining = components.hour ?? 0
                        let minutesRemaining = components.minute ?? 0
                        let secondsRemaining = components.second ?? 0
                        
                        self.timeRemaining = self.convertComponentsToDate(days: daysRemaining, hours: hoursRemaining, minutes: minutesRemaining, seconds: secondsRemaining)
                        index = 0
                    }
                }
        
            }
            
            

        }.onDisappear{
            timer?.invalidate()
            timer = nil
        }.onReceive(userVM.$countdownDurationTimer, perform: { _ in
            let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: (countdowns.isEmpty ? Date() : countdowns[index].endDate?.dateValue() ?? Date()))

            let daysRemaining = components.day ?? 0
            let hoursRemaining = components.hour ?? 0
            let minutesRemaining = components.minute ?? 0
            let secondsRemaining = components.second ?? 0
            
            self.timeRemaining = self.convertComponentsToDate(days: daysRemaining, hours: hoursRemaining, minutes: minutesRemaining, seconds: secondsRemaining)
        })
    }
}

//struct GroupHomeScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupHomeScreenView(group: Group())
//    }
//}

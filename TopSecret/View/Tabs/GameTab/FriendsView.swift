//
//  FriendsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendsView: View {
    
    
    //problem: must store each friends text field text in friendsview
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var searchVM = SearchRepository()
    @StateObject var personalChatVM : PersonalChatViewModel
    @State var openGroupChatView: Bool = false
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    
    
    func sortPersonalChats(userID: String) -> [ChatModel]{
        let chats = userVM.personalChats 
        
        return chats.sorted(by: { !($0.usersThatHaveSeenLastMessage?.contains(userID) ?? false) &&  ($1.usersThatHaveSeenLastMessage?.contains(userID) ?? false)} )
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                VStack(alignment: .leading, spacing: 3){
                    HStack(spacing: 2){
                        Text("\(userVM.personalChats.count) \(userVM.personalChats.count > 1 ? "friends" : "friend")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                        
                        Text(", \(userVM.groups.count) \(userVM.groups.count > 0 ? "groups" : "group")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                        
                        Spacer()
                    }
                    HStack(spacing: 3){
                        Text("4 friend requests").foregroundColor(Color.gray)
                        Button(action:{
                            
                        },label:{
                            Text("See all").foregroundColor(Color("AccentColor"))
                        })
                    }
                    
//                    HStack{
//
//                        Text("0 incoming requests").padding(5).padding(.horizontal,5).background(RoundedRectangle(cornerRadius: 12).fill(Color.red))
//
//                        Text("0 outgoing requests").padding(5).padding(.horizontal,5).background(RoundedRectangle(cornerRadius: 12).fill(Color.red))
//
//                    }
                }.padding(.horizontal,30)
                ScrollView{
                    VStack(spacing: 0){
                        if ((userVM.personalChats.isEmpty )) {
                            
                            Text("You have 0 friends")
                        }else{
                            ForEach(self.sortPersonalChats(userID: userVM.user?.id ?? " "), id: \.id){ chat in
                                if chat.chatType == "groupChat"{
                                    Button(action:{
                                        let dp = DispatchGroup()
                                        dp.enter()
                                        groupVM.changeCurrentGroup(groupID: chat.groupID ?? " ") { finishedFetching in
                                            dp.leave()
                                        }
                                        dp.notify(queue: .main, execute: {
                                            openGroupChatView.toggle()
                                        })
                                    },label:{
                                        GroupChatCell(chat: chat)
                                    })
                                    NavigationLink(destination:  HomeScreenView(chatID: chat.id, groupID: chat.groupID ?? " ", selectedOptionIndex: 1), isActive: $openGroupChatView) {
                                        EmptyView()
                                    }
                                  
                                }else{
                                    NavigationLink {
                                        PersonalChatView(personalChatVM: personalChatVM , chatID: chat.id)
                                    } label: {
                                        FriendCell(user: personalChatVM.getPersonalChatUser(chat: chat, userID: userVM.user?.id ?? " "), personalChatVM: personalChatVM, chat: chat)
                                    }
                                }
                                
                                

                                }
                        }
                  
                    }.padding(.bottom, UIScreen.main.bounds.height/4)
                    
                }
            }
            
          


        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
}



struct GroupChatCell : View {
    @EnvironmentObject var userVM: UserViewModel
    
    
    func getTimeSinceMessage(lastMessageDate: Date) -> String{
        let interval = (Date() - lastMessageDate)
        
        
        let seconds = interval.second ?? 0
        let minutes = (seconds / 60)
        let hours = (minutes / 60)
        let days = (hours / 24)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
        }
        if time == "0s"{
            return "now"
        }else{
            return time
        }
        
    }
    var chat: ChatModel
    var body: some View {
        VStack(alignment: .leading){
            
            
            //Message indicator
            HStack(alignment: .center){
                
                if !((chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? " ") ?? false)){
                    
                    
                    Circle().frame(width: 12, height: 12).foregroundColor(Color("AccentColor"))
                }
                
                
                //Profile Picture
                WebImage(url: URL(string: chat.profileImage ?? " "))
                    .resizable()
                    .scaledToFill()
                    .frame(width:48,height:48)
                    .clipShape(Circle())
                
                HStack(alignment: .center){
                    
                    VStack(alignment: .leading, spacing: 0){
                        
                        VStack(alignment: .leading, spacing: 2){
                            Text("\(chat.name ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.headline)

                        }
   
                    }
                    
                }
                Spacer()
                
                
                
                VStack(alignment: .leading, spacing: 5){
                    Text("\(self.getTimeSinceMessage(lastMessageDate: chat.lastActionDate?.dateValue() ?? Date() ))").font(.subheadline).foregroundColor(Color.gray)
                    
                    if(chat.usersTypingID.contains(userVM.user?.id ?? " ")){
                        Image(systemName: "pencil.line").foregroundColor(Color("AccentColor"))
                    }
                }
                
            }.padding()
        }.padding(.horizontal,10).background(Rectangle().stroke(Color("Color")))
    }
}

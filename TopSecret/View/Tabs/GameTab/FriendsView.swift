//
//  FriendsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI

struct FriendsView: View {
    
    
    //problem: must store each friends text field text in friendsview
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var searchVM = SearchRepository()
    @StateObject var personalChatVM : PersonalChatViewModel
    
    
    
    func sortPersonalChats(userID: String) -> [ChatModel]{
        let chats = userVM.personalChats 
        
        return chats.sorted(by: { !($0.usersThatHaveSeenLastMessage?.contains(userID) ?? false) &&  ($1.usersThatHaveSeenLastMessage?.contains(userID) ?? false)} )
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                VStack(alignment: .leading, spacing: 3){
                    HStack{
                        Text("\(userVM.personalChats.count) \(userVM.personalChats.count > 1 ? "friends" : "friend")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
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
                                NavigationLink {
                                    PersonalChatView(personalChatVM: personalChatVM , chatID: chat.id)
                                } label: {
                                    FriendCell(user: personalChatVM.getPersonalChatUser(chat: chat, userID: userVM.user?.id ?? " "), personalChatVM: personalChatVM, chat: chat)
                                }

                                }
                        }
                  
                    }.padding(.bottom, UIScreen.main.bounds.height/4)
                    
                }
            }
            
          


        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
}


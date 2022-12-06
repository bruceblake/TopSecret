//
//  FriendsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI

struct FriendsView: View {
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
                VStack(spacing: 5){
                    HStack{
                        Text("\(userVM.personalChats.count) \(userVM.personalChats.count > 1 ? "friends" : "friend")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                        Spacer()
                    }
                }.padding(.horizontal,30)
                ScrollView{
                    VStack(spacing: 0){
                        if ((userVM.personalChats.isEmpty ?? false)) {
                            
                            Text("You have 0 friends")
                        }else{
                            ForEach(self.sortPersonalChats(userID: userVM.user?.id ?? " "), id: \.id){ chat in
                                NavigationLink {
                                    PersonalChatView(personalChatVM: personalChatVM, keyboardVM: KeyboardViewModel(), chatID: chat.id)
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


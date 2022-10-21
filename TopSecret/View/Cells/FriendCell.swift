//
//  FriendCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendCell: View {
    var user: User
   @StateObject var personalChatVM: PersonalChatViewModel
    var chat: ChatModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
    
            VStack(alignment: .leading){
                HStack(alignment: .center){
                    
                    if !((chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? " ") ?? false)){
                      
                        
                            Circle().frame(width: 12, height: 12).foregroundColor(Color("AccentColor"))
                    }
                    
                    
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:48,height:48)
                    .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 0){
                        Text("\(user.nickName ?? "")").foregroundColor(Color("Foreground")).bold()
                        
                        HStack{
                            if chat.usersTypingID.contains(user.id ?? ""){
                                Text("is typing...").foregroundColor(Color("AccentColor"))
                            }else{
                        Text("\( (chat.lastMessage ?? Message() ).messageValue ?? "")")
                            
                            
                            Spacer()
                            Text("\( (chat.lastMessage ?? Message() ).timeStamp?.dateValue() ?? Date(), style: .time)")
                        }
                        }.foregroundColor(.gray)
                    }
                    
                    Spacer()
                }.padding()
            }.padding(.horizontal,10).background(Rectangle().stroke(Color("Color"))).onAppear{
                for user in chat.usersTyping{
                    print("username: \(user.username ?? " ")")
                }
            }
    }
}



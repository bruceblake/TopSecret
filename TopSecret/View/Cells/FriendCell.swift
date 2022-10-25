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
    
    
    func getTimeSinceMessage(lastMessageDate: Date) -> String{
       let interval = (Date() - lastMessageDate)
        
        
        var seconds = interval.second ?? 0
        var minutes = (seconds / 60)
        var hours = (minutes / 3600)
        
        if seconds < 60{
            return "\(seconds)s"
        }else if seconds < 3600  {
            return "\(minutes)m"
        }else if seconds < 86400 {
            return "\(hours)h"
        }
        
        return ""
        
    }
    
    var body: some View {
    
            VStack(alignment: .leading){
                
                
                //Message indicator
                HStack(alignment: .center){
                    
                    if !((chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? " ") ?? false)){
                      
                        
                            Circle().frame(width: 12, height: 12).foregroundColor(Color("AccentColor"))
                    }
                    
                    
                    //Profile Picture
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:48,height:48)
                    .clipShape(Circle())
                    
                    HStack(alignment: .center){
                        
                        VStack(alignment: .leading, spacing: 0){
                            
                            VStack(alignment: .leading, spacing: 2){
                            Text("\(user.nickName ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.headline)
                                
                            
                        
                             
                            
                            
                                HStack(alignment: .center){
                                if chat.usersTypingID.contains(user.id ?? ""){
                                    Text("is typing...").foregroundColor(Color("AccentColor"))
                                }else{
                           
                                    if (chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? "") ?? false ){
                                        
                                        Text("\( (chat.lastMessage ?? Message() ).messageValue ?? "")").lineLimit(1).foregroundColor(Color.gray).font(.subheadline
                                        )
                                             
                                    }else{
                                        Text("\( (chat.lastMessage ?? Message() ).messageValue ?? "")").lineLimit(1).foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                    }
                                      
                                
                                    
                                
                                
                               
                            }
                            }.foregroundColor(.gray)
                                
                                if ((chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? " ") ?? false)){
                                  
                                    
                                    if (chat.usersThatHaveSeenLastMessage?.contains(user.id ?? "") ?? false){
                                        HStack(alignment: .center){
                                            
                                            Image(systemName: "play").foregroundColor(Color("AccentColor")).font(.caption)
                                            Text("Read").foregroundColor(Color.gray).font(.subheadline)
                                           
                                            
                                        }
                                            
                                          
                                        
                                    }else{
                                        HStack(alignment: .center){
                                            
                                            
                                            Image(systemName: "play.fill").foregroundColor(Color("AccentColor")).font(.caption)
                                            
                                            Text("Delivered").foregroundColor(Color.gray).font(.subheadline)
                                            
                                          
                                          
                                            
                                        }
                                        
                                    }
                                    
                                  
                                }
                            
                        }
                            
                            
                           
                                  
                            }
                            
                        }
                        Spacer()
                        
                            
                
                    Text("\(self.getTimeSinceMessage(lastMessageDate: chat.lastMessage?.timeStamp?.dateValue() ?? Date() ))").font(.subheadline).foregroundColor(Color.gray)
                    
                }.padding()
            }.padding(.horizontal,10).background(Rectangle().stroke(Color("Color")))
    }
}



//
//  GroupChatView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupChatView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var groupVM: SelectedGroupViewModel
    @StateObject var chatVM = GroupChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    var userID: String
    var groupID: String
    var chatID: String
    @State var text = ""
    
    
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                //Top Bar
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    
                    
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "info")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    
                    Text("\(groupVM.group?.groupName ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.largeTitle)
                    
                    Spacer()
                    
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "video.fill")
                                .font(.headline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "gear")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                }.padding(.horizontal).padding(.top,40)
                
                
                //Active Users
                VStack{
                ScrollView(.horizontal){
                    HStack(spacing: 0){
                        ForEach(chatVM.groupChat?.users ?? [], id: \.id){ user in
                            
                            NavigationLink(destination: UserProfilePage(user: user), label:{
                                
                                VStack(spacing: 5){
                                    WebImage(url: URL(string: user.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(chatVM.usersIdling.contains(user) ? Color(chatVM.getColor(userID: user.id ?? "", groupChat: chatVM.groupChat ?? ChatModel())) : Color.gray,lineWidth: 2))
                                    
                                    Text("\(user.nickName ?? "TOP SECRET USER")").foregroundColor(FOREGROUNDCOLOR)
                                }
                                
                                
                                
                            }).padding(.leading,5).padding(.top,5)
                            
                            
                            
                            
                            
                        }
                    }
                    
                    
                }
                Divider()
            }
                
                
                VStack{
                    ForEach(chatVM.messages){ message in
                        Text("\(message.id)")
                    }
                }
                
                Spacer()
                HStack{
                    TextField("Message", text: $text)
                    Spacer()
                    Button(action:{
                        
                    },label:{
                        Text("Send")
                    })
                }.padding(10).background(Color("Color")).cornerRadius(12).padding().padding(.bottom)
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            chatVM.listenToChat(chatID: chatID, groupID: groupID) { completed in
                print("fetched messages!")
            }
            chatVM.readAllMessages(chatID: chatID, groupID: groupID)
            chatVM.openChat(userID: userID, chatID: chatID, groupID: groupID)
        }.onDisappear{
            chatVM.exitChat(userID: userID, chatID: chatID, groupID: groupID)
        }.onReceive(chatVM.$usersIdling) { output in
            for user in output {
                print("user: \(user.username ?? " ")")
            }
        }
    }
}



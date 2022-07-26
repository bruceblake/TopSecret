//
//  UserProfilePage.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/3/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserProfilePage: View {
    
    @Binding var user: User
    var isCurrentUser: Bool
    @State var goToUserInfoPage : Bool = false
    @State var settingsOpen: Bool = false
    @State var showEditProfile: Bool = false
    @State var goToPersonalChat: Bool = false
    @State var personalChat: ChatModel = ChatModel()
    @State var isLoading: Bool = false
    
    @StateObject var chatVM = ChatViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    
    @Environment(\.presentationMode) var presentationMode
    
    
    
    
    var body: some View {
        
        ZStack{
            Color("Background")
            VStack{
                
                HStack(){
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                    
                    
                    Spacer()
                    
                    Button(action:{
                        
                    },label:{
                        
                        HStack(spacing: 0){
                            Text("\(user.nickName ?? "") ").fontWeight(.bold).font(.subheadline).lineLimit(1).foregroundColor(FOREGROUNDCOLOR)
                            Image(systemName: "chevron.down").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                        }
                        
                        
                        
                    }).padding(.leading,50)
                    
                    Spacer()
                    
                    HStack(spacing: 15){
                        
                        if isCurrentUser {
                            Button(action:{
                                self.showEditProfile.toggle()
                            },label:{
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                                    
                                    
                                    Image(systemName: "pencil.circle").resizable().frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                }
                            }).sheet(isPresented: $showEditProfile, content: {
                                UserEditProfilePageView(user: user).onDisappear(perform: {
                                    userVM.fetchUser(userID: self.user.id ?? "") { user in
                                        self.user = user
                                    }
                                })
                            })
                        }else{
                            Button(action:{
                                
                                
                                chatVM.createPersonalChat(user1: userVM.user?.id ?? "", user2: user.id ?? "") { personalChat in
                                    self.personalChat = personalChat
                                    self.goToPersonalChat.toggle()
                                }
                                
                            },label:{
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                                    
                                    
                                    Image(systemName: "bubble.left").resizable().frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                }
                                
                            })
                            
                            
                        }
                        
                        
                        if isCurrentUser {
                            
                            
                            
                            NavigationLink(destination: SettingsMenuView().onDisappear(perform: {
                                userVM.fetchUser(userID: self.user.id ?? "") { user in
                                    self.user = user
                                }
                            }), label: {
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                                    
                                    Image(systemName: "gear")
                                        .resizable()
                                        .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                    
                                    
                                }
                            })
                            
                        }else{
                            Button(action:{
                                self.goToUserInfoPage.toggle()
                            },label:{
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                    
                                    
                                    Image(systemName: "info.circle").resizable().frame(width: 24, height: 24).foregroundColor(Color("Foreground"))
                                }
                            })
                            
                        }
                    }.padding(10)
                    
                    
                    
                }.padding(.top,50)
                
                
                ScrollView{
                    HStack{
                        Spacer()
                        VStack(spacing: 10){
                            
                            
                            WebImage(url: URL(string: user.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:70,height:70)
                                .clipShape(Circle())
                            
                            HStack{
                                HStack{
                                    Text("@\(user.username ?? "")").foregroundColor(.gray).font(.caption)
                                    
                                    Menu(content:{
                                        
                                        if isCurrentUser{
                                            VStack{
                                                Button(action:{
                                                    userVM.setUserActivity(isActive: false, userID: user.id ?? "", completion: { fetchedUser in
                                                        self.user = fetchedUser
                                                    })
                                                },label:{
                                                    Text("Set to inactive")
                                                })
                                                
                                                Button(action:{
                                                    userVM.setUserActivity(isActive: true, userID: user.id ?? "", completion: { fetchedUser in
                                                        self.user = fetchedUser
                                                    })
                                                },label:{
                                                    Text("Set to active")
                                                })
                                                
                                            }
                                            
                                        }else{
                                            if user.isActive ?? false == false{
                                                Text("inactive since: \(user.lastActive?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                                            }else{
                                                Text("active: now")
                                            }
                                        }
                                        
                                        
                                        
                                        
                                    },label:{
                                        Circle().frame(width: 8, height: 8).foregroundColor(user.isActive ?? false ? Color.green : Color.red)
                                        
                                        
                                    })
                                    
                                    
                                }
                                
                                
                                
                            }
                            
                            
                            
                            
                            
                            Text("\(user.bio ?? "")")
                            
                            
                        }
                        Spacer()
                    }
                    
                    if isCurrentUser == false{
                        Button(action:{
                            userVM.addFriend(friend: self.$user.wrappedValue)
                        },label:{
                            Text("Add Friend").foregroundColor(FOREGROUNDCOLOR)
                        })
                    }
                    
                    
                    Divider()
                    VStack{
                        
                        
                        UserFriendsListView(user: $user)
                        
                        
                    }
                    Spacer()
                }
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            if isCurrentUser{
                self.user = userVM.user ?? User()
            
            }
            
            userVM.fetchUser(userID: user.id ?? " ") { fetchedUser in
                self.user = fetchedUser
            }
            
        }
        
        
    }
}


//struct UserProfilePage_Previews: PreviewProvider {
//    static var previews: some View {
//        UserProfilePage(user: User(dictionary: ["username":"bj_lao","nickName":"B R U C E","bio":"16","profilePicture":"https://firebasestorage.googleapis.com/v0/b/top-secret-dcb43.appspot.com/o/userProfileImages%2FdEUxJX1gXZcYViXUyLJTr0wf5RM2?alt=media&token=68acfeed-0dfb-496e-9929-82bdf70b1e80"]), isCurrentUser: true, personalChat: ChatModel()).environmentObject(UserViewModel()).colorScheme(.dark)
//    }
//}

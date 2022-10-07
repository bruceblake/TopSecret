//
//  UserProfilePage.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/17/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserProfilePage: View {
    
    var user: User
    @StateObject var chatVM = ChatViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    @State var showInfo : Bool = false
    @State var selectedIndex : Int = 0 
    
    @Environment(\.presentationMode) var presentationMode
    
    let columns : [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
        
        
    ]
    var body: some View {
        ZStack{
            Color("Background").zIndex(0)
            VStack{

                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,10)
                    
                    Spacer()
                    
                    Text("@\(user.username ?? "")")
                    
                    Spacer()
                    
                    Button(action:{
                        self.showInfo.toggle()
                    },label:{
                        Text("...").font(.title3)
                    }).padding(.trailing,10)
                    
                }.padding(.top,50)
                    
                  
                HStack{
                    
                    Spacer()
                    
                    VStack(spacing: 4){
                        Button(action:{
                            
                        },label:{
                            WebImage(url: URL(string: user.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:70,height:70)
                                .clipShape(Circle())
                        })
                        VStack(spacing: 7){
                            HStack{
                            Text("\(user.nickName ?? "")").font(.headline).bold()
                                Circle().foregroundColor((user.isActive ?? false) ? Color.green : Color.red).frame(width: 8, height: 8)
                            }
                            
                            if userVM.user?.pendingFriendsListID?.contains(user.id ?? "") ?? false {
                            Text("Pending Friend Request").foregroundColor(.gray)
                            }else if userVM.user?.friendsListID?.contains(user.id ?? "") ?? false{
                                Text("Friends").foregroundColor(.gray)
                            }else if userVM.user?.blockedAccountsID?.contains(user.id ?? "") ?? false{
                                Text("Blocked").foregroundColor(.gray)
                            }
                            else{
                                Button(action:{
                                    userVM.sendFriendRequest(friend: user)
                                },label:{
                                    Text("Send Friend Request").foregroundColor(FOREGROUNDCOLOR).padding(7).background(Color("AccentColor")).cornerRadius(16)
                                })
                            }
                        }
                       
                    }.padding(.leading)
                    
                   
                    
                    Spacer()
                    
                }.padding(.top,10)
              
               
                
                    
                //User Info
                HStack(spacing: 25){
                        
                        Spacer()
                        
                    Button(action:{
                        
                    },label:{
                        VStack{
                            Text("0").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                            Text("Tagged Posts").font(.callout).foregroundColor(.gray)
                        }
                    })
                    
                    Rectangle().frame(width: 1, height: 20).foregroundColor(.gray)
                    
                    
                    NavigationLink(destination: Text("Hello World")){
                        
                        VStack{
                            Text("\(user.groupsID?.count ?? 0)").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                            Text("Groups").font(.callout).foregroundColor(.gray)
                        }
                    }
                    
                    
                    
                    Rectangle().frame(width: 1, height: 20).foregroundColor(.gray)
                    
                    
                    NavigationLink(destination: UserFriendsListView(user: user)) {
                        VStack{
                            Text("\(user.friendsList?.count ?? 0)").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                            Text("Friends").font(.callout).foregroundColor(.gray)
                        }
                    }
                  
                        
                        
             
                      
                        
                        Spacer()
                        
                    }.padding(.vertical)
                
                Text("\(user.bio ?? "")").frame(width: UIScreen.main.bounds.width - 20).multilineTextAlignment(.center)
                
                
             
                //Media
                VStack{
                    HStack{
                        
                        Spacer()
                        
                        
                        Button(action:{
                            selectedIndex = 0
                        },label:{
                            Image(systemName: "square.grid.3x3").font(.title3)
                    
                        }).foregroundColor(FOREGROUNDCOLOR)
                        
                        Spacer()
                        
                        Button(action:{
                            selectedIndex = 1

                        },label:{
                                Image(systemName: "square.grid.3x3").font(.title3)
                        
                        }).foregroundColor(FOREGROUNDCOLOR)
                        
                        Spacer()
                        Button(action:{
                            selectedIndex = 2

                        },label:{
                            
                                Image(systemName: "square.grid.3x3").font(.title3)
                        
                        }).foregroundColor(FOREGROUNDCOLOR)
                        
                        Spacer()
                        
                        Button(action:{
                            selectedIndex = 3

                        },label:{
                            
                                Image(systemName: "square.grid.3x3").font(.title3)
                        
                        }).foregroundColor(FOREGROUNDCOLOR)
                        
                        Spacer()
                    }.padding(.horizontal,30)
                   
                }.padding(.vertical)
                 
                
                
                ScrollView(showsIndicators: false){
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(0..<12){ index in
                       
                            
                            Image(uiImage: UIImage(named: "Icon")!)
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width/3, height: 150)
                                .aspectRatio(contentMode: .fit)
                                .overlay(Rectangle().stroke(Color("Color"), lineWidth: 1))
                        

                        
                    }
                }
            }
                
                
                
                
            }.zIndex(1).opacity(showInfo ? 0.3 : 1).onTapGesture {
                if showInfo{
                    
                showInfo.toggle()
                }
            }.disabled(showInfo)
           
                
                
            BottomSheetView(isOpen: $showInfo, maxHeight: UIScreen.main.bounds.height * 0.45 ) {
                VStack{
                    Button(action:{
                        if userVM.user?.blockedAccounts?.contains(user) ?? false {
                            userVM.unblockUser(unblocker: userVM.user?.id ?? " ", blockee: user.id ?? " ")
                        } else {
                            userVM.blockUser(blocker: userVM.user?.id ?? " ", blockee: user.id ?? " ")
                        }
                    },label:{
                    Text("\(userVM.user?.blockedAccounts?.contains(user) ?? false ? "Unblock User" : "Block User")").fontWeight(.bold).foregroundColor(Color("AccentColor")).padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("Background")).cornerRadius(15)
                    })
                    
                    if !(userVM.user?.blockedAccounts?.contains(user) ?? false) {
                        if userVM.user?.pendingFriendsList?.contains(user) ?? false {
                            Text("Pending Friend Request").fontWeight(.bold).foregroundColor(FOREGROUNDCOLOR).padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("AccentColor")).cornerRadius(15)
                        }else {
                            
                        Button(action:{
                            if userVM.user?.friendsList?.contains(user) ?? false {
                                userVM.removeFriend(friendID: user.id ?? " ")
                            } else {
                                userVM.addFriend(friendID: user.id ?? " ")
                            }
                            
                        },label:{
                            Text("\(userVM.user?.friendsList?.contains(user) ?? false ? "Remove Friend" : "Add Friend")").fontWeight(.bold).foregroundColor(Color("AccentColor")).padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("Background")).cornerRadius(15)
                        })
                        }
                    }
                    
              
                    
                    
                 
                    
                    Button(action:{
                        
                    },label:{
                        Text("Send Message").fontWeight(.bold).foregroundColor(Color("AccentColor")).padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("Background")).cornerRadius(15)
                    })
                    
                }
            }.zIndex(2)
            
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onTapGesture {
            if showInfo{
                
            showInfo.toggle()
            }
        }
    }
}



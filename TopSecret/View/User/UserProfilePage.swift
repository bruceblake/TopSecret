//
//  UserProfilePage.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/17/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserProfilePage: View {
    
    @State var user: User
    @StateObject var chatVM = ChatViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @State var showInfo : Bool = false
    @State var selectedIndex : Int = 0
    @State var seeProfilePicture: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
  
    
  
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
                        Image(systemName: "ellipsis").font(.title3)
                    }).padding(.trailing,10)
                    
                }.padding(.top,50)
                    
                ScrollView{
                    VStack{
                        HStack{
                            
                            Spacer()
                            
                            VStack(spacing: 4){
                                Button(action:{
                                    self.seeProfilePicture.toggle()
                                },label:{
                                    WebImage(url: URL(string: user.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:70,height:70)
                                        .clipShape(Circle())
                                }).fullScreenCover(isPresented: $seeProfilePicture) {
                                    
                                } content: {
                                    WebImage(url: URL(string: user.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFit()
                                        .onTapGesture{
                                            self.seeProfilePicture.toggle()
                                        }
                                }
                                
                                VStack(spacing: 7){
                                    HStack{
                                        Text("\(user.nickName ?? "")").font(.headline).bold()
                                        Circle().foregroundColor((user.isActive ?? false) ? Color.green : Color.red).frame(width: 8, height: 8)
                                    }
                                    
                                    if user.id ?? "" != userVM.user?.id ?? " "{
                                        
                                        if userVM.user?.pendingFriendsListID?.contains(user.id ?? " ") ?? false {
                                            VStack{
                                                Text("Pending Friend Request").foregroundColor(.gray)
                                                
                                                
                                            }
                                        }else if userVM.user?.friendsListID?.contains(user.id ?? " ") ?? false{
                                            Text("Friends").foregroundColor(.gray)
                                        }else if userVM.user?.blockedAccountsID?.contains(user.id ?? "") ?? false{
                                            Text("Blocked").foregroundColor(.gray)
                                        }
                                        else{
                                            Button(action:{
                                                userVM.sendFriendRequest(friend: user){ finished in
                                                    userVM.fetchUser(userID: user.id ?? " ") { fetchedUser in
                                                        self.user = fetchedUser
                                                    }
                                                }
                                             
                                            },label:{
                                                Text("Send Friend Request").foregroundColor(FOREGROUNDCOLOR).padding(7).background(Color("AccentColor")).cornerRadius(16)
                                            })
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                            }.padding(.leading)
                            
                            
                            
                            Spacer()
                            
                        }.padding(.top,10)
                        
                        
                        
                        
                        //User Info
                        HStack(spacing: 25){
                            
                            Spacer()
                            
                            
                            
                            
                            
                            NavigationLink(destination: Text("Hello World")){
                                
                                VStack{
                                    Text("\(user.groupsID?.count ?? 0)").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                    Text("Groups").font(.callout).foregroundColor(.gray)
                                }
                            }
                            
                            
                            
                            Spacer()
                            
                            NavigationLink(destination: UserFriendsListView(user: user)) {
                                VStack{
                                    Text("\(user.friendsList?.count ?? 0)").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                    Text("Friends").font(.callout).foregroundColor(.gray)
                                }
                            }
                            
                            
                            
                            
                            
                            
                            Spacer()
                            
                        }.padding(.vertical)
                        
                        Text("\(user.bio ?? "")").frame(width: UIScreen.main.bounds.width - 20).multilineTextAlignment(.center)
                        
                        
                        Spacer()
                    }
                    Spacer()
                    Text("\(user.username ?? " ") joined Top Secret on \(userVM.user?.dateCreated?.dateValue() ?? Date(), style: .date)").font(.footnote).foregroundColor(.gray)
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
                                userVM.removeFriend(friendID: user.id ?? " ") { finished in
                                    userVM.fetchUser(userID: user.id ?? " ") { fetchedUser in
                                        self.user = fetchedUser
                                    }
                                }
                            } else {
                                userVM.sendFriendRequest(friend: user){ finished in
                                    userVM.fetchUser(userID: user.id ?? " "){ fetchedUser in
                                        self.user = fetchedUser
                                    }
                                }
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



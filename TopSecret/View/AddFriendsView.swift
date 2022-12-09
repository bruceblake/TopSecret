//
//  AddFriendsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/6/22.
//
import SDWebImageSwiftUI
import SwiftUI

struct AddFriendsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var searchVM = SearchRepository()
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(alignment: .center){
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Add Friends").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal)
                
                SearchBar(text: $searchVM.searchText, placeholder: "search for users", onSubmit: {
                    //todo
                })
                 
                AddFriendsSearchList(searchVM: searchVM)
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsers", id: "")
        }
    }
}


struct AddFriendsSearchList : View {
    @StateObject var searchVM : SearchRepository
    @EnvironmentObject var userVM: UserViewModel
    
   
    var body: some View {
        ScrollView{
            VStack{
                VStack(alignment: .leading){
                    if !searchVM.searchText.isEmpty && !searchVM.userReturnedResults.isEmpty{
                        HStack{
                            Text("Users").bold().padding(.leading,10)
                            Spacer()
                        }
                    }
                   
                    VStack{
                        ForEach(searchVM.userReturnedResults){ user in
                            if user.id ?? "" != userVM.user?.id ?? ""{
                            Button(action:{
                                
                            },label:{

                                UserAddSearchCell(user: user)
                            })
                            }
                        }
                    }
                 
                }
            }
        }
    }
}

struct UserAddSearchCell : View {
    var user: User
    @EnvironmentObject var userVM: UserViewModel
    @State var isLoading: Bool = false
    @State var isFriends: Bool = false
    @State var isPendingFriendRequest : Bool = false
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 0){
                    Text("\(user.nickName ?? "")").foregroundColor(Color("Foreground"))
                    Text("@\(user.username ?? "")").font(.subheadline).foregroundColor(.gray)
                }
                
                Spacer()
                
                //if you two are not friends
                if isFriends {
                    HStack{
                        Text("Chat")
                        Button(action:{
                            
                        },label:{
                            Image(systemName: "message")
                        })
                    }.font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                }
                
                else if isPendingFriendRequest{
                    HStack{
                           
                                if isLoading{
                                    ProgressView().font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                                }else{
                                    Text("Pending Friend Request").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color.gray))
                                }
                            
                           
                 
                        
                       
                            Button(action:{
                                isLoading = true
                                userVM.unsendFriendRequest(friend: user) { finished in
                                    if finished {
                                        userVM.fetchUser(userID: user.id ?? " ") { fetchedUser in
                                            if fetchedUser.friendsListID?.contains(userVM.user?.id ?? " ") ?? false {
                                                self.isFriends = true
                                                self.isPendingFriendRequest = false
                                            }else if fetchedUser.pendingFriendsListID?.contains(userVM.user?.id ?? " ") ?? false {
                                                self.isPendingFriendRequest = true
                                                self.isFriends = false
                                            }else{
                                                self.isFriends = false
                                                self.isPendingFriendRequest = false
                                            }
                                            self.isLoading = false
                                        }
                                      
                                    }
                                }
                            },label:{
                                Image(systemName: "xmark").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                            }).disabled(isLoading)
                            
                    }
                    
                }else {
                    HStack{
                            Button(action:{
                                isLoading = true
                                userVM.sendFriendRequest(friend: user) { finished in
                                    if finished {
                                        userVM.fetchUser(userID: user.id ?? " ") { fetchedUser in
                                            if fetchedUser.friendsListID?.contains(userVM.user?.id ?? " ") ?? false {
                                                self.isFriends = true
                                                self.isPendingFriendRequest = false
                                            }else if fetchedUser.pendingFriendsListID?.contains(userVM.user?.id ?? " ") ?? false {
                                                self.isPendingFriendRequest = true
                                                self.isFriends = false
                                            }else{
                                                self.isFriends = false
                                                self.isPendingFriendRequest = false
                                            }
                                            self.isLoading = false
                                        }
                                       
                                    }
                                }
                            },label:{
                                HStack(spacing: 5){
                                    if isLoading{
                                        ProgressView()
                                    }
                                    Text("Send Friend Request")
                                }.font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                            
                                
                            }).disabled(isLoading)
                           
                 
                        
                       
                            Button(action:{
                                
                            },label:{
                                Image(systemName: "xmark").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                            }).disabled(isLoading)
                            
                    }
                  
                }
                
             
                
                
            }.padding(.horizontal,10)
            Divider()
        }.onAppear{
            userVM.fetchUser(userID: user.id ?? " ") { fetchedUser in
                if fetchedUser.friendsListID?.contains(userVM.user?.id ?? " ") ?? false {
                    self.isFriends = true
                    self.isPendingFriendRequest = false
                }else if fetchedUser.pendingFriendsListID?.contains(userVM.user?.id ?? " ") ?? false {
                    self.isPendingFriendRequest = true
                    self.isFriends = false
                }else{
                    self.isFriends = false
                    self.isPendingFriendRequest = false
                }
                self.isLoading = false
            }
        }
    }
}



//Brand A: 10K/mo
//Brand B: 5K/mo
//Brand C: 1K/mo


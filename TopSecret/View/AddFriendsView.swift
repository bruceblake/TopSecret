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
    @ObservedObject var searchVM = SearchRepository()
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
    @ObservedObject var searchVM : SearchRepository
    var body: some View {
        ScrollView{
            VStack{
                VStack(alignment: .leading){
                    HStack{
                        Text("Users").bold().padding(.leading,10)
                        Spacer()
                    }
                    VStack{
                        ForEach(searchVM.userReturnedResults, id: \.id){ user in
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

struct UserAddSearchCell : View {
    var user: User
    @EnvironmentObject var userVM: UserViewModel
    @State var isLoading: Bool = false
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:48,height:48)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 0){
                    Text("\(user.nickName ?? "")").foregroundColor(Color("Foreground"))
                    Text("@\(user.username ?? "")").font(.subheadline).foregroundColor(.gray)
                }
                
                Spacer()
                
                
                if user.friendsListID?.contains(userVM.user?.id ?? " ") ?? false {
                    HStack{
                            Button(action:{
                                isLoading = true
                                userVM.sendFriendRequest(friend: user) { finished in
                                   isLoading = !finished
                                }
                            },label:{
                                if isLoading{
                                    ProgressView().font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                                }else{
                                Text("Send Friend Request").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                                }
                            })
                           
                 
                        
                       
                            Button(action:{
                                
                            },label:{
                                Image(systemName: "xmark").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                            })
                            
                    }
                }
                
                if user.pendingFriendsListID?.contains(userVM.user?.id ?? " ") ?? false{
                    HStack{
                            Button(action:{
                                isLoading = true
                                userVM.sendFriendRequest(friend: user) { finished in
                                   isLoading = !finished
                                }
                            },label:{
                                if isLoading{
                                    ProgressView().font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                                }else{
                                Text("Send Friend Request").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                                }
                            })
                           
                 
                        
                       
                            Button(action:{
                                
                            },label:{
                                Image(systemName: "xmark").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                            })
                            
                    }
                    
                }
              
                
                
            }.padding(.horizontal,10)
            Divider()
        }
    }
}



//Brand A: 10K/mo
//Brand B: 5K/mo
//Brand C: 1K/mo


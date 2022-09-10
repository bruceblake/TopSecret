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
    @StateObject var chatVM = GroupChatViewModel()
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Spacer()
                    Text("Friends").font(.title).bold()
                    Spacer()
                }.padding(.top,50).padding(.horizontal)
                
                
                SearchBar(text: $searchVM.searchText, placeholder: "friends", onSubmit: {
                    
                })
                ScrollView{
                    VStack{
                        
                if searchVM.searchText == "" {
                    
                        ForEach(userVM.user?.personalChats ?? [], id: \.id){ chat in
                            Button(action:{
                                
                            },label:{
                                Text("\(chat.id)")
                            })
                        }

                }else{
                    
                        ForEach(searchVM.userFriendsReturnedResults, id: \.id){ user in
                            
                            Button(action:{
                                
                            },label:{
                                UserSearchCell(user: user, showActivity: false)
                            })
    
                        }
                    
                }
                    }
                }
                
                
            }
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsersFriends", id: userVM.user?.id ?? " ")
        }
    }
}


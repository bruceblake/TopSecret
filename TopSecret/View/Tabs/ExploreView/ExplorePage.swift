//
//  ExplorePage.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/12/22.
//

import SwiftUI

struct ExplorePage: View {
    @StateObject var searchVM = SearchRepository()
    @EnvironmentObject var userVM : UserViewModel
    @State var selectedGroup : Group = Group()
    @State var selectedUser : User = User()
    @State var openGroupProfile : Bool = false
    @State var openUserProfile : Bool = false
    @State var openSearchedView: Bool = false
    @Binding var showSearch : Bool
    func submit(){
        searchVM.hasSearched = true
        openSearchedView.toggle()
        userVM.addToRecentSearches(searchText: searchVM.searchText, uid: userVM.user?.id ?? " ")
    }
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    SearchBar(text: $searchVM.searchText, placeholder: "search for users and groups", onSubmit: {
                      submit()
                    }, showKeyboard: showSearch)
                    
                    Button(action:{
                        withAnimation(.easeOut){
                        showSearch.toggle()
                        }
                    },label:{
                        Text("Cancel")
                    }).padding(.trailing,10)
                }.padding(.top,50).frame(width: UIScreen.main.bounds.width)
                
                if searchVM.hasSearched{
                    
                    if searchVM.isRefreshing{
                        VStack{
                            Spacer()
                          ProgressView()
                            Spacer()
                        }
                        
                    }else{
                        ScrollView(){
                            if !searchVM.searchText.isEmpty && searchVM.groupReturnedResults.isEmpty && searchVM.userReturnedResults.isEmpty{
                                Text("There are no results for \(searchVM.searchText)")
                            }
                            VStack(alignment: .leading){
                              
                                
                                VStack(alignment: .leading){
                                    if !searchVM.searchText.isEmpty && !searchVM.groupReturnedResults.isEmpty{
                                        Text("Groups").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                                    }
                                    VStack{
                                        ForEach(searchVM.groupReturnedResults, id: \.id){ group in
                                            Button(action:{
                                                self.selectedGroup = group
                                                openGroupProfile.toggle()
                                                searchVM.searchText = group.groupName
                                                searchVM.hasSearched = true
                                                userVM.addToRecentSearches(searchText: searchVM.searchText, uid: userVM.user?.id ?? " ")
                                            },label:{
                                                GroupSearchCell(group: group)

                                            })
                                                

                                             
                                            

                                         
                                        }
                                    }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                                }
                                
                                VStack(alignment: .leading){
                                    if !searchVM.searchText.isEmpty && !searchVM.userReturnedResults.isEmpty{
                                        Text("Users").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                                    }
                                    ForEach(searchVM.userReturnedResults, id: \.id){ user in
                                        
                                        Button(action:{
                                            self.selectedUser = user
                                            openUserProfile.toggle()
                                            searchVM.searchText = user.username ?? ""
                                            searchVM.hasSearched = true
                                            userVM.addToRecentSearches(searchText: searchVM.searchText, uid: userVM.user?.id ?? " ")
                                        },label:{
                                            UserSearchCell(user: user, showActivity: false)
                                        })
                                      

                                         
                                        

                                     
                                    }
                                }
                                
                                VStack(alignment: .leading){
                                    if !searchVM.searchText.isEmpty && !searchVM.userFriendsReturnedResults.isEmpty{
                                        Text("Friends").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                                    }
                                    ForEach(searchVM.userFriendsReturnedResults, id: \.id){ user in
                                        
                                        Button(action:{
                                            self.selectedUser = user
                                            openUserProfile.toggle()
                                            searchVM.searchText = user.username ?? ""
                                            searchVM.hasSearched = true
                                            userVM.addToRecentSearches(searchText: searchVM.searchText, uid: userVM.user?.id ?? " ")
                                        },label:{
                                            UserSearchCell(user: user, showActivity: false)
                                        })
                                           
                                         
                                        

                                     
                                    }
                                }
                                

                            }
                            
                            
                        }
                    }
                  
                   
                
                }else{
                    ScrollView(){
                    VStack(spacing: 10){
                        ForEach(userVM.user?.recentSearches ?? [], id: \.self){ recentSearch in
                            Button(action:{
                                searchVM.searchText = recentSearch
                                searchVM.hasSearched = true
                                openSearchedView.toggle()
                            },label:{
                                HStack{
                                    
                                    HStack{
                                        Image(systemName: "clock").foregroundColor(.gray)
                                        Text("\(recentSearch)").foregroundColor(FOREGROUNDCOLOR)
                                    }.padding(.leading,10)
                                    
                                    Spacer()
                                    
                                   
                                        Image(systemName: "xmark").font(.caption).onTapGesture {
                                            userVM.removeFromRecentSearches(searchText: recentSearch, uid: userVM.user?.id ?? " ")
                                        }
                                    .foregroundColor(Color.gray).padding(.trailing,10)
                                }.frame(width: UIScreen.main.bounds.width-30)
                            })
                        }
                        
                        if !(userVM.user?.recentSearches?.isEmpty ?? false)  {
                            Button(action:{
                        for search in userVM.user?.recentSearches ?? [] {
                            userVM.removeFromRecentSearches(searchText: search, uid: userVM.user?.id ?? " ")
                        }
                        },label:{
                            Text("Clear History")
                        })
                        } 
                    
                        Spacer()
                    }
                    }.padding(.horizontal)
                }
                
                   

            
            }

            NavigationLink(isActive: $openSearchedView) {
                SearchedView(searchVM: searchVM)
            } label: {
                EmptyView()
            }
            NavigationLink(isActive: $openGroupProfile) {
                GroupProfileView(group: $selectedGroup, isInGroup: selectedGroup.users?.contains(userVM.user?.id ?? " ") ?? false, showProfileView: $openGroupProfile)
            } label: {
                EmptyView()
            }
            NavigationLink(isActive: $openUserProfile) {
                UserProfilePage(user: selectedUser)
            } label: {
                EmptyView()
            }


            
          

            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsersAndGroups", id: userVM.user?.id ?? " ")
        }.frame(width: UIScreen.main.bounds.width)
    }
}


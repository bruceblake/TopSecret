//
//  ExplorePage.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/12/22.
//

import SwiftUI

struct ExplorePage: View {
    @StateObject var searchVM = SearchRepository()
    @StateObject var recentSearchVM = RecentSearchViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @State var selectedGroup : Group = Group()
    @State var selectedUser : User = User()
    @State var openGroupProfile : Bool = false
    @State var openUserProfile : Bool = false
    @State var openSearchedView: Bool = false
    @Binding var showSearch : Bool
    @State var showSeeAllSearches : Bool = false
    func submit(){
        searchVM.hasSearched = true
        openSearchedView.toggle()
        recentSearchVM.addToRecentSearches(searchText: searchVM.searchText)
        
    }
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    SearchBar(text: $searchVM.searchText, placeholder: "search for users and groups", onSubmit: {
                      submit()
                    })
                    
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
                        ExplorePageSearchList(searchVM: searchVM, recentSearchVM: recentSearchVM)
                    }
                  
                   
                
                }else{
                    ScrollView(){
                    VStack(spacing: 10){
                        
                        
                      
                        ForEach(recentSearchVM.recentSearches.reversed().indices, id: \.self) { i in
                            
                           
                            if i <= 4 {
                                Button(action:{
                                    searchVM.searchText = recentSearchVM.recentSearches[i]
                                    searchVM.hasSearched = true
                                    openSearchedView.toggle()
                                },label:{
                                    HStack{
                                        
                                        HStack{
                                            Image(systemName: "clock").foregroundColor(.gray)
                                            Text("\(recentSearchVM.recentSearches[i])").foregroundColor(FOREGROUNDCOLOR)
                                        }.padding(.leading,10)
                                        
                                        Spacer()
                                        
                                       
                                            Image(systemName: "xmark").font(.caption).onTapGesture {
                                                recentSearchVM.removeFromRecentSearches(searchText: recentSearchVM.recentSearches[i])
                                            }
                                        .foregroundColor(Color.gray).padding(.trailing,10)
                                    }
                                })
                            }
                         
                        }
                        if recentSearchVM.showSeeAll {
                                
                                
                                Button(action:{
                                    showSeeAllSearches.toggle()
                                },label:{
                                    Text("See All")
                                }).fullScreenCover(isPresented: $showSeeAllSearches) {
                                    
                                } content: {
                                    ShowAllRecentSearchView(recentSearchVM: recentSearchVM, searchVM: searchVM)
                                }

                            
                        }
                    
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width)
                    }.padding(.horizontal)
                }
                
                   

            
            }

            NavigationLink(isActive: $openSearchedView) {
                SearchedView(searchVM: searchVM)
            } label: {
                EmptyView()
            }
       

            
          

            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            
            searchVM.startSearch(searchRequest: "allUsersAndGroups", id: userVM.user?.id ?? " ")
            let dp = DispatchGroup()
            
            dp.enter()
            
            recentSearchVM.fetchSearches() { _ in
                dp.leave()
                
            }
            
            dp.notify(queue: .main, execute:{
            if !recentSearchVM.recentSearches.isEmpty {
                recentSearchVM.showSeeAll = true
            }
            })
            
            
            
        }.frame(width: UIScreen.main.bounds.width).onReceive(recentSearchVM.$recentSearches) { addedSearch in
            if recentSearchVM.recentSearches.count >= 4 {
                recentSearchVM.showSeeAll = true
            }else{
                recentSearchVM.showSeeAll = false
            }
        }
    }
}


struct ShowAllRecentSearchView : View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var recentSearchVM : RecentSearchViewModel
    @StateObject var searchVM : SearchRepository
    @EnvironmentObject var userVM: UserViewModel
    @State var openSearchedView: Bool = false

    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left")
                        }
                    })
                    
                    Spacer()
                    
                    Text("Recent Searches").font(.title3).bold()
                    
                   Spacer()
                    
                }.padding(.top,50).padding(10)
               
                
                ScrollView{
                    VStack(spacing: 10){
                        ForEach(recentSearchVM.recentSearches, id: \.self){ recentSearch in
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
                                            recentSearchVM.removeFromRecentSearches(searchText: recentSearch)
                                        }
                                    .foregroundColor(Color.gray).padding(.trailing,10)
                                }
                            })
                   
                        }
                    }
                }
            }
            NavigationLink(isActive: $openSearchedView) {
                SearchedView(searchVM: searchVM)
            } label: {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}


struct ExplorePageSearchList : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var searchVM : SearchRepository
    @StateObject var recentSearchVM : RecentSearchViewModel
    @State var selectedGroup : Group = Group()
    @State var selectedUser : User = User()
    @State var openGroupProfile : Bool = false
    @State var openUserProfile : Bool = false
    
    var body: some View {
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
                                recentSearchVM.addToRecentSearches(searchText: searchVM.searchText)
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
                            recentSearchVM.addToRecentSearches(searchText: searchVM.searchText)
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
                            recentSearchVM.addToRecentSearches(searchText: searchVM.searchText)
                        },label:{
                            UserSearchCell(user: user, showActivity: false)
                        })
                           
                         
                        

                     
                    }
                }
                

            }
            
            
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

    }
}

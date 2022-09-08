//
//  UserProfilePage.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/3/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct CurrentUserProfilePage: View {
    
    @State var settingsOpen: Bool = false
    @State var showEditPage: Bool = false
    @State var isLoading: Bool = false
    @State var switchAccounts : Bool = false
    @State var selectedIndex : Int = 0
    
    @StateObject var chatVM = ChatViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    
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
                                

                                //pfp username nickname
                                    HStack(spacing: 5){
                                        Button(action:{
                                            
                                        },label:{
                                            WebImage(url: URL(string: userVM.user?.profilePicture ?? ""))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width:60,height:60)
                                                .clipShape(Circle())
                                        })
                                
                                       
                                            
                                            VStack(alignment: .leading, spacing: 5){
                                                
                                                Button(action:{
                                                    userVM.hideTabButtons.toggle()
                                                    switchAccounts.toggle()
                                                },label:{
                                                    HStack(spacing: 1
                                                    ){
                                                        Text("\(userVM.user?.nickName ?? "") ").fontWeight(.bold).font(.headline).lineLimit(1).foregroundColor(FOREGROUNDCOLOR)
                                                        Image(systemName: "chevron.down").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                                                    }
                                                
                                                })
                                               

                                                Text("@\(userVM.user?.username ?? "")").font(.footnote).foregroundColor(.gray)
                                            }
                                        

                                      
                                    }.padding(5).padding(.leading)

                                Spacer()
                                
                                    
                                
                                        HStack(spacing: 5){
                                           
                                            
                                       
                                            Button(action:{
                                                self.showEditPage.toggle()
                                            },label:{
                                                Text("Edit Profile").font(.body).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).foregroundColor(FOREGROUNDCOLOR).padding(.horizontal)
                                            })
                                            
                                          
                                            
                                            
                                            NavigationLink(destination: SettingsMenuView(), label: {
                                                ZStack{
                                                    Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                                                    
                                                    Image(systemName: "gear")
                                                        .resizable()
                                                        .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                                    
                                                    
                                                }
                                            })
                                        }
                                      
                                        
                                  
                                      
                                    Spacer()
                                 
                                
                                
                }.padding(.top,60).frame(width: UIScreen.main.bounds.width)
                          
                            
                    
               
                        

  
                    
                    
                    
                  
                
                
                    
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
                            Text("\(userVM.user?.groupsID?.count ?? 0)").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                            Text("Groups").font(.callout).foregroundColor(.gray)
                        }
                    }
                    
                    
                    
                    Rectangle().frame(width: 1, height: 20).foregroundColor(.gray)
                    
                    
                    NavigationLink(destination: UserFriendsListView(user: userVM.user ?? User())) {
                        VStack{
                            Text("\(userVM.user?.friendsList?.count ?? 0)").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                            Text("Friends").font(.callout).foregroundColor(.gray)
                        }
                    }
                  
                        
                        
             
                      
                        
                        Spacer()
                        
                    }.padding(.vertical)
                
                Text("\(userVM.user?.bio ?? "")").frame(width: UIScreen.main.bounds.width - 20).multilineTextAlignment(.center)
                
                
             
        
                   
                 
                
             
                
                                ScrollView(showsIndicators: false){
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<12){ index in
                       
                            
                            Image(uiImage: UIImage(named: "Icon")!)
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width/3, height: 150)
                                .aspectRatio(contentMode: .fit)
                                .overlay(Rectangle().stroke(Color("Color"), lineWidth: 1))
                        

                        
                    }
                }
            }

                
                
            }.zIndex(1).opacity(switchAccounts ? 0.2 : 1)
                
                
            ZStack{
                Color.clear
            }.zIndex(2).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).onTapGesture {
                
                    userVM.hideTabButtons.toggle()
                    switchAccounts.toggle()
                
            }
                
                
            
            
             
            

            BottomSheetView(isOpen: $switchAccounts, maxHeight: UIScreen.main.bounds.height * 0.40) {
                SwitchAccountsView()
            }.zIndex(3)
            
            NavigationLink(destination:  UserEditProfilePageView(showEditPage: $showEditPage), isActive: $showEditPage) {
                EmptyView()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
    }
}


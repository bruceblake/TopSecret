//
//  HomeScreen.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/3/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var openGroupPassword : Bool = false
    @State var selectedGroup : Group = Group()
    
    var widthAdd : CGFloat = 50
    var heightDivide: CGFloat = 5
    var width : CGFloat = UIScreen.main.bounds.width
    var height : CGFloat = UIScreen.main.bounds.height
    

    var body: some View {
        ZStack{
            Color("Background")
            
            
            VStack{
                
                HStack{
                    
                    Spacer()
                    
                    NavigationLink(destination:{
                        UserProfilePage(isCurrentUser: true)
                    },label:{
                        
                        
                        WebImage(url: URL(string: userVM.user?.profilePicture ?? " ")).resizable().frame(width: 40, height: 40).clipShape(Circle()).padding(.trailing,30)
                        
                    })
                    
                    
                    Image("FinishedIcon").resizable().scaledToFit().frame(width: 70, height:70).padding(.horizontal,60)
                    
                    
                    
                    
                    
                    
                    HStack(spacing: 10){
                        
                        NavigationLink {
                            SearchView()
                        } label: {
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                
                                
                                Image(systemName: "magnifyingglass").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                
                            }
                        }
                        
                        NavigationLink(destination: {
                            CreateGroupView()
                        },label:{
                            
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                
                                
                                Image(systemName: "plus").font(.title3).foregroundColor(FOREGROUNDCOLOR)
                                
                            }
                            
                        })
                        
                    }
                    
                    
                    
                    Spacer()
                    
                    
                    
                }.padding(.horizontal,25).padding(.top,45)
                
                ScrollView(showsIndicators: false){
                    VStack(spacing: 30){
                        ForEach(userVM.groups, id: \.id){ group in
                            Button(action:{
                                
                                let dispatchGroup = DispatchGroup()
                                
                                dispatchGroup.enter()
                                self.selectedGroup = group
                                dispatchGroup.leave()
                                
                                dispatchGroup.notify(queue: .global(), execute:{
                                    openGroupPassword.toggle()
                                })
                                
                            },label:{
                                VStack{
                                VStack(alignment: .leading){
                                    
                                    
                                    
                                        HStack{
                                            Spacer()
                                            
                                            
                                        }.padding(50).background(WebImage(url: URL(string: group.groupProfileImage ?? "")).resizable().scaledToFill())
                 
                                    
                                    HStack(alignment: .top){
                                        
                                        VStack(alignment: .leading,spacing:10){
                                            Text(group.groupName).font(.headline).bold().foregroundColor(FOREGROUNDCOLOR)
                                            
                                            HStack{
                                                Text(group.motd)
                                                    .lineLimit(1)
                                            }.foregroundColor(FOREGROUNDCOLOR)
                                            
                                            HStack{
                                                Text("\(group.memberAmount) \(group.memberAmount == 1 ? "member" : "members")").foregroundColor(FOREGROUNDCOLOR)
                                              
                                                
                                            }
                                        }
                                        
                                        Spacer(minLength: 0)
                                    }.padding(10).background(Rectangle().foregroundColor(Color("Color")))
                                    
                                    
                                }.cornerRadius(10)
                                    
                                }.shadow(color: Color.black, radius: 5).frame(width: width - widthAdd, height: height/heightDivide).padding(.top,30)
                            
                            }).disabled(group.groupName == "" || group.groupName == " ")
                            
                        }
                    }
                    .fullScreenCover(isPresented: $openGroupPassword) {
                        
                    } content: {
                        NavigationView{
                            EnterGroupPassword(group: $selectedGroup)
                        }
                    }
                    
                    
                }.padding(.top).padding(.bottom,100)
                
                
                
                
                
                
            }.padding(.horizontal,30)
            
            
            
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
        
        
        
        
    }
}


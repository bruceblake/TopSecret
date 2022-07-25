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
    @State var openGroupHomescreen : Bool = false
    @State var selectedGroup : Group = Group()
    @State var users: [User] = []
    @StateObject var selectedGroupVM = SelectedGroupViewModel()
    
    
    var body: some View {
        ZStack{
            Color("Background")
            
            
            VStack{
                
                TopBar()
                
                if userVM.finishedFetchingPosts{
                    ShowGroups(selectedGroup: $selectedGroup, users: $users, openGroupHomescreen: $openGroupHomescreen)
                }else{
                    ProgressView()
                    Spacer()
                }
             
                
                
                
                
                
                
            }
            
            
            NavigationLink(destination: HomeScreenView(group: $selectedGroup).environmentObject(selectedGroupVM), isActive: $openGroupHomescreen) {
                EmptyView()
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
    
}

struct ShowGroups : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @Binding var selectedGroup : Group
    @Binding var users: [User]
    @Binding var openGroupHomescreen : Bool
    
    var widthAdd : CGFloat = 50
    var heightDivide: CGFloat = 5
    var width : CGFloat = UIScreen.main.bounds.width
    var height : CGFloat = UIScreen.main.bounds.height
    
    
    
    var body: some View{
        ScrollView(showsIndicators: false){
            VStack(spacing: 30){
                ForEach(userVM.groups, id: \.id){ group in
                    Button(action:{
                        
                        let dispatchGroup = DispatchGroup()
                        
                       
                        
                        dispatchGroup.enter()
                        self.selectedGroup = group
                        dispatchGroup.leave()
                        
                        dispatchGroup.notify(queue: .global(), execute:{
                            openGroupHomescreen.toggle()
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
            
            
            
        }.padding(.top).padding(.bottom,100)
    }
}


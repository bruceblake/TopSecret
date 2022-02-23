//
//  HomeScreenView.swift
//  TopSecret
//
//  Created by nathan frenzel on 8/31/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeScreenView: View {
    
    
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    @ObservedObject var notificationRepository = NotificationRepository()
    @StateObject var chatVM = ChatViewModel()
    @StateObject var groupVM = GroupViewModel()
    @State var showInfoScreen : Bool = false

    
    @State private var options = ["Groups","Notifications"]
    
    @State var selectedIndex = 0
    
    @State var isActive : Bool = false
    
    var body: some View {
        
        
        ZStack{
            Color("Background")
            
            VStack{
                VStack{
                    HStack(spacing: 20){
                        
                        HStack{
                            NavigationLink(
                                destination: UserProfilePage(user: userVM.user ?? User(), isCurrentUser: true),
                                label: {
                                    WebImage(url: URL(string: userVM.user?.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                })
                            
                            
                            
                            NavigationLink(
                                destination: UserNotificationView(),
                                label: {
                                    ZStack{
                                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                        
                                        ZStack(){
                                            Image(systemName: "heart")
                                                .resizable()
                                                .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                            if userVM.userNotificationCount != 0{
                                                
                                                ZStack{
                                                    Circle().foregroundColor(Color("AccentColor"))
                                                    Text("\(userVM.userNotificationCount)").foregroundColor(.yellow).font(.footnote)
                                                }.frame(width: 20, height: 20).offset(x: 18, y: -15)
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        
                                        
                                        
                                    }
                                })
                            
                            
                        
                      
                            
                            
                            
                            
                            
                        }.padding(.leading,20)
                        
                        Spacer()
                        
                        Button(action:{
                            userVM.fetchUserGroups()
                        }, label:{
                            Image("FinishedIcon")
                                .resizable()
                                .frame(width: 64, height: 64)
                        })
                        Spacer()
                        HStack(spacing:10){
                            
                            
                            
                            
                            
                            
                            NavigationLink(
                                destination: SearchView(),
                                label: {
                                    ZStack{
                                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                        
                                    }
                                })
                            
                            
                            NavigationLink(destination: PersonalChatListView()) {
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                    Image(systemName: "paperplane.fill")
                                        .resizable()
                                        .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                    
                                }
                            }
                            
                            
                            
                            
                            
                          
                            
                            
                            
                            
                        }.padding(.trailing,20)
                        
                        
                    }.padding(.top,40)
                    //main content
                    VStack{
                        
                        VStack(alignment: .leading){
                            
                            Text("Stories").fontWeight(.bold).padding(.leading,7)
                            
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack{

                                ForEach(userVM.followedGroups){ group in
                                    NavigationLink(destination: GroupProfileView(group: group)) {
                                        
                                        VStack{
                                            WebImage(url: URL(string: group.groupProfileImage ?? ""))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width:50,height:50)
                                                .clipShape(Circle())
                                            
                                            Text("\(group.groupName)").font(.footnote).foregroundColor(FOREGROUNDCOLOR)
                                        }
                                        
                                        
                                        
                                    }
                                 
                                }
                                }
                                
                                }.padding(.leading,7)
                            
                            
                            Divider()
                        }
                        
                      
                      
//                        Button(action:{
//                            groupVM.changeBio(bio: "", groupID: "9450CD87-42E8-4C09-A908-343BE8235E99", userID: userVM.user?.id ?? "")
//                        },label:{
//                            Image(systemName: "plus")
//                        })
                       
                            Spacer()

                        
//
                        
                        
                    }
                }
                
            }.onReceive(self.navigationHelper.$moveToDashboard){ move in
                if move {
                    print("Move to dashboard: \(move)")
                    self.isActive = false
                    self.navigationHelper.moveToDashboard = false
                }
            }
            
            
            
        }.frame(width: UIScreen.main.bounds.width).edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
    
    
    
    
    
    
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView().preferredColorScheme(.dark).environmentObject(UserViewModel())
    }
}



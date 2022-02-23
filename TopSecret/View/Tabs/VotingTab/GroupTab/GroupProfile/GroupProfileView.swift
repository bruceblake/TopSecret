//
//  GroupProfileView.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/26/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupProfileView: View {
    
    @State var group: Group = Group()
    @EnvironmentObject var userVM : UserViewModel
    @ObservedObject var groupVM = GroupViewModel()
    @State var badges : [Badge] = []
    @Environment(\.presentationMode) var dismiss

    
    
    @State var selectedIndex = 0
    @State var isFollowing = false
    @State var isInGroup = false
    @State private var options = ["Gallery","Polls","Events","About"]
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(){
                    Button(action:{
                        dismiss.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "chevron.left")
                                .resizable()
                                .frame(width: 12, height: 12).foregroundColor(Color("Foreground"))
                            
                        }
                    }).padding(.leading)
                    
                    Spacer()
                   
                    VStack{
                        WebImage(url: URL(string: group.groupProfileImage ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:45,height:45)
                            .clipShape(Circle())
                            .padding([.horizontal,.top])
                    Text("\(group.groupName)").fontWeight(.bold).font(.headline)
                    }.padding(.top)
                        
                                            
                       
                        
                    
                    
                    Spacer()

                  
                    NavigationLink(destination: GroupSettingsView(group: group)){
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 24, height: 24).foregroundColor(Color("Foreground"))
                            
                        }
                    }.padding(.trailing)
                  
                }.padding(.top,35)
                
                if isInGroup{
                    Text("In Group").foregroundColor(.gray)
                }else{
                    HStack{
                        if isFollowing{
                            Button(action:{
                                
                            },label:{
                                Text("Request to join")
                            })
                            
                            Button(action:{
                                userVM.unFollowGroup(group: group, user: userVM.user ?? User())
                                userVM.fetchGroup(groupID: group.id) { fetchedGroup in
                                    self.group = fetchedGroup
                                }
                           
                            },label:{
                                Text("Unfollow Group")
                            })
                            
                            Button(action:{
                                
                            },label:{
                                Text("Send Message")
                            })
                        }else{
                            Button(action:{
                                userVM.followGroup(group: group, user: userVM.user ?? User())
                                userVM.fetchGroup(groupID: group.id) { fetchedGroup in
                                    self.group = fetchedGroup
                                }
                            },label:{
                                Text("Follow Group")
                            })
                        }
                        
                       
                    }.padding(5)
                }
                
                HStack(spacing: 30){
                    
                    NavigationLink(destination: GroupFollowersView(group: group)) {
                        Text("\(group.followers?.count ?? 0) followers").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)

                    }
                    Button(action:{
                        
                    },label:{
                        Text("\(group.following?.count ?? 0) following").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                    })
                }.padding(5)
                
                HStack{
                    ForEach(badges){ badge in
                        Button(action:{
                            //TODO
                        },label:{
                            Image(badge.badgeImage ?? "")
                                .resizable()
                                .frame(width:20,height: 20)
                        })
                    }
                    Text("40,021")
                    
                    Button(action:{
                        groupVM.giveBadge(group: group, badge: Badge(dictionary: ["id":UUID().uuidString,"badgeName":"20 hangouts!","badgeDescription":"hangout with your friend group 20 times!","badgeImage":"image"]))
                        userVM.fetchGroupBadges(groupID: group.id) { fetchedBadges in
                            self.badges = fetchedBadges
                        }
                    },label:{
                        Text("give badge")
                    })
                }.padding(5)
          
               
                //GALLERY
                //POLLS
                //ACHIEVEMENTS
                //PLANS
                
                Divider()
                
                Picker("Options",selection: $selectedIndex){
                    ForEach(0..<options.count){ index in
                        Text(self.options[index]).tag(index)
                    }
                }.pickerStyle(SegmentedPickerStyle()).padding(10)
                if selectedIndex == 0{
                    GroupGalleryView(group: group)
                }else if selectedIndex == 1{
                    Text("Hello World 1")
                }else if selectedIndex == 2{
                    Text("Hello World 2")
                }
            
                Spacer()
            }.padding(.bottom,20)
            }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
                
                groupVM.isInGroup(user1: userVM.user ?? User(), group: group) { userIsInGroup in
                    self.isInGroup = userIsInGroup
                }
                
                
                userVM.isFollowingGroup(user: userVM.user ?? User(), group: group) { isFollowingGroup in
                    self.isFollowing = isFollowingGroup
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    userVM.fetchUser(userID: userVM.user?.id ?? " ") { fetchedUser in
                        userVM.user = fetchedUser
                        print("Fetched User!")
                    }
                    
                    userVM.fetchGroupBadges(groupID: group.id) { fetchedBadges in
                        self.badges = fetchedBadges
                    }
                    
                    
                    
                }
                
            }.onReceive(userVM.$user) { user in
                groupVM.isInGroup(user1: userVM.user ?? User(), group: group) { userIsInGroup in
                    self.isInGroup = userIsInGroup
                    print("1")
                }
                
                
                userVM.isFollowingGroup(user: userVM.user ?? User(), group: group) { isFollowingGroup in
                    self.isFollowing = isFollowingGroup
                    print("2")
                    
                  
            }
        }
            
           
    }
        
    }


//struct GroupProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupProfileView(group: Group()).colorScheme(.dark)
//    }
//}


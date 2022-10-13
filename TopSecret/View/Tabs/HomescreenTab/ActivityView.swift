
//  ActivityView.swift
//  Top Secret
//
//  Created by Bruce Blake on 4/16/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ActivityView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    
    @Binding var group: Group
    @State var showEvent : Bool = false
    @ObservedObject var groupVM = GroupViewModel()
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @State var openChat : Bool = false
    @Binding var selectedView: Int
    @State var showUsers : Bool = false
    @State var selectedPoll: PollModel = PollModel()
    
    
    
    var body: some View {
        ZStack{
            Color("Background")
            ScrollView(showsIndicators: false){
                VStack(spacing: 20){
                    
                        
                    HStack(alignment: .top){
                            
                          
                            
                            NavigationLink(destination: GroupNotificationsView(group: $group).environmentObject(selectedGroupVM)) {
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                    
                                    
                                    
                                    Image(systemName: "envelope.fill").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                    
                                 
                                    
                                    
                                }
                            }.padding(.leading,10)
                            
                            Spacer()
                            
                            VStack{
                                
                                ZStack{
                                    Button(action:{
                                        
                                    },label:{
                                        WebImage(url: URL(string: selectedGroupVM.group.groupProfileImage))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width:70,height:70)
                                                .clipShape(Circle())
                                    })
                                    
                                    ZStack{
                                        Circle().foregroundColor(Color("AccentColor")).frame(width: 22, height: 22)
                                        Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR)
                                    }.offset(x: 25, y: 25).onTapGesture {
                                        print("add to group story")
                                    }
                                }
                                
                                Text("427 views")
                                
                            }
                            
                          Spacer()
                            
                            Button(action:{
                                
                         
                                
                                self.openChat.toggle()
                            },label:{
                                    ZStack{
                                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                        
                                        
                                        
                                        Image(systemName: "photo.on.rectangle.angled").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                        
                                      
                                        
                                        
                                    }
                                
                            }).padding(.trailing,10)

                            
                            
                    }.padding(.top)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("MOTD").foregroundColor(FOREGROUNDCOLOR).font(.title2).bold()
                            Spacer()
                        }.padding(.leading,10)
                        HStack{
                            Spacer()
                            Text("\(selectedGroupVM.group.motd )").font(.headline).bold()
                            Spacer()
                        }
                    }
                    

                    GroupFeed(group: selectedGroupVM.group ?? Group())
                    
             
             
                    
                }
                
            }
            
            NavigationLink(destination: GroupChatView(userID: userVM.user?.id ?? " ", groupID: group.id ?? " ", chatID: group.chat.id).environmentObject(selectedGroupVM), isActive: $openChat) {
                EmptyView()
            }
            
            BottomSheetView(isOpen: $showUsers, maxHeight: UIScreen.main.bounds.height * 0.45){
                ShowAllUsersVotedView(showUsers: $showUsers, poll: $selectedPoll)
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
        
        
    }
}


struct GroupFeed : View {
    var group: Group
    var body : some View {
        ZStack{
            Color("Background")
            VStack{
                
            }
        }
    }
}






//
//  ActivityView.swift
//  Top Secret
//
//  Created by Bruce Blake on 4/16/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ActivityView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    
    @Binding var group: Group
    @Binding var groupMembers : [User]
    @State var showEvent : Bool = false
    @ObservedObject var groupVM = GroupViewModel()
    @StateObject var selectedGroupVM : SelectedGroupViewModel
    
    
    func sortUsersActive(users: [User]) -> [User]{
        return users.sorted(by: { ($0.isActive ?? false && !($1.isActive ?? false))} )
    }
    
    func checkIfUserIsActive(userID: String) -> Bool {
        for user in groupMembers {
            let isActive = user.isActive ?? false
            if isActive {
                return true
            }
        }
        return false
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            ScrollView{
            VStack(spacing: 20){
                
                //story
                VStack{
                    HStack{
                        Text("Group Story").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title2)
                        Spacer()
                    }.padding(.leading,10)
                    HStack{
                        Spacer()
                        Button(action:{
                            //TODO
                        },label:{
                            Circle().frame(width: 80, height: 80)
                        })
                        Spacer()
                        
                        
                        
                    }
                }.padding(.top)
                
                
                VStack{
                    HStack{
                        Text("Activity").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title2)
  
                        
                        Spacer()
                    }.padding(.leading,10)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 20){
                            ForEach(sortUsersActive(users: groupMembers)){ user in
                                
                                NavigationLink(destination: UserProfilePage(user: user, isCurrentUser: false), label:{
                                    
                                    VStack(spacing: 5){
                                        WebImage(url: URL(string: user.profilePicture ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width:40,height:40)
                                            .clipShape(Circle())
                                        
                                        HStack{
                                            Text("\(user.nickName ?? "TOP SECRET USER")").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                                            Circle().frame(width: 5, height: 5).foregroundColor(user.isActive ?? false ? Color.green : Color.red)
                                        }
                                        
                                        
                                    }
                                    
                                })
                            }
                        }.padding(.leading, 7)
                        
                    }
                }
                
                
                
                EventList(group: $selectedGroupVM.group)
                CountdownList(group: $selectedGroupVM.group)
                NotificationList(group: $selectedGroupVM.group)
                
            }
            
        }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            selectedGroupVM.fetchGroup(groupID: group.id)
        }
        
        
    }
}


struct NotificationList : View {
    
    @Binding var group : Group
    
    var body : some View {
        VStack{
            HStack{
                HStack{
                    Text("Notifications").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title2)
                    
                    if(group.events?.count == 1){
                        Text("\(group.events?.count ?? 0) notifications today").foregroundColor(Color.gray).font(.footnote)
                    }else{
                        Text("\(group.events?.count ?? 0) notifications today").foregroundColor(Color.gray).font(.footnote)
                    }
                    
                }.padding(.leading,10)
                
                Spacer()
                
            }
            ScrollView(showsIndicators: false){
                
                VStack{
                    ForEach(group.groupNotifications?.identifiableIndices ?? IdentifiableIndices(base: [GroupNotificationModel()])){ index in
                        Button {
                            
                        } label: {
                            GroupNotificationCell(groupNotification: group.groupNotifications?[index.rawValue] ?? GroupNotificationModel())
                            
                        }
                        
                    }
                }
                
                
            }
            
        }
    }
}




struct EventList : View {
    @Binding var group : Group
    @State var showEvent : Bool = false
    
    var body: some View {
        
        VStack{
            HStack{
                HStack{
                    Text("Events").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title2)
                    if(group.events?.count == 1){
                        Text("\(group.events?.count ?? 0) event today").foregroundColor(Color.gray).font(.footnote)
                    }else{
                        Text("\(group.events?.count ?? 0) events today").foregroundColor(Color.gray).font(.footnote)
                    }
                    
                }.padding(.leading,10)
                
                Spacer()
                
            }
            HStack{
                Button(action:{
                    //TODO
                },label:{
                    ZStack{
                        Circle().frame(width:25,height:25).foregroundColor(Color("AccentColor"))
                        Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR)
                    }
                }).padding(.leading,7)
                ScrollView(.horizontal, showsIndicators: false){
                    
                    HStack{
                        ForEach(group.events?.identifiableIndices ?? IdentifiableIndices(base: [EventModel()])){ index in
                            Button {
                                
                            } label: {
                                EventCell(event: group.events?[index.rawValue] ?? EventModel())
                            }.sheet(isPresented: $showEvent){
                                
                            } content: {
                                FullEventView(event:  group.events?[index.rawValue] ?? EventModel())
                            }
                            
                        }
                    }
                    
                }
                
                
            }
        }
    }
}

struct CountdownList : View {
    
    @Binding var group : Group
    @State var showCountdown : Bool = false
    
    var body: some View {
        VStack{
            HStack{
                Text("Countdowns").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).padding(.leading,10).font(.title2)
                HStack(spacing: 4){
                    if(group.countdowns?.count == 1){
                        Text("\(group.countdowns?.count ?? 0) countdowns").foregroundColor(Color.gray).font(.footnote)
                    }else{
                        Text("\(group.countdowns?.count ?? 0) countdowns").foregroundColor(Color.gray).font(.footnote)
                    }
                    Button(action:{
                        //TODO
                    },label:{
                        HStack(spacing: 2){
                            
                            Text("today").foregroundColor(Color("AccentColor")).font(.footnote)
                            Image(systemName: "chevron.down").font(.body)
                        }
                    })
                }
                
                
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    Button(action:{
                        //TODO
                    },label:{
                        ZStack{
                            Circle().frame(width:25,height:25).foregroundColor(Color("AccentColor"))
                            Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,7)
                    ForEach(group.countdowns?.identifiableIndices ?? IdentifiableIndices(base: [CountdownModel()])){ index in
                        Button {
                            
                        } label: {
                            CountdownCell(countdown: group.countdowns?[index.rawValue] ?? CountdownModel())
                        }
                        
                    }
                    
                }
            }
        }
    }
}

//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView().environmentObject(UserViewModel()).colorScheme(.dark)
//    }
//}

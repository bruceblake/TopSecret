
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
    @State var showEvent : Bool = false
    @ObservedObject var groupVM = GroupViewModel()
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    
    
    func sortUsersActive(users: [User]) -> Binding<[User]>{
        
        let users = users.sorted(by: { ($0.isActive ?? false && !($1.isActive ?? false))} )
        return Binding(get: {users}, set: {_ in})
    }
    
    func checkIfUserIsActive(userID: String) -> Bool {
        for user in selectedGroupVM.group?.realUsers ?? [] {
            let isActive = user.isActive ?? false
            if isActive {
                return true
            }
        }
        return false
    }
    func filterIfUnread(notifications: [GroupNotificationModel]) -> [GroupNotificationModel]{
        
        return notifications.filter({ (($0.usersThatHaveSeen ?? []).contains(userVM.user?.id ?? " ") == false)})
        
    }
    
    
    
    var body: some View {
        ZStack{
            Color("Background")
            ScrollView(showsIndicators: false){
                VStack(spacing: 20){
                    
                    VStack{
                        
                        HStack{
                            
                            HStack(spacing: 7){
                                
                                
                                Text("Today").font(.largeTitle).bold().foregroundColor(FOREGROUNDCOLOR)
                                
                                Text(Date(), style: .date).foregroundColor(.gray).fontWeight(.bold).font(.subheadline)
                                
                                
                            }.padding(.leading,10)
                            
                            
                            Spacer()
                            
                            HStack(spacing: 15){
                                NavigationLink(destination: GroupNotificationsView(group: $group).environmentObject(selectedGroupVM)) {
                                    ZStack{
                                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                        
                                        
                                        
                                        Image(systemName: "envelope.fill").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                        
                                        if self.filterIfUnread(notifications: selectedGroupVM.group?.unreadGroupNotifications ?? []).count != 0 {
                                            ZStack{
                                                Circle().foregroundColor(Color("AccentColor")).frame(width: 20, height: 20)
                                                Text("\(self.filterIfUnread(notifications: selectedGroupVM.group?.unreadGroupNotifications ?? []).count )").foregroundColor(Color.yellow).font(.body)
                                            }.offset(x: 15, y: -17)
                                        }
                                        
                                        
                                    }
                                }
                                
                                
                                
                                NavigationLink(destination: GroupCalendarView(group: $group)){
                                    ZStack{
                                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                        
                                        Image(systemName: "calendar").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                    }
                                   
                                }
                            }.padding(15)
                       
                            
                            
                        }.padding(.trailing,10)
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 20){
                                ForEach(sortUsersActive(users: selectedGroupVM.group?.realUsers ?? [])){ user in
                                    
                                    NavigationLink(destination: UserProfilePage(user: user, isCurrentUser: user.wrappedValue.id ?? " " == userVM.user?.id ?? " "), label:{
                                        
                                        VStack(spacing: 5){
                                            WebImage(url: URL(string: user.wrappedValue.profilePicture ?? ""))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width:40,height:40)
                                                .clipShape(Circle())
                                            
                                            HStack{
                                                Text("\(user.wrappedValue.nickName ?? "TOP SECRET USER")").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                                                Circle().frame(width: 5, height: 5).foregroundColor(user.wrappedValue.isActive ?? false ? Color.green : Color.red)
                                            }
                                            
                                            
                                        }
                                        
                                    })
                                }
                            }.padding(.leading,12)
                            
                        }
                        
                    }
                    
                    
                    
                    HomeCalendarView(group: $group)
                    
                    
                    //                EventList(group: $selectedGroupVM.group)
                    //                CountdownList(group: $selectedGroupVM.group)
                    
                }
                
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear {
            selectedGroupVM.fetchGroup(userID: userVM.user?.id ?? " ", groupID: group.id, completion: { fetched in
                //TODO
                self.group = selectedGroupVM.group ?? Group()
            })
        }
        
        
    }
}

struct HomeCalendarView : View {
    @StateObject var homeCalendarVM = HomeCalendarViewModel()
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @Binding var group: Group
    @State var openEventView : Bool = false
    @State var selectedEvent : EventModel = EventModel()
    @State var action : Bool = false
    
    @State var selectedOptionIndex = 0
    
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                
                
                
                
                HStack{
                    
                    HStack{
                        Spacer()
                        Button(action:{
                            withAnimation(.easeInOut){
                                self.selectedOptionIndex = 0
                            }
                        },label:{
                            Text("All").foregroundColor(FOREGROUNDCOLOR)
                        }).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(selectedOptionIndex == 0 ? Color("AccentColor") : Color("Color")))
                        
                        Spacer()
                        
                        Button(action:{
                            withAnimation(.easeInOut){
                                self.selectedOptionIndex = 1
                            }
                        },label:{
                            Text("Events").foregroundColor(FOREGROUNDCOLOR)
                        }).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(selectedOptionIndex == 1 ? Color("AccentColor") : Color("Color")))
                        
                        Spacer()
                        
                        Button(action:{
                            withAnimation(.easeInOut){
                                self.selectedOptionIndex = 2
                            }
                        },label:{
                            Text("Polls").foregroundColor(FOREGROUNDCOLOR)
                        }).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(selectedOptionIndex == 2 ? Color("AccentColor") : Color("Color")))
                        
                        Spacer()
                    }
                    
                 
                    
                    
                    
                    
                }
                
                ScrollView(showsIndicators: false){
                    VStack{
                        switch self.selectedOptionIndex {
                            
                        case 0:
                            
                            if homeCalendarVM.eventsReturnedResults.isEmpty && homeCalendarVM.countdownReturnedResults.isEmpty {
                                Text("Nothing for Today!")
                            }
                            ForEach($homeCalendarVM.eventsReturnedResults, id: \.id){ event in
                                Button(action:{
                                    selectedEvent = event.wrappedValue
                                    
                                    self.openEventView.toggle()
                                },label:{
                                    EventCell(event: event, currentDate:Date(), isHomescreen: true, group: $group, action: $action)
                                })
                            }
                            
                            
                            
                            ForEach(homeCalendarVM.countdownReturnedResults, id: \.id){ countdown in
                                CountdownCell(countdown: countdown)
                            }
                            
                            
                        case 1:
                            if homeCalendarVM.eventsReturnedResults.isEmpty {
                                Text("No Events for Today!")
                            }else{
                                ForEach($homeCalendarVM.eventsReturnedResults, id: \.id){ event in
                                    Button(action:{
                                        selectedEvent = event.wrappedValue
                                        self.openEventView.toggle()
                                    },label:{
                                        EventCell(event: event, currentDate:Date(), isHomescreen: true, group: $group, action: $action)
                                    })
                                }
                            }
                            
                            
                        case 2:
                            if homeCalendarVM.countdownReturnedResults.isEmpty {
                                Text("No Countdowns for Today!")
                            }else{
                                ForEach(homeCalendarVM.countdownReturnedResults, id: \.id){ countdown in
                                    CountdownCell(countdown: countdown)
                                }
                            }
                            
                            
                        default:
                            Text("Hello World")
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                
                
            }
            
            NavigationLink(destination: FullEventView(event: $selectedEvent, group: group), isActive: $openEventView, label: {EmptyView()})
            
            
        }.onAppear{
            homeCalendarVM.startSearch(groupID: group.id)
        }.onChange(of: self.action) { action in
            homeCalendarVM.startSearch(groupID: group.id)
        }
        
    }
}


struct NotificationList : View {
    
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    
    var body : some View {
        VStack{
            HStack{
                
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                },label:{
                    ZStack{
                        Circle().foregroundColor(Color("Color")).frame(width:40, height: 40)
                        
                        Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                    }
                })
                
                Spacer()
            }.padding(.leading).padding(.top,50)
            
            HStack{
                HStack{
                    Text("Notifications").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title2)
                    
                    if(selectedGroupVM.group?.events?.count == 1){
                        Text("\(selectedGroupVM.group?.notificationsCount ?? 0) notifications today").foregroundColor(Color.gray).font(.footnote)
                    }else{
                        Text("\(selectedGroupVM.group?.notificationsCount ?? 0) notifications today").foregroundColor(Color.gray).font(.footnote)
                    }
                    
                }.padding(.leading,10)
                
                Spacer()
                
            }
            ScrollView(showsIndicators: false){
                
                VStack{
                    ForEach(selectedGroupVM.group?.groupNotifications?.identifiableIndices ?? IdentifiableIndices(base: [GroupNotificationModel()])){ index in
                        Button {
                            
                        } label: {
                            GroupNotificationCell(groupNotification: selectedGroupVM.group?.groupNotifications?[index.rawValue] ?? GroupNotificationModel())
                            
                        }
                        
                    }
                }
                
                
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            
            //ERROR
            
            for notification in selectedGroupVM.group?.unreadGroupNotifications ?? []{
                selectedGroupVM.readGroupNotifications(groupID: selectedGroupVM.group?.id ?? " ",userID: userVM.user?.id ?? " ", notification: notification)
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
                            //                            Button {
                            //
                            //                            } label: {
                            ////                                EventCell(event: group.events?[index.rawValue] ?? EventModel())
                            //                            }.sheet(isPresented: $showEvent){
                            //
                            //                            } content: {
                            //                                FullEventView(event:  group.events?[index.rawValue] ?? EventModel())
                            //                            }
                            //
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

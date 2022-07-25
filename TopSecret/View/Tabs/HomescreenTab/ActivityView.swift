
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
                        
                     
                        
                    }
                    
                    Button(action:{
                        self.openChat.toggle()
                    },label:{
                        ChatBubble(chat: selectedGroupVM.group?.chat ?? ChatModel(), groupID: group.id)
                    }).padding()

                    
                    
                    
                    HomeCalendarView(group: $group)
                    
                    
             
                    
                }
                
            }
            
            NavigationLink(destination: ChatView(group: $group, uid: userVM.user?.id ?? " ").environmentObject(selectedGroupVM), isActive: $openChat) {
                EmptyView()
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
        
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
                        }).padding(10).padding(.horizontal,10).background(RoundedRectangle(cornerRadius: 16).fill(selectedOptionIndex == 0 ? Color("AccentColor") : Color("Color")))
                        
                        Spacer()
                        
                        Button(action:{
                            withAnimation(.easeInOut){
                                self.selectedOptionIndex = 1
                            }
                        },label:{
                            Text("Events").foregroundColor(FOREGROUNDCOLOR)
                        }).padding(10).padding(.horizontal,10).background(RoundedRectangle(cornerRadius: 16).fill(selectedOptionIndex == 1 ? Color("AccentColor") : Color("Color")))
                        
                        Spacer()
                        
                        Button(action:{
                            withAnimation(.easeInOut){
                                self.selectedOptionIndex = 2
                            }
                        },label:{
                            Text("Polls").foregroundColor(FOREGROUNDCOLOR)
                        }).padding(10).padding(.horizontal,10).background(RoundedRectangle(cornerRadius: 16).fill(selectedOptionIndex == 2 ? Color("AccentColor") : Color("Color")))
                        
                        Spacer()
                    }
                    
                 
                    
                    
                    
                    
                }
                
                if selectedGroupVM.finishedFetchingGroupEvents {
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
                    
                }else{
                    ProgressView()
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

struct ChatBubble : View {
    
    var chat: ChatModel
    @StateObject var messageVM = MessageViewModel()
    @EnvironmentObject var userVM : UserViewModel
    var groupID: String
    var body: some View {
        VStack{
            
            
            HStack(alignment: .top, spacing: 5){
                
          
                Text("\(messageVM.readLastMessage().name ?? " ")").bold()

                Text("\(messageVM.readLastMessage().messageValue ?? " ")").padding(.leading,7)
                
                Spacer()
                
                Text("\(messageVM.readLastMessage().messageTimeStamp?.dateValue() ?? Date(), style: .time)")
            }
            
            Spacer()
            
        }.foregroundColor(FOREGROUNDCOLOR).padding(15).frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height, alignment: .leading).background(RoundedRectangle(cornerRadius: 25).fill( Color("Color"))).overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("AccentColor"), lineWidth:1.5)).onAppear{
            messageVM.readAllMessages(chatID: chat.id, userID: userVM.user?.id ?? " ", chatType: "groupChat", groupID: groupID)
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
                    
                    
                }.padding(.leading,10)
                
                Spacer()
                
            }
            ScrollView(showsIndicators: false){
                
                VStack{
                    VStack(alignment: .leading, spacing: 0){
                        if selectedGroupVM.group?.groupNotifications?.filter{ item in
                            !(item.usersThatHaveSeen?.contains(userVM.user?.id ?? " ") ?? false)
                        }.count != 0 {
                         
                                
                            
                        Text("New").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline).padding(.leading)
                        }
                        
                        ForEach(selectedGroupVM.group?.groupNotifications?.filter{ item in
                            !(item.usersThatHaveSeen?.contains(userVM.user?.id ?? " ") ?? false) as? Bool ?? false}.identifiableIndices ?? IdentifiableIndices(base: [GroupNotificationModel()]) ){ index in
                            Button {
                                
                            } label: {
                                GroupNotificationCell(groupNotification: selectedGroupVM.group?.groupNotifications?[index.rawValue] ?? GroupNotificationModel())
                                
                            }
                            
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        Text("This Week").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline).padding(.leading)
                        ForEach(selectedGroupVM.group?.groupNotifications?.filter{ item in
                            (item.usersThatHaveSeen?.contains(userVM.user?.id ?? " ") ?? false) as? Bool ?? false}.identifiableIndices ?? IdentifiableIndices(base: [GroupNotificationModel()]) ){ index in
                            Button {
                                
                            } label: {
                                GroupNotificationCell(groupNotification: selectedGroupVM.group?.groupNotifications?[index.rawValue] ?? GroupNotificationModel())
                                
                            }
                            
                        }
                    }
                    
                }
                
                
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onDisappear{
            
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

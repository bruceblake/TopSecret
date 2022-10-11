
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
                    
                        
                    HStack(alignment: .top){
                            
                          
                            
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
                            }.padding(.leading,10)
                            
                            Spacer()
                            
                            VStack{
                                
                                ZStack{
                                    Button(action:{
                                        
                                    },label:{
                                        WebImage(url: URL(string: selectedGroupVM.group?.groupProfileImage ?? ""))
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
                            Text("\(selectedGroupVM.group?.motd ?? "Welcome to the group!")").font(.headline).bold()
                            Spacer()
                        }
                    }
                    

//                    HomeCalendarView(group: $group)
                    
                    ScrollView{
                        VStack(spacing: 10){
                            ForEach(selectedGroupVM.group?.polls ?? [], id: \.id){ poll in
                                if !(poll.finished ?? false){
                                    PollCell(poll: poll, showUsers: $showUsers, selectedPoll: $selectedPoll)
                                }else{
                                }
                            }
                            
                            ForEach(selectedGroupVM.posts) { post in
                                Text("\(post.id)").foregroundColor(FOREGROUNDCOLOR)
                            }
                        }
                    }.padding(10)
                    
             
                    
                }
                
            }
            
            NavigationLink(destination: GroupChatView(userID: userVM.user?.id ?? " ", groupID: group.id ?? " ", chatID: group.chatID ?? "test").environmentObject(selectedGroupVM), isActive: $openChat) {
                EmptyView()
            }
            
            BottomSheetView(isOpen: $showUsers, maxHeight: UIScreen.main.bounds.height * 0.45){
                ShowAllUsersVotedView(showUsers: $showUsers, poll: $selectedPoll)
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
                                   
//                                        EventCell(event: event, currentDate:Date(), isHomescreen: true, group: $group, action: $action).onTapGesture {
//                                            selectedEvent = event.wrappedValue
//
//                                            self.openEventView.toggle()
//                                        }
                                
                                }
                                
                                
                                
                                ForEach(homeCalendarVM.countdownReturnedResults, id: \.id){ countdown in
                                    CountdownCell(countdown: countdown)
                                }
                                
                                
                            case 1:
                                if homeCalendarVM.eventsReturnedResults.isEmpty {
                                    Text("No Events for Today!")
                                }else{
                                    ForEach($homeCalendarVM.eventsReturnedResults, id: \.id){ event in
                                    
//                                            EventCell(event: event, currentDate:Date(), isHomescreen: true, group: $group, action: $action).onTapGesture {
//                                                selectedEvent = event.wrappedValue
//                                                self.openEventView.toggle()
//                                            }
                                        
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
            
            NavigationLink(destination: FullEventView(event: selectedEvent, group: group), isActive: $openEventView, label: {EmptyView()})
            
            
        }.onAppear{
            homeCalendarVM.startSearch(groupID: group.id)
        }.onChange(of: self.action) { action in
            homeCalendarVM.startSearch(groupID: group.id)
        }
        
    }
}

struct ChatBubble : View {
    
    @State var chat: ChatModel
    @StateObject var messageVM = MessageViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @State var groupID: String
    var body: some View {
        VStack{
            
            
            HStack(alignment: .top, spacing: 5){
                
          
                Text("\(messageVM.messages.last?.name ?? " ")").bold()

                Text("\(messageVM.messages.last?.messageValue ?? " ")").padding(.leading,7)
                
                Spacer()
                
                Text("\(messageVM.messages.last?.messageTimeStamp?.dateValue() ?? Date(), style: .time)")
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
                
                
                Text("Notifications").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title2)

                
                Spacer()
            }.padding(.leading).padding(.top,50)
            
         
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




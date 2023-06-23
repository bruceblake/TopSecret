//
//  EventAttendanceView.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/9/23.
//

import SwiftUI

struct EventAttendanceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var selectedOptionIndex : Int = 0
    var event: EventModel
    @StateObject var searchVM = SearchRepository()
    
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "chevron.left").font(.headline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Attendance")
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal)
                
                HStack{
                    
                    
                    Spacer()
                    
                    Button {
                        
                        selectedOptionIndex = 0
                    } label: {
                        VStack{
                            Text("\(event.usersAttendingID?.count ?? 0) Attending").foregroundColor(selectedOptionIndex == 0 ? Color("AccentColor") : FOREGROUNDCOLOR)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedOptionIndex = 1
                    } label: {
                        Text("\(event.usersUndecidedID?.count ?? 0) Undecided").foregroundColor(selectedOptionIndex == 1 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedOptionIndex = 2
                    } label: {
                        Text("\(event.usersDeclinedID?.count ?? 0) Declined").foregroundColor(selectedOptionIndex == 2 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    }
                    
                    Spacer()
                    
                }.padding(5)
                
                SearchBar(text: $searchVM.searchText, placeholder: "Search", onSubmit: {
                    
                })
                
                NavigationLink(destination: InviteFriendsToEventView(event: event)) {
                    HStack{
                        
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "person.fill.badge.plus").font(.system(size: 18)).foregroundColor(FOREGROUNDCOLOR)
                        }
                        
                        
                        Text("Invite Friends").foregroundColor(FOREGROUNDCOLOR)
                        
                        Spacer()
                    }.padding(.vertical,10).padding(.leading,10)
                }
                
                
                Divider()
                
                TabView(selection: $selectedOptionIndex){
                    AttendingAttendanceView(event: event).tag(0)
                    UndecidedAttendanceView(event: event).tag(1)
                    DeclinedAttendanceView(event: event).tag(2)
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct AttendingAttendanceView: View {
    
    var event: EventModel
    @State var usersAttending: [User] = []
    @State var eventVM = EventsTabViewModel()
    @State var isLoading: Bool = false
    var body: some View {
        VStack{
            ScrollView{
                ForEach(usersAttending, id: \.id) { user in
                    UserSearchCell(user: user, showActivity: false)
                }
            }
        }.onAppear{
            let dp = DispatchGroup()
            dp.enter()
            self.isLoading = true
            eventVM.fetchUsers(usersID: event.usersAttendingID ?? []) { fetchedUsers in
                usersAttending = fetchedUsers
                dp.leave()
            }
            dp.notify(queue: .main, execute:{
                self.isLoading = false
            })
        }
    }
}

struct UndecidedAttendanceView: View {
    
    var event: EventModel
    @State var usersUndecided: [User] = []
    @State var eventVM = EventsTabViewModel()
    @State var isLoading: Bool = false
    var body: some View {
        VStack{
            ScrollView{
                ForEach(usersUndecided, id: \.id) { user in
                    UserSearchCell(user: user, showActivity: false)
                }
            }
        }.onAppear{
            let dp = DispatchGroup()
            dp.enter()
            self.isLoading = true
            eventVM.fetchUsers(usersID: event.usersUndecidedID ?? []) { fetchedUsers in
                usersUndecided = fetchedUsers
                dp.leave()
            }
            
            dp.notify(queue: .main, execute:{
                self.isLoading = false
            })
        }
    }
}

struct DeclinedAttendanceView: View {
    
    var event: EventModel
    @State var usersDeclined: [User] = []
    @State var eventVM = EventsTabViewModel()
    @State var isLoading: Bool = false
    var body: some View {
        VStack{
            ScrollView{
                ForEach(usersDeclined, id: \.id) { user in
                    UserSearchCell(user: user, showActivity: false)
                }
            }
        }.onAppear{
            let dp = DispatchGroup()
            dp.enter()
            self.isLoading = true
            eventVM.fetchUsers(usersID: event.usersDeclinedID ?? []) { fetchedUsers in
                usersDeclined = fetchedUsers
                dp.leave()
            }
            dp.notify(queue: .main, execute:{
                self.isLoading = false
            })
        }
    }
}


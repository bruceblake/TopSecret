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
    @State var userGroups : [Group] = []
    @State var openGroupPassword : Bool = false
    @State var selectedGroup : Group = Group()
    
    @State var isMultiColumn : Bool = false
    @State var showRefresh : Bool = true
    
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: isMultiColumn ? 2 : 1)
    }
    
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
                
          
            
                   
                
                Button(action:{
                    isMultiColumn.toggle()
                },label:{
                    Image(systemName: isMultiColumn ? "rectangle.grid.1x2.fill" : "rectangle.grid.2x2.fill").foregroundColor(Color("AccentColor"))
                }).padding(.leading,UIScreen.main.bounds.width-40)
                
                
                if(showRefresh){
                    ZStack{
                        VStack{
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }else{
                    ScrollView{
                        
                             
                              
                        LazyVGrid(columns: columns, alignment: .center,spacing: 10){
                         

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
                                            Text("hello").foregroundColor(FOREGROUNDCOLOR)
    //                                        Text(group.users?.count ?? 0).foregroundColor(FOREGROUNDCOLOR)
                                        }
                                    

                                    
                                }).disabled(group.groupName == "" || group.groupName == " ")

                            }
                        }.padding(.horizontal).animation(.spring(), value: isMultiColumn).fullScreenCover(isPresented: $openGroupPassword) {
                            
                        } content: {
                            NavigationView{
                                EnterGroupPassword(group: $selectedGroup)
                            }
                        }
                       
                        
                    }.padding(.top)
                }
                
                
        
                
                
            }.padding(.horizontal,30)
            
      
            
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            
            let group = DispatchGroup()
            
            group.enter()
            
            self.userGroups.removeAll()
            
            for groupID in userVM.user?.groups ?? [] {
                group.enter()

                userVM.fetchGroup(groupID: groupID) { fetchedGroup in
                    self.userGroups.append(fetchedGroup)
                    group.leave()
                }

            }

            group.leave()
            
            group.notify(queue: .main) {
                showRefresh = false
            }
        
        }
           
           
        
        
       
    }
}





//struct HomeScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeScreen().environmentObject(UserViewModel()).colorScheme(.dark)
//    }
//}
//
//

struct EnterGroupPassword : View {
    

    @State var enteredSlots : [Int] = [-1,-1,-1,-1]
    @State var password : String = ""
    @State var correctPassword : Bool = false
    @State var tryPassword : Bool = false
    @State var openGroupHomeScreen : Bool = false
    @Binding var group : Group
    @State var groupChat : ChatModel = ChatModel()
    @State var users : [User] = []
    @State var events : [EventModel] = []
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var eventVM = EventViewModel()
    @Environment(\.presentationMode) var dismiss
    
    var body : some View {
        ZStack{
            Color("Background")
            
            VStack{
                
               
                    Button(action:{
                        dismiss.wrappedValue.dismiss()
                    },label:{
                        
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "x.circle").foregroundColor(FOREGROUNDCOLOR).font(.title3)

                            
                        }
                    }).foregroundColor(FOREGROUNDCOLOR).padding(.leading,UIScreen.main.bounds.width-60).padding(30)
                
                Spacer()
                
                
                HStack{
                    HStack{
                        Text("You are about to enter").foregroundColor(FOREGROUNDCOLOR)
                        Text(group.groupName).foregroundColor(Color("AccentColor")).fontWeight(.bold)
                    }
                }
                
                HStack{
                    Text("Please Enter The Password")
                }
                
                VStack{
                    Image(systemName: "plus")
                    
                    HStack{
                        ForEach(enteredSlots, id: \.self){ slot in
                            if(slot == -1){
                                Circle().frame(width: 20, height: 20).foregroundColor(FOREGROUNDCOLOR)
                            }else{
                                Circle().frame(width: 20, height: 20).foregroundColor(Color("AccentColor"))
                            }
                        }
                    }
                    
                    KeyPad(enteredSlots: $enteredSlots, password: $password, tryPassword : $tryPassword).padding()
                }
                
                Spacer()
            }.padding(.top)
            
       
            
            
            NavigationLink(destination: HomeScreenView(group: $group, groupChat: $groupChat, users: $users, events: $events), isActive: $openGroupHomeScreen) {
                EmptyView()
            }
       
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onChange(of: tryPassword) { newValue in
            
            print("password: \(password)")
            print("group password: \(group.password ?? "")")
            if(password != group.password){
                print("Wrong password!")
            }
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            userVM.fetchChat(chatID: group.chatID ?? " ") { chat in
                self.groupChat = chat
                groupD.leave()
            }
            
            for eventID in group.events ?? [] {
                groupD.enter()
                eventVM.fetchEvent(eventID: eventID) { event in
                    self.events.append(event)
                    groupD.leave()
                }

            }
            
            
            
            
            for userID in group.users ?? [] {
                groupD.enter()
                userVM.fetchUser(userID: userID) { user in
                    self.users.append(user)
                    groupD.leave()
                }
            }
            
            
            groupD.notify(queue: .main){
                if(password == group.password){
                    openGroupHomeScreen.toggle()
                }
            }
            
            
        }
    }
}


struct KeyPad : View {
    
    @Binding var enteredSlots : [Int]
    @Binding var password : String
    @Binding var tryPassword : Bool
    
    var width : CGFloat = 70
    var height  : CGFloat = 70
    
    var body: some View {
        VStack(spacing: 20){
            HStack(spacing: 15){
                
                ForEach(1..<4) { i in
                    Button(action:{
                        if password.count != 4 {
                            enteredSlots[password.count] = 1
                            password += "\(i)"
                        }
                    },label:{
                        ZStack{
                            Circle().frame(width: width, height: height).foregroundColor(Color("Color"))
                            Text("\(i)").foregroundColor(Color("AccentColor")).font(.title)
                        }
                    })

                }
                
            }
            
            
            HStack(spacing: 15){
                ForEach(4..<7) { i in
                    Button(action:{
                        if password.count != 4 {
                            enteredSlots[password.count] = 1
                            password += "\(i)"
                        }
                    },label:{
                        ZStack{
                            Circle().frame(width: width, height: height).foregroundColor(Color("Color"))
                            Text("\(i)").foregroundColor(Color("AccentColor")).font(.title)
                        }
                    })

                }
            }
            HStack(spacing: 15){
                ForEach(8..<11) { i in
                    Button(action:{
                        if password.count != 4 {
                            enteredSlots[password.count] = 1
                            password += "\(i)"
                        }
                    },label:{
                        ZStack{
                            Circle().frame(width: width, height: height).foregroundColor(Color("Color"))
                            Text("\(i == 10 ? 0 : i)").foregroundColor(Color("AccentColor")).font(.title)
                        }
                    })

                }
            }
            HStack{
                Button(action:{
                    tryPassword = true
                },label:{
                    ZStack{
                        Capsule().frame(width: width + 45, height: height-10).foregroundColor(Color("Color"))
                        Text("Open").foregroundColor(Color("AccentColor")).font(.title)
                    }
                })
                Button(action:{
                    if password.count != 0 {
                        enteredSlots[password.count-1] = -1
                        password.removeLast()
                    }
                 
                },label:{
                    ZStack{
                        Capsule().frame(width: width + 45, height: height-10).foregroundColor(Color("Color"))
                        Text("Delete").foregroundColor(Color("AccentColor")).font(.title)
                    }
                })
            }
        }
    }
}

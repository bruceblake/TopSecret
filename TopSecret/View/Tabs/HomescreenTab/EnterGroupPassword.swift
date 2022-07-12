//
//  EnterGroupPassword.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/10/22.
//

import SwiftUI

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
    @State var isDeveloping: Bool = true
    @StateObject var countdownViewModel = CountdownViewModel()
    
    
    
    
    
    
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
                    
                    KeyPad(enteredSlots: $enteredSlots, password: $password, tryPassword : $tryPassword, isDeveloping : $isDeveloping).padding()
                }
                
                Spacer()
            }.padding(.top)
            
            
            
            
            NavigationLink(destination: HomeScreenView(group: $group, groupChat: $groupChat, users: $users, tryPassword: $tryPassword), isActive: $openGroupHomeScreen) {
                EmptyView()
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onChange(of: tryPassword) { newValue in
            
            
           
                
               
                let groupD = DispatchGroup()
            
            groupD.enter()
            self.users.removeAll()
            groupD.leave()
                
       
                
                
                groupD.enter()
                userVM.fetchChat(chatID: group.chatID ?? " ") { chat in
                    self.groupChat = chat
                    groupD.leave()
                }
                

                
                
                
                for userID in group.users ?? [] {
                    groupD.enter()
                    userVM.fetchUser(userID: userID) { user in
                        self.users.append(user)
                        groupD.leave()
                    }
                }
                
                groupD.notify(queue: .main){
                    if(isDeveloping){
                            openGroupHomeScreen.toggle()
                    }else{
                        if(password == group.password){
                            openGroupHomeScreen.toggle()
                        }
                    }
                }
            
            
            
        }
    }
}

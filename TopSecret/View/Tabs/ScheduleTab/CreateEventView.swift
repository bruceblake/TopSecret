//
//  CreateEventView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase

struct CreateEventView: View {
    @State var eventName: String = ""
    @State var eventLocation: String = ""
    @State var eventStartTime : Date = Date()
    @State var eventEndTime : Date = Date()
    @State var selectedFriends : [User] = []
    @State var selectedGroups : [Group] = []
    @State var openFriendsList : Bool = false
    @State var openGroupsList : Bool = false
    var isGroup : Bool
    @StateObject var eventVM = EventViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    
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
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                    
                    
                    Spacer()
                    
                    Text("Schedule An Event!")
                        .fontWeight(.bold).font(.title)
                    Spacer()
                }.padding(.top,50)
                
                
                VStack(spacing: 20){
                    //Event Name
                    
                    VStack(alignment: .leading){
                        Text("Event Name").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        VStack{
                            CustomTextField(text: $eventName, placeholder: "Event Name", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                        }
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        HStack{
                        Text("Event Location").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            
                            Button(action:{
                                
                            },label:{
                                Text("Create Location")
                            })
                        }
                        ScrollView(.horizontal){
                            HStack(){
                               Button(action:{
                                   if eventLocation == "The White House"{
                                       eventLocation = ""
                                   }else{
                                    eventLocation = "The White House"
                                   }
                                },label:{
                                    Text("The White House").foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 20).fill(eventLocation == "The White House" ? Color("AccentColor") : Color("Color")))
                                })
                            }
                        }
                        
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        Text("Event Start Time").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        HStack{
                            DatePicker("", selection: $eventStartTime)
                            Spacer()
                        }
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        Text("Event End Time").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        HStack{
                            DatePicker("", selection: $eventEndTime)
                            Spacer()
                        }
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        Text("Visible To").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        
                        HStack{
                            Spacer()
                        if isGroup{
                            
                               Button(action:{
                                   selectedGroups.append(selectedGroupVM.group ?? Group())
                                },label:{
                                    Text("\(selectedGroupVM.group?.groupName ?? "")").foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 20).fill(Color("Color")))
                                })
                        }else{
                            HStack(spacing: 15){
                                Button(action:{
                                    withAnimation(.easeIn){
                                        self.openFriendsList.toggle()
                                    }
                                },label:{
                                    Text("Add Friends")
                                }).fullScreenCover(isPresented: $openFriendsList) {
                                
                                } content: {
                                    AddFriendsToEventView(isOpen: $openFriendsList)
                                }

                                
                                Button(action:{
                                    withAnimation(.easeIn){
                                        self.openGroupsList.toggle()
                                    }
                                },label:{
                                    Text("Add Groups")
                                }).fullScreenCover(isPresented: $openGroupsList) {
                                    
                                } content: {
//                                    AddGroupsToEventView()
                                    Text("Hello World")
                                }
                            }
                        }
                         
                            Spacer()
                            
                        }
                    }.padding(.horizontal)
                    
                    
                }.padding(.vertical,10)
                
                
                
                
                
                Button(action:{
                    
                    print("groupID: \(selectedGroupVM.group?.id ?? " ")")
                    eventVM.createEvent(group: selectedGroupVM.group ?? Group(), eventName: eventName, eventLocation: eventLocation, eventStartTime: eventStartTime , eventEndTime: eventEndTime, usersVisibleTo:selectedGroupVM.group?.realUsers ?? [] , user: userVM.user ?? User())
                    presentationMode.wrappedValue.dismiss()
                },label:{
                    Text("Create Event").foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                })
                
                Spacer()
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct CreateEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateEventView()
//    }
//}

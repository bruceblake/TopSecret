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
    @State var membersCanInviteGuests : Bool = false
    @State var isAllDay : Bool = false
    @State var eventEndTime : Date = Date()
    @State var selectedFriends : [User] = []
    @State var selectedGroups : [Group] = []
    @State var openFriendsList : Bool = false
    @State var openGroupsList : Bool = false
    @State var searchLocationView : Bool = false
    @State var openImagePicker: Bool = false
    @State var image = UIImage(named: "topbarlogo")!
    var isGroup : Bool
    @StateObject var eventVM = EventViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    let options = ["Open to Friends", "Open to Mutuals", "Invite Only"]
    @State var selectedOption : Int = 0
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack(alignment: .center){
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
                    
                    Button(action:{
                        
                        eventVM.createEvent(group: selectedGroupVM.group, eventName: eventName, eventLocation: eventLocation, eventStartTime: eventStartTime , eventEndTime: eventEndTime, usersVisibleTo:selectedGroupVM.group.realUsers , user: userVM.user ?? User(), image: image)
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Create").foregroundColor(FOREGROUNDCOLOR).padding(.horizontal,10).padding(.vertical,5).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor"))).disabled(eventName == "")
                           
                    }).disabled(eventName == "")
                }.padding(.top,50).padding(.horizontal,10)
                
                
                ScrollView{
                    
                    
                    VStack(alignment: .leading, spacing: 20){
                        //Event Name
                        
                        VStack(){
                            
                            TextField("Event Name",text: $eventName).multilineTextAlignment(.center).font(.system(size: 25, weight: .bold))
                            Rectangle().frame(width: UIScreen.main.bounds.width-50, height: 2).foregroundColor(Color.gray)
                
                        }.padding(10)
                        HStack{
                            
                            Text("Invitation Type").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            Divider()
                            Menu {
                                VStack{
                                    ForEach(options, id: \.self){ option in
                                        Button(action:{
                                            if option == options[0]{
                                                withAnimation{
                                                    selectedOption = 0
                                                }
                                            }
                                            else if option == options[1]{
                                                withAnimation{
                                                    selectedOption = 1
                                                }
                                            }
                                            else if option == options[2]{
                                                withAnimation{
                                                    selectedOption = 2
                                                }
                                            }
                                            
                                           
                                        },label:{
                                            Text(option)
                                        })
                                    }
                                }
                            } label: {
                                HStack{
                                    Text("\(options[selectedOption])").foregroundColor(FOREGROUNDCOLOR)
                                    Image(systemName: "chevron.down")
                                }
                            }
                            

                        }.padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(.horizontal)
                        
                        
                        //place here
                        
                        VStack(alignment: .leading){
                            Text("Event Details").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            VStack{
                                HStack{
                                    Toggle(isOn: $isAllDay) {
                                        Text("All Day")
                                    }
                                }
                                Divider()
                                
                                
                                
                                HStack{
                                    Text("Start")
                                    if isAllDay{
                                        DatePicker("", selection: $eventStartTime, displayedComponents: .date)
                                    }else{
                                        DatePicker("", selection: $eventStartTime)
                                    }
                                  
                                    Spacer()
                                }
                                
                                HStack{
                                    Text("End")
                                    if isAllDay{
                                        DatePicker("", selection: $eventEndTime, displayedComponents: .date)
                                    }else{
                                        DatePicker("", selection: $eventEndTime)
                                    }
                                    Spacer()
                                }
                                
                                Divider()
                                
                                HStack{
                                    Image(systemName: "mappin")
                                    Text("Add Location")
                                    Spacer()
                                    Button(action:{
                                        
                                    },label:{
                                        Image(systemName: "chevron.right")
                                    })
                                }
                                
                                Divider()
                                
                                HStack{
                                    Image(systemName: "text.alignleft")
                                    Text("Description")
                                    Spacer()
                                    Button(action:{
                                        
                                    },label:{
                                        Image(systemName: "chevron.right")
                                    })
                                }
                                
                            }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        }.padding(.horizontal)
                        
                        VStack(alignment: .leading){
                            Text("Participants").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            VStack{
                                
                                HStack{
                                    VStack{
                                        Text("Invite Members")
                                    }
                                    Spacer()
                                    Button(action:{
                                        
                                    },label:{
                                        Image(systemName: "chevron.right")
                                    })
                                }
                                Divider()
                                HStack{
                                    VStack{
                                        Text("Exclude Members")
                                    }
                                    Spacer()
                                    Button(action:{
                                        
                                    },label:{
                                        Image(systemName: "chevron.right")
                                    })
                                }
                                Divider()
                                
                                Toggle(isOn: $membersCanInviteGuests) {
                                    Text("Members Can Invite Guests")
                                }
                            }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        }.padding(.horizontal)
                    
                  
                        
                       
                        
                    }.padding(.vertical,10)
                    
                    
                   
                }
                
                
                
              
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct CreateEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateEventView()
//    }
//}

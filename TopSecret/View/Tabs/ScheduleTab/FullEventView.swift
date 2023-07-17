//
//  FullEventView.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/22/22.
//

import SwiftUI
import Firebase

struct FullEventView : View {
    
  
    var event : EventModel
    var group: Group
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var eventVM = EventViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                    
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        }
                    }).padding(.leading,10)
                    Spacer()
                    Text("\(event.eventName ?? "EVENT_NAME")").fontWeight(.bold).font(.largeTitle).foregroundColor(FOREGROUNDCOLOR)
                    Spacer()
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "pencil").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        }
                    }).padding(.trailing, 10)
                    
                    
                }.padding(.top,50)
                
                VStack(alignment: .leading, spacing: 30){
                    
                    
                    //Date
                    HStack{
                        VStack(alignment: .leading, spacing: 10){
                            Text("Date").font(.title)
                            VStack{
                                Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .date)")
                            }.padding(.horizontal)
                        }
                        Spacer()
                    }
                    
                    //Time
                    HStack{
                        VStack(alignment: .leading, spacing: 10){
                            Text("Time").font(.title)
                            HStack{
                                Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .time)")
                                Image(systemName: "arrow.right").foregroundColor(.gray)
                                Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .time)")

                            }.padding(.horizontal)
                        }
                        Spacer()
                    }
                   
                    
                    //Location
                    VStack(alignment: .leading, spacing: 10){
                        Text("Location").font(.title)
                        VStack{
                            Text("\(event.eventLocation ?? "EVENT_LOCATION")")
                        }.padding(.horizontal)
                    }
                    
                    //Availability
                    VStack(alignment: .leading, spacing: 10){
                        HStack{
                            Text("Availability").font(.title)
                            Button(action:{
                                
                            },label:{
                                Text("See Info")
                            })
                        }
                        VStack{
                            ForEach(event.usersAttending ?? []){ user in
                                UserSearchCell(user: user, showActivity: true)
                            }
                        }
                    }
                    
                    Spacer()
                }.padding()
                
                
                if !(event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false){
                    Button(action: {
                        eventVM.joinEvent(eventID: event.id, userID: userVM.user?.id ?? " ")
                    }, label: {
                        Text("Join Event").foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                           .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                    }).padding(30)
                }else{
                    Button(action: {
                        eventVM.leaveEvent(eventID: event.id, groupID: group.id, userID: userVM.user?.id ?? " ")
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Edit Availability").foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                           .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                    }).padding(30)
                }
               
               
             
                
            
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct FullEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        FullEventView(event: EventModel(), group: Group())
//    }
//}

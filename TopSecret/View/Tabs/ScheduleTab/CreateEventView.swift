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
    @State var eventTime : Date = Date()
    @State var usersVisibleTo : [String] = []
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
                        Text("Event Location").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        VStack{
                            CustomTextField(text: $eventLocation, placeholder: "Event Location", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                            
                        }
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        Text("Event Time").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        HStack{
                            DatePicker("", selection: $eventTime)
                            Spacer()
                        }
                    }.padding(.horizontal)
                    
                    
                }.padding(.vertical,10)
                
                
                
                
                
                Button(action:{
                    
                    print("groupID: \(selectedGroupVM.group?.id ?? " ")")
                    eventVM.createEvent(groupID: selectedGroupVM.group?.id ?? " ", eventName: eventName, eventLocation: eventLocation, eventTime: eventTime , usersVisibleTo: usersVisibleTo, user: userVM.user ?? User())
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

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
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                Text("Schedule An Event!")
                    .font(.title)
                    .fontWeight(.bold).padding(.top,30)
                Spacer()
                
                //Event Name
                CustomTextField(text: $eventName, placeholder: "Event Name", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                
                //Event Location
                CustomTextField(text: $eventLocation, placeholder: "Event Location", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                
                
                DatePicker("", selection: $eventTime, displayedComponents: [.date,.hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                
          
                
                
                Button(action:{
                    eventVM.createEvent(eventName: eventName, eventLocation: eventLocation, eventTime: eventTime ?? Date(), usersVisibleTo: usersVisibleTo, userID: userVM.user?.id ?? "")
                    presentationMode.wrappedValue.dismiss()
                },label:{
                    Text("Create Event")
                })
                
                Spacer()
            }
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}

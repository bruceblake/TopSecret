//
//  CreateCountdownView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/22/22.
//

import SwiftUI
import Firebase

struct CreateCountdownView: View {
    @State var selectedDate: Date = Date()
    @StateObject var groupVM = GroupViewModel()
    @State var countdownName : String = ""
    @Binding var group: Group
    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                TextField("Countdown name", text: $countdownName)
                DatePicker("Countdown end", selection: $selectedDate)
                Button(action:{
                    groupVM.createCountdown(group: group, countdownName: countdownName, startDate: Timestamp(), endDate: selectedDate)
                },label:{
                    Text("Create Countdown")
                })
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct CreateCountdownView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateCountdownView()
//    }
//}

//
//  EnterBirthday.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct EnterBirthday: View {
    
    @State var isNext:Bool = false
    @State var selectedDate = Date()
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ZStack{
            
            Color("Background")
            VStack{
                Text("Enter your birthday").foregroundColor(Color("Foreground")).font(.largeTitle).fontWeight(.bold).padding(.horizontal)
                
                Text("Don't worry, you can create an account regardless of your age").font(.headline).padding(.bottom,30)
                
                
                
                
                //BIRTHDAY PICKER TODO
                
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                
                
                
                Button(action: {
                    self.isNext.toggle()
                    userVM.birthday = selectedDate
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                NavigationLink(
                    destination: EnterUserProfilePicture(),
                    isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                
                Spacer()
            }.padding(.top,100)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct EnterBirthday_Previews: PreviewProvider {
    static var previews: some View {
        EnterBirthday().preferredColorScheme(.dark).environmentObject(UserViewModel())
    }
}

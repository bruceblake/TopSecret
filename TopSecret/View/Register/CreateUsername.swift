//
//  CreateUsername.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct CreateUsername: View {
    
    @State var isNext:Bool = false
    @State var showErrorMessage:Bool = false
    @EnvironmentObject var userAuthVM: UserViewModel
    @StateObject var registerValidation = RegisterValidationViewModel()
    
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                Text("Create Your Username").foregroundColor(Color("Foreground")).font(.largeTitle).fontWeight(.bold).padding(.horizontal)
                
                Text("Create a unique username").font(.headline)
                
                Text("Remeber, you can only change your username once every two weeks").padding(.bottom,20).font(.footnote).foregroundColor(Color("Foreground").opacity(0.5)).padding(.horizontal,20).padding(.top,10)
                
                
                CustomTextField(text: $registerValidation.username, placeholder: "Username", isPassword: false, isSecure: false, hasSymbol: true,symbol: "person").padding(.horizontal,20)
               
                if showErrorMessage{
                Text("\(registerValidation.usernameErrorMessage)").padding(.top,5).foregroundColor(registerValidation.usernameErrorMessage == "valid!" ? .green : .red)
                }
                Button(action: {
                    if registerValidation.usernameErrorMessage == "valid!"{
                    self.isNext.toggle()
                    self.userAuthVM.username = registerValidation.username
                    }else{
                        showErrorMessage = true
                    }
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                NavigationLink(
                    destination: EnterFullName(),
                    isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                
                Spacer()
            }.padding(.top,100)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct CreateUsername_Previews: PreviewProvider {
    static var previews: some View {
        CreateUsername().preferredColorScheme(.dark)
            .environmentObject(UserViewModel())
    }
}

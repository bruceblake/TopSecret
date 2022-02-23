//
//  CreatePassword.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct CreatePassword: View {
    @State var password: String = ""
    @State var showErrorMessage:Bool = false
    @EnvironmentObject var userVM : UserViewModel
    @ObservedObject var registerVM = RegisterValidationViewModel()
    
    var body: some View {
        ZStack{
            
            Color("Background")
            VStack{
                Text("Create A Password").foregroundColor(Color("Foreground")).font(.largeTitle).fontWeight(.bold).padding(.horizontal)
                
                Text("Make sure your password is secure").font(.headline).padding(.bottom,30)
                
                
                
                
                CustomTextField(text: $registerVM.password, placeholder: "Password", isPassword: true, isSecure: true, hasSymbol: true ,symbol: "lock").padding(.horizontal,20)
                
                if showErrorMessage{
                Text(registerVM.passwordErrorMessage).padding(.top,5).foregroundColor(registerVM.passwordErrorMessage == "Password is valid!" ? .green : .red)
                }
                
                Button(action: {
                    if registerVM.passwordErrorMessage == "Password is valid!"{
                        userVM.createUser(email: userVM.email , password: registerVM.password, username: userVM.username, nickName: userVM.nickName , birthday: userVM.birthday , image: userVM.userProfileImage)
                    }else{
                        showErrorMessage = true
                    }
                }, label: {
                    Text("Create Account")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                
                
                Spacer()
            }.padding(.top,100)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct CreatePassword_Previews: PreviewProvider {
    static var previews: some View {
        CreatePassword().preferredColorScheme(.dark).environmentObject(UserViewModel())
    }
}

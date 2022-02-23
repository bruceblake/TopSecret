//
//  UserEditProfilePageView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/4/22.
//

import SwiftUI

struct UserEditProfilePageView: View {
    @State var bio: String = ""
    @Environment(\.presentationMode) var dismiss
    @EnvironmentObject var userVM: UserViewModel
    @State var user: User
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                
                Text("Change Bio")
                
                
                CustomTextField(text: $bio, placeholder: user.bio ?? "Bio" ,isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                
                
                Button(action:{
                    userVM.changeBio(userID: userVM.user?.id ?? "", bio: bio)
                    dismiss.wrappedValue.dismiss()
                    
                },label:{
                    Text("Save")
                })
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct UserEditProfilePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserEditProfilePageView()
//    }
//}

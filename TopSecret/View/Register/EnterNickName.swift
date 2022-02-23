//
//  EnterFullName.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct EnterFullName: View {
    
    @State var nickName: String = ""
    @State var isNext: Bool = false
    @EnvironmentObject var userAuthVM: UserViewModel
    
    
    var body: some View {
        ZStack{
            
            Color("Background")
            VStack{
                Text("Enter your nickname").foregroundColor(Color("Foreground")).font(.largeTitle).fontWeight(.bold).padding(.horizontal)
                
                Text("This is the name your friends will see you as").font(.headline).padding(.bottom,30)
                
                
                
                
                CustomTextField(text: $nickName, placeholder: "Nickname", isPassword: false, isSecure: false, hasSymbol: false,symbol: "none").padding(.horizontal,20)
                
                
                
                
                
                Button(action: {
                    self.isNext.toggle()
                    userAuthVM.nickName = nickName
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                NavigationLink(
                    destination: EnterBirthday(),
                    isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                
                Spacer()
            }.padding(.top,100)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct EnterFullName_Previews: PreviewProvider {
    static var previews: some View {
        EnterFullName().preferredColorScheme(.dark)
            .environmentObject(UserViewModel())
    }
}

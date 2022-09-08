//
//  RegisterView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/4/21.
//

import SwiftUI

struct RegisterEmailView: View {
    @State var isNext:Bool = false
    @State var usingEmail:Bool = true
    @State var showErrorMessage:Bool = false
    @EnvironmentObject var validationVM : RegisterValidationViewModel
    
    
    
    
    
    var body: some View {
        
        
        
        if usingEmail {
            ZStack {
                
                Color("Background")
                
                NavigationLink(
                    destination:CreateUsername().environmentObject(validationVM),             isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                VStack{
                    
                    
                    
                    VStack{
                        Text("Enter Email").foregroundColor(Color("Foreground")).fontWeight(.bold).font(.largeTitle).padding(.bottom,10)
                        
                        CustomTextField(text: $validationVM.email, placeholder: "Email", isPassword: false, isSecure: false, hasSymbol: true,symbol: "envelope").padding(.horizontal,20)
                        
                        if showErrorMessage{
                        Text("\(validationVM.emailErrorMessage)").padding(.top,5).foregroundColor(validationVM.emailErrorMessage == "valid!" ? .green : .red)
                        }
                        Button(action: {
                            if validationVM.emailErrorMessage == "valid!"{
                              
                                self.isNext.toggle()
                            
                            }else{
                                showErrorMessage = true
                            }
                            
                            
                        }, label: {
                            Text("Next")
                                .foregroundColor(Color("Foreground"))
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                        }).padding()
                        
                        
                        Button(action:{
                            self.usingEmail.toggle()
                        },label:{Text("I want to use my phone number").font(.body)})
                        
                        
                    
                    }
                    
                    Spacer()
                    
                }.padding(.top,100)
                
            }.edgesIgnoringSafeArea(.all)
        }else{
            RegisterPhoneView(usingEmail: $usingEmail)
        }
    }
    
    

    
}

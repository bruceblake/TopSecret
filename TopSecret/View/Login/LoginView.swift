//
//  LoginView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/3/21.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var userAuthVM: UserViewModel
    @StateObject var userCoreDataVM = UserCoreDataViewModel()
    @State var showForgotPasswordView = false
    @State var beginRegisterView: Bool = false
    @State var value: CGFloat = 0
    var body: some View {
        
        NavigationView {
            ZStack{
                //Background color
                Color("Background")
                    
                    //Overal VStack
                VStack{
                    
                    
                 Spacer()
                   
                    
                 //Icon and Name
                VStack{
                    
                  
                    Image("FinishedIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 150, height: 150)
                    Text("Top Secret")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Foreground"))
                    
                }
                    
                    VStack(spacing: 10){
                        
                        Text(userAuthVM.loginErrorMessage).foregroundColor(.red)
                    
                        //Text Fields
                    VStack(spacing: 20){
                        CustomTextField(text: $email, placeholder: "Email", isPassword: false, isSecure: false, hasSymbol: true,  symbol: "envelope")
                        CustomTextField(text: $password, placeholder: "Password", isPassword: true, isSecure: true, hasSymbol: true, symbol: "key")
                           
                      
                    }.padding(.horizontal)
                        //Forgot Password
                        HStack{
                          
                            Spacer()
                            
                            Button(action: {
                                showForgotPasswordView = true
                            },label: {
                                Text("Forgot Password?").foregroundColor(Color("AccentColor")).font(.system(size: 12)).padding(.trailing,30)
                            })
                            
                        }
                        

                    Button(action: {
                        userAuthVM.signIn(withEmail: email, password: password, completion: { fetchedUser in
                            userCoreDataVM.addUser(user: fetchedUser)
                            print("user: \(fetchedUser.username ?? " ")")
                        })
                    }, label: {
                        Text("Login")   .foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                           .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                    }).padding(.top,15)
                    .sheet(isPresented: $showForgotPasswordView, content: {
                        ForgotPasswordView(showForgotPasswordView: $showForgotPasswordView)
                    })
                    
                    }.padding(.top,50)
                    
                    Spacer()
                }.offset(y: -self.value)
                .onAppear{
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                        let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                        let height = value.height/2
                        self.value = height
                    }
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                   
                        self.value = 0
                    }
                }
                
                NavigationLink(
                    destination: RegisterEmailView(),
                    isActive: $beginRegisterView,
                    label: {
                        EmptyView()
                    })
                    
                    
                
            }.edgesIgnoringSafeArea(.all)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        self.beginRegisterView.toggle()
                    },label:{
                        Text("Register")
                    })
                }
        }
            
            
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().preferredColorScheme(.dark).environmentObject(UserViewModel())
    }
}


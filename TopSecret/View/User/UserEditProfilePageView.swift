//
//  UserEditProfilePageView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/4/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserEditProfilePageView: View {
   
    @State var bio: String = ""
    @State var username : String = ""
    @State var nickName: String = ""
    @Environment(\.presentationMode) var dismiss
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var userEditVM = UserEditProfileViewModel()
    @EnvironmentObject var registerValidation : RegisterValidationViewModel
    @State var showErrorMessage : Bool = false
    @State var isShowingPhotoPicker : Bool = false
    @State var avatarImage : UIImage = UIImage(named: "Icon")!
    @State var images : [UIImage] = []
    @State var showContentView : Bool = false
    @Binding var showEditPage : Bool
    
    @State var storedUsername : Bool = false
  
    var body: some View {
        
       
        ZStack{
            Color("Background")
            VStack{
                
                HStack{
                    
                    Button(action:{
                        if userEditVM.didChangeUsername || userEditVM.didChangeBio || userEditVM.didChangeNickName {
                            showContentView.toggle()
                        }else{
                        dismiss.wrappedValue.dismiss()
                        }
                    },label:{
                        
                        Text("Cancel").foregroundColor(FOREGROUNDCOLOR).padding(10).background(Capsule().fill(Color("Color")))
                        
                    }).padding(.leading,10)
                    
                    Spacer()
                    
                    Text("Edit Profile").font(.largeTitle).bold()
                    
                    Spacer()
                    
                    Button(action:{
                        
                        
                        
                        if userEditVM.didChangeUsername{
                            userEditVM.changeUsername(userID: userVM.user?.id ?? " ", username: registerValidation.username)
                        }
                        
                        if userEditVM.didChangeBio{

                            userEditVM.changeBio(userID: userVM.user?.id ?? " ", bio: bio)
                        }
                        
                        if userEditVM.didChangeNickName{
                            userEditVM.changeNickname(userID: userVM.user?.id ?? " ", nickName: nickName)
                        }

                       
                        dismiss.wrappedValue.dismiss()
                        
                    },label:{
                        Text("Save")
                            .foregroundColor(registerValidation.usernameErrorMessage == "valid!" || !showErrorMessage ? Color("AccentColor") : .gray).padding(10).background(Capsule().fill(Color("Color")))
                    }).padding(.trailing,10).disabled(showErrorMessage && registerValidation.usernameErrorMessage != "valid!")
                    

                    
                }.padding(.top,50).padding(.bottom)
                
                
                VStack(alignment: .leading, spacing: 20){
                    
                    VStack{
                        HStack{
                            Text("Profile Picture").bold()
                            Spacer()
                        }.padding(.leading)
                        
                      
                            WebImage(url: URL(string: userVM.user?.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:50,height:50)
                                .clipShape(Circle())
                        
                      
                        Button(action:{
                            self.isShowingPhotoPicker.toggle()
                        },label:{
                            Text("Change Profile Picture")
                        }).fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                            ImagePicker(avatarImage: $avatarImage,allowsEditing: true)
                        })
                    }
                    
                VStack{
                    HStack{
                        Text("Username").bold()
                        Spacer()
                        Text("\(registerValidation.username.count)/15").foregroundColor(registerValidation.username.count < 16 ? .gray : .red).font(.caption).padding(.trailing)
                    }.padding(.leading)
                    CustomTextField(text: $registerValidation.username, placeholder: "\(userVM.user?.username ?? "")", isPassword: false, isSecure: false, hasSymbol: false, symbol: "").foregroundColor(FOREGROUNDCOLOR)
                    if showErrorMessage{
                    Text("\(registerValidation.usernameErrorMessage)").padding(.top,5).foregroundColor(registerValidation.usernameErrorMessage == "valid!" ? .green : .red)
                    }
                }
                    
                    VStack{
                        HStack{
                            Text("Nickname").bold()
                            Spacer()
                        }.padding(.leading)
                        CustomTextField(text: $nickName, placeholder: "\(userVM.user?.nickName ?? "")", isPassword: false, isSecure: false, hasSymbol: false, symbol: "").foregroundColor(FOREGROUNDCOLOR)
                    }
                
                VStack{
                    HStack{
                        Text("Bio")
                        Spacer()
                    }.padding(.leading)
                    ZStack{
                        
                        TextEditor(text: $bio).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        Text(bio).opacity(0).padding()
                    }.shadow(radius: 1).frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height / 8)
                }
                    
                  
                }
                
                        
                    
                
         
                Spacer()
                
               
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).opacity(showContentView ? 0.2 : 1).disabled(showContentView).overlay{
            if showContentView{
                SaveChangesOverlay(showContentView: $showContentView, dismiss: $showEditPage).frame(width: UIScreen.main.bounds.width/1.2,height: UIScreen.main.bounds.height/7).cornerRadius(16)
            }
        }.onReceive(registerValidation.$username) { newValue in
            if storedUsername{
                if newValue != userVM.user?.username ?? "" {
                    showErrorMessage = true
                }else{
                    showErrorMessage = false
                }
                userEditVM.didChangeUsername = true
            }
  

        }.onChange(of: nickName) { newValue in
            userEditVM.didChangeNickName = true
        }.onChange(of: bio) { newValue in
            userEditVM.didChangeBio = true
        }.onAppear{
            let dp = DispatchGroup()
            
            dp.enter()
            registerValidation.username = userVM.user?.username ?? " "
            dp.leave()
            
            dp.notify(queue: .main, execute: {
            self.storedUsername = true
            })
        }
        
    }
}


struct SaveChangesOverlay : View {
    
    @Binding var showContentView : Bool
    @Binding var dismiss : Bool
    
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                
                Spacer()
                
                HStack{
                    
                    Spacer()
                    
                    VStack{
                        
                        Text("You have unsaved changes")
                            .foregroundColor(FOREGROUNDCOLOR).font(.headline).bold()
                        
                        Spacer()
                        
                        HStack{
                            Button(action:{
                                showContentView.toggle()
                                dismiss.toggle()
                            },label:{
                                Text("Discard Changes").font(.body).padding(5).padding(.horizontal).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background"))).foregroundColor(FOREGROUNDCOLOR)
                            })
                            
                            Spacer()
                            
                            Button(action:{
                                showContentView.toggle()
                            },label:{
                                Text("Keep Editing").font(.body).padding(5).padding(.horizontal).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background"))).foregroundColor(FOREGROUNDCOLOR)
                            })
                        }
                        
                        
                    }
                    
                    Spacer()
                }
                
             
               
                Spacer()
            }
        }
    }
}


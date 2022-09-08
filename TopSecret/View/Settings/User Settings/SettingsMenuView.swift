//
//  SettingsMenuView.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/4/21.
//

import SwiftUI

struct SettingsMenuView: View {
    @Environment(\.presentationMode) var dismiss
    @EnvironmentObject var userAuthVM: UserViewModel
    @State var logOut : String = "Log Out"
    @State var openChangeNicknameScreen : Bool = false
    @State var openChangeUsernameScreen : Bool = false
    @State var openBlockedAccountsScreen : Bool = false

    var body: some View {
        ZStack{
            Color("Background")
            VStack(alignment: .leading){
                
                HStack(alignment: .center){
                 
                    Spacer()
                    
                    
                    Text("Settings").fontWeight(.bold).font(.title).padding(.leading,60)
                    
                    Spacer()
                    
                    Button(action:{
                        dismiss.wrappedValue.dismiss()
                    },label:{
                        Text("Back").foregroundColor(FOREGROUNDCOLOR).padding(.vertical,10).padding(.horizontal).background(Capsule().foregroundColor(Color("Color"))).padding(.trailing)
                    })
                    
                    
                    
                    
                }.padding(.top,50)
                
                
                ScrollView(){
                    VStack(alignment: .leading){
                        
                        VStack(alignment: .leading){
                            
                            Text("My Account").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
                            
                            VStack(alignment: .leading, spacing: 15){
                                SettingsButtonCell(text: "Blocked Accounts", includeDivider: true, action: {
                                    self.openBlockedAccountsScreen.toggle()
                                }).padding(.top,15)
                                
                                
                                SettingsButtonCell(text: "Color Preferences", includeDivider: true,  action:{
                                    //TODO
                                })
                                SettingsButtonCell(text: "Change Username", includeDivider: true,  action:{
                                    self.openChangeUsernameScreen.toggle()
                                })
                                
                                SettingsButtonCell(text: "Change Nickname", includeDivider: true,  action:{
                                    self.openChangeNicknameScreen.toggle()
                                })

                                
                                SettingsButtonCell(text: "Verify Email", includeDivider: true, action:{
                                    //TODO
                                })
                                
                             
                                
                                SettingsButtonCell(text: "Change Password", includeDivider: true,  action:{
                                    //TODO
                                })
                                
                                SettingsButtonCell(text: "Two Factor Authentification", includeDivider: false, action:{
                                    //TODO
                                }).padding(.bottom,15)
                                
                                
                                
                                
                            }.background(Color("Color")).cornerRadius(12).padding([.horizontal,.bottom])
                        }
                        
                    
                    
                    
                    
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Support").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
                            
                            VStack{
                                SettingsButtonCell(text: "Contact Us", includeDivider: true,  action:{
                                    //TODO
                                }).padding(.top,10)
                                
                                SettingsButtonCell(text: "Contact Us", includeDivider: false, action: {
                                    print("cock")
                                })
                                .padding(.bottom,15)
                            }.background(Color("Color")).cornerRadius(12).padding([.horizontal,.bottom])
                        }
                        
                        
                        
                    }
                    
                    
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Account Actions").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
                            
                            VStack{
                                SettingsButtonCell(text: "Switch Accounts", includeDivider: true, action:{
                                    //TODO
                                }).padding(.top,10)
                                SettingsButtonCell(text: logOut, includeDivider: false, action:{
                                    self.dismiss.wrappedValue.dismiss()
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        userAuthVM.signOut()
                                                    }
                                }).padding(.bottom,15)
                                
                            }.background(Color("Color")).cornerRadius(12).padding([.horizontal,.bottom])
                        }
                        
                        
                        
                    }
                    
                    
                }
                }
                
                
                //Navigation Links
                
                    //Change Nickname
               
                    NavigationLink(destination: ChangeNicknameView(openNicknameScreen: $openChangeNicknameScreen), isActive: $openChangeNicknameScreen) {
                    EmptyView()
                    }
                
                
                    //Change Username
                
                    NavigationLink(destination: ChangeUsernameView(openUsernameScreen: $openChangeUsernameScreen), isActive: $openChangeUsernameScreen) {
                    EmptyView()
                    }
                
                //Blocked Accounts
                
                    NavigationLink(destination: BlockedAccountsView( openBlockedAccountsScreen: $openBlockedAccountsScreen), isActive: $openBlockedAccountsScreen) {
                    EmptyView()
                    }
                
                
                
                
                
                
                
                
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct SettingsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenuView().colorScheme(.dark)
    }
}

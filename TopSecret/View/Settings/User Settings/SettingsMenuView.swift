//
//  SettingsMenuView.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/4/21.
//

import SwiftUI

struct SettingsMenuView: View {
    @EnvironmentObject var userVM : UserViewModel
    @Environment(\.presentationMode) var dismiss
    @EnvironmentObject var userAuthVM: UserViewModel
    @State var logOut : String = "Log Out"
    @State var openChangeNicknameScreen : Bool = false
    @State var openChangeUsernameScreen : Bool = false
    @State var openBlockedAccountsScreen : Bool = false
    @ObservedObject var settingsVM = UserSettingsViewModel()
    
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
                        
                        VStack(alignment: .leading, spacing: 5){
                            
                            Text("My Account").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
                            
                            VStack(alignment: .leading, spacing: 15){
                                SettingsButtonCell(text: "Blocked Accounts", includeDivider: true, action: {
                                   
                                    let dp = DispatchGroup()
                                    dp.enter()
                                    
                                    settingsVM.fetchBlockedAccounts(blockedAccountIDS: userVM.user?.blockedAccountsID ?? [], completion: { fetched in
                                        if fetched{
                                            dp.leave()
                                        }
                                    })
                                    dp.notify(queue: .main, execute:{
                                            self.openBlockedAccountsScreen.toggle()
                                        
                                    })
                                  
                                    
                                }).padding(.top,15)
                                
                            }.background(Color("Color")).cornerRadius(12).padding([.horizontal,.bottom])
                        }
                        
                        HStack{
                            Spacer()
                            
                            
                            Button(action:{
                                self.dismiss.wrappedValue.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    userAuthVM.signOut()
                                }
                            },label:{
                                Text("Sign Out").foregroundColor(Color("AccentColor"))
                            })
                            Spacer()
                        }
                        
                        
                        
                    }
                }
                
                
                //Navigation Links
                
                
                
                //Blocked Accounts
                
                NavigationLink(destination: BlockedAccountsView( openBlockedAccountsScreen: $openBlockedAccountsScreen, settingsVM: settingsVM), isActive: $openBlockedAccountsScreen) {
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

//
//  BlockedAccountsView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/8/22.
//



import SwiftUI
import Firebase

struct BlockedAccountsView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var openBlockedAccountsScreen : Bool
    @StateObject var settingsVM = UserSettingsViewModel()
    
    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                HStack{
                  
                    Button(action:{
                        openBlockedAccountsScreen.toggle()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                }.padding(.top,50).padding(.leading,10)
                
                
                VStack{
                    Text("Blocked Accounts").fontWeight(.bold).font(.title)
                    Text("frick these people").foregroundColor(.gray).padding(.horizontal,10).font(.body)
                }.padding(.bottom,150).padding(.top,40)
           
                    
                ScrollView{
                    VStack{
                        ForEach(settingsVM.blockedAccounts){ blockedUser in
                            UserSearchCell(user: blockedUser, showActivity: false)
                        }
                    }
                }
                
               
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear {
            settingsVM.fetchBlockedAccounts(blockedAccountIDS: userVM.user?.blockedAccountsID ?? [])
        }
       
       
    }
}

//struct ChangeNicknameView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeNicknameView()
//    }
//}


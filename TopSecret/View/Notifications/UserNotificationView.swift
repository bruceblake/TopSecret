//
//  UserNotificationView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/10/22.
//

import SwiftUI

struct UserNotificationView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,10)
                    
        
                    Spacer()

                    Text("Notifications").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.largeTitle)
                    
                 
                    
                    Spacer()
                }.padding(.leading).padding(.top,50)
                
                       
                        
                    
                
                ScrollView(showsIndicators: false){
                    
                    VStack(alignment: .leading, spacing: 0){
                        VStack(spacing: 10){
                            
                            
                            HStack{
                                
                            Text("New").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline).padding(.leading)
                                Spacer()
                            }
                            
                            
                            ForEach(userVM.user?.notifications ?? []){ notification in
                               
                                Button(action:{
                                    
                                },label:{
                                    UserNotificationCell(userNotification: notification)
                                })
                                Divider()

                            }
                        }
                        
                        
                        
                    }
                    
                    
                }
            }
            
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear {
            for notification in userVM.user?.notifications ?? [] {
                userVM.readUserNotification(userNotification: notification, userID: userVM.user?.id ?? " ")
                print("notification!")
            }
        }
    }
}


struct UserNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        UserNotificationView().environmentObject(UserViewModel()).colorScheme(.dark)
    }
}

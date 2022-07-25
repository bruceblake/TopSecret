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
                            Circle().foregroundColor(Color("Color")).frame(width:40, height: 40)
                            
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        }
                    })
                    
                    Spacer()
                    
                    Text("Notifications").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title2)
                    
                    Spacer()
                }.padding(.leading).padding(.top,50)
                
                       
                        
                    
                
                ScrollView(showsIndicators: false){
                    
                    VStack{
                        VStack(alignment: .leading, spacing: 0){
                            
                            
                            
                            
                            Text("New").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline).padding(.leading)
                            
                            ForEach(userVM.user?.notifications ?? []){ notification in
                                Button(action:{
                                    
                                },label:{
                                    UserNotificationCell(userNotification: notification)
                                })
                               
                            }
                        }
                        
                        
                        
                    }
                    
                    
                }
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear {
            for notification in userVM.user?.notifications ?? [] {
                userVM.readUserNotification(userNotification: notification, userID: userVM.user?.id ?? " ")
            }
        }
    }
}


//struct UserNotificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserNotificationView()
//    }
//}

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
                    
                    Spacer()
                    
        
                    

                    Text("Notifications").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.largeTitle)
                    
                 
                    
                    Spacer()
                }.padding(.leading).padding(.top,50)
                
                       
                        
                    
                
                ScrollView(showsIndicators: false){
                    
                    VStack{
                        VStack(alignment: .leading, spacing: 0){
                            
                            
                            
                            
                            Text("New").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline).padding(.leading)
                            
                            ForEach(userVM.user?.notifications ?? []){ notification in
                               
                                    UserNotificationCell(userNotification: notification)
                                
                               
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


struct UserNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        UserNotificationView().environmentObject(UserViewModel()).colorScheme(.dark)
    }
}

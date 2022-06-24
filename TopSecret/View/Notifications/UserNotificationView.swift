//
//  UserNotificationView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/10/22.
//

import SwiftUI

struct UserNotificationView: View {
   
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
   
        ZStack(alignment: .topTrailing){
            Color("Background")

            VStack{
                ForEach(notificationManager.notifications, id: \.identifier){ noti in
                    Text(noti.content.title)
                        .fontWeight(.semibold)
                }
            
            }
            
                Button(action:{
                    
                },label:{
                    Image(systemName: "plus.circle")
                        .imageScale(.large).foregroundColor(FOREGROUNDCOLOR)
                }).padding(60).padding(.trailing,30)
            
          
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            notificationManager.reloadAuthorizationStatus()
        }
        .onChange(of: notificationManager.authorizationStatus){ authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                notificationManager.requestAuthorization()
            case .authorized:
                notificationManager.reloadLocalNotifications()
                break
            default:
                break
            }
        }
            
        }
    }


struct UserNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        UserNotificationView()
    }
}

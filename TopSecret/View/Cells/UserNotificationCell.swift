//
//  UserNotificationCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/24/22.
//

import SwiftUI

struct UserNotificationCell: View {
    var userNotification : UserNotificationModel
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        VStack{
            
            
            switch userNotification.notificationType ?? ""{
            case "eventCreated":
                UserEventCreatedNotificationCell(userNotification: userNotification).padding(.horizontal,40)
            default:
                Text("Notification")
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}



struct UserEventCreatedNotificationCell : View {
    
    var userNotification : UserNotificationModel
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                
                
                Text("\(userNotification.group?.groupName ?? " ")").padding(.leading,5)
                
                Text("\(userNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray)
                
                Text((userNotification.notificationCreator as? User ?? User()).username ?? " ").foregroundColor(.gray)
                Spacer()
                
            }
            
            HStack{
                Text((userNotification.notificationCreator as? User ?? User()).nickName ?? " ")
                Text("created an event!")
            }
        }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10).padding(.horizontal,30)
    }
}



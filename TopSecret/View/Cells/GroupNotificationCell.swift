//
//  GroupNotificationCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupNotificationCell: View {
    
    var groupNotification : GroupNotificationModel
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var notificationVM = GroupNotificationViewModel()
    
    var body: some View {
        VStack{
            
            switch groupNotification.notificationType ?? " "{
            case "eventCreated":
                EventCreatedNotificationCell(groupNotification: groupNotification, user: notificationVM.notificationCreator)
            case "countdownCreated":
                CountdownCreatedNotificationCell(groupNotification: groupNotification, user: notificationVM.notificationCreator)
            default:
                Text("Notification")
            }
            
        }.onAppear{
            notificationVM.fetchNotificationCreator(notification: groupNotification)
        }
     
    }
}



struct EventCreatedNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    var user: User
    var body: some View {
    
            VStack{
                HStack{
                    
                    WebImage(url: URL(string: user.profilePicture ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:40,height:40)
                        .clipShape(Circle())
                    
                    Text("\(user.username ?? "USER_USERNAME") has created an event!").fontWeight(.bold).foregroundColor(FOREGROUNDCOLOR)
                    Spacer()
                    Text("\(groupNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                }
            }.padding().background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
        
    }
}

struct CountdownCreatedNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    var user: User

    var body: some View {
        VStack{
            HStack{
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                Text("\(user.username ?? "USER_USERNAME") has created a countdown!").fontWeight(.bold).foregroundColor(FOREGROUNDCOLOR)
                Spacer()
                Text("\(groupNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
            }
        }.padding().background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
    
    }
}


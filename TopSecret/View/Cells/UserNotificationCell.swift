//
//  UserNotificationCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/24/22.
//

import SwiftUI
import SDWebImageSwiftUI


//User Notifications
// - User accepted friend request
// - User denied friend request
// - You have been sent a group invitation
// - You have been sent a event invitation
// - User has sent you a message

struct UserNotificationCell: View {
    var userNotification : UserNotificationModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ZStack{
            
            
            switch userNotification.notificationType ?? ""{
            case "eventCreated":
                UserEventCreatedNotificationCell(userNotification: userNotification)
            case "sentFriendRequest":
                UserSentFriendRequestNotificationCell(userNotification: userNotification)
            case "acceptedFriendRequest":
                UserAcceptedFriendRequestNotificationCell(userNotification: userNotification)
            default:
                Text("Notification")
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct UserAcceptedFriendRequestNotificationCell : View {
    
    var userNotification: UserNotificationModel
    
    var body: some View {
        HStack{
            
            
            
            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 10){
                    
                    WebImage(url: URL(string: (userNotification.notificationCreator as? User ?? User()).profilePicture ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:50,height:50)
                        .clipShape(Circle())
                        .padding(.leading,5)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("\((userNotification.notificationCreator as? User ?? User()).username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.title2)
                            Text("\(userNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                        }
                        Text("\((userNotification.notificationCreator as? User ?? User()).nickName ?? " ") accepted your friend request").font(.subheadline)
                        
                    }
                    
                }
                
            }
            
            Spacer()
            
            
            
            
        }
    }
}

struct UserSentFriendRequestNotificationCell : View {
    
    @EnvironmentObject var userVM : UserViewModel
    var userNotification: UserNotificationModel
    var body: some View {
        HStack{
            
            
            
            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 10){
                    
                    WebImage(url: URL(string: (userNotification.notificationCreator as? User ?? User()).profilePicture ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:50,height:50)
                        .clipShape(Circle())
                        .padding(.leading,5)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("\((userNotification.notificationCreator as? User ?? User()).username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.title2)
                            Text("\(userNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                        }
                        Text("\((userNotification.notificationCreator as? User ?? User()).nickName ?? " ") sent a friend request").font(.subheadline)
                        
                    }
                    
                }
                
            }
            
            Spacer()
            
            Button(action:{
                userVM.acceptFriendRequest(friend: (userNotification.notificationCreator as? User ?? User()))
            },label:{
                Text("Accept Friend Request")
            })
            
            
            
        }
    }
}

struct UserEventCreatedNotificationCell : View {
    
    var userNotification : UserNotificationModel
    
    
    var body: some View {
        
        HStack{
            
            
            
            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 10){
                    
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("\((userNotification.notificationCreator as? User ?? User()).username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.title2)
                            Text("\(userNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                        }
                        Text("\((userNotification.notificationCreator as? User ?? User()).nickName ?? " ") created an event").font(.subheadline)
                        
                    }
                    
                    
                    
                    
                }
                
                
                
                
                
                
                
            }
            
            Spacer()
            
            
            
            
            
            
            
            
        }
    }
    
}



struct UserNotificationCell_Previews : PreviewProvider {
    
    static var previews: some View {
        UserNotificationCell(userNotification: UserNotificationModel()).colorScheme(.dark)
    }
}

//
//  UserNotificationCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/24/22.
//

import SwiftUI
import SDWebImageSwiftUI




struct UserNotificationCell: View {
    var userNotification : UserNotificationModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ZStack{
            
            
            switch userNotification.notificationType ?? ""{
            case "eventCreated":
                NavigationLink {
                    Text("event: \((userNotification.notificationCreator as? EventModel ?? EventModel()).eventName ?? "" ) ")
                } label: {
                UserEventCreatedNotificationCell(userNotification: userNotification)
                }

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
            
            
            NavigationLink {
                UserProfilePage(user: (userNotification.notificationCreator as? User ?? User()) )
            } label: {
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
                                Text("\((userNotification.notificationCreator as? User ?? User()).username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.title3)
                                Text("\(userNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                            }
                            Text("\((userNotification.notificationCreator as? User ?? User()).nickName ?? " ") sent a friend request").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                            
                        }
                        
                    }
                    
                }
            }

           
            
            Spacer()
            
            if !(userVM.user?.pendingFriendsListID?.contains((userNotification.notificationCreator as? User ?? User()).id ?? " ") ?? false) {
                
            HStack{
            Button(action:{
                userVM.acceptFriendRequest(friend: (userNotification.notificationCreator as? User ?? User()))
            },label:{
              
                ZStack{
                    Rectangle().frame(width: 60, height: 30).foregroundColor(Color.green)
                    
                    Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                }            })
                
                
            Button(action:{
                userVM.denyFriendRequest(friend: (userNotification.notificationCreator as? User ?? User()))
            },label:{
                ZStack{
                    Rectangle().frame(width: 60, height: 30).foregroundColor(Color.green)
                    
                    Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                }
                
               
            })
            }.padding(.trailing)
            }
            
            else if  (userVM.user?.friendsListID?.contains((userNotification.notificationCreator as? User ?? User()).id ?? " ") ?? false){
                Text("Friends").foregroundColor(.gray).font(.subheadline).padding(.trailing,10)
            }
            
            
            
            
        }
    }
}

struct UserEventCreatedNotificationCell : View {
    
    var userNotification : UserNotificationModel
    
    
    var body: some View {
        

            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 10){
                    
                    WebImage(url: URL(string: (userNotification.notificationCreator as? EventModel ?? EventModel()).creator?.profilePicture ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:50,height:50)
                        .clipShape(Circle())
                        .padding(.leading, 5)
                    
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("\((userNotification.notificationCreator as? EventModel ?? EventModel()).creator?.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.title3)
                            Text("\(userNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                        }
                        Text("\((userNotification.notificationCreator as? EventModel ?? EventModel()).creator?.nickName ?? " ") created an event").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                        
                    }

                }

            }
            
    }
    
}



struct UserNotificationCell_Previews : PreviewProvider {
    
    static var previews: some View {
        UserNotificationCell(userNotification: UserNotificationModel()).colorScheme(.dark)
    }
}

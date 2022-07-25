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
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    
    var body: some View {
        VStack{
            
            
            
            //TODO
            //1 hour left on event, countdown, poll
            //user posted on story
            
            
            //user sent a text
            //user sent an image
            //user sent a video
            //user replied
            //user edited
            //user deleted a chat
            
            //group bio changed
            //group name changed
            //group motd changed
            //group earned a badge
            
            switch groupNotification.notificationType ?? " "{
            case "eventCreated":
                GroupEventCreatedNotificationCell(groupNotification: groupNotification)
            case "countdownCreated":
                CountdownCreatedNotificationCell(groupNotification: groupNotification)
            case "pollCreated":
                Text("Hello World")
            case "userAdded":
                UserAddedNotificationCell(groupNotification: groupNotification, groupName: selectedGroupVM.group?.groupName ?? " ",actionTaken: "joined")
            case "userLeft":
                UserAddedNotificationCell(groupNotification: groupNotification, groupName: selectedGroupVM.group?.groupName ?? " ",actionTaken: "left")
            case "oneHourRemainingEvent":
                Text("Hello World")
            case "oneHourRemainingCountdown":
                Text("Hello World")
            case "oneHourRemainingPoll":
                Text("Hello World")
            case "userPosted":
                Text("Hello World")
            case "userSentAText":
                UserSentTextNotificationCell(groupNotification: groupNotification)
            case "userChangedGroupName":
                Text("Hello World")
            case "userChangedGroupBio":
                Text("Hello World")
            case "userChangedGroupMOTD":
                Text("Hello World")
            case "groupEarnedBadge":
                Text("Hello World")
            default:
                Text("Notification")
            }
            
        }
        
    }
}



struct GroupEventCreatedNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    var body: some View {
        
        VStack(alignment: .leading){
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.notificationCreator as? User ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                Text("\((groupNotification.notificationCreator as? User ?? User() ).username ?? "USER_USERNAME") created an event!").fontWeight(.bold).font(.callout).foregroundColor(FOREGROUNDCOLOR)
                Spacer()
                Text("\(groupNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
            }
        }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding()
        
    }
}

struct CountdownCreatedNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    
    var body: some View {
        VStack{
            HStack{
                WebImage(url: URL(string: (groupNotification.notificationCreator as? User ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                Text("\((groupNotification.notificationCreator as? User ?? User()).username ?? "USER_USERNAME") created a countdown!").fontWeight(.bold).foregroundColor(FOREGROUNDCOLOR).font(.callout)
                
                Spacer()
                
                Text("\(groupNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                
            }
        }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
        
    }
}


struct UserAddedNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    var groupName : String
    var actionTaken : String
    var body: some View {
        VStack{
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.notificationCreator as? User ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                Text("\((groupNotification.notificationCreator as? User ?? User() ).username ?? "USER_USERNAME") \(actionTaken) \(groupName)!").fontWeight(.bold).font(.callout).foregroundColor(FOREGROUNDCOLOR)
                Spacer()
                Text("\(groupNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
            }
        }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
    }
}


struct UserSentTextNotificationCell : View {
    
    var groupNotification : GroupNotificationModel
    
    var body: some View {
        VStack{
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.notificationCreator as? User ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                Text("\((groupNotification.notificationCreator as? User ?? User()).username ?? "USER_USERNAME") sent a message").fontWeight(.bold).font(.callout).foregroundColor(FOREGROUNDCOLOR)
                Spacer()
                Text("\(groupNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
            }
        }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
        
    }
}




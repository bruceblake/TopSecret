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
            
            switch groupNotification.type ?? " "{
            case "eventCreated":
                GroupEventCreatedNotificationCell(groupNotification: groupNotification)
            case "pollCreated":
                Text("Hello World")
            case "acceptedGroupInvitation":
                UserAddedNotificationCell(groupNotification: groupNotification)
            case "userLeft":
                UserAddedNotificationCell(groupNotification: groupNotification)
            case "oneHourRemainingEvent":
                Text("Hello World")
            case "oneHourRemainingPoll":
                Text("Hello World")
            case "userChangedGroupName":
                Text("Hello World")
            default:
                Text("\(groupNotification.type ?? "cock")")
            }
            
        }
        
    }
}



struct GroupEventCreatedNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    var groupNotificationVM = GroupNotificationViewModel()
    var body: some View {
        
        VStack(alignment: .leading){
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.sender as? User ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading){
                    Text("\((groupNotification.sender as? User ?? User() ).username ?? "USER_USERNAME")").fontWeight(.bold).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                    Text("\((groupNotification.sender as? User ?? User() ).nickName ?? "USER_USERNAME") created an event").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                }
                Spacer()
                Text("\(groupNotification.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
            }
        }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
        
    }
}


struct UserAddedNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    @EnvironmentObject var groupVM: SelectedGroupViewModel
    var body: some View {
        VStack{
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.sender as? User ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                VStack(alignment: .leading){
                    Text("\((groupNotification.sender as? User ?? User() ).username ?? "USER_USERNAME")").fontWeight(.bold).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                    Text("\((groupNotification.sender as? User ?? User() ).nickName ?? "USER_USERNAME") accepted their invitation to \(groupVM.group.groupName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                }
             
                Spacer()
                Text("\(groupNotification.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
            }
        }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
    }
}






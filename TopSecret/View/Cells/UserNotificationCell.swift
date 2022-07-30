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
        
        HStack{
            
         
            
            VStack(alignment: .leading, spacing: 8){
            
                    
                HStack(alignment: .top, spacing: 10){
                
                WebImage(url: URL(string: userNotification.group?.groupProfileImage ?? " "))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                Text("\(userNotification.group?.groupName ?? " ")").foregroundColor(FOREGROUNDCOLOR).bold().font(.title2)
                
                
             
   
        }
            
            HStack{
                
               
                
                
                Text("\((userNotification.notificationCreator as? User ?? User()).nickName ?? " ") created an event").font(.title3)
            }.foregroundColor(FOREGROUNDCOLOR)
                

            
        
    }
            
            Spacer()
            
            VStack{
                
                Text("\(userNotification.notificationTime?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                
           
                
                Spacer()
                
                NavigationLink(destination: FullEventView(event: userNotification.actionType as? EventModel ?? EventModel(), group: userNotification.group ?? Group())    ) {
                    Text("See Event").foregroundColor(FOREGROUNDCOLOR)
                }.padding(7).background(Capsule().fill(Color("AccentColor"))).cornerRadius(16)
            }
            
         

                         
                        
        
    }.padding().background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10).padding(.horizontal,30)
}
    
}



struct UserNotificationCell_Previews : PreviewProvider {
    
    static var previews: some View {
        UserNotificationCell(userNotification: UserNotificationModel()).colorScheme(.dark)
    }
}

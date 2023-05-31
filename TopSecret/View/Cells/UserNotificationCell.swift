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
            
            
            switch userNotification.type ?? ""{
            case "eventCreated":
               
                UserEventCreatedNotificationCell(userNotification: userNotification)
                

            case "sentFriendRequest":
                UserSentFriendRequestNotificationCell(userNotification: userNotification)
            case "acceptedFriendRequest":
                UserAcceptedFriendRequestNotificationCell(userNotification: userNotification)
            case "sentGroupInvitation":
                UserSentGroupInvitationNotificationCell(userNotification: userNotification)
            case "acceptedGroupInvitation":
                UserAcceptedGroupInvitationNotificationCell(userNotification: userNotification)
            default:
                Text("Notification")
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}




struct UserAcceptedGroupInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()

    var body: some View {
        HStack{
            
            
            NavigationLink {
                GroupProfileView(group: userNotification.group ?? Group(), isInGroup: (userNotification.group ?? Group()).users.contains(userVM.user?.id ?? " "))
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.group ?? Group()).groupProfileImage ))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading,5)
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text("\((userNotification.group ?? Group()).groupName )").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            HStack(spacing: 2){
                                
                                Text("\( ( (userNotification.user ?? User()).id ?? " ") == userVM.user?.id ?? " " ? "You": (userNotification.user ?? User()).nickName ?? " ") accepted the group invitation to \( (userNotification.group ?? Group()).groupName ).").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                            }
                    
                        }
                        
                    }
                    
                }
            }

           
            
            Spacer()
            
            if (userVM.user?.pendingGroupInvitationID?.contains((userNotification.group ?? Group()).id ) ?? false) {
                
            HStack{
            Button(action:{
                groupVM.acceptGroupInvitation(group: userNotification.group ?? Group(), user: self.userVM.user ?? User())
            },label:{
              
                ZStack{
                    Rectangle().frame(width: 60, height: 30).foregroundColor(Color.green)
                    
                    Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                }            })
                
                
            Button(action:{
                groupVM.denyGroupInvitation(group: userNotification.group ?? Group(), user: self.userVM.user ?? User())
            },label:{
                ZStack{
                    Rectangle().frame(width: 60, height: 30).foregroundColor(Color.green)
                    
                    Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                }
                
               
            })
            }.padding(.trailing)
            }
            
           
            
            
            
            
        }
    }
}








struct UserSentGroupInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()

    var body: some View {
        HStack{
            
            
            NavigationLink {
                GroupProfileView(group: userNotification.group ?? Group(), isInGroup: (userNotification.group ?? Group()).users.contains(userVM.user?.id ?? " "))
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.group ?? Group()).groupProfileImage ))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading,5)
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text("\((userNotification.group ?? Group()).groupName )").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            HStack(spacing: 2){
                                Text("\((userNotification.user ?? User()).nickName ?? " ") invited you to \( (userNotification.group ?? Group()).groupName ).").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                            }
                    
                        }
                        
                    }
                    
                }
            }

           
            
            Spacer()
            
            if (userVM.user?.pendingGroupInvitationID?.contains((userNotification.group ?? Group()).id ) ?? false) {
                
            HStack{
            Button(action:{
                groupVM.acceptGroupInvitation(group: userNotification.group ?? Group(), user: self.userVM.user ?? User())
            },label:{
              
                ZStack{
                    RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.green)
                    
                    Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                }             })
                
                
            Button(action:{
                groupVM.denyGroupInvitation(group: userNotification.group ?? Group(), user: self.userVM.user ?? User())
            },label:{
                ZStack{
                    RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.red)
                    
                    Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                }
                
               
            })
            }.padding(.trailing)
            }
            
           
            
            
            
            
        }
    }
}

struct UserAcceptedFriendRequestNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()

    var body: some View {
        
        NavigationLink {
            UserProfilePage(user: (userNotification.user ?? User()) )
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.user ?? User()).profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading,5)
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text("\((userNotification.user ?? User()).username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            HStack(spacing: 2){
                                Text("\((userNotification.user ?? User()).nickName ?? " ") accepted your friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                            }
                            
                        }
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }

    
    
        
    }
}

struct UserSentFriendRequestNotificationCell : View {
    
    @EnvironmentObject var userVM : UserViewModel
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()

    var body: some View {
        HStack{
            
            
            NavigationLink {
                UserProfilePage(user: (userNotification.user ?? User()) )
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .center, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.user ?? User()).profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading,5)
                        
                        VStack(alignment: .leading){
                            HStack(alignment: .top){
                                Text("\((userNotification.user ?? User()).username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Spacer()
                            }
                                HStack(spacing: 2){
                                    Text("\((userNotification.user ?? User()).nickName ?? " ") sent a friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                         
                               
                            
                       
                            
                        }
                        
                        Spacer()
                        if(userNotification.finished ?? false){
                            Text("Expired").foregroundColor(Color.gray).padding(.trailing,10).font(.subheadline)
                        }else{
                            
                            if (userVM.user?.pendingFriendsListID?.contains((userNotification.user ?? User()).id ?? " ") ?? false) {
                                
                            HStack{
                            Button(action:{
                                userVM.acceptFriendRequest(friend: (userNotification.user ?? User()))
                                COLLECTION_USER.document(userVM.user?.id ?? " ").collection("Notifications").document(userNotification.id).updateData(["finished":true])
                            },label:{
                              
                                ZStack{
                                    RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.green)
                                    
                                    Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                                }            })
                                
                                
                            Button(action:{
                                userVM.denyFriendRequest(friend: (userNotification.user ?? User()))
                                COLLECTION_USER.document((userNotification.user ?? User()).id ?? " ").collection("Notifications").document(userNotification.id).updateData(["finished":true])
                            },label:{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.red)
                                    
                                    Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                                }
                                
                               
                            })
                            }.padding(.trailing)
                            }
                            
                            else if  (userVM.user?.friendsListID?.contains((userNotification.user ?? User()).id ?? " ") ?? false){
                                Text("Friends").foregroundColor(.gray).font(.subheadline).padding(.trailing,10)
                            }
                        
                    }
                    
                }
            }

           
            
            
           
            }
          
            
            
            
            
        }
    }
}

struct UserEventCreatedNotificationCell : View {
    
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()

    
    var body: some View {
        

            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 10){
                    
                    WebImage(url: URL(string: (userNotification.event ?? EventModel()).creator?.profilePicture ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:50,height:50)
                        .clipShape(Circle())
                        .padding(.leading, 5)
                    
                    
                    VStack(alignment: .leading){
                        HStack(alignment: .top){
                            Text("\((userNotification.event ?? EventModel()).creator?.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.title3)
                            Spacer()
                            Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                        }
                        Text("\((userNotification.event ?? EventModel()).creator?.nickName ?? " ") created an event").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                        
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

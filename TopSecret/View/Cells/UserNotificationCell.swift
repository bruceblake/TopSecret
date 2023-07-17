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
    @State var showAddEventView: Bool = false
    var body: some View {
        ZStack{
            
            
            switch userNotification.type ?? ""{
                case "eventCreated":
                    UserEventCreatedNotificationCell(userNotification: userNotification)
                case "sentFriendRequest":
                    UserSentFriendRequestNotificationCell(userNotification: userNotification)
                case "acceptedFriendRequest":
                    UserAcceptedFriendRequestNotificationCell(userNotification: userNotification)
                case "deniedFriendRequest":
                    UserDeniedFriendRequestNotificationCell(userNotification: userNotification)
                case "rescindFriendRequest":
                    UserRescindedFriendRequestNotificationCell(userNotification: userNotification)
                case "sentGroupInvitation":
                    UserSentGroupInvitationNotificationCell(userNotification: userNotification)
                case "acceptedGroupInvitation":
                    UserAcceptedGroupInvitationNotificationCell(userNotification: userNotification)
                case "invitedToEvent":
                    UserInvitedToEventNotificationCell(userNotification: userNotification, showAddEventView: $showAddEventView)
                case "acceptedEventInvitation":
                    UserAcceptedEventInvitationNotificationCell(userNotification: userNotification)
                case "deniedGroupInvitation":
                    UserDeniedGroupInvitationNotificationCell(userNotification: userNotification)
                    
                default:
                    Text("Notification")
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct UserAcceptedEventInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }
    
    var body: some View {
        HStack{
            
            
            NavigationLink {
                
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "party.popper").foregroundColor(FOREGROUNDCOLOR)
                        }
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text("\((userNotification.event ?? EventModel()).eventName ?? " ")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            HStack(spacing: 2){
                                
                                Text(" \(sender.nickName ?? " ") accepted the invitation to \(event.eventName ?? " ") " ).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
            
            
        }
    }
}




struct UserAcceptedGroupInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var group: Group {
        return userNotification.group ?? Group()
    }
    
    var body: some View {
                        
            NavigationLink {
                GroupProfileView(group: userNotification.group ?? Group(), isInGroup: (userNotification.group ?? Group()).usersID.contains(userVM.user?.id ?? " "))
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.group ?? Group()).groupProfileImage ))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading, 5)
                        
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.group ?? Group()).groupName )").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            if sender.id == USER_ID{
                                Text("You accepted the invitation to \(group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text("\(sender.nickName ?? " ") accepted the invitation to \(group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                       
                            
                        }
                        
                        Spacer()
                        
                    }
                    
                }
            }
            
            
            
        
    }
}


struct UserDeniedGroupInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var group: Group {
        return userNotification.group ?? Group()
    }
    
    var body: some View {
                        
            NavigationLink {
                GroupProfileView(group: userNotification.group ?? Group(), isInGroup: (userNotification.group ?? Group()).usersID.contains(userVM.user?.id ?? " "))
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.group ?? Group()).groupProfileImage ))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading, 5)
                        
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.group ?? Group()).groupName )").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            if sender.id == USER_ID{
                                Text("You denied the invitation to \(group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text("\(sender.nickName ?? " ") denied the invitation to \(group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                       
                            
                        }
                        
                        Spacer()
                        
                    }
                    
                }
            }
            
            
            
        
    }
}







struct UserSentGroupInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var group: Group {
        return userNotification.group ?? Group()
    }
    
    var body: some View {
        HStack{
            
            
            NavigationLink {
                GroupProfileView(group: userNotification.group ?? Group(), isInGroup: (userNotification.group ?? Group()).usersID.contains(userVM.user?.id ?? " "))
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
                            HStack(spacing: 5){
                                Text("\((userNotification.group ?? Group()).groupName )").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                                
                                if sender.id ?? " " == USER_ID {
                                    Text("You sent a group invitation to \(receiver.nickName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                }else{
                                    Text("\(sender.nickName ?? " ") sent you an invitation to \(group.groupName) ").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                }
                            
                            
                        }
                        
                    }
                    
                }
            }
            
            
            
            Spacer()
            
            if userNotification.requiresAction ?? false == false {
                Text("Expired").foregroundColor(Color.gray).font(.footnote)
            }else{
                if (userVM.user?.pendingGroupInvitationID?.contains((userNotification.group ?? Group()).id ) ?? false) {
                    
                    HStack{
                        Button(action:{
                            groupVM.acceptGroupInvitation(group: userNotification.group ?? Group(), user: self.userVM.user ?? User())
                            userNotificationVM.setRequiresAction(usersID: [USER_ID], notificationID: userNotification.id)
                        },label:{
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.green)
                                
                                Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                            }             })
                        
                        
                        Button(action:{
                            groupVM.denyGroupInvitation(group: userNotification.group ?? Group(), user: self.userVM.user ?? User())
                            userNotificationVM.setRequiresAction(usersID: [USER_ID], notificationID: userNotification.id)
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
}

struct UserRescindedFriendRequestNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                if USER_ID == sender.id ?? " " {
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                } else {
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                }
                              
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            
                            if USER_ID == sender.id ?? " " {
                                Text("rescinded your friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text("You rescinded their friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                               
                            
                        }
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }
        
        
        
        
    }
}

struct UserAcceptedFriendRequestNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            //current user is sender
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        VStack(alignment: .leading){
                            if sender.id ?? " " == USER_ID {
                                HStack(spacing: 5){
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("You accepted \(receiver.username ?? " ")'s friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                
                            }else{
                                HStack(spacing: 5){
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)

                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("\(sender.nickName ?? " ") accepted your friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                  
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }
        
        
        
        
    }
}

struct UserDeniedFriendRequestNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        if receiver.id ?? " " != USER_ID {
                       
                            
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                                }
                                    Text("You denied their friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                   
                                
                            }
                        }else {
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("denied your friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
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
    
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        HStack{
            
            
            NavigationLink {
                //current user is the sender
                if USER_ID == sender.id ?? " "{
                    UserProfilePage(user: (receiver) )
                }else{
                    //current user is the receiver
                    UserProfilePage(user: (sender) )
                }
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .center, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        VStack(alignment: .leading){
                            HStack(alignment: .top, spacing: 5){
                                    //current user is sender
                                if sender.id ?? " " == USER_ID {
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                }else{
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                }
                                
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)

                                
                            }
                                //current user is sener
                                if sender.id ?? " " == USER_ID {
                                  
                                    Text("You sent a friend request").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                }else{
                                    //current user is receiver
                                    Text("sent you a friend request").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                   
                                }
                                
                               
                                
                                
                            
                            
                            
                            
                            
                            
                        }
                        
                        Spacer()
                        
                        
                        if(userNotification.requiresAction == false){
                            Text("Expired").foregroundColor(Color.gray).padding(.trailing,10).font(.subheadline)
                        }else{
                            
                            if (userVM.user?.incomingFriendInvitationID?.contains(sender.id ?? " ") ?? false) && userNotification.requiresAction ?? false {
                                
                                HStack{
                                    Button(action:{
                                        userVM.acceptFriendRequest(friend: sender)
                                        userNotificationVM.setRequiresAction(usersID: [sender.id ?? " ", receiver.id ?? " "], notificationID: userNotification.id)
                                    },label:{
                                        
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.green)
                                            
                                            Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                                        }            })
                                    
                                    
                                    Button(action:{
                                        userVM.denyFriendRequest(friend: sender)
                                        userNotificationVM.setRequiresAction(usersID: [sender.id ?? " ", receiver.id ?? " "], notificationID: userNotification.id)
                                    },label:{
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.red)
                                            
                                            Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                                        }
                                        
                                        
                                    })
                                }.padding(.trailing)
                            }
                            
                            else if  (userVM.user?.friendsListID?.contains(receiver.id ?? " ") ?? false){
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
    
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }
    
    var body: some View {
        
        
        VStack(alignment: .leading, spacing: 8){
            
            
            HStack(alignment: .top, spacing: 10){
                
                WebImage(url: URL(string: event.creator?.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:50,height:50)
                    .clipShape(Circle())
                    .padding(.leading, 5)
                
                
                VStack(alignment: .leading){
                    HStack(alignment: .top, spacing: 5){
                        Text("\((userNotification.event ?? EventModel()).creator?.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                        Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                    }
                    Text("\((userNotification.event ?? EventModel()).creator?.nickName ?? " ") created an event").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                    
                }
                
            }
            
        }
        
    }
    
}




struct UserInvitedToEventNotificationCell : View {
    
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var eventVM = EventViewModel()
    @State var userIsAttending: Bool = false
    func userIsAttending(event: EventModel) -> Bool{
        return event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false
    }
    @Binding var showAddEventView: Bool
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }
    
    
    var body: some View {
        
        NavigationLink {
            UserProfilePage(user: sender)
        } label : {
            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 10){
                    
                    WebImage(url: URL(string: (userNotification.event ?? EventModel()).creator?.profilePicture ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:40,height:40)
                        .clipShape(Circle())
                        .padding(.leading, 5)
                    
                    HStack{
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.event ?? EventModel()).eventName ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            Text("\((userNotification.event ?? EventModel()).creator?.nickName ?? " ") invited you to \((userNotification.event ?? EventModel()).eventName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            
                        }
                        
                        Spacer()
                        
                        Button(action:{
                            self.showAddEventView.toggle()
                        },label:{
                            Text("See Details").padding(.trailing)
                        })
                        
                    }
                 
                    
                    
                    
                    
                    
                }
                
            }
            NavigationLink(destination:   EventDetailView(event: userNotification.event ?? EventModel(), showAddEventView: $showAddEventView), isActive: $showAddEventView) {
                EmptyView()
            }
        }
        
        .onAppear{
            eventVM.fetchEvent(eventID: userNotification.eventID ?? " ")
           
        }
        
        
    }
}

//
//  NotificationCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/10/22.
//

import SwiftUI

struct NotificationCell: View {
    var notification : NotificationModel
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var groupVM = GroupViewModel()
    @State var timeElapsed : String = ""
    @State var personalChat : ChatModel = ChatModel()
    @State var openPersonalChat: Bool = false
    @State var personalChatFriend : User = User()
    
    func isFriends(user1: User, user2: String) -> Bool{
        let friendsList = user1.friendsList ?? []
        return friendsList.contains(user2)
            
    }
    
    func convertComponentsToDate(days: Int, hours: Int, minutes: Int, seconds: Int) -> String {
        var ans = ""
    
        let noDays = (days <= 0)
        let noHours = (hours <= 0)
        let noMinutes = (minutes <= 0)
        let noSeconds = (seconds <= 0)
        
       if(noDays && noHours && noMinutes && !noSeconds){
            ans = "\(seconds) secs"
        }else if(noDays && noHours && !noMinutes){
            ans = "\(minutes) mins"
        }else if (noDays && !noHours && noMinutes){
            ans = "\(hours) hrs"
        }else if (!noDays && noHours && noMinutes){
            ans = "\(days) days"
        }else if (!noDays && !noHours && !noMinutes){
            ans = "\(days) days"
        }else if (!noDays && !noHours && noMinutes){
            ans = "\(days) days"
        }else if (!noDays && noHours && !noMinutes){
            ans = "\(days) days"
        }else if (noDays && !noHours && !noMinutes){
            ans = "\(hours) hrs"
        }else if (noDays && noHours && !noMinutes && !noSeconds){
            ans = "\(minutes) mins"
        }
        
        return ans
        
    }
    
      
    
    
    func inGroup(group: String, user: User, completion: @escaping (Bool) -> ()) -> (){
        COLLECTION_GROUP.document(group).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            let users = snapshot!.get("users") as? [String] ?? []
            
            return completion(users.contains(user.id ?? ""))
                
        }
    }
    
    var body: some View {
        VStack{
            
            HStack{
                
                
                Text("\(notification.value ?? "")")
                
                Spacer()
                
                switch (notification.actionType){
                    case "none":
                        EmptyView()
                    case "friendRequest":
                        if isFriends(user1: userVM.user ?? User(), user2: notification.subjectID) {
                            Text("Accepted").foregroundColor(.gray)
                        }else{
                            HStack{
                                Button(action:{
                                    userVM.addFriend(user: userVM.user ?? User(), friendID: notification.subjectID)
                                    COLLECTION_USER.document(userVM.user?.id ?? "").collection("Notifications").document(notification.id).updateData(["actionUsed":true])
                                },label:{
                                    Image(systemName: "checkmark.circle").font(.title2).foregroundColor(.green)
                                })
                                
                                Button(action:{
                                    //TODO
                                    userVM.declineFriendRequest(friendID: notification.subjectID, user: userVM.user ?? User())
                                    COLLECTION_USER.document(userVM.user?.id ?? "").collection("Notifications").document(notification.id).updateData(["actionUsed":true])
                                },label:{
                                    Image(systemName: "x.circle").font(.title2).foregroundColor(.red)
                                })
                            }
                        }
                        
                case "groupInvite":
                    
                    
                                    
                            HStack{
                                Button(action:{
                                    groupVM.joinGroup(groupID: notification.subjectID, username: userVM.user?.username ?? "")
                                    COLLECTION_USER.document(userVM.user?.id ?? "").collection("Notifications").document(notification.id).updateData(["actionUsed":true])
                                },label:{
                                    Image(systemName: "checkmark.circle").font(.title2).foregroundColor(.green)
                                })
                                Button(action:{
                                    //TODO
                                    COLLECTION_USER.document(userVM.user?.id ?? "").collection("Notifications").document(notification.id).updateData(["actionUsed":true])
                                },label:{
                                    Image(systemName: "x.circle").font(.title2).foregroundColor(.red)
                                })
                            }
                    
                case "personalMessage":

                    
                    //init a personalChat
                    //when clicked, set personalChat to correct chat using function and then toggle boolean to go to navigationLink
                    
                    Button(action:{
                        userVM.getPersonalChat(user1: userVM.user ?? User(), user2: notification.subjectID, completion: { chat in
                            self.personalChat = chat
                        })
                        userVM.fetchUser(userID: notification.subjectID) { fetchedUser in
                            self.personalChatFriend = fetchedUser
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.openPersonalChat.toggle()
                        }
                    },label:{
                        Image(systemName: "bubble.left")
                    })
                    

                    
                    
                    default:
                        EmptyView()
                }
                
            }
            HStack{
                Spacer()
                Text(timeElapsed)
            }
            
            
            NavigationLink(destination: PersonalChatView(friend: self.$personalChatFriend, chat: $personalChat), isActive: $openPersonalChat) {
                EmptyView()
            }
            
            
        }.padding(.vertical,10).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: notification.notificationTime?.dateValue() ?? Date(), to: Date())
            let day = components.day ?? 0
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let second = components.second ?? 0
            
            self.timeElapsed = convertComponentsToDate(days: day, hours: hour, minutes: minute, seconds: second)
            
            
        }
        
      
            
    }
}

//struct NotificationCell_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationCell()
//    }
//}

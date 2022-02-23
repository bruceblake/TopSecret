//
//  UserNotificationView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/10/22.
//

import SwiftUI

struct UserNotificationView: View {
    @EnvironmentObject var userVM : UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var selectedIndex : Int = 0
    var options = ["All","Friend Requests","Group Invites"]
    
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                
                
                HStack{
                    Button(action:{
                        
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Back")
                    }).padding(.leading,10)
                    
                    Spacer()
                    
                    Text("Notifications")
                    
                    Spacer()
                }
                .padding(.top,70)
                
                Picker("Options",selection: $selectedIndex){
                    ForEach(0..<options.count){ index in
                        Text(self.options[index]).tag(index)
                    }
                }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal)
                ScrollView{
                    
                    VStack{
                        ForEach(userVM.notifications){ notification in
                            
                            switch selectedIndex{
                            
                            case 0:
                                
                                //all notifications
                                NotificationCell(notification: notification).padding(.horizontal)
                                Divider()
                                
                                
                            case 1:
                                
                                //Friend Requests
                                if notification.notificationType == "friendRequest"{
                                    NotificationCell(notification: notification).padding(.horizontal)
                                    Divider()
                                }
                                
                                
                            default:
                                if notification.notificationType == "groupInvite"{
                                    NotificationCell(notification: notification).padding(.horizontal)
                                    Divider()
                                    
                                }
                                
                            }
                            
                            
                            
                            
                        }
                        
                    } 
                
                }
                
                
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onDisappear{
            userVM.readAllUserNotifications(uid: userVM.user?.id ?? "")
        }
    }
}

struct UserNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        UserNotificationView()
    }
}

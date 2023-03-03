//
//  MessageCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/5/21.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI


struct MessageCell: View {
    var message: Message
    @Binding var selectedMessage : Message
    @Binding var showOverlay: Bool
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var personalChatVM: PersonalChatViewModel

    var body: some View {
        
        switch message.type ?? "" {
        case "text":
            MessageTextCell(message: message, chatID: personalChatVM.chat.id).padding([.leading,.top],5)
//                .simultaneousGesture(LongPressGesture(minimumDuration: 0.25).onEnded({ value in
//                    withAnimation{
//                        UIDevice.vibrate()
//                        self.selectedMessage = message
//                        self.showOverlay.toggle()
//                        userVM.hideBackground.toggle()
//
//                    }
//                }))
        case "followUpUserText":
            MessageFollowUpTextCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5)
//                .simultaneousGesture(LongPressGesture(minimumDuration: 0.25).onEnded({ value in
//                    withAnimation{
//                        UIDevice.vibrate()
//                        self.selectedMessage = message
//                        self.showOverlay.toggle()
//                        userVM.hideBackground.toggle()
//
//                    }
//                }))
        case "delete":
            MessageDeleteCell(message: message)
        case "repliedMessage":
            MessageReplyCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5)
        case "postMessage":
            MessagePostCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5)
        case "pollMessage":
            MessagePollCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5)
        case "eventMessage":
            MessageEventCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5)
        default:
            Text("Hello World")
        }
    

    }
}

struct MessageTextCell: View {
    @EnvironmentObject var userVM: UserViewModel
    var message: Message
    var chatID: String
    
    
    
    var body: some View {
        
        
        ZStack{
            Color("Background")
            VStack(alignment: .leading, spacing: 0){
                
                HStack(spacing: 3){
                        Image(systemName: "chevron.left").foregroundColor(message.userID == userVM.user?.id ?? "" ? Color("AccentColor") : Color("blue"))
                        .frame(width:2).padding(.horizontal,5)
                        Text("\(message.userID == userVM.user?.id ?? "" ? "Me"  : message.name ?? "")").foregroundColor(message.userID == userVM.user?.id ?? "" ? Color("AccentColor") : Color("blue"))
                    
                    
            
                    
                    Spacer()
                    
                }.padding(.top,3)
                
                
                HStack(alignment: .center){
                    
                    HStack(spacing: 3){
                        Rectangle().foregroundColor(Color("\(message.userID == userVM.user?.id ?? " " ? "AccentColor" : "blue")")).frame(width:2).padding(.horizontal,5)
                        
                        HStack{
                            Text("\(message.value ?? "")").foregroundColor(FOREGROUNDCOLOR).lineLimit(5)
                            if message.edited ?? false{
                                Text("(edited)").foregroundColor(.gray).font(.footnote)
                            }
                        }
                    }
                    
                    
                    
                    
                    Spacer()
                    
                    
                }.padding(.top,5)
                
                
                
            }
            
            
        }
        
        
        
        
     
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
}

struct MessageEventCell : View {
    @EnvironmentObject var userVM: UserViewModel
    var message: Message
    @State var selectedEvent = EventModel()
    @State var shareType : String = ""
    var chatID: String
    
    var body: some View{
        ZStack{
            VStack(alignment: .leading, spacing: 2){
                HStack(spacing: 3){
                    if message.userID == userVM.user?.id ?? ""{
                        Image(systemName: "chevron.left").foregroundColor(Color("AccentColor")).frame(width:2).padding(.horizontal,5)
                        Text("Me").foregroundColor(Color("AccentColor"))
                    }else{
                        Image(systemName: "chevron.left").foregroundColor(Color("blue")).frame(width:2).padding(.horizontal,5)
                        Text("\(message.name ?? "")").foregroundColor(Color("blue"))
                    }
                    
                    Spacer()
                    
                }.padding(.top,3)
                    HStack(spacing: 3){
                        Rectangle().foregroundColor(Color("\(message.userID == userVM.user?.id ?? " " ? "AccentColor" : "blue")")).frame(width:2).padding(.horizontal,5)
                        
                       
                        EventCell(event: message.event ?? EventModel(), selectedEvent: $selectedEvent, shareType: $shareType).frame(width: UIScreen.main.bounds.width/1.25)
                        
                     
                        
                        Spacer()
                    }
                    
                   
                
            }
        }
    }
}

struct MessagePollCell: View {
    @EnvironmentObject var userVM: UserViewModel
    var message: Message
    @State var selectedPoll = PollModel()
    @State var shareType : String = ""
    var chatID: String
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 2){
                HStack(spacing: 3){
                    if message.userID == userVM.user?.id ?? ""{
                        Image(systemName: "chevron.left").foregroundColor(Color("AccentColor")).frame(width:2).padding(.horizontal,5)
                        Text("Me").foregroundColor(Color("AccentColor"))
                    }else{
                        Image(systemName: "chevron.left").foregroundColor(Color("blue")).frame(width:2).padding(.horizontal,5)
                        Text("\(message.name ?? "")").foregroundColor(Color("blue"))
                    }
                    
                    Spacer()
                    
                }.padding(.top,3)
                    HStack(spacing: 3){
                        Rectangle().foregroundColor(Color("\(message.userID == userVM.user?.id ?? " " ? "AccentColor" : "blue")")).frame(width:2).padding(.horizontal,5)
                        
                       
                        PollCell(poll: message.poll ?? PollModel(), selectedPoll: $selectedPoll, shareType: $shareType).frame(width: UIScreen.main.bounds.width/1.25)
                        
                     
                        
                        Spacer()
                    }
                    
                   
                
            }
        }
    }
}

struct MediaPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat){
        value = nextValue()
    }
}

extension View {
    
    func updateRectangleHeight(_ size: CGFloat) -> some View{
        preference(key: MediaPreferenceKey.self, value: size)
    }
}

struct MessagePostCell : View {
    @EnvironmentObject var userVM: UserViewModel
    var message: Message
    @State var selectedPost: GroupPostModel = GroupPostModel()
    var chatID: String
    @State var shareType : String = ""
    @State var rectangleHeight : CGFloat = .zero

    
    var body: some View {
        
        ZStack{
            VStack(alignment: .leading, spacing: 2){
                HStack(spacing: 3){
                    if message.userID == userVM.user?.id ?? ""{
                        Image(systemName: "chevron.left").foregroundColor(Color("AccentColor")).frame(width:2).padding(.horizontal,5)
                        Text("Me").foregroundColor(Color("AccentColor"))
                    }else{
                        Image(systemName: "chevron.left").foregroundColor(Color("blue")).frame(width:2).padding(.horizontal,5)
                        Text("\(message.name ?? "")").foregroundColor(Color("blue"))
                    }
                    
                    Spacer()
                    
                }.padding(.top,3)
                    HStack(spacing: 3){
                        
                        Rectangle().foregroundColor(Color("\(message.userID == userVM.user?.id ?? " " ? "AccentColor" : "blue")")).frame(width:2, height: rectangleHeight).padding(.horizontal,5)
                        
                        
                        
                        if (message.post?.id ?? "") == "deleted" {
                            Button(action:{
                                //leave this empty
                            },label:{
                                ZStack{
                                    Color("Color").blur(radius: 30)
                                    VStack{
                                        Spacer()
                                            Text("Post has been deleted").foregroundColor(Color.gray.opacity(0.5))

                                        Spacer()
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width/1.5, height: 300).cornerRadius(12).updateRectangleHeight(CGFloat(300))
                            })
                        }else{
                            NavigationLink(destination: FullScreenGroupPostView(post: message.post ?? GroupPostModel() )) {
                               
                                    GroupPostCell(post: message.post ?? GroupPostModel(), selectedPost: $selectedPost, shareType: $shareType, hideControls: true
                                    ).overlay(
                                        GeometryReader { geo in
                                            Color.clear.preference(key: MediaPreferenceKey.self, value: geo.size.height)
                                        }
                                    )
                                
                                    
                                
                            
                                
                               
                                
                       
                                    .frame(width: UIScreen.main.bounds.width/1.5).cornerRadius(12)
                            }
                        }
                      
                      
                     
                        
                        Spacer()
                    }
                    
                   
                
            }
      
        }.onPreferenceChange(MediaPreferenceKey.self){
            self.rectangleHeight = $0
        }
        
    }
}


struct MessageDeleteCell : View {
    var message: Message
    
    var body: some View {
        ZStack{
            Color("Background")
            HStack{
                Spacer()
                Text("\(message.value ?? " ")").foregroundColor(Color.red)
                Spacer()
            }
        }
    }
}

struct MessageReplyCell : View {
    
    
    
    var message: Message
    var chatID: String
    @EnvironmentObject var userVM: UserViewModel
    var body: some View{
        ZStack{
            Color("Background")
            VStack(alignment: .leading, spacing: 2){
                HStack(spacing: 3){
                    if message.userID == userVM.user?.id ?? ""{
                        Image(systemName: "chevron.left").foregroundColor(Color("AccentColor")).frame(width:2).padding(.horizontal,5)
                        Text("Me").foregroundColor(Color("AccentColor"))
                    }else{
                        Image(systemName: "chevron.left").foregroundColor(Color("blue")).frame(width:2).padding(.horizontal,5)
                        Text("\(message.name ?? "")").foregroundColor(Color("blue"))
                    }
                    
                    Spacer()
                    
                }.padding(.top,3)
                HStack(alignment: .center){
                    HStack(spacing: 3){
                        Rectangle().foregroundColor(Color("\(message.userID == userVM.user?.id ?? " " ? "AccentColor" : "blue")")).frame(width:2).padding(.horizontal,5)
                        
                        VStack(spacing: 0){
                            
                          
                          
                            
                          
                               
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 12).fill(Color("Color"))
                                
                                RoundedRectangle(cornerRadius: 12).strokeBorder(message.repliedMessage?.type == "deletedMessage" ? Color.red : (message.repliedMessage?.userID == userVM.user?.id ?? "" ? Color("AccentColor") : Color("blue")), lineWidth: 2)
                                VStack(alignment: .leading, spacing: 4){
                                    
                                    if message.repliedMessage?.type != "deletedMessage"{
                                        HStack(spacing: 3){
                                            
                                            if message.repliedMessage?.userID == userVM.user?.id ?? ""{
                                                Image(systemName: "chevron.left").foregroundColor(Color("AccentColor")).frame(width:2).padding(.horizontal,5)
                                                Text("Me").foregroundColor(Color("AccentColor"))
                                            }else{
                                                Image(systemName: "chevron.left").foregroundColor(Color("blue")).frame(width:2).padding(.horizontal,5)
                                                Text("\(message.repliedMessage?.name ?? "")").foregroundColor(Color("blue"))
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(message.repliedMessage?.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(Color.gray).font(.caption)
                                        }
                                        
                                    }
                                  
                                    HStack{
                                        
                                        
                                        HStack{
                                            Text("\(message.repliedMessage?.value ?? "")").foregroundColor(FOREGROUNDCOLOR).lineLimit(5).font(.system(size: 16))
                                            if message.repliedMessage?.edited ?? false{
                                                Text("(edited)").foregroundColor(.gray).font(.system(size: 16))
                                            }
                                        }
                                        
                                        
                                        
                                        Spacer()
                                        
                                        
                                    }
                                    
                                    
                                    
                                }.padding(10)
                            }.padding(10)
                            
                            HStack(alignment: .center){
                                Text("\(message.value ?? "")").foregroundColor(FOREGROUNDCOLOR).lineLimit(5).font(.system(size: 16))
                                if message.edited ?? false{
                                    Text("(edited)").foregroundColor(.gray).font(.footnote)
                                }
                                Image(systemName: "arrow.uturn.up").font(.system(size: 16)).foregroundColor(message.repliedMessage?.type == "deletedMessage" ? Color.red : (message.repliedMessage?.userID == userVM.user?.id ?? "" ? Color("AccentColor") : Color("blue")))
                                Spacer()
                            }.padding(.top,5)
                        }
                       
                        
                    }
                    
                    Spacer()
                }
             
            }
            
        }
    }
}

struct MessageFollowUpTextCell : View {
    @EnvironmentObject var userVM: UserViewModel
    var message: Message
    var chatID: String
    var body: some View {
        
        ZStack{
            Color("Background")
            VStack(alignment: .leading, spacing: 0){
                
                
                
                
                HStack(alignment: .center){
                    HStack(spacing: 3){
                        
                        Rectangle().foregroundColor(Color("\(message.userID == userVM.user?.id ?? " " ? "AccentColor" : "blue")")).frame(width:2).padding(.horizontal,5)
                        
                        HStack{
                            Text("\(message.value ?? "")").foregroundColor(FOREGROUNDCOLOR).lineLimit(5)
                            if message.edited ?? false{
                                Text("(edited)").foregroundColor(.gray).font(.footnote)
                            }
                        }
                    }
                    
                    
                    Spacer()
                    
                    
                }
                
            }
            
            
            
            
        }
    }
}

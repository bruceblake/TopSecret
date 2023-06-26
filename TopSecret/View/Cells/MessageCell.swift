//
//  MessageCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/5/21.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import AVFoundation
import AVKit


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
                    .delaysTouches(for: 0.1).gesture(LongPressGesture(minimumDuration: 0.25).onEnded({ value in
                        withAnimation{
                            UIDevice.vibrate()
                            self.selectedMessage = message
                            self.showOverlay.toggle()
                            userVM.hideBackground.toggle()
                            
                        }
                    }))
            case "followUpUserText":
                MessageFollowUpTextCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5)
                    .delaysTouches(for: 0.1).gesture(LongPressGesture(minimumDuration: 0.25).onEnded({ value in
                        withAnimation{
                            UIDevice.vibrate()
                            self.selectedMessage = message
                            self.showOverlay.toggle()
                            userVM.hideBackground.toggle()
                            
                        }
                    }))
            case "delete":
                MessageDeleteCell(message: message)
            case "repliedMessage":
                MessageReplyCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5).delaysTouches(for: 0.3).gesture(LongPressGesture(minimumDuration: 0.25).onEnded({ value in
                    withAnimation{
                        UIDevice.vibrate()
                        self.selectedMessage = message
                        self.showOverlay.toggle()
                        userVM.hideBackground.toggle()
                        
                    }
                }))
            case "pollMessage":
                MessagePollCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5)
            case "eventMessage":
                MessageEventCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5)
            case "image", "video", "multipleVideos", "multipleImages":
                MessageMediaCell(message: message, chatID: personalChatVM.chat.id).padding(.leading,5).delaysTouches(for: 0.2).gesture(LongPressGesture(minimumDuration: 0.35).onEnded({ value in
                    withAnimation{
                        UIDevice.vibrate()
                        self.selectedMessage = message
                        self.showOverlay.toggle()
                        userVM.hideBackground.toggle()
                        
                    }
                }))
            default:
                Text("Hello World")
        }
        
        
    }
}

struct MessageMediaCell : View {
    @EnvironmentObject var userVM: UserViewModel
    var message: Message
    var chatID: String
    @State var showFullScreen: Bool = false
    let columns : [GridItem] = [
        GridItem(.adaptive(minimum: UIScreen.main.bounds.width/3.5), spacing: 0),
        GridItem(.adaptive(minimum: UIScreen.main.bounds.width/3.5), spacing: 0),
        GridItem(.adaptive(minimum: UIScreen.main.bounds.width/3.5), spacing: 0)
        
        
    ]
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
                        
                        if message.type ?? "" == "image"{
                            Button {
                                self.showFullScreen.toggle()
                            } label: {
                                
                                WebImage(url: URL(string: message.value ?? " ")).resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width/3, height: 200)
                                    .clipped()
                                    .cornerRadius(12)
                                    .sheet(isPresented: $showFullScreen) {
                                        MessageImageFullScreenView(message: message)
                                    }
                            }
                        }else if message.type == "video"{
                            Button {
                                self.showFullScreen.toggle()
                            } label: {
                                VideoThumbnailImage(videoUrl: URL(string: message.value ?? " ") ?? URL(fileURLWithPath: " ") ).cornerRadius(12)
                            }.sheet(isPresented: $showFullScreen) {
                                MessageVideoFullScreenView(message: message)
                            }
                            
                            
                        }else if message.type == "multipleVideos"{
                            LazyVGrid(columns: columns, spacing: 1){
                                ForEach(message.urls ?? [], id: \.self){ url in
                                    Button(action:{
                                        self.showFullScreen.toggle()
                                    },label:{
                                        VideoThumbnailImage(videoUrl: URL(string: url) ?? URL(fileURLWithPath: " "), width: UIScreen.main.bounds.width/3.5).cornerRadius(12)
                                    }).sheet(isPresented: $showFullScreen) {
                                        MessageVideoFullScreenView(message: message)
                                    }
                                    
                                }
                            }
                            
                            
                        }else if message.type == "multipleImages"{
                            LazyVGrid(columns: columns, spacing: 1){
                                ForEach(message.urls ?? [], id: \.self){ url in
                                    Button {
                                        self.showFullScreen.toggle()
                                    } label: {
                                        WebImage(url: URL(string: url)).resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.width/3.5, height: 200)
                                            .clipped()
                                            .cornerRadius(12)
                                            .sheet(isPresented: $showFullScreen) {
                                                MessageImageFullScreenView(message: message)
                                            }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                    Spacer()
                    
                    
                }.padding(.top,5)
                
                
                
            }
            
            
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
                            Text("\(message.value ?? "")").foregroundColor(FOREGROUNDCOLOR)
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
                    
                    
                    EventCell(event: message.event ?? EventModel(), selectedEvent: $selectedEvent).frame(width: UIScreen.main.bounds.width/1.25)
                    
                    
                    
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
                    
                    
                    PollCell(poll: message.poll ?? PollModel(), selectedPoll: $selectedPoll).frame(width: UIScreen.main.bounds.width/1.25)
                    
                    
                    
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

struct MessageImageFullScreenView : View {
    var message: Message
    @Environment(\.presentationMode) var presentationMode
    
    func getTimeSince(date: Date) -> String{
        let interval = (Date() - date)
        
        
        var seconds = interval.second ?? 0
        var minutes = (seconds / 60)
        var hours = (minutes / 60)
        var days = (hours / 24)
        var time = ""
        if seconds < 60{
            if seconds == 1 {
                time = "\(seconds) second ago"
            }else{
                time = "\(seconds) seconds ago"
            }
        }else if seconds < 3600  {
            if minutes == 1 {
                time = "\(minutes) minute ago"
            }else{
                time = "\(minutes) minutes ago"
            }
        }else if seconds < 86400 {
            if hours == 1 {
                time = "\(hours) hour ago"
            }else{
                time = "\(hours) hours ago"
            }
        }else if seconds < 604800 {
            if days == 1 {
                time = "\(days) day ago"
            }else{
                time = "\(days) days ago"
            }
        }
        if time == "0 seconds ago"{
            return "now"
        }else{
            return time
        }
        
    }
    var body: some View {
        
        if message.urls?.isEmpty ?? false {
            ZStack{
                AsyncImage(url: URL(string: message.value ?? " ") ?? URL(string: "turd")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .resizeToScreenSize()
                        .clipped()
                        .cornerRadius(12)
                } placeholder: {
                    ZStack{
                        Rectangle().foregroundColor(Color("Color")).resizeToScreenSize()
                        ProgressView()
                    }
                }
                VStack{
                    HStack{
                        HStack(spacing: 5){
                            WebImage(url: URL(string: message.profilePicture ?? " "))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 1){
                                Text("\(message.name ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                Text("\(getTimeSince(date: message.timeStamp?.dateValue() ?? Date()))").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                
                            }
                        }.padding(.top,10)
                        
                        Spacer()
                        
                        Circle().frame(width: 40,height: 40).foregroundColor(Color.clear)
                    }.padding(.horizontal).padding(.top,50).background(Color("Background").opacity(0.5))
                    Spacer()
                }
            }.resizeToScreenSize().edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        }else{
            TabView(){
                ForEach(message.urls ?? [], id: \.self) { url in
                    ZStack{
                        AsyncImage(url: URL(string: url) ?? URL(string: "turd")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .resizeToScreenSize()
                                .clipped()
                                .cornerRadius(12)
                        } placeholder: {
                            ZStack{
                                Rectangle().foregroundColor(Color("Color")).resizeToScreenSize()
                                ProgressView()
                            }
                        }
                        VStack{
                            HStack{
                                HStack(spacing: 5){
                                    WebImage(url: URL(string: message.profilePicture ?? " "))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 1){
                                        Text("\(message.name ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                        Text("\(getTimeSince(date: message.timeStamp?.dateValue() ?? Date()))").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                        
                                    }
                                }.padding(.top,10)
                                
                                Spacer()
                                
                                Circle().frame(width: 40,height: 40).foregroundColor(Color.clear)
                            }.padding(.horizontal).padding(.top,50).background(Color("Background").opacity(0.5))
                            Spacer()
                        }
                    }.resizeToScreenSize().edgesIgnoringSafeArea(.all).navigationBarHidden(true)
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
      
    }
}

struct MessageVideoFullScreenView : View {
    var message: Message
    @Environment(\.presentationMode) var presentationMode
    var player : AVPlayer {
        AVPlayer(url: URL(string: message.value ?? " ") ?? URL(fileURLWithPath: " "))
    }
    func getTimeSince(date: Date) -> String{
        let interval = (Date() - date)
        
        
        var seconds = interval.second ?? 0
        var minutes = (seconds / 60)
        var hours = (minutes / 60)
        var days = (hours / 24)
        var time = ""
        if seconds < 60{
            if seconds == 1 {
                time = "\(seconds) second ago"
            }else{
                time = "\(seconds) seconds ago"
            }
        }else if seconds < 3600  {
            if minutes == 1 {
                time = "\(minutes) minute ago"
            }else{
                time = "\(minutes) minutes ago"
            }
        }else if seconds < 86400 {
            if hours == 1 {
                time = "\(hours) hour ago"
            }else{
                time = "\(hours) hours ago"
            }
        }else if seconds < 604800 {
            if days == 1 {
                time = "\(days) day ago"
            }else{
                time = "\(days) days ago"
            }
        }
        if time == "0 seconds ago"{
            return "now"
        }else{
            return time
        }
        
    }
    var body: some View {
        
        if message.urls?.isEmpty ?? false{
            ZStack{
                
                Video(player: player
                , url: URL(string: message.value ?? " ") ?? URL(fileURLWithPath: " "), cameraVM: CameraViewModel()).cornerRadius(12)
                
                
                VStack{
                    HStack{
                        HStack(spacing: 5){
                            WebImage(url: URL(string: message.profilePicture ?? " "))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 1){
                                Text("\(message.name ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                Text("\(getTimeSince(date: message.timeStamp?.dateValue() ?? Date()))").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                
                            }
                        }.padding(.top,10)
                        
                        Spacer()
                        
                        Circle().frame(width: 40,height: 40).foregroundColor(Color.clear)
                    }.padding(.horizontal).padding(.top,50).background(Color("Background").opacity(0.5))
                    Spacer()
                }
            }.resizeToScreenSize().edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        }else{
            TabView{
                
                ForEach(message.urls ?? [], id: \.self){ url in
                    ZStack{
                        
                        Video(player:AVPlayer(url: URL(string: url) ?? URL(fileURLWithPath: " "))
                              , url: URL(string: url) ?? URL(fileURLWithPath: " "), cameraVM: CameraViewModel()).cornerRadius(12)
                        
                        
                        VStack{
                            HStack{
                                HStack(spacing: 5){
                                    WebImage(url: URL(string: message.profilePicture ?? " "))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 1){
                                        Text("\(message.name ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                        Text("\(getTimeSince(date: message.timeStamp?.dateValue() ?? Date()))").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                        
                                    }
                                }.padding(.top,10)
                                
                                Spacer()
                                
                                Circle().frame(width: 40,height: 40).foregroundColor(Color.clear)
                            }.padding(.horizontal).padding(.top,50).background(Color("Background").opacity(0.5))
                            Spacer()
                        }
                    }.resizeToScreenSize().edgesIgnoringSafeArea(.all).navigationBarHidden(true)
                    
                }
                
                
                
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
        
        
    }
}

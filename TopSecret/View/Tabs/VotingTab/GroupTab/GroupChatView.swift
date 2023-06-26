//
//  GroupChatView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Foundation
import UIKit
import OmenTextField
import SwiftUIPullToRefresh
import Firebase
import MediaPicker
import AVFoundation
import AVKit

struct GroupChatView: View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var chatVM = GroupChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State var height: CGFloat = 20
    @State var keyboardHeight : CGFloat = 0
    @State var showMenu : Bool = false
    @State var openAddContent : Bool = false
    @State private var scrollViewOffset = CGFloat.zero
    @State var isShowingMediaPicker : Bool = false
    @State var urls : [URL] = []
    @State var images: [UIImage] = []
    @State var videos: [URL] = []
    @State var isLoadingMedia : Bool = false
    @State var isLeavingChat: Bool = false
    @State var showOverlay : Bool = false
    @State var selectedMessage: Message = Message()
    @State var showEditView: Bool = false
    @State var showReplyView: Bool = false
    @State var canAddAnotherLine : Bool = true
    @State var showAddContent: Bool = false

    var chatID: String
    var groupID: String

    func initKeyboardGuardian(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification , object: nil, queue: .main) { data in
            let height1 = data.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            withAnimation(.easeOut(duration: 0.25)){
                self.keyboardHeight = height1.cgRectValue.height - 20
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.25)){
                self.keyboardHeight = 0
            }
        }

    }
    
    func getPersonalChatUser() -> User{
        
        for user in chatVM.chat.users ?? [] {
            if user.id ?? "" != userVM.user?.id ?? " "{
                return user
            }
        }
        
        return User()
    }
    
    
    func getChatColor(userID: String) -> String{
        var color = ""
        var nameColors = chatVM.chat.nameColors
        
        for index in nameColors{
            var keys = index.map{$0.key}
            var values = index.map{$0.value}
            
            for i in keys.indices {
                if keys[i] == userID{
                    color = values[i]
                }
            }
        }
        
        return color
    }
    
    func scrollToBottom(scrollViewProxy: ScrollViewProxy){
        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
    }
    
    
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                //Active Users
                ScrollView(.horizontal){
                    HStack(spacing: 5){
                        ForEach(chatVM.users, id: \.id){ user in
                            
                            NavigationLink(destination: UserProfilePage(user: user), label:{
                                
                                VStack(spacing: 5){
                                    WebImage(url: URL(string: user.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(chatVM.usersIdling.contains(user) ? Color(chatVM.getColor(userID: user.id ?? "", groupChat: chatVM.chat)) : Color.gray,lineWidth: 2))
                                    
                                    Text("\(user.nickName ?? "TOP SECRET USER")").foregroundColor(FOREGROUNDCOLOR)
                                }
                                
                                
                                
                            }).padding(.leading,5).padding(.top,5)
                            
                            
                            
                            
                            
                        }
                    }
                    
                    
                }
                
                Divider()
               
                //messages
                ZStack(alignment: .bottomTrailing){
                    
                    ScrollView{
                        ScrollViewReader { scrollViewProxy in
                            VStack(spacing: 0){
                                ForEach(chatVM.messages, id: \.id){ message in
                                    if message.type == "text"{
                                        MessageTextCell(message: message, chatID: chatVM.chat.id)
                                    }else if message.type == "followUpUserText"{
                                        MessageFollowUpTextCell(message: message, chatID: chatVM.chat.id)
                                    }
                                }
                                    HStack{Spacer()}.padding(0).id("Empty")
                                }.background(GeometryReader{ proxy -> Color in
                                    DispatchQueue.main.async{
                                        scrollViewOffset = -proxy.frame(in: .named("scroll")).origin.y
                                    }
                                    return Color.clear
                                }).padding(5).onReceive(chatVM.$scrollToBottom, perform: { _ in
                                    withAnimation(.easeOut(duration: 0.5)){
                                        
                                        self.scrollToBottom(scrollViewProxy: scrollViewProxy)
                                    }
                                })
                                
                            
                            
                        }
                     
                    }.coordinateSpace(name: "scroll").simultaneousGesture(DragGesture().onChanged { _ in
                        UIApplication.shared.keyWindow?.endEditing(true)
                    })
                    
                    Button(action:{
                        chatVM.scrollToBottom += 1
                        
                    },label:{
                        ZStack{
                            Circle().frame(width: 30, height: 30).foregroundColor(Color("AccentColor"))
                            Image(systemName: "chevron.down").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(10)
                }
               
                
                Spacer()
          
                //keyboard
                
                VStack{
                    if showReplyView {
                        HStack{
                            VStack(alignment: .leading, spacing: 3){
                                HStack(spacing: 3){
                                    if selectedMessage.userID == userVM.user?.id ?? ""{
                                        Image(systemName: "chevron.left").foregroundColor(Color("AccentColor")).frame(width:2).padding(.horizontal,5)
                                        Text("Me").foregroundColor(Color("AccentColor"))
                                    }else{
                                        Image(systemName: "chevron.left").foregroundColor(Color("blue")).frame(width:2).padding(.horizontal,5)
                                        Text("\(selectedMessage.name ?? "")").foregroundColor(Color("blue"))
                                    }
                                    Spacer()
                                }
                                
                                HStack{
                                    
                                    
                                    HStack{
                                        Text("\(selectedMessage.value ?? "")").foregroundColor(FOREGROUNDCOLOR).lineLimit(5)
                                        if selectedMessage.edited ?? false{
                                            Text("(edited)").foregroundColor(.gray).font(.footnote)
                                        }
                                    }
                                    
                                    
                                    
                                    Spacer()
                                    
                                    
                                }
                                
                                
                                
                            }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background"))).padding(10)
                            Button(action:{
                                withAnimation{
                                    self.showReplyView.toggle()
                                }
                            },label:{
                                ZStack{
                                    Circle().frame(width: 40, height: 40).foregroundColor(Color("Background"))
                                    Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                                }
                            }).padding(.trailing,5)
                        }
                    }
                    Divider()
                    if urls.isEmpty{
                        HStack(alignment: .bottom){
                            
                            Button(action:{
                            },label:{
                                ZStack{
                                    Circle().frame(width:35, height:35).foregroundColor(Color("Background"))
                                    Image(systemName: "camera").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                                }
                            })
                            
                            
                            
                            Button(action:{
                                self.urls = []
                                self.isShowingMediaPicker.toggle()
                            },label:{
                                ZStack{
                                    Circle().foregroundColor(Color("Background")).frame(width: 35, height: 35)
                                    Image(systemName: "photo.on.rectangle.angled").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                                }
                            }).mediaImporter(isPresented: $isShowingMediaPicker, allowedMediaTypes: .all, allowsMultipleSelection: true) { result in
                                switch result {
                                    case .success(let urls):
                                        self.urls = urls
                                    case .failure(let error):
                                        print(error)
                                        self.urls = []
                                }
                            }
                            
                            Spacer()
                            OmenTextField("Send a text..",text: $chatVM.text, returnKeyType: .send , onCommit: {
                                    if showReplyView{
                                        chatVM.sendReplyTextMessage(text:  chatVM.text, user: userVM.user ?? User(), nameColor: self.getChatColor(userID: userVM.user?.id ?? " "), repliedMessageID: selectedMessage.id, messageType: "repliedMessage", chatID:  chatVM.chat.id)
                                        withAnimation{
                                            self.showReplyView.toggle()
                                        }
                                    }else{
                                        chatVM.sendTextMessage(text:  chatVM.text, user: userVM.user ?? User(), timeStamp: Timestamp(), nameColor: self.getChatColor(userID: userVM.user?.id ?? " "), messageID: UUID().uuidString, messageType:  chatVM.getLastMessage().userID == userVM.user?.id ?? " "  ? "followUpUserText" : "text", chatID:  chatVM.chat.id)
                                    }
                                    
                                    
                               
                                    
                                
                                chatVM.text = ""
                                chatVM.scrollToBottom += 1
                                
                            
                            } ,canAddAnotherLine: $canAddAnotherLine, hasMicrophone: true).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                            Button(action:{
                                self.showAddContent.toggle()
                            },label:{
                                ZStack{
                                    Circle().frame(width:35, height:35).foregroundColor(Color("Background"))
                                    Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                }
                            })
                        }.padding().padding(.bottom,10)

                    }else{
                        HStack(alignment: .top, spacing: 4){
                            if isLoadingMedia{
                                VStack{
                                    Text("Loading Media").foregroundColor(Color.gray)
                                    ProgressView()
                                }
                            }else{
                                if  chatVM.sendingMedia{
                                    VStack{
                                        Text("Sending Media...").foregroundColor(FOREGROUNDCOLOR)
                                        VStack(alignment: .leading){
                                            if !images.isEmpty{
                                                Text("\( chatVM.imagesSent) out of \(images.count) images sent").foregroundColor(Color.gray)
                                            }
                                            if !videos.isEmpty{
                                                Text("\(chatVM.videosSent) out of \(videos.count) videos sent").foregroundColor(Color.gray)
                                            }
                                        }
                                    }
                                }else{
                                    Button(action:{
                                        //todo
                                        withAnimation{
                                            self.urls = []
                                            self.images = []
                                            self.videos = []
                                        }
                                    },label:{
                                        Image(systemName: "xmark").font(.title).foregroundColor(Color.red)
                                    })
                                    ScrollView(.horizontal, showsIndicators: false){
                                        HStack{
                                            ForEach(images, id: \.self){ image in
                                                Image(uiImage: image).resizable().scaledToFill().frame(width: 50, height: 50).clipped().cornerRadius(12)
                                                
                                            }
                                        
                                            ForEach(0..<videos.count, id: \.self) { index in
                                                VideoThumbnailImage(videoUrl: videos[index], width: 50, height: 50).cornerRadius(12)
                                                
                                            }
                                        }
                                       
                                    }
                                }
                             
                            }
                           
                            if !chatVM.sendingMedia {
                                Spacer()
                                Button(action:{
                                    //todo
                                    let dp = DispatchGroup()
                                    var finishedSendingImages = false
                                    var finishedSendingVideos = false
                                    if !images.isEmpty{
                                        chatVM.sendingMedia = true
                                        for image in images {
                                            dp.enter()
                                            chatVM.sendImageMessage(image: image, user: userVM.user ?? User()) { sentImage in
                                                    finishedSendingImages = true
                                                chatVM.imagesSent += 1
                                                dp.leave()
                                            }
                                        }
                                    }else{
                                        dp.enter()
                                        finishedSendingImages = true
                                        dp.leave()
                                    }
                                   
                                    if !videos.isEmpty{
                                        chatVM.sendingMedia = true
                                        for video in videos {
                                            dp.enter()
                                            chatVM.sendVideoMessage(videoUrl: video, user: userVM.user ?? User()) { sentVideo in
                                                    finishedSendingVideos = true
                                                chatVM.videosSent += 1
                                                    dp.leave()
                                            }
                                        }
                                    }else{
                                        dp.enter()
                                        finishedSendingVideos = true
                                        dp.leave()
                                    }
                                    dp.notify(queue: .main) {
                                        if finishedSendingImages && finishedSendingVideos{
                                            withAnimation{
                                                self.urls = []
                                                self.videos = []
                                                self.images = []
                                                chatVM.sendingMedia = false
                                                chatVM.imagesSent = 0
                                                chatVM.videosSent = 0
                                            }
                                           
                                        }
                                    }
                                  
                                },label:{
                                    Image(systemName: "play.fill").font(.largeTitle).foregroundColor(Color("AccentColor"))
                                }).disabled(isLoadingMedia)
                            }
                           
                        }.padding().padding(.bottom,30)
                    }
                    
                }.background(Color("Color")).offset(y: -self.keyboardHeight)
                
            }.opacity(self.openAddContent ? 0.2 : 1).disabled(self.openAddContent).onTapGesture(perform: {
                if self.openAddContent {
                    self.openAddContent.toggle()
                }
            })
            
            
            BottomSheetView(isOpen: $openAddContent, maxHeight: UIScreen.main.bounds.height / 3){
                ChatAddContentView(chatVM: chatVM)
            }
            
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear{
                
                self.initKeyboardGuardian()
                    chatVM.listenToChat(chatID: chatID, groupID: groupID) { completed in
                }
                chatVM.readAllMessages(chatID: chatID, groupID: groupID)
                chatVM.openChat(userID: userVM.user?.id ?? " " ,chatID: chatID, groupID: groupID)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                chatVM.scrollToBottom += 1
                    print("groupID: \(groupID)")
                }
                chatVM.readLastMessage(chatID: chatID, userID: userVM.user?.id ?? " ")
        }
            .onDisappear{
                chatVM.exitChat(userID: userVM.user?.id ?? " ", chatID: chatID, groupID: groupID)
            }
            .onTapGesture {
                if self.keyboardHeight != 0 {
                    
            UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
                }
            }
    }
}


struct ChatAddContentView : View {
    
    @StateObject var chatVM: GroupChatViewModel = GroupChatViewModel()
    @StateObject var personalChatVM : PersonalChatViewModel = PersonalChatViewModel()
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ZStack(alignment: .top){
            Color("Color")
            VStack{
                NavigationLink {
                    
                } label: {
                    Text("Color Wheel")
                }.padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("Background")).cornerRadius(15)

           
            }
            
        }
    }
}


struct ResizableTF : UIViewRepresentable {
   
    
    @Binding var height: CGFloat
    @StateObject var chatVM: GroupChatViewModel = GroupChatViewModel()
    @StateObject var personalChatVM: PersonalChatViewModel = PersonalChatViewModel()
    var isPersonalChat : Bool
    
    func makeCoordinator() -> Coordinator {
        return ResizableTF.Coordinator(parent1: self)
    }
    
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = true
        view.isScrollEnabled = true
        view.text = "message"
        view.font = .systemFont(ofSize: 18)
        view.textColor = .gray
        view.backgroundColor = UIColor(Color("Background"))
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async{
            self.height = uiView.contentSize.height
            if uiView.text != "" {
                if isPersonalChat{
                    uiView.text = personalChatVM.text
                    uiView.textColor = UIColor(FOREGROUNDCOLOR)
                }else{
                uiView.text = chatVM.text
                uiView.textColor = UIColor(Color("\(chatVM.currentChatColor)"))
                }
            }
        }
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent : ResizableTF
        
        init(parent1: ResizableTF){
            self.parent = parent1
        }
        
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            
            if self.parent.isPersonalChat{
                if self.parent.personalChatVM.text == ""{
                    textView.text = ""
                    textView.textColor = UIColor(FOREGROUNDCOLOR)
                }
            }else{
                if self.parent.chatVM.text == ""{
                    textView.text = ""
                    textView.textColor = UIColor(FOREGROUNDCOLOR)
                }
            }
            
           
            
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            
            if self.parent.isPersonalChat{
                if self.parent.personalChatVM.text == ""{
                    textView.text = "message"
                    textView.textColor = .gray
                }
            }else{
                if self.parent.chatVM.text == ""{
                    textView.text = "message"
                    textView.textColor = .gray
                }
            }
           
        }
        
        
        
        
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async{
                self.parent.height = textView.contentSize.height
                if self.parent.isPersonalChat{
                self.parent.personalChatVM.text = textView.text
                }else{
                self.parent.chatVM.text = textView.text
                }
            }
        }
    }
    
  
}



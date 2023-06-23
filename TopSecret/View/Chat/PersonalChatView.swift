import SwiftUI
import SDWebImageSwiftUI
import Foundation
import Firebase
import OmenTextField
import SwiftUIPullToRefresh
import MediaPicker
import AVFoundation
import AVKit




fileprivate var initialY : CGFloat? = nil

struct PersonalChatView : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var personalChatVM = PersonalChatViewModel()
    @State var showOverlay : Bool = false
    @State var selectedMessage: Message = Message()
    @State var showEditView: Bool = false
    @State var showReplyView: Bool = false
    @State var height: CGFloat = 20
    @State var editText: String = ""
    @State var keyboardHeight : CGFloat = 0
    @State var text = ""
    @State var focused: Bool = false
    @State var showAddContent: Bool = false
    @State var showAddEventView: Bool = false
    let notificationSender = PushNotificationSender()
    @Environment(\.scenePhase) var scenePhase
    @State private var scrollViewOffset = CGFloat.zero
    @State var canAddAnotherLine : Bool = true
    @State var chatID: String
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var reachedHalfway : Bool = false
    @State var isShowingMediaPicker : Bool = false
    @State var urls : [URL] = []
    @State var images: [UIImage] = []
    @State var videos: [URL] = []
    @State var isLoadingMedia : Bool = false
    @State var isLeavingChat: Bool = false
    
    
  
    
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
        
        for user in personalChatVM.chat.users ?? [] {
            if user.id ?? "" != userVM.user?.id ?? " "{
                return user
            }
        }
        
        return User()
    }
    
    func checkIfUserIsActive() -> Bool {
        if personalChatVM.chat.usersIdlingID.contains(self.getPersonalChatUser().id ?? "") {
            return true
        }else{
            return false
        }
    }
    
    
    func scrollToBottom(scrollViewProxy: ScrollViewProxy){
        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
    }
    
    
    func getChatColor(userID: String) -> String{
        var color = ""
        var nameColors = personalChatVM.chat.nameColors
        
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
    @State private var offset: CGFloat = 0

    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack{
                Color("Background")
                VStack{
                    HStack(alignment: .top){
                        //top bar
                        
                        
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                        
                        
                        
                        
                        
                        
                        Spacer()
                        
                        NavigationLink {
                            UserProfilePage(user: getPersonalChatUser())
                        } label: {
                            VStack{
                                WebImage(url: URL(string: getPersonalChatUser().profilePicture ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:50,height:50)
                                    .clipShape(Circle())
                                    .overlay{
                                        
                                        
                                        if  self.checkIfUserIsActive(){
                                            Circle().stroke(Color("AccentColor"), lineWidth: 3)
                                            
                                            
                                            
                                        }else{
                                            Circle().stroke(Color.gray, lineWidth: 3)
                                        }
                                        
                                        
                                    }
                                
                                Text("\(getPersonalChatUser().nickName ?? "")").bold().font(.headline)
                            }
                        }.foregroundColor(FOREGROUNDCOLOR)
                        
                        
                        Spacer()
                        
                        
                        
                        Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                        
                        
                    }.padding(.top,50).padding(.horizontal)
                    
                    
                    ZStack(alignment: .bottomTrailing){
                        Color("Background")
                        
                        ScrollViewReader{ scrollViewProxy in
                            RefreshableScrollView(action: {
                                await personalChatVM.loadMoreMessages(chatID: chatID)
                                
                                
                            }, progress: { state in
                                Image(systemName: "arrow.up")
                                
                            }) {
                                VStack(spacing: 0){
                                    if personalChatVM.isLoading{
                                        ProgressView()
                                    }
                                    ForEach(personalChatVM.messages.indices, id: \.self){ index in
                                        
                                        
                                        MessageCell(message: personalChatVM.messages[index], selectedMessage: $selectedMessage,
                                                    showOverlay: $showOverlay, personalChatVM: personalChatVM).disabled(isLeavingChat)
                                        
                                        
                                    }
                                    
                                    
                                    VStack{
                                        ForEach(personalChatVM.chat.usersTyping){ user in
                                            HStack{
                                                if user.id == userVM.user?.id ?? " "{
                                                    Text("You are typing").foregroundColor(Color("AccentColor")).bold()
                                                }else{
                                                    Text("\(user.nickName ?? "") is typing...").foregroundColor(Color("AccentColor")).bold()
                                                }
                                                Spacer()
                                            }.padding(5)
                                        }
                                    }
                                    HStack{Spacer()}.padding(0).id("Empty")
                                }.background(GeometryReader{ proxy -> Color in
                                    DispatchQueue.main.async{
                                        scrollViewOffset = -proxy.frame(in: .named("scroll")).origin.y
                                    }
                                    return Color.clear
                                    
                                }).padding(5).onReceive(personalChatVM.$scrollToBottom, perform: { _ in
                                    withAnimation(.easeOut(duration: 0.5)){
                                        
                                        self.scrollToBottom(scrollViewProxy: scrollViewProxy)
                                    }
                                }).padding(.bottom, UIScreen.main.bounds.height / 4).offset(y: -keyboardHeight)
                            }
                            
                            
                            
                        }.coordinateSpace(name: "scroll")
                        
                        
                        Button(action:{
                            personalChatVM.scrollToBottom += 1
                            
                        },label:{
                            ZStack{
                                Circle().frame(width: 30, height: 30).foregroundColor(Color("AccentColor"))
                                Image(systemName: "chevron.down").foregroundColor(FOREGROUNDCOLOR)
                            }
                        }).padding(10)
                        
                    }.edgesIgnoringSafeArea(.all)

                    
                    
                    
                    
                    Spacer()
                    
                    
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
                                OmenTextField("Send a text..",text: $personalChatVM.text, returnKeyType: .send , onCommit: {
                                        if showReplyView{
                                            personalChatVM.sendReplyTextMessage(text: personalChatVM.text, user: userVM.user ?? User(), nameColor: self.getChatColor(userID: userVM.user?.id ?? " "), repliedMessageID: selectedMessage.id, messageType: "repliedMessage", chatID: personalChatVM.chat.id)
                                            withAnimation{
                                                self.showReplyView.toggle()
                                            }
                                        }else{
                                            personalChatVM.sendTextMessage(text: personalChatVM.text, user: userVM.user ?? User(), timeStamp: Timestamp(), nameColor: self.getChatColor(userID: userVM.user?.id ?? " "), messageID: UUID().uuidString, messageType: personalChatVM.getLastMessage().userID == userVM.user?.id ?? " "  ? "followUpUserText" : "text", chatID: personalChatVM.chat.id)
                                        }
                                        
                                        
                                        if !personalChatVM.chat.usersIdlingID.contains(self.getPersonalChatUser().id ?? ""){
                                            self.notificationSender.sendPushNotification(to: self.getPersonalChatUser().fcmToken ?? " ", title: userVM.user?.nickName ?? " ", body: personalChatVM.text)
                                        }
                                        
                                    
                                        personalChatVM.text = ""
                                        personalChatVM.scrollToBottom += 1
                                    
                                
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
                                    if personalChatVM.sendingMedia{
                                        VStack{
                                            Text("Sending Media...").foregroundColor(FOREGROUNDCOLOR)
                                            VStack(alignment: .leading){
                                                if !images.isEmpty{
                                                    Text("\(personalChatVM.imagesSent) out of \(images.count) images sent").foregroundColor(Color.gray)
                                                }
                                                if !videos.isEmpty{
                                                    Text("\(personalChatVM.videosSent) out of \(videos.count) videos sent").foregroundColor(Color.gray)
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
                               
                                if !personalChatVM.sendingMedia {
                                    Spacer()
                                    Button(action:{
                                        //todo
                                        let dp = DispatchGroup()
                                        var finishedSendingImages = false
                                        var finishedSendingVideos = false
                                        if !images.isEmpty{
                                            personalChatVM.sendingMedia = true
                                            for image in images {
                                                dp.enter()
                                                personalChatVM.sendImageMessage(image: image, user: userVM.user ?? User()) { sentImage in
                                                        finishedSendingImages = true
                                                    personalChatVM.imagesSent += 1
                                                    dp.leave()
                                                }
                                            }
                                        }else{
                                            dp.enter()
                                            finishedSendingImages = true
                                            dp.leave()
                                        }
                                       
                                        if !videos.isEmpty{
                                            personalChatVM.sendingMedia = true
                                            for video in videos {
                                                dp.enter()
                                                personalChatVM.sendVideoMessage(videoUrl: video, user: userVM.user ?? User()) { sentVideo in
                                                        finishedSendingVideos = true
                                                    personalChatVM.videosSent += 1
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
                                                    personalChatVM.sendingMedia = false
                                                    personalChatVM.imagesSent = 0
                                                    personalChatVM.videosSent = 0
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
                    
                }.opacity(userVM.hideBackground ? 0.2 : 1).disabled(userVM.hideBackground).onTapGesture(perform: {
                    if userVM.hideBackground {
                        userVM.hideBackground.toggle()
                    }
                    if self.showAddContent{
                        self.showAddContent.toggle()
                    }
                    if self.showOverlay{
                        self.showOverlay.toggle()
                    }
                    if self.showEditView{
                        self.showEditView.toggle()
                    }
                }).overlay {
                    if self.showOverlay{
                        VStack{
                            VStack(alignment: .leading, spacing: 5){
                                HStack{
                                    if selectedMessage.userID == userVM.user?.id ?? " "{
                                        Text("Me").foregroundColor(Color("AccentColor"))
                                    }else{
                                        Text("\(selectedMessage.name ?? " ")").foregroundColor(Color.blue)
                                    }
                                    Spacer()
                                    Text("\(selectedMessage.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                                }
                                HStack{
                                    Text("\(selectedMessage.value ?? "")").foregroundColor(FOREGROUNDCOLOR).lineLimit(5)
                                    if selectedMessage.edited ?? false{
                                        Text("(edited)").foregroundColor(.gray).font(.footnote)
                                    }
                                    
                                    Spacer()
                                }
                                HStack{
                                    
                                    
                                    
                                    if (personalChatVM.chat.usersThatHaveSeenLastMessage?.contains(self.getPersonalChatUser().id ?? "") ?? false){
                                        HStack(alignment: .center){
                                            
                                            Image(systemName: "play").foregroundColor(Color("AccentColor")).font(.caption)
                                            Text("Read").foregroundColor(Color.gray).font(.subheadline)
                                            
                                            
                                        }
                                        
                                        
                                        
                                    }else{
                                        HStack(alignment: .center){
                                            
                                            
                                            Image(systemName: "play.fill").foregroundColor(Color("AccentColor")).font(.caption)
                                            
                                            Text("Delivered").foregroundColor(Color.gray).font(.subheadline)
                                            
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    Spacer()
                                }
                            }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color("Color")))
                            
                            if selectedMessage.userID == userVM.user?.id ?? "" {
                                VStack(alignment: .leading){
                                    Button(action:{
                                        withAnimation{
                                            self.showEditView.toggle()
                                            self.showOverlay.toggle()
                                            editText = self.selectedMessage.value ?? ""
                                            self.focused = true
                                        }
                                        
                                    },label:{
                                        HStack{
                                            Text("Edit")
                                            Spacer()
                                        }.foregroundColor(FOREGROUNDCOLOR)
                                    })
                                    Divider()
                                    Button(action:{
                                        withAnimation{
                                            self.showReplyView.toggle()
                                            self.showOverlay.toggle()
                                            userVM.hideBackground.toggle()
                                        }
                                        
                                    },label:{
                                        HStack{
                                            Text("Reply")
                                            Spacer()
                                        }
                                    }).foregroundColor(FOREGROUNDCOLOR)
                                    Divider()
                                    Button(action:{
                                        withAnimation{
                                            personalChatVM.deleteMessage(messageID: selectedMessage.id, chatID: personalChatVM.chat.id, user: userVM.user ?? User())
                                            self.showOverlay.toggle()
                                            userVM.hideBackground.toggle()
                                        }
                                        
                                        
                                    },label:{
                                        HStack{
                                            Text("Delete")
                                            Spacer()
                                        }
                                    }).foregroundColor(FOREGROUNDCOLOR)
                                    
                                }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color("Color")))
                            }else{
                                VStack{
                                    Button(action:{
                                        self.showReplyView.toggle()
                                        self.showOverlay.toggle()
                                        userVM.hideBackground.toggle()
                                    },label:{
                                        HStack{
                                            Text("Reply")
                                            Spacer()
                                        }
                                    }).foregroundColor(FOREGROUNDCOLOR)
                                }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color("Color")))
                                
                            }
                            
                            
                        }.frame(width: UIScreen.main.bounds.width-20)
                        
                    }
                    if showEditView{
                        VStack(alignment: .leading, spacing: 5){
                            HStack{
                                if selectedMessage.userID == userVM.user?.id ?? " "{
                                    Text("Me").foregroundColor(Color("AccentColor"))
                                }else{
                                    Text("\(selectedMessage.name ?? " ")").foregroundColor(Color.blue)
                                }
                                Spacer()
                                Text("\(selectedMessage.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                            }
                            
                            HStack{
                                TextField("\(selectedMessage.value ?? "")", text: $editText).padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                                
                                Button(action:{
                                    personalChatVM.editMessage(messageID: selectedMessage.id, chatID: personalChatVM.chat.id, text: editText)
                                    self.editText = ""
                                    self.showEditView.toggle()
                                    userVM.hideBackground.toggle()
                                },label:{
                                    Text("Send").padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                                }).disabled(self.editText == "")
                            }
                            
                            
                        }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color("Color"))).frame(width: UIScreen.main.bounds.width-20)
                    }
                }
                
                
                
                BottomSheetView(isOpen: $showAddContent, maxHeight: UIScreen.main.bounds.height / 3) {
                    ChatAddContent(showAddContentView: $showAddContent, showAddEventView: $showAddEventView)
                }
                
                
                
            }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).frame(width: geometry.size.width, height: geometry.size.height)
                .offset(x: self.offset)
                .opacity(Double(1 - abs(self.offset / geometry.size.width)))
                .simultaneousGesture(DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width > 30 && self.urls.isEmpty{
                            isLeavingChat = true
                            UIApplication.shared.windows.forEach { $0.endEditing(true)}
                            self.offset = gesture.translation.width
                        }
                        if abs(self.offset) > geometry.size.width / 3 {
                            if !reachedHalfway{
                                reachedHalfway = true
                                UIDevice.vibrate()
                            }
                        }else{
                            reachedHalfway = false
                        }
                        
                    }
                    .onEnded { gesture in
                        if reachedHalfway {
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            withAnimation{
                                self.offset = 0
                                isLeavingChat = false
                                reachedHalfway = false
                            }
                        }
                    }
                )
        }
       .onAppear{
           UIScrollView.appearance().keyboardDismissMode = .interactive

           personalChatVM.listenToChat(chatID: chatID)
           personalChatVM.fetchAllMessages(chatID: chatID, userID: USER_ID)
           personalChatVM.readLastMessage(chatID: chatID, userID: userVM.user?.id ?? " ")
           personalChatVM.openChat(userID: userVM.user?.id ?? " ", chatID: chatID)
            self.initKeyboardGuardian()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                personalChatVM.scrollToBottom += 1
            }
        }.onDisappear{
            personalChatVM.exitChat(userID: userVM.user?.id ?? " ", chatID: chatID)
        } .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                personalChatVM.openChat(userID: userVM.user?.id ?? " ", chatID: chatID)
            }else if newPhase == .background{
                personalChatVM.exitChat(userID: userVM.user?.id ?? " ", chatID: chatID)
            }
        }.onChange(of: urls) { newValue in
            if !newValue.isEmpty {
                // Create a dispatch group to wait for all downloads to finish
                isLoadingMedia = true
                let group = DispatchGroup()
                
               
                for url in urls {
                    
                    switch try! url.resourceValues(forKeys: [.contentTypeKey]).contentType! {
                        case let contentType where contentType.conforms(to: .image):
                            //if image
                            group.enter()
                            
                            // Create a URLSession data task for each URL
                            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if let error = error {
                                    print("Error downloading photo: \(error.localizedDescription)")
                                } else {
                                    if let data = data, let image = UIImage(data: data) {
                                        // Add the downloaded image to the array
                                        images.append(image)
                                    }
                                }
                                
                                group.leave()
                                
                            }
                            task.resume()
                        case let contentType where contentType.conforms(to: .audiovisualContent):
                            group.enter()
                            videos.append(url)
                            group.leave()
                        default:
                            group.enter()
                            print("error")
                            group.leave()
                    }
                    
                    
                    
                    
                }
                
                // Wait for all downloads to finish before continuing
                group.notify(queue: DispatchQueue.main) {
                    withAnimation{
                        isLoadingMedia = false
                    }
                }
                
                
                
                
            }
        }
        
        
    }
    
    
}




extension View {
    func endEditing(_ force: Bool = true) {
        UIApplication.shared.windows.forEach { $0.endEditing(force)}
    }
}

import SwiftUI
import SDWebImageSwiftUI
import Foundation
import Firebase
import OmenTextField
import SwiftUIPullToRefresh





fileprivate var initialY : CGFloat? = nil

struct PersonalChatView : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var personalChatVM: PersonalChatViewModel
    @StateObject var keyboardVM: KeyboardViewModel
    @State var openAddContent : Bool = false
    @State var showOverlay : Bool = false
    @State var selectedMessage: Message = Message()
    @State var showEditView: Bool = false
    @State var showReplyView: Bool = false
    @State var height: CGFloat = 20
    @State var editText: String = ""
    @State var keyboardHeight : CGFloat = 0
    @State var text = ""
    @State var focused: Bool = false
    let notificationSender = PushNotificationSender()
    @Environment(\.scenePhase) var scenePhase
    @State private var scrollViewOffset = CGFloat.zero

    @State var chatID: String
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    
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
        
        for user in personalChatVM.chat.users {
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
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local).onEnded { state in
            print("ended")
        }
    }
  
        
    var body: some View {
        
      
        ZStack{
            Color("Background")
            VStack{
                HStack(alignment: .top){
                    //top bar
                    
                    HStack{
                        
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                                
                                
                            }
                        })
                      
                    }
                   
                    .padding(.leading,10)
                    
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
                    
                    HStack{
                        
                        Button(action:{
                            personalChatVM.loadMoreMessages(chatID: chatID)
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                
                                Image(systemName: "phone").foregroundColor(FOREGROUNDCOLOR)
                                Spacer()
                                
                            }
                        })
                        
                   
                        
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                
                                Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR)
                                Spacer()
                                
                            }
                        })
                        
                       
                    }
                    
                    
              
                    .padding(.trailing,10)
                    
                }.padding(.top,50)
                
                
                ZStack(alignment: .bottomTrailing){
                    Color("Background")
                    
                    ScrollViewReader{ scrollViewProxy in
                    RefreshableScrollView(action: {
                        await personalChatVM.loadMoreMessages(chatID: chatID)
                        
                        
                    }, progress: { state in
                        if state == .loading{
                            ProgressView()
                        }
                        
                    }) {
                        LazyVStack(spacing: 0){
                            if personalChatVM.isLoading{
                                ProgressView()
                            }
                            ForEach(personalChatVM.messages.indices, id: \.self){ index in
                                
                                
                                MessageCell(message: personalChatVM.messages[index], selectedMessage: $selectedMessage,
                                            showOverlay: $showOverlay, personalChatVM: personalChatVM).onAppear{
                                    if index == 0{
                                        print("seen top")
                                    }
                                }
                                
                                
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
                        })
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
                    
                }.edgesIgnoringSafeArea(.all).simultaneousGesture(DragGesture().onChanged { _ in
                    UIApplication.shared.keyWindow?.endEditing(true)
                    print("drop keyboard")
                })
                
                
                
                
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
                    
                    HStack(alignment: .center){
                        
                        Button(action:{
                            self.openAddContent.toggle()
                        },label:{
                            ZStack{
                                Circle().frame(width:30, height:30).foregroundColor(Color("Background"))
                                Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                    
                        Spacer()
                        OmenTextField("",text: $personalChatVM.text).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                        Button(action:{
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

                        },label:{
                            Text("Send").padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                        }).disabled(!(personalChatVM.text != ""))
                    }.padding().padding(.bottom,10)
                      
                }.background(Color("Color")).offset(y: -self.keyboardHeight)
                
            }.opacity(userVM.hideBackground ? 0.2 : 1).disabled(userVM.hideBackground).onTapGesture(perform: {
                if userVM.hideBackground {
                    userVM.hideBackground.toggle()
                }
                if self.openAddContent{
                    self.openAddContent.toggle()
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
            
            
            
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{

            self.initKeyboardGuardian()
            personalChatVM.listenToChat(chatID: chatID)
            personalChatVM.fetchAllMessages(chatID: chatID, userID: userVM.user?.id ?? " ")
            personalChatVM.readLastMessage(chatID: chatID, userID: userVM.user?.id ?? " ")
            personalChatVM.openChat(userID: userVM.user?.id ?? " ", chatID: chatID)
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
        }
        
       
    }
    
    
}





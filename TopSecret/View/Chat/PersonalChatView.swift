import SwiftUI
import SDWebImageSwiftUI
import Foundation
import Firebase


struct PersonalChatView : View {
   
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var personalChatVM: PersonalChatViewModel
    @StateObject var keyboardVM: KeyboardViewModel
    @State var openAddContent : Bool = false
    @State var showMenu : Bool = false
    @State private var scrollViewOffset = CGFloat.zero
    @State var height: CGFloat = 20
    @State var keyboardHeight : CGFloat = 0
    var chatID: String
    
    func initKeyboardGuardian(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { data in
            let height1 = data.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            
            self.keyboardHeight = height1.cgRectValue.height - 20
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
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
    
    var body: some View {
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
                                        .overlay(Circle().stroke(personalChatVM.chat.usersIdlingID.contains(self.getPersonalChatUser().id ?? "") ? Color("AccentColor") : Color.gray, lineWidth: 3))
                    Text("\(getPersonalChatUser().nickName ?? "")").bold().font(.headline)
                        }
                    }.foregroundColor(FOREGROUNDCOLOR)

                    
                    Spacer()
                    
           
                        
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                    
                            Text("...").font(.title).foregroundColor(FOREGROUNDCOLOR)
                                Spacer()
                            
                        }
                    })
                    .padding(.trailing,10)
                    
                }.padding(.top,50)
             
                
                ZStack(alignment: .bottomTrailing){
                    
                    ScrollView{
                        ScrollViewReader { scrollViewProxy in
                            VStack(spacing: 0){
                                ForEach(personalChatVM.messages, id: \.id){ message in
                                    
                                    
                                    if message.messageType == "text"{
                                        MessageTextCell(showMenu: $showMenu, message: message, chatID: personalChatVM.chat.id).padding([.leading,.top],5)
                                    }else if message.messageType == "followUpUserText"{
                                        MessageFollowUpTextCell(showMenu: $showMenu, message: message, chatID: personalChatVM.chat.id).padding([.leading,.top],5)
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
                            }.padding(.bottom, self.keyboardHeight).background(GeometryReader{ proxy -> Color in
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
                     
                    }.coordinateSpace(name: "scroll").gesture(DragGesture().onChanged { _ in
                        self.keyboardHeight = 0
                        UIApplication.shared.windows.forEach { $0.endEditing(false) }
                    })
                    
                    Button(action:{
                        personalChatVM.scrollToBottom += 1
                        
                    },label:{
                        ZStack{
                            Circle().frame(width: 30, height: 30).foregroundColor(Color("AccentColor"))
                            Image(systemName: "chevron.down").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(10)
                }
               
                
                Spacer()
          
                VStack{
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
                        ResizableTF(height: $height, personalChatVM: personalChatVM, isPersonalChat: true).frame(height: self.height).cornerRadius(12)
                    Spacer()
                    Button(action:{
                        personalChatVM.sendTextMessage(text: personalChatVM.text, user: userVM.user ?? User(), timeStamp: Timestamp(), nameColor: self.getChatColor(userID: userVM.user?.id ?? " "), messageID: UUID().uuidString, messageType: personalChatVM.getLastMessage().userID == userVM.user?.id ?? " "  ? "followUpUserText" : "text", chatID: personalChatVM.chat.id, messageColor: personalChatVM.currentChatColor)
                        personalChatVM.text = ""
                        personalChatVM.scrollToBottom += 1


                    },label:{
                        Text("Send").padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                    }).disabled(!(self.personalChatVM.text != ""))
                }.padding().padding(.bottom,10)
                }.background(Color("Color")).offset(y: -self.keyboardHeight)
                
            }.opacity(self.openAddContent ? 0.2 : 1).disabled(self.openAddContent).onTapGesture(perform: {
                if self.openAddContent {
                    self.openAddContent.toggle()
                }
            })
            
            BottomSheetView(isOpen: $openAddContent, maxHeight: UIScreen.main.bounds.height / 3){
                ChatAddContentView(personalChatVM: personalChatVM)
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
        }.onTapGesture {
            if self.keyboardHeight != 0 {
                UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
            }
        }.onDisappear{
            personalChatVM.removeListeners()
            personalChatVM.exitChat(userID: userVM.user?.id ?? " ", chatID: chatID)
        }.onReceive(personalChatVM.$text) { newText in
            if newText != "" {
                personalChatVM.startTyping(userID: userVM.user?.id ?? " ", chatID: chatID)
            }else{
                personalChatVM.stopTyping(userID: userVM.user?.id ?? " ", chatID: chatID)
            }
        }
        
    }
}

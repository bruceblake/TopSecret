//
//  PersonalChatView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/7/22.
//

import SwiftUI
import Firebase

struct PersonalChatView: View {
    
    @State var value: CGFloat = 0
    @State var text = ""
    @State var infoScreen: Bool = false
    @State var isShowingPhotoPicker:Bool = false
    @State var showImageSendView : Bool = false
    @State var avatarImage = UIImage(named: "Icon")!
    @State var name: String = ""
    @State var replyToMessage: Bool = false
    @State var messageToReplyTo : Message = Message()
    @State var showMenu: Bool = false
    @State var isFocused: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var chatVM = ChatViewModel()
    @StateObject var messageVM = MessageViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @State var chat: ChatModel
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                VStack(spacing: 2){
                    HStack(alignment: .center){
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Back").foregroundColor(FOREGROUNDCOLOR)
                    }).padding(.leading)
                    
                    Spacer()
                    Text("\(name)").foregroundColor(FOREGROUNDCOLOR)
                     Spacer()
                }
                    Divider()
                }.padding(.top,50).background(Color("Color"))
                ScrollView(showsIndicators: false){
                    ScrollViewReader{ scrollViewProxy in
                        
                        VStack{
                            ForEach(messageVM.messages){ message in
                               
                                MessageCell(replyToMessage: $replyToMessage, messageToReplyTo: $messageToReplyTo, showMenu: $showMenu,message: message, chatID: chat.id)
                             
                            }
                            
                            HStack{Spacer()}.id("Empty")
                            
                        }.onReceive(messageVM.$scrollToBottom, perform: { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                            }
                        })
                        
                    }
                    
                    
                }
                
                
                VStack{
                    
                    Divider()
                    HStack{
                        
                        Button(action:{
                            self.isShowingPhotoPicker.toggle()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "photo.on.rectangle")
                            }
                        }).fullScreenCover(isPresented: $isShowingPhotoPicker, onDismiss: {
                            self.showImageSendView.toggle()
                        }, content: {
                            ImagePicker(avatarImage: $avatarImage, allowsEditing: false)
                            
                        })
                        
                        
                        TextField("message", text: $text).onChange(of: text, perform: { value in
                            if text == ""{
                                chatVM.stopTyping(userID: userVM.user?.id ?? "", chatID: chat.id, chatType: "personal")
                            }else{
                                chatVM.startTyping(userID: userVM.user?.id ?? "", chatID: chat.id, chatType: "personal")
                            }
                        }).padding(.vertical,10).padding(.leading,5).background(Color("Color")).cornerRadius(12).sheet(isPresented: $showImageSendView, content: {
                            ImageSendView(message: Message(dictionary: ["id":UUID().uuidString,"timeStamp":Timestamp(),"name":userVM.user?.nickName ?? "","profilePicture":userVM.user?.profilePicture ?? "","imageURL":"","messageType":"image"]), imageURL: avatarImage, chatID: chat.id, messageVM: messageVM)
                        })
                        
                        Button(action:{
                            
                            messageVM.sendPersonalChatTextMessage(text: text, user: userVM.user ?? User(),timeStamp: Timestamp(), nameColor: "red", messageID: UUID().uuidString, messageType: "text", chat: chat, chatType: "personal")
                            
                            
                            
                            text = ""
                            
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                                let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                                let height = value.height
                                self.value = height
                            }
                            
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                                
                                self.value = 0
                            }
                            
                        },label:{
                            Text("Send")
                        }).disabled(text == "")
                    }.padding()
                    
                    if replyToMessage{
                        ReplyOverlay(replyToMessage: $replyToMessage,message: messageToReplyTo, chatID: chat.id)
                    }
                    
                    
                }.padding(.bottom,10).background(Color("Background")).offset(y: -self.value)
                .animation(.spring())
                .onAppear{
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                        let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                        let height = value.height
                        self.value = height
                    }
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                        
                        self.value = 0
                    }
                }
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true) .onAppear{
            
            let id = userVM.user?.id ?? ""
            userVM.fetchUser(userID: id == chat.users[0] ? chat.users[1] : chat.users[0], completion: { user in
                self.name = user.nickName ?? ""
            })
            messageVM.readAllMessages(chatID: chat.id, userID: userVM.user?.id ?? "", chatType: "personal")
            messageVM.getPinnedMessage(chatID: chat.id)
            chatVM.openChat(userID: userVM.user?.id ?? "", chatID: chat.id, chatType: "personal")
            chatVM.getUsersIdlingList(chatID: chat.id)
            chatVM.getUsersTypingList(chatID: chat.id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                messageVM.scrollToBottom += 1
            }
        }
    }
}

//struct PersonalChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonalChatView()
//    }
//}

//
//  ChatView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM : UserViewModel
    
    @StateObject var chatVM = ChatViewModel()
    @StateObject var messageVM = MessageViewModel()
    @StateObject var groupVM = GroupViewModel()
    @StateObject var imagePickerVM = ImagePickerViewModel()
    
    @State var value: CGFloat = 0
    @State var text = ""
    @State var infoScreen: Bool = false
    @State var isShowingPhotoPicker:Bool = false
    @State var showImageSendView : Bool = false
    @State var avatarImage = UIImage(named: "Icon")!
    @State var replyToMessage: Bool = false
    @State var editMessage: Bool = false
    @State var currentMessage : Message = Message()
    @State var showMenu: Bool = false
    @State var userIDList: [String] = []
    @State var images : [UIImage] = []
    var columns3Fixed: [GridItem] = [
        GridItem(.fixed(100), spacing: 10),
        GridItem(.fixed(100), spacing: 10),
        GridItem(.fixed(100), spacing: 10)
    ]
    
    var uid: String
    @State var chat: ChatModel
    
    
    
    func getColor(userID: String, groupChat: ChatModel) -> String{
        var ans = ""
        for maps in groupChat.nameColors ?? []{
            for key in maps.keys{
                if key == userID{
                    ans = maps[userID] ?? ""
                }
            }
        }
        print("user: \(userID) : \(ans)")
        return ans
    }
    
    
    var body: some View {
        
        
        
        
        ZStack(alignment: .top){
            Color("Background")
            
            VStack{
                
               
                ScrollView(showsIndicators: false){
                    ScrollViewReader{ scrollViewProxy in
                        
                      
                        VStack{
                            
                           
                           
                            ForEach(messageVM.messages){ message in
                                MessageCell(replyToMessage: $replyToMessage, messageToReplyTo: $currentMessage, showMenu: $showMenu,message: message, chatID: chat.id).padding(.horizontal,10)
                            }
                            
                            HStack{Spacer()}.padding(0).id("Empty")
                            
                        }.padding(.top,200).padding(.bottom,30).onReceive(messageVM.$scrollToBottom, perform: { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                            }
                        }).navigationBarHidden(true)
                        
                    }
                    
                    
                }
                 
               
                
                VStack{
         
                    
                    Divider()
            
                    
                    VStack(spacing: 0){
                    
                    HStack{
                        Button(action:{
                            
                            
                            imagePickerVM.openImagePicker()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: imagePickerVM.showImagePicker ? "xmark" :  "photo.on.rectangle")
                            }
                        })
                        
                        
                        CustomChatTextField(text: $text, isShowingPhotoPicker: $isShowingPhotoPicker, avatarImage: $avatarImage, sendAction : {
                            messageVM.sendGroupChatTextMessage(text: text, user: userVM.user ?? User(), timeStamp: Timestamp(), nameColor: chatVM.colors[chat.users.firstIndex(of: uid) ?? 0], messageID: UUID().uuidString, messageType: "text", chat: chat, chatType: "groupChat")
                        }, textChange: {
                            
                           
                            if text == ""{
                                chatVM.stopTyping(userID: uid, chatID: chat.id, chatType: "groupChat")
                            }else{
                                chatVM.startTyping(userID: uid, chatID: chat.id, chatType: "groupChat")
                            }
                            
                        }, editingChange: {
                            if imagePickerVM.showImagePicker{
                                withAnimation{imagePickerVM.showImagePicker.toggle()}
                            }
                        })
                        
                       
                            
                            .sheet(isPresented: $showImageSendView, content: {
                            ImageSendView(message: Message(dictionary: ["id":UUID().uuidString,"nameColor":chatVM.colors[chat.users.firstIndex(of: uid) ?? 0],"timeStamp":Timestamp(),"name":userVM.user?.nickName ?? "","profilePicture":userVM.user?.profilePicture ?? "","messageType":"image"]), imageURL: avatarImage, chatID: chat.id, messageVM: messageVM)
                        }).fullScreenCover(isPresented: $isShowingPhotoPicker, onDismiss: {
                            self.showImageSendView.toggle()
                        }, content: {
                            ImagePicker(avatarImage: $avatarImage, images: $images, allowsEditing: false)
                        })

                    }.padding(.leading,5)
                    
                    ScrollView{
                        VStack{
                            //Images
                            LazyVGrid(
                                   columns: columns3Fixed,
                                   alignment: .center,
                                   spacing: 10,
                                   pinnedViews: []
                               ) {
                                  
                                   ForEach(imagePickerVM.fetchedPhotos){ photo in
                                     
                                       ThumbnailView(photo: photo).onTapGesture {
                                           imagePickerVM.extractPreviewData(asset: photo.asset)
                                           imagePickerVM.showPreview.toggle()
                                       }
                                
                                       
                                      
                                       
                                       
                                   }
                                  
                               }
                            
                           
                            
                        
                            if imagePickerVM.libraryStatus == .denied || imagePickerVM.libraryStatus == .limited {
                                VStack(spacing: 10){
                                    Text(imagePickerVM.libraryStatus == .denied ? "Allow Access for Photos" : "Select More Photos").foregroundColor(.gray)
                                         
                                         Button(action:{
                                             UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                                    },label:{
                                        Text(imagePickerVM.libraryStatus == .denied ?  "Allow Acces" : "Select More").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).padding(.vertical,10).padding(.horizontal).background(Color("AccentColor")).cornerRadius(5)
                                    })
                                }.frame(width: 150)
                            }
                        }
                    }.frame(height: imagePickerVM.showImagePicker ? 150 : 0).background(Color("Color")).opacity(imagePickerVM.showImagePicker ? 1 : 0)
                    
                        
                }
                        
                        
                   
                    
                }.padding(.bottom,10).background(Color("Background")).offset(y: -self.value).navigationBarHidden(true)
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
            
            VStack(){
                VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Back")
                    }).padding([.leading,.bottom],10)
                    Spacer()
                    NavigationLink(destination: GroupHomeScreenView(group: chatVM.group), label: {
                        VStack{
                            WebImage(url: URL(string: chatVM.group.groupProfileImage ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:45,height:45)
                                .clipShape(Circle())
                            Text("\(chat.name ?? "")").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Button(action:{
                        
                    },label:{
                        Text("Info")
                    }).padding([.trailing,.bottom],10)
                }
                    
                  
                }
                
                ScrollView(.horizontal){
                    HStack(spacing: 0){
                        ForEach(chatVM.userList){ user in
                            
                            NavigationLink(destination: UserProfilePage(user: user, isCurrentUser: false), label:{
                                WebImage(url: URL(string: user.profilePicture ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:40,height:40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(chat.usersIdling.contains(user.id ?? "") ? Color(getColor(userID: user.id ?? "", groupChat: chat)) : Color.gray,lineWidth: 2))
                            }).padding([.leading,.bottom],7).padding(.top,5)
                            
                         

                              
                               
                        }
                    }
                   
                 
                }
            
                Divider()
            }.padding(.top,40).background(Color("Background"))
         
            
         
         
            
            if replyToMessage{
                GeometryReader{ _ in
                    ReplyOverlay(replyToMessage: $replyToMessage, message: currentMessage, chatID: chat.id)
                }.padding(.horizontal,40).padding(.top,350).background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all)
            }
            
            if editMessage{
                GeometryReader{ _ in
                    
                    
                    EditMessageOverlay(message: currentMessage, chatID: chat.id, editMessage: $editMessage)
                }.padding(.horizontal,40).padding(.top,350).background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all)
                
            }
            
            
            
            if showMenu {
                
                GeometryReader { geometry in
                    
                    VStack{
                        //message
                        
                        VStack(alignment: .leading){
                            HStack{
                                WebImage(url: URL(string: currentMessage.profilePicture ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:50,height:50)
                                    .clipShape(Circle())
                                    .padding([.trailing,.top,.bottom],7)
                                
                                VStack(alignment: .leading, spacing: 5){
                                    HStack{
                                        Text("\(currentMessage.name ?? "")").foregroundColor(Color(currentMessage.nameColor ?? ""))
                                        
                                        Spacer()
                                        
                                        Text("\(currentMessage.timeStamp?.dateValue() ?? Date(), style: .time)")
                                    }
                                  
                                    
                                    HStack{
                                        Text("\(currentMessage.messageValue ?? "")")
                                        if currentMessage.edited ?? false{
                                            Text("(edited)").foregroundColor(.gray).font(.footnote)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                    
                                
                                
                                
                              
                                
                            }
                        }.padding(.horizontal).background(Color("Color")).cornerRadius(16)
                        
                        VStack{
                            
                            if currentMessage.name == userVM.user?.nickName{
                            Button(action:{
                                withAnimation(.easeIn(duration: 0.2)){
                                    self.showMenu.toggle()
                                }
                                
                                messageVM.deleteMessage(chatID: chat.id, message: currentMessage)
                            },label:{
                                Text("Delete").foregroundColor(FOREGROUNDCOLOR)
                            }).padding(10)
                            
                            Divider()
                            }
                            
                            Button(action:{
                                withAnimation(.easeIn(duration: 0.2)){
                                self.showMenu.toggle()
                            }
                            
                                
                                messageVM.pinMessage(chatID: chat.id, messageID: currentMessage.id, userID: userVM.user?.id ?? "")
                            },label:{
                                Text("Pin").foregroundColor(FOREGROUNDCOLOR)
                            }).padding(10)
                            
                            Divider()
                            
                            if currentMessage.name == userVM.user?.nickName{

                            Button(action:{
                                //EDIT MESSAGE
                                withAnimation(.easeIn(duration: 0.2)){
                                    self.showMenu.toggle()
                                    self.editMessage.toggle()
                                }
                                
                          
                            },label:{
                                Text("Edit").foregroundColor(FOREGROUNDCOLOR)
                            }).padding(10)
                            
                            Divider()
                            }
                            Button(action:{
                                withAnimation(.easeIn(duration: 0.2)){
                                    self.showMenu.toggle()
                                    replyToMessage.toggle()
                                }
                                
                            },label:{
                                Text("Reply").foregroundColor(FOREGROUNDCOLOR)
                            }).padding(10)
                            
                        }.background(Color("Color")).cornerRadius(12)
                        
                    }
                    
                    
                }.padding(.horizontal,60).padding(.top,300).background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all).onTapGesture {
                    withAnimation(.easeIn(duration: 1)){
                        self.showMenu.toggle()
                    }
                }
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarTitle("").navigationBarHidden(true).navigationBarBackButtonHidden(true)
                
        .onAppear{
            imagePickerVM.setUp()

            messageVM.readAllMessages(chatID: chat.id, userID: userVM.user?.id ?? "", chatType: "groupChat")
            messageVM.getPinnedMessage(chatID: chat.id)
            chatVM.getGroup(groupID: chat.groupID ?? " ")
            chatVM.openChat(userID: uid, chatID: chat.id, chatType: "groupChat")
            chatVM.getUsers(usersID: chat.users)
            chatVM.getUsersIdlingList(chatID: chat.id)
            chatVM.getUsersTypingList(chatID: chat.id)
            
            
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                messageVM.scrollToBottom += 1
                chatVM.getUsersIDList(users: chatVM.usersIdlingList) { users in
                    self.userIDList = users
                }
            }
            
        }.onDisappear{
            chatVM.exitChat(userID: uid, chatID: chat.id, chatType: "groupChat")
        }.onReceive(userVM.$groupChats) { i in
            for groupChat in i {
                if chat.id == groupChat.id {
                    self.chat = groupChat
                }
            }
            
            
        }
    }
}

struct ThumbnailView: View {
    
    var photo: AssetModel
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 115, height: 115)

            if photo.asset.mediaType == .video{
                Image(systemName: "video.fill").font(.title2).foregroundColor(FOREGROUNDCOLOR)
            }
        }
    }
}


struct CustomChatTextField : View {
    
    
    

    
    
    @State var showSend : Bool = false
    @State var value: CGFloat = 0
    @Binding var text : String
    @Binding var isShowingPhotoPicker : Bool
    @Binding var avatarImage : UIImage
    @State var showImageSendView : Bool = false


    var sendAction : () -> (Void)
    var textChange : () -> (Void)
    var editingChange: () -> (Void)
    
    var body: some View {
        HStack{
         
            
            TextField("Message", text: $text).onTapGesture {
                editingChange()
            }.onChange(of: text) { message in
                showSend = message != ""
                textChange()
            }.padding(.leading,5)
            
            Spacer()
            
            if !showSend{
                HStack{
                    
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Image("Poll Icon").resizable().frame(width: 30, height: 30)
                        }
                    }).padding(.leading)
                    
                 
                }
            }else{
                Button(action:{
                    
                    sendAction()
                    
                    
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
                }).disabled(text == "").frame(width: 40, height: 40).padding(.trailing,5)
            }
        }.padding(.vertical,5).background(Color("Color")).cornerRadius(12).padding()
    }
}



struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(uid: "", chat: ChatModel())
    }
}





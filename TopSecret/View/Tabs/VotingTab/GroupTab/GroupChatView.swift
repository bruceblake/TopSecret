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
import NIOSSL
import Firebase


struct GroupChatView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var groupVM: SelectedGroupViewModel
    @StateObject var chatVM = GroupChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    var userID: String
    var groupID: String
    var chatID: String
    @State var height: CGFloat = 20
    @State var keyboardHeight : CGFloat = 0
    @State var showMenu : Bool = false
    @State var openAddContent : Bool = false
    
    func initKeyboardGuardian(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { data in
            let height1 = data.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            
            self.keyboardHeight = height1.cgRectValue.height - 20
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    func scrollToBottom(scrollViewProxy: ScrollViewProxy){
        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                //Top Bar
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    
                    
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "info")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    
                    Text("\(groupVM.group?.groupName ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.largeTitle)
                    
                    Spacer()
                    
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "video.fill")
                                .font(.headline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "gear")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                }.padding(.horizontal).padding(.top,40)
                
                
                //Active Users
                VStack{
                ScrollView(.horizontal){
                    HStack(spacing: 0){
                        ForEach(chatVM.groupChat?.users ?? [], id: \.id){ user in
                            
                            NavigationLink(destination: UserProfilePage(user: user), label:{
                                
                                VStack(spacing: 5){
                                    WebImage(url: URL(string: user.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(chatVM.usersIdling.contains(user) ? Color(chatVM.getColor(userID: user.id ?? "", groupChat: chatVM.groupChat ?? ChatModel())) : Color.gray,lineWidth: 2))
                                    
                                    Text("\(user.nickName ?? "TOP SECRET USER")").foregroundColor(FOREGROUNDCOLOR)
                                }
                                
                                
                                
                            }).padding(.leading,5).padding(.top,5)
                            
                            
                            
                            
                            
                        }
                    }
                    
                    
                }
                Divider()
            }
                ZStack(alignment: .bottomTrailing){
                    
                    ScrollView{
                        ScrollViewReader { scrollViewProxy in
                                VStack{
                                ForEach(chatVM.messages, id: \.id){ message in
                                    if message.messageType == "text"{
                                        MessageTextCell(showMenu: $showMenu, message: message, chatID: chatID)
                                    }else if message.messageType == "followUpUserText"{
                                        MessageFollowUpTextCell(showMenu: $showMenu, message: message, chatID: chatID)
                                    }
                                }
                                    HStack{Spacer()}.padding(0).id("Empty")
                                }.padding(5).onReceive(chatVM.$scrollToBottom, perform: { _ in
                                    withAnimation(.easeOut(duration: 0.5)){
                                        
                                        self.scrollToBottom(scrollViewProxy: scrollViewProxy)
                                    }
                                })
                                
                            
                            
                        }
                     
                    }
                    
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
                        ResizableTF(height: $height, chatVM: chatVM).frame(height: self.height).cornerRadius(12)
                    Spacer()
                    Button(action:{
                        chatVM.sendTextMessage(text: chatVM.text, user: userVM.user ?? User(), timeStamp: Timestamp(), nameColor: "green", messageID: UUID().uuidString, messageType: chatVM.readLastMessage().userID == userVM.user?.id ?? " "  ? "followUpUserText" : "text", chatID: chatID, groupID: groupID, messageColor: chatVM.currentChatColor)
                        chatVM.text = ""
                        chatVM.scrollToBottom += 1

                    },label:{
                        Text("Send").disabled(!(self.chatVM.text != "")).padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                    })
                }.padding().padding(.bottom,10)
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
                print("fetched messages!")
            }
            chatVM.readAllMessages(chatID: chatID, groupID: groupID)
            chatVM.openChat(userID: userID, chatID: chatID, groupID: groupID)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                chatVM.scrollToBottom += 1
                }
        }
            .onDisappear{
            chatVM.exitChat(userID: userID, chatID: chatID, groupID: groupID)
        }
            .onTapGesture {
                if self.keyboardHeight != 0 {
                    
            UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
                }
        }
    }
}

struct ChatAddContentView : View {
    
    @StateObject var chatVM: GroupChatViewModel
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        ZStack(alignment: .top){
            Color("Color")
            VStack{
                Button(action:{
                    chatVM.currentChatColor =  chatVM.currentChatColor == "green" ? "red" : "green"
                },label:{
                    HStack{
                        Text("Text Color: ")
                        Text("\(chatVM.currentChatColor.uppercased())").foregroundColor(Color("\(chatVM.currentChatColor)"))
                    }
                }).padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("Background")).cornerRadius(15)
            }
            
        }
    }
}


struct ResizableTF : UIViewRepresentable {
   
    
    @Binding var height: CGFloat
    @StateObject var chatVM: GroupChatViewModel
    
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
                uiView.text = chatVM.text
                uiView.textColor = UIColor(Color("\(chatVM.currentChatColor)"))
            }
        }
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent : ResizableTF
        
        init(parent1: ResizableTF){
            self.parent = parent1
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if self.parent.chatVM.text == ""{
                textView.text = ""
                textView.textColor = UIColor(Color("\(parent.chatVM.currentChatColor)"))
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if self.parent.chatVM.text == ""{
                textView.text = "message"
                textView.textColor = .gray
            }
        }
        
        
        
        
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async{
                self.parent.height = textView.contentSize.height
                self.parent.chatVM.text = textView.text
            }
        }
    }
    
  
}

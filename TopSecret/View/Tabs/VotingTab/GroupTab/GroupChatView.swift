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
//import NIOSSL
import Firebase

struct GroupChatView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var groupVM: SelectedGroupViewModel
    @StateObject var chatVM = GroupChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    var userID: String
    @State var height: CGFloat = 20
    @State var keyboardHeight : CGFloat = 0
    @State var showMenu : Bool = false
    @State var openAddContent : Bool = false
    @State private var scrollViewOffset = CGFloat.zero

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
    
    func scrollToBottom(scrollViewProxy: ScrollViewProxy){
        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
    }
    
    
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                //Top Bar
                
            
                
                //Active Users
                VStack{
                ScrollView(.horizontal){
                    HStack(spacing: 5){
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
                    
                    
                }.padding(5)
                Divider()
            }
                ZStack(alignment: .bottomTrailing){
                    
                    ScrollView{
                        ScrollViewReader { scrollViewProxy in
                            VStack(spacing: 0){
                                ForEach(chatVM.messages, id: \.id){ message in
                                    if message.type == "text"{
                                        MessageTextCell(message: message, chatID: groupVM.group.chatID ?? " ")
                                    }else if message.type == "followUpUserText"{
                                        MessageFollowUpTextCell(message: message, chatID: groupVM.group.chatID ?? " ")
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
                        ResizableTF(height: $height, chatVM: chatVM, isPersonalChat: false).frame(height: self.height).cornerRadius(12)
                    Spacer()
                    Button(action:{
                        chatVM.sendTextMessage(text: chatVM.text, user: userVM.user ?? User(), timeStamp: Timestamp(), nameColor: "green", messageID: UUID().uuidString, messageType: chatVM.readLastMessage().userID == userVM.user?.id ?? " "  ? "followUpUserText" : "text",chatID: groupVM.group.chatID ?? " ", groupID: groupVM.group.id, messageColor: chatVM.currentChatColor)
                        chatVM.text = ""
                        chatVM.scrollToBottom += 1
                        

                    },label:{
                        Text("Send").padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                    }).disabled(!(self.chatVM.text != ""))
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
                    chatVM.listenToChat(chatID: groupVM.group.chatID ?? " ", groupID: groupVM.group.id) { completed in
                    print("fetched messages!")
                }
                chatVM.readAllMessages(chatID: groupVM.group.chatID ?? " ", groupID: groupVM.group.id)
                chatVM.openChat(userID: userID ,chatID: groupVM.group.chatID ?? " ", groupID: groupVM.group.id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                chatVM.scrollToBottom += 1
     
                }
        }
            .onDisappear{
            chatVM.exitChat(userID: userID, chatID: groupVM.group.chatID ?? " ", groupID: groupVM.group.id)
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



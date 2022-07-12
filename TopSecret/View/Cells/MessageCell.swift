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
    @StateObject var messageVM = MessageViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @Binding var replyToMessage: Bool
    @Binding var messageToReplyTo: Message
    @Binding var showMenu : Bool
    var message: Message
    var chatID: String
    
 
    
    var body: some View {
        
        if message.messageType == "text"{
               
            ZStack{
                Color("Background")
                VStack(alignment: .leading, spacing: 0){
                    
                    HStack(spacing: 3){
                            Image(systemName: "chevron.left").foregroundColor(Color("\(message.nameColor ?? "")")).frame(width:2).padding(.horizontal,5)
                            Text("\(message.name ?? "")").foregroundColor(Color("\(message.nameColor ?? "")"))
                            Spacer()
                        }.padding(.top,3)
                    
                    
                    
                    HStack(alignment: .center){
                        HStack{
                            
                            HStack(spacing: 3){
                                Rectangle().foregroundColor(Color("\(message.nameColor ?? "")")).frame(width:2).padding(.horizontal,5)

                                HStack{
                                    Text("\(message.messageValue ?? "")").lineLimit(5)
                                    if message.edited ?? false{
                                        Text("(edited)").foregroundColor(.gray).font(.footnote)
                                    }
                                }
                            }
                          
                        }
               
                    
                        Spacer()
                        Text("\(message.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                    

                    }.padding(.top,5)
                
            }
        
      
                
                
            }.onTapGesture{}  .onLongPressGesture {
                UIDevice.vibrate()

                withAnimation(.easeOut(duration: 0.2)){
                    self.showMenu.toggle()

                }
                    self.messageToReplyTo = message
                
                }
        
        }
        else if message.messageType == "followUpUserText"{
            ZStack{
                Color("Background")
                VStack(alignment: .leading, spacing: 0){
                    
                    
                    
                    
                    HStack(alignment: .center){
                        HStack(spacing: 3){
                            
                            Rectangle().foregroundColor(Color("\(message.nameColor ?? "")")).frame(width:2).padding(.horizontal,5)
                            
                            HStack{
                                Text("\(message.messageValue ?? "")").lineLimit(5)
                                if message.edited ?? false{
                                    Text("(edited)").foregroundColor(.gray).font(.footnote)
                                }
                            }
                        }
               
                    
                        Spacer()
                        Text("\(message.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                    

                }
                
            }
        
       
                
                
            }.onTapGesture{}.onLongPressGesture {
                UIDevice.vibrate()

                withAnimation(.easeOut(duration: 0.2)){
                    self.showMenu.toggle()

                }
                    self.messageToReplyTo = message
                
                }
        }
        else if message.messageType == "image"{
            ZStack{
                Color("Background")
                VStack(spacing: 0){
                    HStack{
                        Text("\(message.name ?? "")").foregroundColor(Color(message.nameColor ?? ""))
                        Spacer()
                    }
                    
                    HStack(alignment: .center){
                        HStack{
                            Rectangle().foregroundColor(Color("\(message.nameColor ?? "")")).frame(width:2).padding(.leading,2)
                            
                           
                            
                            WebImage(url: URL(string: message.messageValue ?? ""))
                                .resizable().scaledToFit().frame(width:100, height: 100)
                            
                        }
               
                    
                        Spacer()
                        Text("\(message.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                    

                }
                
            }
        
       
                
            }.onTapGesture{}.onLongPressGesture {
                
                withAnimation(.easeOut(duration: 0.2)){
                    self.showMenu.toggle()

                }
                    self.messageToReplyTo = message
                
                }
                    
            }
            
        else if message.messageType == "deletedMessage"{
            HStack(spacing: 5){
                Text("\(message.name ?? "")").foregroundColor(Color(message.nameColor ?? ""))
                Text("deleted a chat!").foregroundColor(.gray)
            }
        }else if message.messageType == "replyMessage"{
                HStack{
                    VStack(spacing: 5){
                      
                       
                        
                        HStack{
                            VStack(spacing: 0){
                                Text("\(message.repliedMessageName ?? "")").foregroundColor(Color("\(message.repliedMessageNameColor ?? "")")).padding(1)
                                HStack{
                                    Rectangle().foregroundColor(Color("\(message.nameColor ?? "")")).frame(width:2).padding(.leading,2)
                                    Spacer()
                                }
                               
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 7){
                                
                                Spacer()
                                
                                HStack{
                                    Image(systemName: "arrowshape.turn.up.right")
                                    ReplyMessageCell(message: message, chatID: chatID).frame(width:250, height: 50)
                                    
                                }
                                        HStack{
                                            Text("\(message.messageValue ?? "")").lineLimit(5)
                                            if message.edited ?? false{
                                                Text("(edited)").foregroundColor(.gray).font(.footnote)
                                            }
                                            
                                            Spacer()
                                        }
                            }
                        }
    
                    }
                    
                    HStack{
                        Spacer()
                        Text("\(message.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                    
                    }

                }
                    
        }
            
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
}

//struct MessageCell_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageCell()
//    }
//}

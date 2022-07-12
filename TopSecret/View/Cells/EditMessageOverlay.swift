//
//  EditMessageOverlay.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/29/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditMessageOverlay: View {
    
    var message: Message
    var chatID: String
    var groupID: String
    @State var text: String = ""
    @StateObject var messageVM = MessageViewModel()
    @Binding var editMessage: Bool
    var body: some View {
        VStack{
            VStack(alignment: .leading){
                HStack{
                    WebImage(url: URL(string: message.profilePicture ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:50,height:50)
                        .clipShape(Circle())
                        .padding([.trailing,.top,.bottom],5)
                    
                    VStack(alignment: .leading, spacing: 5){
                        HStack{
                            Text("\(message.name ?? "")").foregroundColor(Color(message.nameColor ?? ""))
                            
                            Spacer()
                            
                            Text("\(message.timeStamp?.dateValue() ?? Date(), style: .time)")
                        }
                      
                        
                        HStack{
                            Text("\(message.messageValue ?? "")")
                            if message.edited ?? false{
                                Text("(edited)").foregroundColor(.gray).font(.footnote)
                            }
                        }
                    }
                    
                    Spacer()
                    
                        
                    
                    
                    
                  
                    
                }
            }.padding(.horizontal).background(Color("Color")).cornerRadius(16)
            
            VStack{
            TextField("\(message.messageValue ?? "")", text: $text)
                HStack{
                    
                    Spacer() 
                    Button(action:{
                      
                  
                        messageVM.editMessage(messageID: message.id, chatID: chatID, text: text, groupID: groupID)
                      
                        self.editMessage.toggle()
                    },label:{
                        Text("Send")
                    })
                    
                    Spacer()
                    
                    Button(action:{
                        self.editMessage.toggle()
                    },label:{
                        Image(systemName: "x.circle")
                    })

                }
            }.padding().background(Color("Color")).cornerRadius(16)
            
            
        }.padding()
    
    }
}

//struct EditMessageOverlay_Previews: PreviewProvider {
//    static var previews: some View {
//        EditMessageOverlay()
//    }
//}

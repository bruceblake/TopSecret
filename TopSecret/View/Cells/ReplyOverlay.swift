//
//  ReplyOverlay.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/25/22.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ReplyOverlay: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var messageVM = MessageViewModel()
    @State var text: String = ""
    @State var color = "dildo"
    
    @Binding var replyToMessage: Bool
    
    var message: Message
    var chatID: String
    var groupID: String

    func getColor(chatID: String, userID: String, completion: @escaping (String) -> ()) -> (){
        
        COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            let nameColors = snapshot?.get("nameColors") as? [[String:String]] ?? [["":""]]
            
            for maps in nameColors {
                for key in maps.keys {
                    if key == userID{
                        return completion(maps[key] ?? "")
                    }
             
                }
            }
            
        }
    }
    
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
                TextField("Reply", text: $text)
                
                HStack{
                    Spacer()
                Button(action:{
                    self.getColor(chatID: chatID, userID: userVM.user?.id ?? "") { name in
                        self.color = name
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        messageVM.sendReplyMessage(replyMessage: Message(dictionary:
                                        ["id":UUID().uuidString,
                                         "name":message.name,
                                         "profilePicture":message.profilePicture,
                                         "messageValue":message.messageValue,
                                         "messageTimeStamp":message.messageTimeStamp,
                                         "nameColor":message.nameColor,
                                         "repliedMessageNameColor": color,
                                         "repliedMessageValue":text,
                                         "repliedMessageName":userVM.user?.nickName ?? "",
                                         "repliedMessageProfilePicture":userVM.user?.profilePicture ?? "",
                                         "repliedMessageTimestamp":Timestamp(),"timeStamp":Timestamp()]), chatID: chatID, groupID: groupID)
                    }
                  
                    self.replyToMessage.toggle()
                },label:{
                    Text("Send")
                })
                    
                    Spacer()
                
                    Button(action:{
                        self.replyToMessage.toggle()
                    },label:{
                        Image(systemName: "x.circle")
                    })

                }
                
            }.padding().background(Color("Color")).cornerRadius(16)
            
            
        }.padding()
        
    }
}

//struct ReplyOverlay_Previews: PreviewProvider {
//    static var previews: some View {
//        ReplyOverlay()
//    }
//}





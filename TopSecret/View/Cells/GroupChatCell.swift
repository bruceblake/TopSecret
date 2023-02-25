//
//  GroupChatCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/26/21.
//

import SwiftUI

struct GroupChatCell: View {
    
    @StateObject var chatVM = ChatViewModel()
    var message: Message
    var chat: ChatModel
    var body: some View {
        
        VStack{
            HStack{
                Text("Groupchat")
                    .fontWeight(.bold)
            }
            
            
            
            HStack{
                Text("\(message.name ?? "") : \(message.value ?? "")")
                
            }
            HStack{
                Spacer()
            }
            
            HStack{
                HStack(spacing: -10){
                    
                    if chatVM.usersIdlingList.count > 0{
                        
                        ForEach(Array(zip(chatVM.usersIdlingList.indices,chatVM.usersIdlingList)),id: \.1){ index, user in
                            if index < 4{
                                GroupUsersProfilePictureCell(image: user.profilePicture!).padding(.bottom)
                                
                            }
                            
                        }
                        
                    }
                    
                    Spacer()
                    
                    
                }.padding(.leading)
                
                if chatVM.usersIdlingList.count > 4 {
                    Text(" +\(chatVM.usersIdlingList.count - 4) members active")
                }
                
            }.padding(.bottom,40)
            
            
            
            
        }.background(Color("Color")).cornerRadius(12).padding().shadow(color: Color.black, radius: 5)
        
    }
}

struct GroupChatCell_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatCell(message: Message(), chat: ChatModel()).colorScheme(.dark)
    }
}

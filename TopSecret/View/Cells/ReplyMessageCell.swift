//
//  ReplyMessageCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/25/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReplyMessageCell: View {
    
    var message: Message
    @StateObject var messageVM = MessageViewModel()
    @EnvironmentObject var userVM : UserViewModel
    var chatID : String
    
    var body: some View {
        
        VStack(spacing: 0){
            HStack{
                Text("\(message.name ?? "")").foregroundColor(Color(message.nameColor ?? ""))
                Spacer()
            }
            
            HStack(alignment: .center){
                HStack(spacing: 2){
                    Rectangle().foregroundColor(Color("\(message.nameColor ?? "")")).frame(width:2).padding(.leading,2)
                    
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
        
        }.padding(.vertical,7).padding(.horizontal,5).background(RoundedRectangle(cornerRadius: 12).stroke(Color("\(message.nameColor ?? "")")))
    }
}
//struct ReplyMessageCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ReplyMessageCell()
//    }
//}

//
//  ImageSendView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/5/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageSendView: View {
    
    var message: Message
    var imageURL: UIImage
    var chatID: String
    
    var messageVM : MessageViewModel
    
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                Image(uiImage: imageURL).resizable().scaledToFit()
                
                Button(action:{
                    messageVM.sendImageMessage(name: message.name!, timeStamp: message.timeStamp!, nameColor: message.nameColor!, messageID: message.id, profilePicture: message.profilePicture!, messageType: message.messageType!, chatID: chatID, imageURL: imageURL)
                    
                    presentationMode.wrappedValue.dismiss()
                },label:{
                    Text("Send")
                })
                
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                },label:{
                    Text("Back")
                })
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct ImageSendView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageSendView()
//    }
//}

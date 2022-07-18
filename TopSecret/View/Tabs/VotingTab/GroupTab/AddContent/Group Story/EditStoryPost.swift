//
//  EditStoryPost.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/13/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditStoryPost: View {
    
    @Binding var image : UIImage
    
    var body: some View {
        ZStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(image.size, contentMode: .fit)

            VStack{
                
                HStack{
                    
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,10)
                    
                    Spacer()
                }.padding(.top,50)
                
                Spacer()
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}



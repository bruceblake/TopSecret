//
//  GalleryPostLikeListView.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/1/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GalleryPostLikeListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var galleryPost: GalleryPostModel
    @Binding var userLikesList : [User]
    
    var body: some View {
        ZStack(){
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 30, height: 30).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Likes").foregroundColor(FOREGROUNDCOLOR).font(.title).fontWeight(.bold)
                    Spacer()
                    
                }.padding().padding(.top,40)
              
                ScrollView{
                 
                }
            }
            
         
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct GalleryPostLikeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryPostLikeListView()
//    }
//}

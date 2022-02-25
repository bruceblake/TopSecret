//
//  GalleryPostCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/23/22.
//

import SwiftUI

struct GalleryPostCell: View {
    
    @Binding var galleryPost: GalleryPostModel
    @Binding var group: Group
    
  
    
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                HStack{
                    Text("Group: \(group.groupName)")
                    Text("\(galleryPost.post ?? "")")
                }
                Text("@\(galleryPost.creator ?? "")")
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
          
           
        }
    }
}

//struct GalleryPostCell_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryPostCell()
//    }
//}

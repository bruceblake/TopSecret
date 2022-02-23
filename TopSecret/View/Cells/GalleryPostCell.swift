//
//  GalleryPostCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/23/22.
//

import SwiftUI

struct GalleryPostCell: View {
    
    @State var galleryPost: GalleryPostModel
    
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                Text("\(galleryPost.post ?? "")")
                Text("@\(galleryPost.creator ?? "")")
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct GalleryPostCell_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryPostCell()
//    }
//}

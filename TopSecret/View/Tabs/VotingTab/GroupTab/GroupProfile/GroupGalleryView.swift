//
//  GroupGalleryView.swift
//  TopSecret
//
//  Created by Bruce Blake on 12/7/21.
//

import SwiftUI

struct GroupGalleryView: View {
    var group: Group
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var groupVM = GroupViewModel()
    @State var text = ""
    var body: some View {
        ScrollView{
            VStack{
                ForEach(groupVM.galleryPosts, id: \.id){ post in
//                    GalleryPostCell(galleryPost: post)
                }
            }
        }.onAppear{
            groupVM.fetchGroupGalleryPosts(groupID: group.id)
        }
    }
}
//
//struct GroupGalleryView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupGalleryView()
//    }
//}

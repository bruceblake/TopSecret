//
//  GalleryPostCommentView.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/1/22.
//

import SwiftUI

struct GalleryPostCommentView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var galleryVM = GalleryRepository()
    
    @Binding var galleryPost : GalleryPostModel
    @Binding var comments : [GalleryPostCommentModel]
    @State var text: String = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack(alignment: .topLeading){
            Color("Background")
            VStack{
               
                ScrollView{
                    VStack{
                        ForEach(comments){  comment in
                            HStack{
                                Text("@\(comment.user?.username ?? "\(comment.creator ?? "")")")
                                Text(": \(comment.text ?? "")")
                            }
                        }
                    }
                }.padding(.top,50)
                HStack{
                    CustomTextField(text: $text, placeholder: "message", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                    Button(action:{
                        galleryVM.addComment(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ", userID: userVM.user?.id ?? " ", text: text)
                        galleryVM.fetchGalleryPost(galleryPostID: galleryPost.id ?? " "){ fetchedPost in
                            galleryPost = fetchedPost
                        }
                        galleryVM.fetchPostComments(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ") { fetchedComments in
                            comments = fetchedComments
                        }
                    },label:{
                        Text("Add Comment")
                    })
                }.padding(30)
            }
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                },label:{
                    ZStack{
                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                        Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                    }
                })
                Spacer()
                Text("Comments").font(.title)
                Spacer()
            }.padding(40)
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct GalleryPostCommentView_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryPostCommentView()
//    }
//}

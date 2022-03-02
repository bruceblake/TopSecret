//
//  GalleryPostCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/23/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GalleryPostCell: View {
    
    @Binding var galleryPost: GalleryPostModel
    @Binding var selectedGalleryPost : GalleryPostModel
    @Binding var group: Group
    @Binding var user: User
    @Binding var isInGroup: Bool
    @Binding var isFollowingGroup: Bool 
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var galleryVM = GalleryRepository()
    @Binding var selectedGalleryPostComments : [GalleryPostCommentModel]
    @Binding var openComments : Bool 
  
    
    var body: some View {
        ZStack{
            VStack{
                
                
                HStack{
                    
                    VStack(spacing: 5){
                        HStack(alignment: .firstTextBaseline){
                            NavigationLink(destination: GroupProfileView(group: group)) {
                                HStack{
                                    WebImage(url: URL(string: group.groupProfileImage ?? "")).resizable().frame(width: 40, height: 40).clipShape(Circle())
                                    Text("\(group.groupName)").fontWeight(.bold).font(.headline).foregroundColor(FOREGROUNDCOLOR)
                                }
                            }
                            HStack(spacing: 2){
                                Text("•").foregroundColor(.gray).font(.footnote)
                                Text("@\(user.username ?? "")").foregroundColor(.gray).font(.footnote).fontWeight(.bold)

                            }
                           
                            
                            Spacer()
                            Button(action:{
                                //todo
                            },label:{
                                Image(systemName: "info.circle").frame(width: 30, height: 30).foregroundColor(FOREGROUNDCOLOR)
                            }).padding(.leading,5)
                        }
                        
                        HStack{
                            if isInGroup{
                                Text("In Group").foregroundColor(.gray).font(.footnote)
                            }else if isFollowingGroup{
                                Text("Following Group").foregroundColor(.gray).font(.footnote)
                            }
                            Spacer()
                        }
                      
                    }
                   
                    
                    Spacer()
                    
                }.padding(7)
            
//                if galleryPost.posts?.count ?? 0 > 1{
//                    
//                    VStack{
//                    ScrollView(.horizontal){
//                        HStack{
//                            ForEach(galleryPost.posts ?? [], id: \.self){ post in
//                                WebImage(url: URL(string: post))
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: UIScreen.main.bounds.width - 70, height: UIScreen.main.bounds.height / 2.5)
//                            }
//                        }
//                    }
//                        HStack{
//                            Spacer()
//                            Text("*&")
//                            Spacer()
//                        }
//                    }
//                    
//                }else{
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/top-secret-dcb43.appspot.com/o/userProfileImages%2Fb517MKUsMUNzqQkNVPeEQKfnzLg1?alt=media&token=873b3f28-8573-4f78-9b5f-4c516f4f4a50"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width - 70, height: UIScreen.main.bounds.height / 2.5)
//                }
               
           
                
                HStack(){
                    Text("\(galleryPost.description ?? "")")
                    Spacer()
                }.padding(.leading,5)
                
                
                HStack{
                    
                    NavigationLink(destination: EmptyView()) {
                        Text("\(galleryPost.likes?.count ?? 0) likes").fontWeight(.bold)
                    }
                    
                    Button(action:{
                        //TODO
                        if galleryVM.userHasAlreadyLikedPost(userID: userVM.user?.id ?? " ", likes: galleryPost.likes ?? []){
                            galleryVM.unlikePost(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ", userID: userVM.user?.id ?? " ")
                        }else{
                            galleryVM.likePost(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID  ?? " ", userID: userVM.user?.id ?? " ")
                        }
                        galleryVM.fetchGalleryPost(galleryPostID: galleryPost.id ?? " ") { fetchedPost in
                            self.galleryPost = fetchedPost
                        }
                    },label:{
                        Image(systemName: galleryVM.userHasAlreadyLikedPost(userID: userVM.user?.id ?? " ", likes: galleryPost.likes ?? []) ?  "heart.fill" : "heart").foregroundColor(Color("AccentColor"))
                    })
                    
                    Button(action:{
                        //TODO
                        galleryVM.fetchPostComments(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ") { fetchedComments in
                            self.selectedGalleryPostComments = fetchedComments
                            self.selectedGalleryPost = galleryPost
                            self.openComments.toggle()
                        }
                       
                    },label:{
                        ZStack{
                            Image(systemName: "text.bubble").foregroundColor(FOREGROUNDCOLOR)
                            ZStack{
                                Circle().frame(width: 12, height: 12).foregroundColor(Color("AccentColor"))
                                Text("\(galleryPost.comments?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR)
                            }.offset(x: 6, y: 5)
                           
                        }
                    })
                    
                    Spacer()
                    
                    Text("\(galleryPost.dateCreated?.dateValue() ?? Date(), style: .date)").foregroundColor(.gray).font(.caption)

                }.padding(7)
                
            }.background(Color("Color")).cornerRadius(16)
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct GalleryPostCell_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryPostCell()
//    }
//}

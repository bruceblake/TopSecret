////
////  GalleryPostCell.swift
////  TopSecret
////
////  Created by Bruce Blake on 2/23/22.
////
//
//import SwiftUI
//import SDWebImageSwiftUI
//
//struct GalleryPostCell: View {
//
//    var galleryPost: GalleryPostModel
//    @Binding var selectedGalleryPost : GalleryPostModel
//    @EnvironmentObject var userVM: UserViewModel
//    @StateObject var galleryVM = GalleryRepository()
//    @Binding var selectedGalleryPostComments : [GalleryPostCommentModel]
//    @Binding var openComments : Bool
//    @State var usersLikeList : [User] = []
//    @State var showLikeListView : Bool = false
//
//
//    var body: some View {
//        ZStack{
//            VStack{
//
//
//                HStack{
//
//                    VStack(spacing: 5){
//                        HStack(alignment: .firstTextBaseline){
////                            NavigationLink(destination: GroupProfileView(group: galleryPost.group ?? Group())) {
////                                HStack{
////                                    WebImage(url: URL(string: galleryPost.group?.groupProfileImage ?? "")).resizable().frame(width: 40, height: 40).clipShape(Circle())
////                                    Text("\(galleryPost.group?.groupName ?? "")").fontWeight(.bold).font(.headline).foregroundColor(FOREGROUNDCOLOR)
////                                }
////                            }
//                            HStack(spacing: 2){
//                                Text("•").foregroundColor(.gray).font(.footnote)
//                                Text("@\(galleryPost.creator?.username ?? "")").foregroundColor(.gray).font(.footnote).fontWeight(.bold)
//
//                            }
//
//
//                            Spacer()
//                            Menu {
//                                VStack{
//                                    if galleryPost.isInGroup ?? false{
//                                        Button(action:{
//                                            //TODO
//                                        },label:{
//                                            Text("Edit Post").foregroundColor(FOREGROUNDCOLOR)
//                                        })
//
//                                        Button(action:{
//                                            //TODO
//                                            galleryVM.deleteGalleryPost(galleryPostID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ")
//                                            userVM.homescreenPosts.removeValue(forKey: galleryPost.id ?? " ")
//                                        },label:{
//                                            Text("Delete Post").foregroundColor(FOREGROUNDCOLOR)
//                                        })
//                                    }
//
//                                    Button(action:{
//                                        //todo
//                                    },label:{
//                                        Text("Share Post").foregroundColor(FOREGROUNDCOLOR)
//                                    })
//
//
//                                }
//                            } label: {
//                                Image(systemName: "info.circle").frame(width: 30, height: 30).foregroundColor(FOREGROUNDCOLOR)
//                            }.padding(.leading, 5)
//
//
//
//                        }
//
//                        HStack{
//                            if galleryPost.isInGroup ?? false{
//                                Text("In Group").foregroundColor(.gray).font(.footnote)
//                            }else if galleryPost.isFollowingGroup ?? true {
//                                Text("Following Group").foregroundColor(.gray).font(.footnote)
//                            }
//                            Spacer()
//                        }
//
//                    }
//
//
//                    Spacer()
//
//                }.padding(7)
//
//                if galleryPost.posts?.count == 1 {
//                    WebImage(url: URL(string: galleryPost.posts?[0] ?? ""))
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5).padding().padding(.top,5)
//                }else{
//                    ScrollView(.horizontal, showsIndicators: false){
//                        HStack(spacing: 100){
//
//                                ForEach(galleryPost.posts ?? [], id: \.self){post in
//                                    WebImage(url: URL(string: post))
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
//
//                                }
//                        }.padding(.horizontal,40)
//                    }.frame(width: UIScreen.main.bounds.width)
//
//                }
//
//
//
//
//
//
//
//                HStack(){
//                    Text("\(galleryPost.description ?? "")")
//                    Spacer()
//                }.padding(.leading,5)
//
//
//                HStack(spacing: 20){
//
//
////
////                    NavigationLink(isActive: $showLikeListView) {
////                        GalleryPostLikeListView(galleryPost: $galleryPost, userLikesList: $usersLikeList)
////                    } label: {
////                        EmptyView()
////                    }
////
//
//
//                    HStack(spacing: 25){
//
//
//                    Button(action:{
//                        //TODO
//                        let dispatchGroup = DispatchGroup()
//                        dispatchGroup.enter()
//                        galleryVM.fetchPostComments(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ") { fetchedComments in
//                            self.selectedGalleryPostComments = fetchedComments
//                            self.selectedGalleryPost = galleryPost
//                            dispatchGroup.leave()
//
//                        }
//                        dispatchGroup.notify(queue: .main){
//                            self.openComments.toggle()
//                        }
//
//
//                    },label:{
//                        VStack(spacing: 3){
//                            Image(systemName: "text.bubble").foregroundColor(FOREGROUNDCOLOR)
//                            Text("\(galleryPost.commentsIDS?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
//
//                        }.frame(width: 20, height : 25)
//                    })
//
//                    Button(action:{
//                        //TODO
//                        galleryVM.fetchPostComments(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ") { fetchedComments in
//                            self.selectedGalleryPostComments = fetchedComments
//                            self.selectedGalleryPost = galleryPost
//                            self.openComments.toggle()
//                        }
//
//                    },label:{
//                        VStack(spacing: 3){
//                            Image(systemName: "paperplane").foregroundColor(FOREGROUNDCOLOR)
//                            Text("\(galleryPost.comments?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
//
//                        }.frame(width: 20, height : 25)
//                    })
//                    }.padding(.leading)
//
//                    Spacer()
//
//                    Text("\(galleryPost.dateCreated?.dateValue() ?? Date(), style: .date)").foregroundColor(.gray).font(.caption)
//
//                }.padding(.vertical,12)
//
//                Divider().padding(0)
//            }.background(Color("Color")).frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height / 3)
//        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
//    }
//}
//
////struct GalleryPostCell_Previews: PreviewProvider {
////    static var previews: some View {
////        GalleryPostCell()
////    }
////}

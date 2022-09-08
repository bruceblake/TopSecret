////
////  GalleryPostCommentCell.swift
////  Top Secret
////
////  Created by Bruce Blake on 3/7/22.
////
//
//import SwiftUI
//import Firebase
//import SDWebImageSwiftUI
//
//struct GalleryPostCommentCell: View {
//   @Binding var comment : GalleryPostCommentModel
//    @State var timeElapsed : String = ""
//    @EnvironmentObject var userVM: UserViewModel
//    var rank : Int
//
//
//    func convertComponentsToDate(days: Int, hours: Int, minutes: Int, seconds: Int) -> String {
//        var ans = ""
//
//        let noDays = (days <= 0)
//        let noHours = (hours <= 0)
//        let noMinutes = (minutes <= 0)
//        let noSeconds = (seconds <= 0)
//
//       if(noDays && noHours && noMinutes && !noSeconds){
//            ans = "\(seconds) secs"
//        }else if(noDays && noHours && !noMinutes){
//            ans = "\(minutes) mins"
//        }else if (noDays && !noHours && noMinutes){
//            ans = "\(hours) hrs"
//        }else if (!noDays && noHours && noMinutes){
//            ans = "\(days) days"
//        }else if (!noDays && !noHours && !noMinutes){
//            ans = "\(days) days"
//        }else if (!noDays && !noHours && noMinutes){
//            ans = "\(days) days"
//        }else if (!noDays && noHours && !noMinutes){
//            ans = "\(days) days"
//        }else if (noDays && !noHours && !noMinutes){
//            ans = "\(hours) hrs"
//        }else if (noDays && noHours && !noMinutes && !noSeconds){
//            ans = "\(minutes) mins"
//        }
//
//        return ans
//
//    }
//
//    func fetchComment(galleryID: String,commentID: String, completion: @escaping (GalleryPostCommentModel) -> ()) -> (){
//        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").document(commentID).getDocument { snapshot, err in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//
//            let dispatchGroup = DispatchGroup()
//
//             let data = snapshot!.data()
//            let id = data?["id"] as? String ?? " "
//             let text = data?["text"] as? String ?? ""
//             let dateCreated = data?["dateCreated"] as? Timestamp ?? Timestamp()
//             let likes = data?["likes"] as? Int ?? 0
//            let usersLiked = data?["usersLiked"] as? [String] ?? []
//             let creator = data?["creator"] as? String ?? " "
//             var groupID = data?["groupID"] as? String ?? " "
//             var galleryPostID = data?["galleryPostID"] as? String ?? " "
//             var user : User = User()
//            dispatchGroup.enter()
//             userVM.fetchUser(userID: creator) { fetchedUser in
//               user = fetchedUser
//                 dispatchGroup.leave()
//             }
//
//
//
//            dispatchGroup.notify(queue: .main){
//
//                return completion(GalleryPostCommentModel(dictionary: ["id":id,"text":text,"dateCreated":dateCreated,"likes":likes,"creator":creator,"user":user,"galleryPostID":galleryPostID,"groupID":groupID,"usersLiked":usersLiked]))
//
//            }
//
//
//
//        }
//    }
//
//    func likeComment(galleryID: String, groupID: String, userID: String, commentID: String){
//        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").document(commentID).updateData(["likes":FieldValue.increment(Int64(1))])
//        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").document(commentID).updateData(["usersLiked":FieldValue.arrayUnion([userID])])
//
//        fetchComment(galleryID: galleryID, commentID: commentID) { fetchedComment in
//            comment = fetchedComment
//        }
//    }
//
//    func unlikeComment(galleryID: String, groupID: String, userID: String, commentID: String){
//        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").document(commentID).updateData(["likes":FieldValue.increment(Int64(-1))])
//        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").document(commentID).updateData(["usersLiked":FieldValue.arrayRemove([userID])])
//        fetchComment(galleryID: galleryID, commentID: commentID) { fetchedComment in
//            comment = fetchedComment
//        }
//    }
//
//    func userHasLiked(likeList: [String], userID: String) -> Bool {
//        var hasLiked = false
//        for user in likeList{
//            if userID == user{
//                hasLiked = true
//                return true
//            }
//        }
//        return hasLiked
//    }
//
//    var body: some View {
//        ZStack{
//            HStack{
//
//                HStack{
//                    NavigationLink(destination: {
//                        UserProfilePage(user: comment.user ?? User(), isCurrentUser: comment.user?.id ?? "" == userVM.user?.id ?? "")
//                    }) {
//                        WebImage(url: URL(string: comment.user?.profilePicture ?? "")).resizable().frame(width: 30, height: 30).clipShape(Circle())
//                    }
//
//                    VStack(alignment: .leading,spacing: 5){
//                        HStack(spacing: 3){
//                                    NavigationLink(destination: {
//                                        UserProfilePage(user: comment.user ?? User(), isCurrentUser: comment.user?.id ?? "" == userVM.user?.id ?? "")
//                                    }) {
//                                        Text("\(comment.user?.username ?? ""):").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.subheadline)
//                                    }
//
//                                    Text("\(comment.text ?? "")")
//                                }
//                                HStack{
//                                    Text(timeElapsed).foregroundColor(.gray).font(.caption)
//                                    Button(action:{
//
//                                    },label:{
//                                        Text("Reply").foregroundColor(.gray).font(.footnote)
//                                    })
//                                }
//                            }
//
//
//
//
//
//                }
//
//
//                Spacer()
//
//                HStack{
//                    if rank == 1{
//                        Image("firstPlaceMedal").resizable().frame(width: 30, height: 30)
//                    }else if rank == 2{
//                        Image("secondPlaceMedal").resizable().frame(width: 30, height: 30)
//                    }else if rank == 3{
//                        Image("thirdPlaceMedal").resizable().frame(width: 30, height: 30)
//                    }
//
//                    VStack{
//                        Button(action:{
//                            if userHasLiked(likeList: comment.usersLiked ?? [], userID: userVM.user?.id ?? " "){
//                                unlikeComment(galleryID: comment.galleryPostID ?? " ", groupID: comment.groupID ?? " ", userID: userVM.user?.id ?? " ", commentID: comment.id ?? " ")
//                            }else{
//                                likeComment(galleryID: comment.galleryPostID ?? " ", groupID: comment.groupID ?? " ", userID: userVM.user?.id ?? " ", commentID: comment.id ?? " ")
//                            }
//
//                        },label:{
//                            Image(systemName: userHasLiked(likeList: comment.usersLiked ?? [] , userID: userVM.user?.id ?? " ") ? "heart.fill" : "heart")
//                        })
//
//                        Text("\(comment.likes ?? 0)")
//
//                    }
//
//
//                }
//
//            }
//
//        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
//            let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: comment.dateCreated?.dateValue() ?? Date(), to: Date())
//            let day = components.day ?? 0
//            let hour = components.hour ?? 0
//            let minute = components.minute ?? 0
//            let second = components.second ?? 0
//
//            self.timeElapsed = convertComponentsToDate(days: day, hours: hour, minutes: minute, seconds: second)
//
//
//        }
//    }
//}
//
////struct GalleryPostCommentCell_Previews: PreviewProvider {
////    static var previews: some View {
////        GalleryPostCommentCell()
////    }
////}

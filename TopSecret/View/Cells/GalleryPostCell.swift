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
    @Binding var group: Group
    @Binding var user: User
    @Binding var isInGroup: Bool
    @Binding var isFollowingGroup: Bool 
    @EnvironmentObject var userVM: UserViewModel
    
  
    
    var body: some View {
        ZStack{
            VStack{
                
                
                HStack{
                    
                    VStack(spacing: 5){
                        HStack(alignment: .firstTextBaseline){
                            NavigationLink(destination: GroupProfileView(group: group)) {
                                Text("\(group.groupName)").fontWeight(.bold).font(.title2).foregroundColor(FOREGROUNDCOLOR)
                            }
                            HStack(spacing: 5){
                                Text("•").foregroundColor(.gray).font(.footnote)
                                if isInGroup{
                                    Text("In Group").foregroundColor(.gray).font(.footnote)
                                }else if isFollowingGroup{
                                    Text("Following Group").foregroundColor(.gray).font(.footnote)
                                }
                            }
                           
                            
                            Spacer()
                            Button(action:{
                                //todo
                            },label:{
                                Image(systemName: "info.circle").frame(width: 30, height: 30).foregroundColor(FOREGROUNDCOLOR)
                            }).padding(.leading,5)
                        }
                        
                        HStack{
                            Text("@\(user.username ?? "")").foregroundColor(.gray).font(.subheadline).fontWeight(.bold)
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
                        Text("400 views").fontWeight(.bold)
                    }
                    
                    Button(action:{
                        //TODO
                    },label:{
                        Image(systemName: "heart")
                    })
                    
                    Button(action:{
                        //TODO
                    },label:{
                        Image(systemName: "bubble.left")
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

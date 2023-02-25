//
//  GroupPostCommentsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/15/22.
//

import SwiftUI

struct GroupPostCommentsView: View {
    @StateObject var commentsVM = GroupPostCommentViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @Binding var showComments : Bool
    @State var text: String = " "
    @State var seeMedia : Bool = false

    @Binding var post: GroupPostModel
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        self.showComments.toggle()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    
                    Text("Comments").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                    
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)

                }.padding(.top,50).padding(.horizontal)
                Button(action:{
                    withAnimation{
                        self.seeMedia.toggle()
                    }
                },label:{
                    Image(uiImage: post.image ?? UIImage()).resizable().scaledToFill().cornerRadius(16).frame(width: UIScreen.main.bounds.width-20).padding(.vertical).fullScreenCover(isPresented: $seeMedia) {
                        
                    } content: {
                        ZStack{
                            Color("Background")
                            VStack{
                                Spacer()
                                Image(uiImage: post.image ?? UIImage()).resizable().scaledToFit()
                                Spacer()
                            }
                            
                            VStack{
                                HStack{
                                    Button(action:{
                                        self.seeMedia.toggle()

                                    },label:{
                                        ZStack{
                                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                                        }
                                    })
                                    
                                    Spacer()
                                    
                                    
                                    
                                }.padding()
                                Spacer()
                                HStack{
                                    VStack{
                                        ExpandableText(post.description ?? "", lineLimit: 2, username: post.creator?.username ?? "")
                                    }
                                }.padding()
                            }.padding()
                            
                        }.edgesIgnoringSafeArea(.all)
                    .onTapGesture{
                            self.seeMedia.toggle()
                        }
                    }
                })
               
               
                if commentsVM.hasLoaded{
                    ScrollView{
                        VStack{
                         
                            ForEach(commentsVM.comments){ comment in
                                GroupPostCommentCell(comment: comment)
                                Divider()
                            }
                        }
                    }
                   
                }else{
                    VStack{
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                
               
                
                Spacer()
                
                
                HStack{
                    TextField("comment", text: $text).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                    
                    Spacer()
                    Button(action:{
                        commentsVM.addComment(postID: post.id ?? " ", userID: userVM.user?.id ?? " " , text: text)
                        commentsVM.fetchComments(postID: post.id ?? " ")
                        self.text = " "
                    },label:{
                        Text("Send")
                    })
                }.padding([.horizontal,.bottom],30)
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            commentsVM.fetchComments(postID: post.id ?? " ")
        }
    }
}


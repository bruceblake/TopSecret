//
//  HomeScreenView.swift
//  TopSecret
//
//  Created by nathan frenzel on 8/31/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeScreenView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    
    @Binding var showTabButtons : Bool

    @State var options = ["Activity","Chat","Games","Top Secret's Profile"]
    @State var selectedView : Int = 0
    
    
    var body: some View {
        
        
        ZStack{
            
            Color("Background")
            
            VStack{
                
                HStack{
                    
                    
                    //Group Selection
                    Menu(content:{
                        ForEach(userVM.groups, id: \.id){ group in
                            Button(action:{
                                userVM.userSelectedGroup = group
                            },label:{
                                Text(group.groupName)
                            })
                        }
                    },label:{
                        HStack{
                            Text(userVM.userSelectedGroup.groupName).fontWeight(.bold).font(.title2).foregroundColor(FOREGROUNDCOLOR)
                            Image(systemName: "chevron.down").font(.footnote)

                        }
                    }).padding(.leading,120)
                       
                    
                    
                   
                    HStack{
                        Button(action:{
                            
                        },label:{
                            Image(systemName: "map").foregroundColor(.green)
                        })
                        
                        Button(action:{
                            
                        },label:{
                            Image(systemName: "list.bullet").foregroundColor(.blue)
                        })
                        
                        Spacer()
                        
                        NavigationLink(destination:{
                            UserProfilePage(isCurrentUser: true)
                        },label:{
                            Image(systemName: "person")
                        }).padding(.trailing,100)
                      
                    }.padding(.leading)
                    
                }.padding(.top,40)
                
                Spacer()
                
                HStack(spacing: 20){
                    
                    Button(action:{
                        selectedView = 0
                    },label:{
                        VStack{
                            Text("Activity")
                            Rectangle().frame(width: UIScreen.main.bounds.width/5,height:1)
                        }
                    }).foregroundColor(selectedView == 0 ? Color("AccentColor") : FOREGROUNDCOLOR)
                   
                    Button(action:{
                        selectedView = 1
                    },label:{
                        
                        VStack{
                            Text("Chat")
                            Rectangle().frame(width: UIScreen.main.bounds.width/5,height:1)
                        }
                    }).foregroundColor(selectedView == 1 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    
                    
                    Button(action:{
                        selectedView = 2
                    },label:{
                        VStack{
                            Text("Games")
                            Rectangle().frame(width: UIScreen.main.bounds.width/5,height:1)
                        }
                        
                    }).foregroundColor(selectedView == 2 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    
                    Button(action:{
                        selectedView = 3
                    },label:{
                        VStack{
                            Text("Profile")
                            Rectangle().frame(width:UIScreen.main.bounds.width/5,height:1)
                        }
                    }).foregroundColor(selectedView == 3 ? Color("AccentColor") : FOREGROUNDCOLOR)
                   
               
                    
                }.padding(.top)
                
                TabView(selection: $selectedView){
                    ActivityView().tag(0)
                    Text("Chat").tag(1)
                    Text("Games").tag(2)
                    Text("Profile").tag(3)
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
            }
        
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
    
    
    
    
    
    
}


struct Home : View {
    
    @State var openComments : Bool = false
    @State var selectedGalleryPostComments : [GalleryPostCommentModel] = []
    @State var selectedGalleryPost : GalleryPostModel = GalleryPostModel()

    
    func homeScreenPostsAreEmpty(posts: [String:String]) -> Bool{
        var isEmpty = true
        for value in posts.values {
            if value != ""{
                isEmpty = false
            }
            print("value: \(value)")
        }
        return isEmpty
    }
    
    
    @EnvironmentObject var userVM : UserViewModel

    var body: some View {
        if homeScreenPostsAreEmpty(posts: userVM.homescreenPosts){
            
            VStack{
                Text("Your feed is empty :(")
                Spacer()
            }.padding(.top,UIScreen.main.bounds.height/3.5)
             
            
          
        }else{
            ScrollView{
                Rectangle().foregroundColor(.clear).frame(height: UIScreen.main.bounds.height/10)
                LazyVStack(spacing: 195){
//                                ForEach(userVM.homescreenPosts.keys.sorted(), id: \.self){ key in
//                                    HomeScreenPostView(id: key, postType: userVM.homescreenPosts[key] ?? " ", selectedGalleryPost: $selectedGalleryPost, showInfoScreen: $showInfoScreen, openComments: $openComments, selectedGalleryPostComments: $selectedGalleryPostComments)
//                                }
                
                if userVM.finishedFetchingPosts{
                    ForEach(userVM.homescreenGalleryPosts, id: \.id){ post in
                        
                        if post.id != "Comment Manager"{
                            GalleryPostCell(galleryPost: post, selectedGalleryPost: $selectedGalleryPost, selectedGalleryPostComments: $selectedGalleryPostComments, openComments: $openComments).padding(.top,50)
                        }
              
                    }
                }else{
                    VStack{
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                
             
                
              
            }
                Rectangle().foregroundColor(.clear).frame(height: UIScreen.main.bounds.height/3)

            }
            
            NavigationLink(isActive: $openComments, destination: {GalleryPostCommentView(galleryPost: $selectedGalleryPost, comments: $selectedGalleryPostComments)}, label: {
                EmptyView()
            })
            
            
        }
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView(showTabButtons: .constant(true)).preferredColorScheme(.dark).environmentObject(UserViewModel())
    }
}


//struct HomeScreenPostView : View {
//
//
//    @State var id: String
//    @State var postType: String
//    @State var currentPoll: PollModel = PollModel()
//    @State var currentGroup : Group = Group()
//    @State var galleryPost: GalleryPostModel = GalleryPostModel()
//    @Binding var selectedGalleryPost : GalleryPostModel
//    @State var postCreator: User = User()
//    @State var isInGroup: Bool = false
//    @State var isFollowingGroup: Bool = false
//    @Binding var showInfoScreen : Bool
//    @Binding var openComments : Bool
//    @Binding var selectedGalleryPostComments : [GalleryPostCommentModel]
//    @EnvironmentObject var userVM: UserViewModel
//
//
//
//
//    var body : some View {
//
//
//
//
//        ZStack{
//            if postType == "poll"{
//
//            }else if postType == "event"{
//                Text("event")
//            }else if postType == "post"{
//                GalleryPostCell(galleryPost: self.galleryPost, selectedGalleryPost: $selectedGalleryPost, group: $currentGroup, user:  $postCreator, isInGroup: $isInGroup, isFollowingGroup: $isFollowingGroup, selectedGalleryPostComments: $selectedGalleryPostComments, openComments: $openComments)
//            }
//        }
//
//    }
//}









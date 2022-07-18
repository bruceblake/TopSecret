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
    @StateObject var groupRepository = GroupRepository()
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel

    @State var options = ["Home","Chat","Map","Profile","Games"]
    @State var selectedView : Int = 0
    @State var goBack = false
    @State var showAddContent = false
    @Binding var group : Group
    @Binding var users : [User]
    @State var offset : CGSize = .zero
    @State var showProfileView : Bool = false
    @State var showGalleryView : Bool = false
    @State var showTabButtons : Bool = false

    
    @Environment(\.presentationMode) var presentationMode

            
    var body: some View {
        
        ZStack{
            
            Color("Background").opacity(showAddContent ? 0.2 : 1).zIndex(0)
            
            VStack{
                
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                       
                        HStack(spacing: 2){
                                Image(systemName: "chevron.left")
                                    .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                                Image(systemName: "house")
                                    .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }.padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                     
                        
                    }).padding(.leading)
                    

                    Text(selectedGroupVM.group?.groupName ?? "TOPSECRET_GROUP_GROUPNAME").font(.title2).fontWeight(.heavy).minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    HStack{
                        
                        Button(action: {

                                withAnimation(.spring()){
                                    self.showProfileView.toggle()
                                }
                        },label:{
                                Image(systemName: "person.3.fill").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        
                        
                        Button(action:{
                            showAddContent.toggle()
                        },label:{
                            Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                        }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        
   

                    }.padding(.trailing,12)
                    
           
                
                }.padding(.top,60)
                
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false){
                
                HStack(spacing: 20){
                     
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 0
                        }
                    
                    },label:{
                        VStack{
                            Text("Home").fontWeight(.bold)
                            Rectangle().frame(width: UIScreen.main.bounds.width/5,height:2)
                        }
                    }).foregroundColor(selectedView == 0 ? Color("AccentColor") : FOREGROUNDCOLOR)
                   
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 1
                        }
                     
                    },label:{
                        
                        VStack{
                            Text("Chat").fontWeight(.bold)
                            Rectangle().frame(width: UIScreen.main.bounds.width/5,height:2)
                        }
                    }).foregroundColor(selectedView == 1 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    

              
                    
                    
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 2
                        }
                       
                    },label:{
                        VStack{
                            Text("Games").fontWeight(.bold)
                            Rectangle().frame(width:UIScreen.main.bounds.width/5,height:2)
                        }
                    }).foregroundColor(selectedView == 2 ? Color("AccentColor") : FOREGROUNDCOLOR)
                   
                    
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 3
                        }
                       
                    },label:{
                        VStack{
                            Text("Map").fontWeight(.bold)
                            Rectangle().frame(width:UIScreen.main.bounds.width/5,height:2)
                        }
                    }).foregroundColor(selectedView == 3 ? Color("AccentColor") : FOREGROUNDCOLOR)
               
                    
                }.padding(.leading,5).padding(.top,10)
                
                }
                
                TabView(selection: $selectedView){
                    ActivityView(group: $group).tag(0)
                 
                
                    ChatView(group: $group, uid: userVM.user?.id ?? " ").tag(1)
        
                    
                    Text("Games").tag(2)

                    
                    MapView(group: $group, groupUsers: $users).tag(3)
                    
                        
                    
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
              
                
            }.zIndex(1).opacity(showAddContent ? 0.2 : 1).onTapGesture {
                if(showAddContent){
                    showAddContent.toggle()
                }
            }
            
            BottomSheetView(isOpen: $showAddContent, maxHeight: UIScreen.main.bounds.height * 0.45) {
                
                    AddContentView(showAddContentView: $showAddContent, group: $group)
                
            }.zIndex(2)
            
            if showProfileView{
                GroupProfileView(group: $group, isInGroup: group.users?.contains(userVM.user?.id ?? " ") ?? false, showProfileView: $showProfileView).zIndex(3)
            }
         
            
//            if showGalleryView {
//                ZStack{
//                    Color("AccentColor")
//                    VStack{
//
//                        HStack{
//
//                            Spacer()
//                            Button(action:{
//                    withAnimation(.spring()){
//                                    showGalleryView.toggle()
//                                }
//                                offset = .zero
//                            },label:{
//                                Text("X").foregroundColor(FOREGROUNDCOLOR)
//                            })
//
//                            Spacer()
//                        }.padding(.top,50)
//
//                        Text("Gallery")
//                    }
//                }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
//            }
            
        
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            selectedGroupVM.fetchGroup(userID: userVM.user?.id ?? " ", groupID: group.id) { fetched in
                if fetched {
                    print("fetched \(group.groupName ?? "")")

                }
            }
        }
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









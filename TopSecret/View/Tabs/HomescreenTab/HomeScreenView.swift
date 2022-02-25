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
    @ObservedObject var notificationRepository = NotificationRepository()
    @StateObject var chatVM = ChatViewModel()
    @StateObject var groupVM = GroupViewModel()
    @State var showInfoScreen : Bool = false
    
    
    @State private var options = ["Groups","Notifications"]
    
    @State var selectedIndex = 0
    
    @State var isActive : Bool = false
    
    
    
    var body: some View {
        
        
        ZStack{
            Color("Background")
            
            VStack{
                VStack{
                    HStack(spacing: 20){
                        
                        HStack{
                            NavigationLink(
                                destination: UserProfilePage(user: userVM.user ?? User(), isCurrentUser: true),
                                label: {
                                    WebImage(url: URL(string: userVM.user?.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                })
                            
                            
                            
                            NavigationLink(
                                destination: UserNotificationView(),
                                label: {
                                    ZStack{
                                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                        
                                        ZStack(){
                                            Image(systemName: "heart")
                                                .resizable()
                                                .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                            if userVM.userNotificationCount != 0{
                                                
                                                ZStack{
                                                    Circle().foregroundColor(Color("AccentColor"))
                                                    Text("\(userVM.userNotificationCount)").foregroundColor(.yellow).font(.footnote)
                                                }.frame(width: 20, height: 20).offset(x: 18, y: -15)
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        
                                        
                                        
                                    }
                                })
                            
                            
                            
                            
                            
                            
                            
                            
                            
                        }.padding(.leading,20)
                        
                        Spacer()
                        
                        Button(action:{
                            userVM.fetchUserGroups()
                        }, label:{
                            Image("FinishedIcon")
                                .resizable()
                                .frame(width: 64, height: 64)
                        })
                        Spacer()
                        HStack(spacing:10){
                            
                            
                            
                            NavigationLink(
                                destination: SearchView(),
                                label: {
                                    ZStack{
                                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                        
                                    }
                                })
                            
                            
                            NavigationLink(destination: PersonalChatListView()) {
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                    Image(systemName: "paperplane.fill")
                                        .resizable()
                                        .frame(width: 16, height: 16).foregroundColor(Color("Foreground"))
                                    
                                }
                            }
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                        }.padding(.trailing,20)
                        
                        
                    }.padding(.top,40)
                    //main content
                    VStack{
                        
                        VStack(alignment: .leading){
                            
                            Text("Stories").fontWeight(.bold).padding(.leading,7)
                            
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                                    
                                    ForEach(userVM.followedGroups){ group in
                                        NavigationLink(destination: GroupProfileView(group: group)) {
                                            
                                            VStack{
                                                WebImage(url: URL(string: group.groupProfileImage ?? ""))
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width:50,height:50)
                                                    .clipShape(Circle())
                                                
                                                Text("\(group.groupName)").font(.footnote).foregroundColor(FOREGROUNDCOLOR)
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                }
                                
                            }.padding(.leading,7)
                            
                            
                            Divider()
                        }
                        
                        
                    }
                    
                    
                    
                }
                ScrollView{
                    VStack{
                        ForEach(userVM.homescreenPosts.keys.sorted(), id: \.self){ key in
                            HomeScreenPostView(id: key, postType: userVM.homescreenPosts[key] ?? "", showInfoScreen: $showInfoScreen)
                        }
                        
                    }
                }
                
            }.onReceive(self.navigationHelper.$moveToDashboard){ move in
                if move {
                    print("Move to dashboard: \(move)")
                    self.isActive = false
                    self.navigationHelper.moveToDashboard = false
                }
            }
            
            
            
        }.frame(width: UIScreen.main.bounds.width).edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
    
    
    
    
    
    
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView().preferredColorScheme(.dark).environmentObject(UserViewModel())
    }
}


struct HomeScreenPostView : View {
    
    
    @State var id: String
    @State var postType: String
    @State var currentPoll: PollModel = PollModel()
    @State var currentGroup : Group = Group()
    @State var galleryPost: GalleryPostModel = GalleryPostModel()
    @State var testText: String = ""
    @Binding var showInfoScreen : Bool
    @EnvironmentObject var userVM: UserViewModel
    
    
    func fetchPoll(pollID: String, completion: @escaping (PollModel) -> ()) -> () {
        COLLECTION_POLLS.document(pollID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(PollModel(dictionary: data ?? [:]))
        }
    }
    
    
    func fetchGroup(groupID: String, completion: @escaping (Group) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(Group(dictionary: data ?? [:]))
            
        }
    }
    
    var body : some View {
        
        
        
        
        ZStack{
            if postType == "poll"{
                PollCell(poll: currentPoll, showInfoScreen: $showInfoScreen)
            }else if postType == "event"{
                Text("event")
            }else if postType == "post"{
                GalleryPostCell(galleryPost: self.$galleryPost, group: $currentGroup)
            }
        }.onAppear{
            
            COLLECTION_GALLERY_POSTS.document(id).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot!.data()
                
                self.galleryPost = GalleryPostModel(dictionary: data ?? [:])
                
                self.fetchGroup(groupID: snapshot!.get("groupID") as? String ?? " ") { fetchedGroup in
                        self.currentGroup = fetchedGroup
                    }
                
            }
            
         
        }
        
    }
}









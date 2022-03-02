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
    @State var goToGroupProfile : Bool = false
    @State var goToCreateGroupView : Bool = false
    @State var openComments : Bool = false
    @State var selectedGalleryPostComments : [GalleryPostCommentModel] = []
    @State var selectedGalleryPost : GalleryPostModel = GalleryPostModel()
    @Binding var showTabButtons : Bool
    
    

    
    @State var selectedIndex = 0
    
    @State var isActive : Bool = false
    @State var unseenStoryGroups : [Group] = []
    @State var selectedStoryPosts : [StoryModel] = [StoryModel()]
    @State var selectedGroupStory : Group = Group()
    @State var showStoryScreen : Bool = false
    
    
    
    func unseenGroupsContainGroup(unseenGroups: [Group], group: Group) -> Bool{
        var contains : Bool = false
        for unseenGroup in unseenGroups{
            if unseenGroup.id == group.id{
                contains = true
            }
        }
        
        return contains
    }
    
    
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
                                    WebImage(url: URL(string: userVM.user?.profilePicture ?? " "))
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
                                            Image(systemName: "envelope.fill")
                                                .resizable()
                                                .frame(width: 20, height: 16).foregroundColor(Color("Foreground"))
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
                            
                            Text("Groups").fontWeight(.bold).padding(.leading,7)
                            
                            
                            if userVM.groups.count == 0 {
                                VStack{
                                    HStack{
                                        Spacer()
                                        Text("Your groups will appear here.").foregroundColor(FOREGROUNDCOLOR).font(.footnote).lineLimit(2)
                                        Spacer()
                                    }
                                    
                            
                                        
                                    HStack{
                                        Spacer()
                                        
                                        Button(action:{
                                            self.goToCreateGroupView.toggle()
                                        },label:{
                                            Text("Create a group")
                                        }).foregroundColor(Color("Foreground"))
                                            .padding(.vertical,10)
                                            .frame(width: UIScreen.main.bounds.width/3).background(Color("AccentColor")).cornerRadius(15).fullScreenCover(isPresented: $goToCreateGroupView, content: {
                                                CreateGroupView(goBack: $goToCreateGroupView)
                                            })


                                        
                                     
                                        
                                        Spacer()
                                    }
                                   
                                        
                                        
                                        
                                    
                                }
                            }else{
                                
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 10){
                                        
                                        
                                        NavigationLink(destination: CreateStoryPostView()){
                                            VStack{
                                                
                                                
                                                ZStack{
                                                    Circle().frame(width: 50, height: 50).foregroundColor(Color("Color"))
                                                    Image(systemName: "plus")
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width:20,height:20).foregroundColor(FOREGROUNDCOLOR)
                                                }
                                                
                                                
                                                
                                                
                                                Text("Add To A Group Story").font(.caption).foregroundColor(FOREGROUNDCOLOR)
                                            }
                                        }
                                        
                                        
                                        
                                        
                                        
                                        ForEach(userVM.groups){ group in
                                            
                                            Button(action:{
                                                userVM.fetchGroupStories(groupID: group.id, completion:{ stories in
                                                    self.selectedStoryPosts = stories
                                                    self.selectedGroupStory = group
                                                    if selectedStoryPosts.isEmpty{
                                                        self.goToGroupProfile.toggle()
                                                    }else{
                                                        withAnimation(.easeInOut){
                                                            self.showStoryScreen.toggle()
                                                            self.showTabButtons.toggle()
                                                        }
                                                    }
                                                })
                                                
                                                
                                                
                                            },label:{
                                                VStack{
                                                    
                                                    
                                                    
                                                    WebImage(url: URL(string: group.groupProfileImage ?? " "))
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width:50,height:50)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(self.unseenGroupsContainGroup(unseenGroups: self.unseenStoryGroups, group: group) ? Color(.red) :  Color.gray,lineWidth: 2))
                                                    
                                                    
                                                    
                                                    Text("\(group.groupName)").font(.footnote).foregroundColor(FOREGROUNDCOLOR)
                                                }
                                            })
                                            
                                            
                                            
                                            
                                            
                                            
                                        }
                                        
                                        ForEach(userVM.followedGroups){ group in
                                            NavigationLink(destination: GroupProfileView(group: group)) {
                                                
                                                VStack{
                                                    WebImage(url: URL(string: group.groupProfileImage ?? " "))
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
                                
                            }
                            Divider()
                        }
                        
                        
                    }
                    
                    
                    
                }
                
                    
                    
                    if homeScreenPostsAreEmpty(posts: userVM.homescreenPosts){
                        
                        VStack{
                            Text("Your feed is empty :(")
                            Spacer()
                        }.padding(.top,UIScreen.main.bounds.height/3.5)
                         
                        
                      
                    }else{
                        ScrollView{
                        LazyVStack(spacing: 20){
                            ForEach(userVM.homescreenPosts.keys.sorted(), id: \.self){ key in
                                HomeScreenPostView(id: key, postType: userVM.homescreenPosts[key] ?? " ", selectedGalleryPost: $selectedGalleryPost, showInfoScreen: $showInfoScreen, openComments: $openComments, selectedGalleryPostComments: $selectedGalleryPostComments).padding(.horizontal)
                            }
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
            
            if showStoryScreen {
                GroupStoryView(storyPosts: $selectedStoryPosts, groupID: $selectedGroupStory.id, isPresented: $showStoryScreen).onDisappear{
                    self.showTabButtons = true
                }
            }
            
            NavigationLink(isActive: $goToGroupProfile, destination: {GroupProfileView(group: selectedGroupStory)}, label: {
                EmptyView()
            })
            
            NavigationLink(isActive: $openComments, destination: {GalleryPostCommentView(galleryPost: $selectedGalleryPost, comments: $selectedGalleryPostComments)}, label: {
                EmptyView()
            })
            
            
        }.frame(width: UIScreen.main.bounds.width).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            
            
            
            
            
            
            
            for group in userVM.allUserGroups{
                COLLECTION_GROUP.document(group.id).collection("Story").getDocuments(completion: { snapshot, err in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    for document in snapshot!.documents {
                        
                        let usersSeenStory = document.get("usersSeenStory") as? [String] ?? []
                        if !usersSeenStory.contains(userVM.user?.id ?? " "){
                            self.unseenStoryGroups.append(group)
                        }
                    }
                    
                    
                })
            }
            
             
          
            
        }
        
    }
    
    
    
    
    
    
}

//struct HomeScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeScreenView().preferredColorScheme(.dark).environmentObject(UserViewModel())
//    }
//}


struct HomeScreenPostView : View {
    
    
    @State var id: String
    @State var postType: String
    @State var currentPoll: PollModel = PollModel()
    @State var currentGroup : Group = Group()
    @State var galleryPost: GalleryPostModel = GalleryPostModel()
    @Binding var selectedGalleryPost : GalleryPostModel
    @State var postCreator: User = User()
    @State var isInGroup: Bool = false
    @State var isFollowingGroup: Bool = false
    @Binding var showInfoScreen : Bool
    @Binding var openComments : Bool
    @Binding var selectedGalleryPostComments : [GalleryPostCommentModel]
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
    
    func isInGroup(groupID: String, userID: String, completion: @escaping (Bool) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let groups = snapshot!.get("groups") as? [String] ?? []
            
            for group in groups {
                if group == groupID{
                    return completion(true)
                }
            }
        }
    }
    
    func isFollowingGroup(groupID: String, userID: String, completion: @escaping (Bool) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let followers = snapshot!.get("followers") as? [String] ?? []
            for user in followers {
                if user == userID{
                    return completion(true)
                }
            }
        }
    }
    
    var body : some View {
        
        
        
        
        ZStack{
            if postType == "poll"{
                
            }else if postType == "event"{
                Text("event")
            }else if postType == "post"{
                GalleryPostCell(galleryPost: self.$galleryPost, selectedGalleryPost: $selectedGalleryPost, group: $currentGroup, user:  $postCreator, isInGroup: $isInGroup, isFollowingGroup: $isFollowingGroup, selectedGalleryPostComments: $selectedGalleryPostComments, openComments: $openComments)
            }
        }.onAppear{
            
            COLLECTION_GALLERY_POSTS.document(id).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot!.data()
                
                self.galleryPost = GalleryPostModel(dictionary: data ?? [" ":" "])
                let groupID = snapshot!.get("groupID") as? String ?? " "
                
                self.fetchGroup(groupID: groupID) { fetchedGroup in
                    self.currentGroup = fetchedGroup
                }
                self.isInGroup(groupID: groupID, userID: userVM.user?.id ?? " ", completion: { res in
                    self.isInGroup = res
                })
                self.isFollowingGroup(groupID: groupID, userID: userVM.user?.id ?? " ") { res in
                    self.isFollowingGroup = res
                }
                
                userVM.fetchUser(userID: galleryPost.creator ?? " ") { fetchedUser in
                    self.postCreator = fetchedUser
                }
            }
            
            
            
            
        }
        
    }
}









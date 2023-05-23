//
//  HomeScreen.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/3/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Foundation
import SwiftUIPullToRefresh

struct HomeScreen: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var feedVM : FeedViewModel
    @State var showSearch : Bool = false
    @State var selectedViewOption = 0
    @EnvironmentObject var shareVM: ShareViewModel
    @Binding var selectedPost: GroupPostModel
    @Binding var selectedPoll: PollModel
    @Binding var selectedEvent: EventModel
    @Binding var shareType : String
    
    var body: some View {
        ZStack{
            Color("Background")
            
            
            ZStack(alignment: .top){
                
                
                VStack{
                
                    
                    if selectedViewOption == 0 {
                        YourGroupsView(feedVM: feedVM, selectedPost: $selectedPost,  selectedPoll: $selectedPoll,selectedEvent: $selectedEvent, shareType: $shareType)
                    }else{
                        YourFeedView(feedVM: feedVM, selectedPost: $selectedPost,  selectedPoll: $selectedPoll, selectedEvent: $selectedEvent, shareType: $shareType)
                    }
                }
              
                    
                  
                    
                    HStack(spacing: 60){
                        
                        Button(action:{
                            selectedViewOption = 0
                        },label:{
                            VStack(spacing: 5){
                                Text("Your Groups").foregroundColor(selectedViewOption == 0 ? FOREGROUNDCOLOR : Color.gray)
                                Rectangle().frame(width: 50, height: 2).foregroundColor(selectedViewOption == 0 ? FOREGROUNDCOLOR : Color.clear)
                            }
                        })
                        
                        
                        Button(action:{
                            selectedViewOption = 1
                        },label:{
                            VStack(spacing: 5){
                                Text("Your Feed").foregroundColor(selectedViewOption == 1 ? FOREGROUNDCOLOR : Color.gray)
                                Rectangle().frame(width: 40, height: 2).foregroundColor(selectedViewOption == 1 ? FOREGROUNDCOLOR : Color.clear)
                            }
                        })
                        
                        
                    }
                
               
                
                
            }
          
            
            
            
            
           
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
            
        
        
        
        
        
        
        
        
        
        
        
    }
    
}


struct YourGroupsView : View {
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var feedVM : FeedViewModel
    @Binding var selectedPost: GroupPostModel
    @Binding var selectedPoll: PollModel
    @Binding var selectedEvent: EventModel
    @Binding var shareType: String
  
    
    private var groupsFilter : [FeedItemObjectModel] {
        return (feedVM.feed ?? []).filter  { item in
            return userVM.groups.contains(where: {$0.id == item.groupID ?? ""})
        }
    }
    
//    private var combinedGroupsFilter: [StoryModel] {
//
//    }

    var body: some View {
        
        RefreshableScrollView {
            await feedVM.fetchAll(userID: userVM.user?.id ?? " ")
        } progress: { state in
            Image(systemName: "arrow.up").foregroundColor(Color("AccentColor"))
        } content: {
            
            VStack(spacing: 15){
                if feedVM.isLoading{
                    ProgressView()
                }
                
                VStack(alignment: .leading){
                    ScrollView(.horizontal){
                        HStack(spacing: 5){
                            
                            VStack(alignment: .center){
                                ZStack{
                                    Circle().foregroundColor(Color("AccentColor")).frame(width: 40, height: 40)
                                    Image(systemName: "plus")
                                }
                                Text("Add to story").foregroundColor(FOREGROUNDCOLOR).font(.caption)
                            }
                            
//                            ForEach(combinedGroupsFilter, id: \.id){ item in
//
//                            }
                            
                            
                         
                         
                            
                        }
                    }.padding(.leading,25)
                    Divider()
                }.padding(.top)
                
                ForEach(groupsFilter, id: \.id){ item in
                    switch item.itemType {
                    case .event:
                        EventCell(event: item.event ?? EventModel(), selectedEvent: $selectedEvent).frame(width: UIScreen.main.bounds.width-30)
                    case .poll:
                        PollCell(poll: item.poll ?? PollModel(), selectedPoll: $selectedPoll).frame(width: UIScreen.main.bounds.width-30)
                    case .post:
                        GroupPostCell(post: item.post ?? GroupPostModel(), selectedPost: $selectedPost).frame(width: UIScreen.main.bounds.width-30)
                    default:
                        Text("Unknown")
                    }
                    
                }
                
            }.padding(.top)
        .padding(.bottom,UIScreen.main.bounds.height / 8)
        }

       
        
    }
}

struct YourFeedView : View {
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var feedVM: FeedViewModel
    @State var showInfo: Bool = false
    @Binding var selectedPost: GroupPostModel
    @Binding var selectedPoll: PollModel
    @Binding var selectedEvent: EventModel

    @Binding var shareType: String
   
    
    
    private var feedFilter : [FeedItemObjectModel]{
       return (feedVM.feed ?? []).filter  { item in
            return userVM.user?.groupsFollowingID?.contains(where: {$0 == item.groupID ?? ""}) ?? false
        }
    }
   
    
    var body: some View {
        if !userVM.connected{
            VStack{
                Spacer()
            Text("Unable to connect")
                Spacer()
            }
            
        }else if feedVM.isLoading && feedVM.feedIsEmpty(){
            VStack{
                Spacer()
                VStack{
                    Text("Loading Posts...").foregroundColor(FOREGROUNDCOLOR)
                    ProgressView()
                }
                Spacer()
            }
        }else{
            RefreshableScrollView {
                await feedVM.fetchAll(userID: userVM.user?.id ?? " ")
            } progress: { state in
                Image(systemName: "arrow.up").foregroundColor(Color("AccentColor"))
            } content: {
                
                            VStack(spacing: 15){
                                if feedVM.isLoading{
                                    ProgressView()
                                }
                                ForEach(feedFilter, id: \.id){ item in
                                    switch item.itemType {
                                        case .event:
                                        EventCell(event: item.event ?? EventModel(), selectedEvent: $selectedEvent).frame(width: UIScreen.main.bounds.width-30)
                                    case .poll:
                                    PollCell(poll: item.poll ?? PollModel(), selectedPoll: $selectedPoll).frame(width: UIScreen.main.bounds.width-30)
                                    case .post:
                                    GroupPostCell(post: item.post ?? GroupPostModel(), selectedPost: $selectedPost).frame(width: UIScreen.main.bounds.width-30)
                                        default:
                                            Text("Unknown")
                                    }
                            
                                }
                            }.padding(.top,40)
                            
                        .padding(.bottom,UIScreen.main.bounds.height / 8)
                            .opacity(userVM.showAddContent ? 0.2 : 1).disabled(userVM.showAddContent).onTapGesture {
                                if userVM.showAddContent {
                                    userVM.showAddContent.toggle()
                                    userVM.hideTabButtons.toggle()
                                }
                            }
            }

        
//
//                BottomSheetView(isOpen: Binding(get: {userVM.showAddContent}, set: {userVM.showAddContent = $0}), maxHeight: UIScreen.main.bounds.height / 3){
//                    GroupPostShowInfoView(postID: selectedPost.id ?? " ")
//                 }
                 
            
            
        }
        
        
        
        
    }
}

struct ShowGroups : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var selectedGroupVM: SelectedGroupViewModel
    @Environment(\.refresh) private var refresh
    @Binding var selectedGroup : Group
    @Binding var users: [User]
    @Binding var openGroupHomescreen : Bool
    
    var widthAdd : CGFloat = 50
    var heightDivide: CGFloat = 5
    var width : CGFloat = UIScreen.main.bounds.width
    var height : CGFloat = UIScreen.main.bounds.height
    
    
    
    var body: some View{
        VStack(alignment: .leading){
            Text("You are in \(userVM.groups.count) \(userVM.groups.count > 1 ? "groups" : "group")").fontWeight(.bold)
            ScrollView(showsIndicators: false){
                VStack(spacing: 30){
                    
                    if userVM.connected {
                        ForEach(userVM.groups, id: \.id){ group in
                            Button(action:{
                                
                                let dispatchGroup = DispatchGroup()
                                
                                
                                
                                dispatchGroup.enter()
                                self.selectedGroup = group
                                selectedGroupVM.changeCurrentGroup(groupID: group.id){ finishedFetching in
                                    if finishedFetching{
                                        dispatchGroup.leave()
                                    }
                                }

                                dispatchGroup.notify(queue: .main, execute:{
                                    openGroupHomescreen.toggle()
                                })
                                
                            },label:{
                                VStack{
                                    VStack(alignment: .leading){
                                        
                                        
                                        
                                        HStack{
                                            Spacer()
                                        }.padding(50).background(WebImage(url: URL(string: group.groupProfileImage )).resizable().scaledToFill())
                                        
                                        
                                        HStack(alignment: .top){
                                            
                                            VStack(alignment: .leading,spacing:10){
                                                Text(group.groupName).font(.headline).bold().foregroundColor(FOREGROUNDCOLOR)
                                                
                                                HStack{
                                                    Text(group.motd)
                                                }.foregroundColor(FOREGROUNDCOLOR)
                                                
                                                HStack{
                                                    Text("\(group.memberAmount) \(group.memberAmount == 1 ? "member" : "members")").foregroundColor(FOREGROUNDCOLOR)
                                                    
                                                    
                                                }
                                            }
                                            
                                            Spacer(minLength: 0)
                                        }.padding(10).background(Rectangle().foregroundColor(Color("Color")))
                                        
                                        
                                    }.cornerRadius(10)
                                    
                                }.shadow(color: Color.black, radius: 5).frame(width: width - widthAdd, height: height/heightDivide).padding(.top,30)
                                
                                
                                
                                
                                
                            })
                            
                        }
                        
                    }else{
                        Text("Unable to connect!")
                    }
                    
                   
                    
                    
                    
                }.padding(.bottom, UIScreen.main.bounds.height/4)
                
            }
        }
       
        .edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
}


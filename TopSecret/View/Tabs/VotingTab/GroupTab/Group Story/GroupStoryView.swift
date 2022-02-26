//
//  GroupStoryView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/26/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupStoryView: View {
    
    @Binding var storyPosts : [StoryModel]
    @Binding var groupID: String
    @StateObject var groupVM = GroupViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @State var index = 0
    var body: some View {
        ZStack{
            WebImage(url: URL(string: storyPosts[index].image ?? "")).resizable().scaledToFill()
            
            VStack{
                Button(action:{
                    index = index + 1
                    groupVM.seeStory(groupID: groupID, storyID: storyPosts[index].id, userID: userVM.user?.id ?? "")
                },label:{
                    Text("\(storyPosts[index].id)")
                })
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                groupVM.seeStory(groupID: groupID, storyID: storyPosts[index].id, userID: userVM.user?.id ?? "")
            }
        }
        
    }
}

//struct GroupStoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupStoryView()
//    }
//}

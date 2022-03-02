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
    @Binding var isPresented : Bool
    @State var index = 0
    var body: some View {
        ZStack{
            
            WebImage(url: URL(string: storyPosts[index].image ?? "")).resizable().scaledToFill()
            

            VStack{
                HStack{
                    Button(action:{
                        withAnimation(.easeInOut){
                            isPresented.toggle()
                        }
                    },label:{
                        Text("X").foregroundColor(.red)
                    }).padding(.leading,10)
                    
                    Spacer()
                }.padding(.top,40)
                
                Spacer()
                
                HStack{
                    
                }.padding(.bottom)
            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
//
//            VStack{
//                Button(action:{
//                    if index == storyPosts.count-1 {
//                        index = 0
//                    }else{
//                        index = index + 1
//                    }
//                    groupVM.seeStory(groupID: groupID, storyID: storyPosts[index].id, userID: userVM.user?.id ?? "")
//                },label:{
//                    Text("\(storyPosts[index].id)")
//                })
//            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            index = storyPosts.count - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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

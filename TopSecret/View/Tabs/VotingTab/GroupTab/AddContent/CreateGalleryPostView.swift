//
//  CreateGalleryPostView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/23/22.
//

import SwiftUI

struct CreateGalleryPostView: View {
    
    var group: Group
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State var description : String  = ""
    @State var taggedUsers : [String] = []
    @State var post: String = ""
    @State var isPrivate : Bool = false
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()

                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    Text("Create Gallery Post").font(.title2).fontWeight(.bold)

                    
                    Spacer()
                    
                }.padding(.top,50)
                
                
                Text("Post")
                TextField("post", text: $post)
                
                Text("Description")
                TextField("description", text: $description)
                
                
                Button(action:{
                    groupVM.createGalleryPost(groupID: group.id, post: post, description: description, creator: userVM.user?.id ?? "", isPrivate: isPrivate, taggedUsers: taggedUsers)
                },label:{
                    Text("Create Post")
                })
                
                //isPrivate
                //taggedUsers
                
                
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct CreateGalleryPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateGalleryPostView()
//    }
//}

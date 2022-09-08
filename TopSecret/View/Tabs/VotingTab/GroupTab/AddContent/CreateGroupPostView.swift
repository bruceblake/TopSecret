//
//  CreateGroupPostView.swift
//  Top Secret
//
//  Created by Bruce Blake on 9/6/22.
//

import SwiftUI

struct CreateGroupPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var createPostVM = CreateGroupPostViewModel()
    var group: Group
    @EnvironmentObject var userVM: UserViewModel
    @State var openImagePicker: Bool = false
    @State var post = UIImage(named: "Icon")!
    @State var showOverlay : Bool = false
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                //top bar
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Text("Create Post")
                    
                    Spacer()
                }.padding(.top,50)
                
                Spacer()
                
                Button(action:{
                    self.openImagePicker.toggle()
                },label:{
                    Image(uiImage: post)
                        .resizable()
                        .scaledToFill()
                        .frame(width:UIScreen.main.bounds.width,height:100)
                }).fullScreenCover(isPresented: $openImagePicker, content: {
                    ImagePicker(avatarImage: $post, allowsEditing: true)
                })
                Spacer()
                Button(action:{
                    createPostVM.createPost(image: post, userID: userVM.user?.id ?? " ", group: group)
                },label:{
                    Text("Create Post")
                })
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onReceive(createPostVM.$uploadStatus) { uploadStatus in
            if uploadStatus == .finishedUpload{
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

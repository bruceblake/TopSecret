//
//  CreateGalleryPostView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/23/22.
//

import SwiftUI

struct CreateGalleryPostView: View {
    
    @Binding var group: Group
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    @StateObject var galleryVM = GalleryRepository()
    @Environment(\.presentationMode) var presentationMode
    @State var showImageSendView : Bool = false
    @State var avatarImage = UIImage(named: "Icon")!
    @State var posts : [UIImage] = []
    
    @State var description : String  = ""
    @State var taggedUsers : [String] = []
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
                    
                }.padding(.leading,5)
                
             
                    
                   
                    
                    Button(action:{
                        self.showImageSendView.toggle()
                    },label:{
                        Image(uiImage: avatarImage).resizable().scaledToFit().frame(width:  UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height / 2.5)
                    }).fullScreenCover(isPresented: $showImageSendView) {
                        
                    } content: {
                        ImagePicker(avatarImage: $avatarImage, images: $posts, allowsEditing: true)
                    }
                    
                 
                ScrollView(.horizontal){
                    HStack{
                        ForEach(self.posts, id: \.self){ post in
                            Image(uiImage: post).resizable().scaledToFill().clipShape(Circle()).frame(width: 20, height: 20)
                        }
                    }
                }
               
               
                
                
                Button(action:{
                    galleryVM.createGalleryPost(groupID: group.id, posts: posts, description: description, creatorID: userVM.user?.id ?? "", isPrivate: isPrivate, taggedUsers: taggedUsers)
                },label:{
                    Text("Create Post")
                })
                

                
                Spacer()

            }.padding(.top,80)
            
        
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct CreateGalleryPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateGalleryPostView(group: Group()).colorScheme(.dark).environmentObject(UserViewModel())
//    }
//}



//
//  CreateStoryPostView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/26/22.
//

import SwiftUI

struct CreateStoryPostView: View {
    
    @StateObject var imagePickerVM = ImagePickerViewModel()
    @StateObject var groupVM = GroupViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM: UserViewModel

    @State var avatarImage = UIImage(named: "Icon")!
    @State var selectedGroup : Group = Group()
    @State var showImageSendView: Bool = false
    @State var posts : [UIImage] = [UIImage(named: "Icon")!]

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
                    Text("Create Story Post").font(.title2).fontWeight(.bold)

                    
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
                        ForEach(userVM.groups){ group in
                            Button(action:{
                                self.selectedGroup = group
                            },label:{
                                Text("\(group.groupName)").foregroundColor(selectedGroup.id == group.id ? Color("AccentColor") : FOREGROUNDCOLOR)
                            })
                        }
                    }
                }
                
                Button(action:{
                    groupVM.addToGroupStory(groupID: selectedGroup.id, post: $posts[0], creator: userVM.user?.id ?? "")
                },label:{
                    Text("Add To Story")
                })
                
                
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct CreateStoryPostView_Previews: PreviewProvider {
    static var previews: some View {
        CreateStoryPostView()
    }
}

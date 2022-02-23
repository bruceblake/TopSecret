//
//  EnterUserProfilePicture.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/29/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct EnterUserProfilePicture: View {
    
    @State var isShowingPhotoPicker:Bool = false
    @State var avatarImage = UIImage(named: "Icon")!
    @State var isNext: Bool = false
    @EnvironmentObject var userVM : UserViewModel
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                Spacer()
                Text("Enter a profile picture!").foregroundColor(FOREGROUNDCOLOR)
                Button(action:{
                    isShowingPhotoPicker.toggle()
                },label:{
                    Image(uiImage: avatarImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width:100,height:100)
                        .clipShape(Circle())
                        .padding()
                }).fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                    ImagePicker(avatarImage: $avatarImage, allowsEditing: true)
                })
                
        Button(action: {
                    self.isNext.toggle()
            userVM.userProfileImage = avatarImage
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                NavigationLink(
                    destination: CreatePassword(),
                    isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                Spacer()
            }
            
           
        }.edgesIgnoringSafeArea(.all)
    }
}

struct EnterUserProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        EnterUserProfilePicture().colorScheme(.dark)
    }
}

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
    @State var avatarImage = UIImage(named: "topbarlogo")!
    @State var isNext: Bool = false
    @EnvironmentObject var registerVM : RegisterValidationViewModel
    @State var images : [UIImage] = []
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                Spacer()
                Text("Enter a profile picture!").foregroundColor(FOREGROUNDCOLOR)
                ZStack{
                    Circle().foregroundColor(Color("Color")).frame(width: 175, height: 175)
                    Button(action:{
                        isShowingPhotoPicker.toggle()
                    },label:{
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width:200,height:200)
                            .clipShape(Circle())
                            .padding()
                    }).fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                        ImagePicker(avatarImage: $avatarImage, allowsEditing: true)
                    })
                }
              
                
        Button(action: {
                    self.isNext.toggle()
            registerVM.userProfileImage = avatarImage
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                NavigationLink(
                    destination: PickInterestsView(),
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

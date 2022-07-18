//
//  CreateGroupView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI
import Firebase

struct CreateGroupView: View {
    
    @EnvironmentObject var userVM : UserViewModel

    @ObservedObject var groupNameLimit = TextLimitViewModel(limit: 16)
    @ObservedObject var groupPasswordLimit = TextLimitViewModel(limit: 4)
    @Environment(\.presentationMode) var presentationMode
    @StateObject var groupVM = GroupViewModel()
    @State var memberLimit: Int = 0
    @State var isShowingPhotoPicker:Bool = false
    @State var avatarImage = UIImage(named: "Icon")!
    @State var images : [UIImage] = []
    @State var password : String = ""
    @State var groupName : String = ""
    
    
    var body: some View {
        ZStack(alignment: .topLeading){
            Color("Background")
            VStack{
                
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                    Spacer()
                    
                    Text("Create Group!").fontWeight(.bold).font(.title).padding(.trailing,10)
                    
                    Spacer()
                    

                }.padding(.top,50)
            
          
                VStack(spacing: 20){
                    VStack(alignment: .leading){
                        Text("Create Group").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        VStack{
                            CustomTextField(text: $groupName, placeholder: "Group Name", isPassword: false, isSecure: false, hasSymbol: false ,symbol: "")
                        }
                    }.padding(.horizontal)
                    
                     
                    VStack(alignment: .leading){
                        Text("Group Password").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        VStack{
                            CustomTextField(text: $password, placeholder: "Group Password", isPassword: false, isSecure: false, hasSymbol: false ,symbol: "", numbersOnly: true)
                        }
                    }.padding(.horizontal)
                    
                }.padding(.vertical,10)
            
      
            
           

            
            Button(action:{
                isShowingPhotoPicker.toggle()
            },label:{
                Image(uiImage: avatarImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width:45,height:45)
                    .clipShape(Circle())
                    .padding()
            }).fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                ImagePicker(avatarImage: $avatarImage, images: $images, allowsEditing: true)
            })
            
            Button(action:{
                let id = UUID().uuidString
                groupVM.createGroup(groupName: groupName, memberLimit: memberLimit, dateCreated: Date(), users: [userVM.user?.id ?? ""],image: avatarImage, currentUser: userVM.user?.id ?? "",  id: id, password: password)
              
                userVM.changeUserSelectedGroup(groupID: id,userID: userVM.user?.id ?? " ")
                
                presentationMode.wrappedValue.dismiss()
            },label:{
                Text("Create Group")
                    
            })
            

            Spacer()
        
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
}
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}

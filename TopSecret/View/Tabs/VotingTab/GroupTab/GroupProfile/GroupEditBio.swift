////
////  GroupEditBio.swift
////  Top Secret
////
////  Created by Bruce Blake on 6/22/22.
////
//
//import SwiftUI
//
//struct GroupEditBio: View {
//    
//    @State var bio : String = ""
//    @Binding var group : Group
//    @StateObject var groupVM = GroupViewModel()
//    @EnvironmentObject var userVM: UserViewModel
//    @Environment(\.presentationMode) var dismiss
//
//    var body: some View {
//        ZStack{
//            Color("Background")
//            VStack{
//                Text("Edit Bio").font(.title).foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).padding(.top,15)
//                
//                Spacer()
//                
////                CustomTextField(text: $bio, placeholder: group.bio ?? "GROUP_BIO", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
//                
//                Button(action:{
//                    let dp = DispatchGroup()
//                    
//                    dp.enter()
//                    
//                    groupVM.changeBio(bio: bio, groupID: group.id, userID: userVM.user?.id ?? " ")
//                    dp.leave()
//                    
//                    dp.notify(queue: .main, execute: {
//                        dp.enter()
//                        userVM.fetchGroup(groupID: group.id) { fetchedGroup in
//                            self.group = fetchedGroup
//                            dp.leave()
//                        }
//                        
//                        dp.notify(queue: .main) {
//                            dismiss.wrappedValue.dismiss()
//                        }
//                    })
//                },label:{
//                    Text("Save Changes")
//                })
//                
//                Spacer()
//                
//            }
//        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
//    }
//}
//
////struct GroupEditBio_Previews: PreviewProvider {
////    static var previews: some View {
////        GroupEditBio()
////    }
////}

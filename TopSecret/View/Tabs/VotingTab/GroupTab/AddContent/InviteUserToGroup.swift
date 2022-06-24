//
//  InviteUserToGroup.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/23/22.
//

import SwiftUI

struct InviteUserToGroup: View {
    
    @State var username : String = ""
    @Binding var group : Group
    @StateObject var groupVM = GroupViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Back")
                    }).padding(.leading,10)
                    
                    Spacer()
                    
                    Text("Invite Friend").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.largeTitle)
                    
                    Spacer()

                }
                
                VStack{
                    Text("Enter Username")
                    CustomTextField(text: $username, placeholder: "Username", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                    
                    Button(action:{
                        
                        let dp = DispatchGroup()
                        
                        dp.enter()
                        
                        groupVM.joinGroup(groupID: group.id, username: username)
                        groupVM.userVM?.fetchGroup(groupID: group.id, completion: { fetchedGroup in
                            group = fetchedGroup
                            dp.leave()
                        })
                        
                        dp.notify(queue: .main) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    },label:{
                        Text("Add User To Group!")
                    })
                    
                }
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct InviteUserToGroup_Previews: PreviewProvider {
//    static var previews: some View {
//        InviteUserToGroup()
//    }
//}

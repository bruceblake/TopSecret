//
//  UserFriendsListView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/4/22.
//

import SwiftUI

struct UserFriendsListView: View {
    @Binding var user: User
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        ScrollView(){
            VStack(alignment: .leading){
                if user.friendsList?.isEmpty ?? true{
                    Text("0 friends :(").foregroundColor(FOREGROUNDCOLOR)
                }
                else{
                    VStack{
                        ForEach(Binding(get: {user.friendsList ?? []}, set: {_ in}), id: \.self) { user in
                            NavigationLink(
                                destination: UserProfilePage(user: user, isCurrentUser: userVM.user?.id == user.wrappedValue.id ?? ""),
                                label: {
                                    UserSearchCell(user: user, showActivity: true)
                                })
                            
                        }
                    }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                    
                }
                
                
                
                
            }
            
            
        }
    }
}

//struct UserFriendsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserFriendsListView()
//    }
//}

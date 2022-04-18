//
//  UserFriendsListView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/4/22.
//

import SwiftUI

struct UserFriendsListView: View {
    @State var user: User 
    @State var friendsList: [User] = []
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        ScrollView(){
            VStack(alignment: .leading){
                if friendsList.isEmpty{
                    Text("0 friends :(").foregroundColor(FOREGROUNDCOLOR)
                }
                else{
                    VStack{
                        ForEach(friendsList, id: \.self) { user in
                            NavigationLink(
                                destination: UserProfilePage(user: user, isCurrentUser: userVM.user?.id == user.id ?? ""),
                                label: {
                                    UserSearchCell(user: user, showActivity: true)
                                })
                            
                        }
                    }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                    
                }
                
                
                
                
            }
            
            
        }.onAppear{
            userVM.fetchUser(userID: user.id ?? "", completion: { user in
                self.user = user
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                userVM.getUserFriendsList(user: user, completion: { list in
                    friendsList = list
                })
              
            }
            
        }
    }
}

//struct UserFriendsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserFriendsListView()
//    }
//}

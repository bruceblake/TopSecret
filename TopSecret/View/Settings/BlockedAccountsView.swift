//
//  BlockedAccountsView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/8/22.
//

import SwiftUI
import Firebase


struct BlockedAccountsView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var users: [User] = []
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                ForEach(users, id: \.self){ account in
                    Text("blocked: @\(account.username ?? "")")
                }
            }
        }.onAppear{
            for user in userVM.user?.blockedAccounts ?? []{
                userVM.fetchUser(userID: user, completion: { fetchedUser in
                    users.append(fetchedUser)
                })
            }
        }
    }
}

struct BlockedAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        BlockedAccountsView()
    }
}

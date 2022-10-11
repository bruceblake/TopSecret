//
//  FriendsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var searchVM = SearchRepository()
    @StateObject var chatVM = GroupChatViewModel()
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                Text("Hello World")
                Spacer()
            }
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsersFriends", id: userVM.user?.id ?? " ")
        }
    }
}


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
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Spacer()
                    Text("Friends").font(.title).bold()
                    Spacer()
                }.padding(.top,50).padding(.horizontal)
                
                
                ScrollView{
                    VStack{
                        ForEach(userVM.user?.friendsList ?? [], id: \.id){ friend in
                            UserSearchCell(user: friend, showActivity: false)
                        }
                    }
                }
                
                
            }
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsersFriends", id: userVM.user?.id ?? " ")
        }
    }
}


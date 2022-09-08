////
////  GroupFollowersView.swift
////  TopSecret
////
////  Created by Bruce Blake on 2/22/22.
////
//
//import SwiftUI
//
//struct GroupFollowersView: View {
//    @State var group: Group = Group()
//    @StateObject var searchRepository = SearchRepository()
//    @StateObject var groupVM = GroupViewModel()
//    @EnvironmentObject var userVM: UserViewModel
//    @Environment(\.presentationMode) var presentationMode
//
//
//
//    var body: some View {
//        ZStack{
//            Color("Background")
//
//            VStack{
//
//                HStack{
//                    Button(action:{
//                        presentationMode.wrappedValue.dismiss()
//
//                    },label:{
//                        ZStack{
//                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
//
//                            Image(systemName: "chevron.left")
//                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
//                        }
//                    }).padding(.horizontal,10)
//
//
//                    Text("\(group.followers?.count ?? 0) \(group.followers?.count ?? 0 > 1 ? "Followers"  : "Follower")").font(.title2).fontWeight(.bold)
//
//                    Spacer()
//
//                }
//
//                ScrollView{
//                    VStack(alignment: .leading){
//                        if !searchRepository.searchText.isEmpty{
//                            Text("Followers").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
//                        }
//
//                        if searchRepository.searchText.isEmpty{
//                            VStack{
//                                ForEach(groupVM.followers) { user in
//                                    if user.id != userVM.user?.id ?? ""{
//                                    NavigationLink(
//                                        destination: CurrentUserProfilePage(user: user, isCurrentUser: false),
//                                        label: {
//                                            UserSearchCell(user: user, showActivity: false)
//                                        })
//                                    }
//
//                                }
//
//                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
//                        }else{
//                            VStack{
//                                ForEach(searchRepository.userReturnedResults, id: \.id) { user in
//                                    NavigationLink(
//                                        destination: CurrentUserProfilePage(user: user, isCurrentUser: false),
//                                        label: {
//                                            UserSearchCell(user: user, showActivity: false)
//                                        })
//
//                                }
//                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
//                        }
//
//
//
//
//                    }
//                }
//            }.padding(.top,50)
//        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
//            searchRepository.startSearch(searchRequest: "groupUsersFollowers", id: group.id)
//
//
//            groupVM.loadGroupFollowers(groupID: group.id)
//
//
//
//        }
//    }
//}
//
//struct GroupFollowersView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupFollowersView()
//    }
//}

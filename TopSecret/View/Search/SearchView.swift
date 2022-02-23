//
//  SearchView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/1/22.
//

import SwiftUI
import Combine

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var searchRepository = SearchRepository()
    @EnvironmentObject var userVM : UserViewModel

    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack(alignment: .center){
                    SearchBar(text: $searchRepository.searchText, placeholder: "friends and groups")
                        .padding(.top)
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Cancel").foregroundColor(.gray).fontWeight(.bold)
                    }).padding([.trailing,.top])
                }.padding(.top,40)
                
                
                ScrollView(){
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            if !searchRepository.searchText.isEmpty{
                                Text("Users").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                            }
                            VStack{
                                ForEach(searchRepository.userReturnedResults, id: \.id) { user in
                                    if user.id != userVM.user?.id{
                                    NavigationLink(
                                        destination: UserProfilePage(user: user, isCurrentUser: false),
                                        label: {
                                            UserSearchCell(user: user)
                                        })
                                    }
                                }
                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading){
                            if !searchRepository.searchText.isEmpty{
                                Text("Groups").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                            }
                            VStack{
                                ForEach(searchRepository.groupReturnedResults, id: \.id) { group in
                                    
                                    NavigationLink(destination: GroupProfileView(group: group)) {
                                        GroupSearchCell(group: group)
                                    }
                                
                                }
                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                        }
                        
                        

                    }
                    
                    
                }
                Spacer()
            }
       

        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchRepository.startSearch(searchRequest: "allGroupsAndUsers", id: "")
        }
    }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}

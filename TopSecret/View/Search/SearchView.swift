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
    @State var openGroupProfile : Bool = false
    @State var selectedGroup : Group = Group()
    
    
    func convertToBinding(users: [User]) -> Binding<[User]>{
        
        
        return Binding(get: {users}, set: {_ in})
    }

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
                                ForEach(self.convertToBinding(users: searchRepository.userReturnedResults), id: \.id) { user in
                                    NavigationLink(
                                        destination: UserProfilePage(user: user, isCurrentUser: false),
                                        label: {
                                            UserSearchCell(user: user, showActivity: true)
                                        })
                                    
                                }
                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading){
                            if !searchRepository.searchText.isEmpty{
                                Text("Groups").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                            }
                            VStack{
                                ForEach(searchRepository.groupReturnedResults, id: \.id) { group in
                                    
                                    Button(action:{
                                        selectedGroup = group
                                        openGroupProfile.toggle()
                                    },label:{
                                        GroupSearchCell(group: group)
                                    })
                                    
                                   
                                
                                }
                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                        }
                        
                        

                    }
                    
                    
                }
                Spacer()
            }
            
            
            NavigationLink(destination: GroupProfileView(group: $selectedGroup, isInGroup: selectedGroup.users?.contains(userVM.user?.id ?? " ") ?? false, showProfileView: $openGroupProfile), isActive: $openGroupProfile){
                EmptyView()
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

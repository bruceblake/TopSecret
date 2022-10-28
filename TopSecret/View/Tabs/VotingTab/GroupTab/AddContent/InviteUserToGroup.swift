//
//  InviteUserToGroup.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/23/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct InviteUserToGroup: View {
    
    @State var username : String = ""
    @Binding var group : Group
    @StateObject var groupVM = GroupViewModel()
    @StateObject var searchRepository = SearchRepository()
    @State var selectedUsers : [User] = []
    @EnvironmentObject var userVM : UserViewModel

    
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

                }.padding(.top,50)
                
                Spacer()
                VStack{
                    Text("Enter Username").fontWeight(.bold).font(.largeTitle).foregroundColor(FOREGROUNDCOLOR)
                    SearchBar(text: $searchRepository.searchText, onSubmit: {
                        
                    })
                    
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(selectedUsers){ user in
                                HStack{
                                    Text("\(user.username ?? "")")
                                    Button(action:{
                                        selectedUsers.removeAll(where: {$0 == user})
                                    },label:{
                                        Image(systemName: "x.circle.fill")
                                    }).foregroundColor(FOREGROUNDCOLOR)
                                }.padding(10).background(RoundedRectangle(cornerRadius: 15).fill(Color("AccentColor")))
                            }
                        }
                    }.padding(.top,10)
                    

                    
                    
                    Spacer()
                    
                    VStack{
                        ForEach(searchRepository.userReturnedResults){ user in
                            Button(action:{
                                if selectedUsers.contains(user){
                                    selectedUsers.removeAll(where: {$0 == user})
                                }else{
                                    selectedUsers.append(user)
                                }
                            },label:{
                                if user.id != userVM.user?.id{
                               
                                
                                VStack(alignment: .leading){
                                    HStack{
                                        
                                        WebImage(url: URL(string: user.profilePicture ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width:48,height:48)
                                            .clipShape(Circle())
                                        
                                        Text("\(user.username ?? "")").foregroundColor(FOREGROUNDCOLOR)
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedUsers.contains(user) ? "checkmark.circle.fill" : "circle").font(.title)
                                        
                                    }.padding(.horizontal,10).padding(.vertical)
                                    Divider()
                                }
                                }
                            })
                        }
                        
                        
                    }
                    
                    Button(action:{
                        
                        let dp = DispatchGroup()
                        
                        
                        for user in selectedUsers {
                            dp.enter()
                            groupVM.sendGroupInvitation(group: group, friend: user, userID: self.userVM.user?.id ?? " ")
                            dp.leave()
                        }
                        
                    
                        
                        dp.notify(queue: .main) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    },label:{
                        Text( selectedUsers.count <= 1 ? "Add User To Group!" : "Add Users To Group!")
                    })
                    
                    Spacer()
                }
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchRepository.startSearch(searchRequest: "allUsers", id: "")
        }
    }
}

//struct InviteUserToGroup_Previews: PreviewProvider {
//    static var previews: some View {
//        InviteUserToGroup()
//    }
//}

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
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    
                    Text("Invite Friend To Group").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline)
                    
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)

                }.padding(.top,50).padding(.horizontal)
                
                Spacer()
                VStack{
         
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
                    }.padding(10)
                    

                    
                    
                    
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
                                            .frame(width:40,height:40)
                                            .clipShape(Circle())
                                        
                                        Text("\(user.username ?? "")").foregroundColor(FOREGROUNDCOLOR)
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedUsers.contains(user) ? "checkmark.circle.fill" : "circle").font(.title).foregroundColor(FOREGROUNDCOLOR)
                                        
                                    }.padding(.horizontal,10)
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
                        Text( selectedUsers.count <= 1 ? "Add User To Group!" : "Add Users To Group!").foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                    }).padding(.vertical)
                    
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

//
//  InviteMembersToEventView.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/26/23.
//

import SDWebImageSwiftUI
import SwiftUI

struct InviteMembersToEventView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @Binding var selectedUsers : [User]
    @StateObject var searchVM = SearchRepository()
    @Binding var openInviteFriendsView: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        
        ZStack{
            Color("Color")
        VStack(spacing: 20){
            
            HStack{
                
                Button(action:{
                    self.openInviteFriendsView.toggle()
                },label:{
                    ZStack{
                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Background"))
                        Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                    }
                })
                SearchBar(text: $searchVM.searchText, placeholder: "search", onSubmit:{
                    searchVM.hasSearched = true
                }, backgroundColor: Color("Background"))
            }.padding(.top,30)
            
            
            VStack(alignment: .leading){
               
                if !selectedUsers.isEmpty{
                    Text("Invited Users").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                }
                ScrollView(.horizontal){
                    HStack{
                        ForEach(selectedUsers, id: \.id){ user in
                            if user.id != userVM.user?.id ?? "" {
                                Button(action:{
                                    searchVM.searchText = user.nickName ?? ""
                                },label:{
                                    HStack{
                                        Text(user.nickName ?? "").foregroundColor(FOREGROUNDCOLOR)
                                        Button(action:{
                                            selectedUsers.removeAll(where: {$0 == user})
                                        },label:{
                                            Image(systemName: "x.circle.fill")
                                        }).foregroundColor(FOREGROUNDCOLOR)
                                    }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                                    
                                })
                                
                            }
                        }
                    }
                }
            }.padding(.top)
            
                ScrollView(){
                    VStack(spacing: 10){
  
                            VStack(alignment: .leading){
                                if !searchVM.userFriendsReturnedResults.isEmpty{
                                    VStack(alignment: .leading){
                                        Text("Friends").fontWeight(.bold).foregroundColor(Color("Foreground"))
                                    }
                                }
                                ForEach(searchVM.userFriendsReturnedResults, id: \.id){ friend in
                                Button(action:{
                                    if selectedUsers.contains(friend){
                                        selectedUsers.removeAll { user in
                                            user.id == friend.id ?? ""
                                        }
                                    }else{
                                    selectedUsers.append(friend)
                                    }
                                },label:{
                                HStack{
                                    
                                    WebImage(url: URL(string: friend.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading){
                                        Text("\(friend.nickName ?? "")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                        Text("@\(friend.username ?? "")").font(.footnote).foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    Circle().frame(width: 20, height: 20).foregroundColor(selectedUsers.contains(friend) ? Color("AccentColor") : FOREGROUNDCOLOR)
                                    
                               
                                }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background")))
                                })
                            
                                
                            }
                                
                                
                                
                                
                                
                            }
                       
                    }
                        
                    
                }.gesture(DragGesture().onChanged { _ in
                    UIApplication.shared.keyWindow?.endEditing(true)
                })
            
            Button(action:{
             
                presentationMode.wrappedValue.dismiss()
            },label:{
                Text("Add Members").foregroundColor(FOREGROUNDCOLOR)
                .frame(width: UIScreen.main.bounds.width/1.5).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                    
            }).padding(.vertical,10).padding(.bottom,30)
            
         Spacer()
            
           
           
          
        }.padding()
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUserFriendsAndGroups", id: userVM.user?.id ?? " ")
            
        }
        
        
        
        
    }
}


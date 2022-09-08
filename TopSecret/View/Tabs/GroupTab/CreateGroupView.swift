//
//  CreateGroupView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct CreateGroupView: View {
    
    @EnvironmentObject var userVM : UserViewModel

    @Environment(\.presentationMode) var presentationMode
    @StateObject var groupVM = GroupViewModel()
    @State var isShowingPhotoPicker:Bool = false
    @State var avatarImage = UIImage(named: "Icon")!
    @State var images : [UIImage] = []
    @State var groupName : String = ""
    @State var selectedUsers : [User] = []
    @StateObject var searchVM = SearchRepository()
    
    var body: some View {
        ZStack(alignment: .topLeading){
            Color("Background")
            VStack{
                
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                    Spacer()
                    
                    Text("Create Group!").fontWeight(.bold).font(.title).padding(.trailing,10)
                    
                    Spacer()
                    

                }.padding(.top,50)
                
                
                
               
            
          
                VStack(spacing: 20){
                    
              
                    
                    //group pfp
                    VStack(alignment: .leading){
                        Text("Group Profile Picture").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        
                        HStack{
                            
                        Spacer()
                            
                        Button(action:{
                            isShowingPhotoPicker.toggle()
                        },label:{
                            Image(uiImage: avatarImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width:45,height:45)
                                .clipShape(Circle())
                                .padding()
                        }).fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                            ImagePicker(avatarImage: $avatarImage, allowsEditing: true)
                        })
                            
                        Spacer()
                        }
                        
                    }.padding(.horizontal)
                    
                    //group name
                    VStack(alignment: .leading){
                        Text("Group Name").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        VStack{
                            CustomTextField(text: $groupName, placeholder: "Group Name", isPassword: false, isSecure: false, hasSymbol: false ,symbol: "")
                        }
                    }.padding(.horizontal)
                    //select users
                    VStack(alignment: .leading){
                        Text("Select Users for Group").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        VStack(spacing: 20){
                            
                            HStack{
                                SearchBar(text: $searchVM.searchText, placeholder: "search", onSubmit:{
                                    searchVM.hasSearched = true
                                }, backgroundColor: Color("Background"))
                            }
                            
                            
                            
                            VStack{
                                ScrollView(){
                                    VStack(spacing: 10){
                                        
                                        if searchVM.hasSearched{
                                            VStack(alignment: .leading){
                                                if !searchVM.searchText.isEmpty && !searchVM.userFriendsReturnedResults.isEmpty{
                                                    Text("Friends").fontWeight(.bold).foregroundColor(Color("Foreground"))
                                                }
                                                ForEach(searchVM.userFriendsReturnedResults, id: \.id){ friend in
                                                    
                                                    Button(action:{
                                                        if selectedUsers.contains(friend){
                                                            selectedUsers.removeAll { user in
                                                                friend.id == user.id ?? ""
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
                                                
                                                VStack(alignment: .leading){
                                                    if !searchVM.searchText.isEmpty && !searchVM.userReturnedResults.isEmpty{
                                                        Text("Users").fontWeight(.bold).foregroundColor(Color("Foreground"))
                                                    }
                                                    ForEach(searchVM.userReturnedResults, id: \.id){ user in
                                                        
                                                        if !(userVM.user?.friendsList?.contains(user) ?? false) {
                                                            Button(action:{
                                                                if selectedUsers.contains(user){
                                                                    selectedUsers.removeAll { selectedUser in
                                                                        selectedUser.id == user.id ?? ""
                                                                    }
                                                                }else{
                                                                selectedUsers.append(user)
                                                                }
                                                            },label:{
                                                                HStack{
                                                                    
                                                                    WebImage(url: URL(string: user.profilePicture ?? ""))
                                                                        .resizable()
                                                                        .scaledToFill()
                                                                        .frame(width:40,height:40)
                                                                        .clipShape(Circle())
                                                                    
                                                                    VStack(alignment: .leading){
                                                                        Text("\(user.nickName ?? "")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                                                        Text("@\(user.username ?? "")").font(.footnote).foregroundColor(.gray)
                                                                    }
                                                                    
                                                                    Spacer()
                                                                    Circle().frame(width: 20, height: 20).foregroundColor(selectedUsers.contains(user) ? Color("AccentColor") : FOREGROUNDCOLOR)
                                                                    
                                                               
                                                                }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background")))
                                                            })
                                                        }
                                                        
                                                      
                                                      

                                                         
                                                        

                                                     
                                                    }
                                                }
                                            }
                                        }else{
                                           
                                            VStack(alignment: .leading){
                                                VStack(alignment: .leading){
                                                    Text("Friends").fontWeight(.bold).foregroundColor(Color("Foreground"))
                                                }
                                                
                                            ForEach(userVM.user?.friendsList ?? [], id: \.id){ friend in
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
                                
                                        
                                        
                                        
                                    }
                                        
                                    
                                }
                            }
                            
                            
                           
                          
                        }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                    }.padding(.horizontal)
                     
                    VStack(alignment: .leading){
                        Text("Selected Users").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(selectedUsers, id: \.id){ user in
                                    if user.id == userVM.user?.id ?? "" {
                                        Text("YOU").padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                                    }else{
                                        Button(action:{
                                            searchVM.searchText = user.nickName ?? ""
                                        },label:{
                                    Text(user.nickName ?? "").padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                                        })
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal)
                    
                }
                
             
                
                

            Button(action:{
                let id = UUID().uuidString
                groupVM.createGroup(groupName: groupName, dateCreated: Date(), users: selectedUsers.map({ user in
                    return user.id ?? ""
                }) ,image: avatarImage,id: id)
              
     
                
                presentationMode.wrappedValue.dismiss()
            },label:{
                Text("Create Group").frame(width: UIScreen.main.bounds.width/1.5).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                    
            }).padding(.vertical,10).padding(.bottom,30)
            

            Spacer()
        
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsersAndUsersFriends", id: userVM.user?.id ?? " ")
            self.selectedUsers.append(userVM.user ?? User())
        }
}
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}

//
//  AddChatView.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/17/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct AddChatView: View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var searchRepository = SearchRepository()
    @StateObject var groupVM = GroupViewModel()
    
    @State var selectedUsers : [User] = []
    @State var chat: ChatModel = ChatModel()
    @State var goToPersonalChat: Bool = false
    @State var goToGroupChat: Bool = false
    
    @Environment(\.presentationMode) var dismiss
    
    @StateObject var chatVM = ChatViewModel()
    
    func getUsersID(users: [User]) -> [String]{
        var usersID: [String] = []
        var id : String = ""
        for user in users {
            id = user.id ?? ""
            usersID.append(id)
        }
        return usersID
    }
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack{
                    Button(action:{
                        //TODO
                        dismiss.wrappedValue.dismiss()
                    },label:{
                        Text("Back")
                        
                    }).padding(.leading)
                    
                    Spacer()
                    
                    Text("New Message!")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action:{
                        //TODO
                        if selectedUsers.count == 1 {
                            //create personal chat with 1 person
                            chatVM.createPersonalChat(user1: userVM.user?.id ?? "", user2: selectedUsers[0].id ?? "") { personalChat in
                                self.chat = personalChat
                                self.goToPersonalChat.toggle()
                            }
                        }else{
                            //create group with multiple people
                            self.selectedUsers.append(userVM.user ?? User())
                            groupVM.createGroup(currentUser: userVM.user?.id ?? "", groupName: "New Group", memberLimit: 50, dateCreated: Date(), users: self.getUsersID(users: selectedUsers), image: UIImage(named: "Icon")!, completion:{ groupChat in
                                self.chat = groupChat
                                self.goToGroupChat.toggle()
                            })
                        }
                    },label:{
                        Text("Chat")
                    }).padding(.trailing).disabled(selectedUsers.isEmpty)
                    
                }.padding()
                
                    SearchBar(text: $searchRepository.searchText)
                
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
                
                
                ScrollView{
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
                }
                
                
            }.padding(.top,50)
            NavigationLink(
                destination: PersonalChatView(chat: chat),
                isActive: $goToPersonalChat,
                label: {
                    EmptyView()
                })
            NavigationLink(
                destination: ChatView(uid: userVM.user?.id ?? "", chat: chat),
                isActive: $goToGroupChat,
                label: {
                    EmptyView()
                })
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchRepository.startSearch(searchRequest: "allUsers", id: "")
        }
        
    }
}

//struct AddChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddChatView()
//    }
//}

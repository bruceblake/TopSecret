////
////  PollInfoOverlay.swift
////  TopSecret
////
////  Created by Bruce Blake on 2/1/22.
////
//
//import SwiftUI
//
//struct PollInfoOverlay: View {
//    
//    @State var selectedIndex = 0
//    
//    @Binding var poll : PollModel
//    @StateObject var pollVM = PollViewModel()
//    @EnvironmentObject var userVM : UserViewModel
//    
//    func getUsersAnswered(usersAnswered : [String:String]) -> [String] //first is the user, second is the choice
//    {
//        var ans : [String] = []
//        for map in usersAnswered {
//            
//            ans.append(map.key)
//            ans.append(map.value)
//        }
//    
//        return ans
//    }
//    
//    var body: some View {
//        VStack{
//            
//            
//            VStack{
//                HStack{
//                    Button(action:{
//                        withAnimation(.easeIn){
//                            selectedIndex = 0
//                        }
//                    },label:{
//                        Text("Who Voted").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
//                    }).background(selectedIndex == 0 ? Color(.gray) : Color("")).cornerRadius(12).padding(.leading)
//                    
//                    Spacer()
//                    
//                    Button(action:{
//                        withAnimation(.easeIn){
//                            selectedIndex = 1
//                        }
//                    },label:{
//                        Text("Users Visible To").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
//                    }).background(selectedIndex == 1 ? Color(.gray) : Color("")).cornerRadius(12).padding(.trailing)
//                    
//                }.padding(10).padding(.vertical).background(Color("Background"))
//            
//            if selectedIndex == 0{
//                ScrollView(){
//                    VStack{
//                        ForEach(poll.usersAnswered ?? [], id: \.self){ map in
//                            if poll.usersAnswered!.isEmpty {
//                                HStack{
//                                    Text("No Answers")
//                                   
//                                }.padding(.top,10)
//                            }else{
//                                HStack{
//                                    Text("\(getUsersAnswered(usersAnswered: map)[0])")
//                                    Text(":")
//                                    Text("\(getUsersAnswered(usersAnswered: map)[1])")
//                                }.padding(.top,10)
//                            }
//                          
//                            Divider()
//                        }
//
//                    }
//                }
//            }else{
//                ScrollView(){
//                    VStack{
//                        ForEach(poll.users ?? [], id: \.self){ user in
//                          
//                            UserVisibleToCell(userID: user)
//                          
//                            Divider()
//                        }
//
//                    }
//                }
//            }
//            
//            }.background(Color("Color")).cornerRadius(16).padding(.leading,40).padding(.trailing)
//            
//            
//            
//            HStack(spacing: 15){
//                    
//                    Button(action:{
//                      
//                        pollVM.endPoll(pollID: poll.id ?? "")
//                        
//                    },label:{
//                        Text("End Poll")
//                    }).foregroundColor(FOREGROUNDCOLOR)
//                
//            
//                    
//                    Button(action:{
//                        
//                    },label:{
//                        Text("Hide Poll")
//                    }).foregroundColor(FOREGROUNDCOLOR)
//
//                }
//                .padding().background(Color("Color")).cornerRadius(16)
//            
//            
//        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
//    
//    }
//}
//
//
//struct UserVisibleToCell : View {
//    
//    @State var user : User = User()
//    @EnvironmentObject var userVM: UserViewModel
//    var userID: String
//    
//    var body: some View {
//        
//          
//            
//            VStack{
//                Text("\(user.username ?? "")").foregroundColor(FOREGROUNDCOLOR)
//            }
//        .onAppear{
//            userVM.fetchUser(userID: userID) { fetchedUser in
//                self.user = fetchedUser
//            }
//        }
//    }
//}
//
////struct PollInfoOverlay_Previews: PreviewProvider {
////    static var previews: some View {
////        PollInfoOverlay()
////    }
////}

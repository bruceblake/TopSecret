//
//  HomeScreen.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/3/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeScreen: View {

    @EnvironmentObject var userVM: UserViewModel
   
    @State var showSearch : Bool = false
    @State var selectedViewOption = 1
    
    var body: some View {
        ZStack{
            Color("Background")


            ZStack(alignment: .top){
                    
                  
                    
                    if selectedViewOption == 0 {
                        YourGroupsView()
                    }else{
                        YourFeedView()
                    }
                
                HStack(spacing: 20){
                    
                    Spacer()
                    Button(action:{
                        selectedViewOption = 0
                    },label:{
                        VStack(spacing: 5){
                            Text("Your Groups").foregroundColor(selectedViewOption == 0 ? FOREGROUNDCOLOR : Color.gray)
                            Rectangle().frame(width: 50, height: 2).foregroundColor(selectedViewOption == 0 ? FOREGROUNDCOLOR : Color.clear)
                        }
                    })
                    
                    
                    Button(action:{
                        selectedViewOption = 1
                    },label:{
                        VStack(spacing: 5){
                            Text("Your Feed").foregroundColor(selectedViewOption == 1 ? FOREGROUNDCOLOR : Color.gray)
                            Rectangle().frame(width: 40, height: 2).foregroundColor(selectedViewOption == 1 ? FOREGROUNDCOLOR : Color.clear)
                        }
                    })
                    
                    Spacer()
                    
                }
                
                    
                }
//                    ShowGroups(selectedGroup: $selectedGroup, users: $users, openGroupHomescreen: $openGroupHomescreen)
            
                
           


             


        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)










        }

    }


struct YourGroupsView : View {
    
    var body: some View {
        ScrollView{
            VStack{
                Spacer()
                Text("Your Groups")
                Spacer()
            }
        }
      
    }
}

struct YourFeedView : View {
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(spacing: 15){
                 ForEach(userVM.feed.indices){ feedItemIndex in
                    GroupPostCell(post: userVM.feed[feedItemIndex] as? GroupPostModel ?? GroupPostModel())
                }
            }.padding(.top,40)
        }.padding(.bottom,UIScreen.main.bounds.height / 8)
    }
}

    struct ShowGroups : View {

        @EnvironmentObject var userVM: UserViewModel
        @Environment(\.refresh) private var refresh
        @Binding var selectedGroup : Group
        @Binding var users: [User]
        @Binding var openGroupHomescreen : Bool

        var widthAdd : CGFloat = 50
        var heightDivide: CGFloat = 5
        var width : CGFloat = UIScreen.main.bounds.width
        var height : CGFloat = UIScreen.main.bounds.height

        

        var body: some View{
            ScrollView(showsIndicators: false){
                VStack(spacing: 30){
                    
                    if userVM.finishedFetchingGroups {
                            ForEach(userVM.groups, id: \.id){ group in
                                Button(action:{

                                    let dispatchGroup = DispatchGroup()



                                    dispatchGroup.enter()
                                    self.selectedGroup = group
                                    dispatchGroup.leave()

                                    dispatchGroup.notify(queue: .global(), execute:{
                                        openGroupHomescreen.toggle()
                                    })

                                },label:{
                                    VStack{
                                        VStack(alignment: .leading){



                                            HStack{
                                                Spacer()
                                            }.padding(50).background(WebImage(url: URL(string: group.groupProfileImage ?? "")).resizable().scaledToFill())


                                            HStack(alignment: .top){

                                                VStack(alignment: .leading,spacing:10){
                                                    Text(group.groupName).font(.headline).bold().foregroundColor(FOREGROUNDCOLOR)

                                                    HStack{
                                                        Text(group.motd)
                                                    }.foregroundColor(FOREGROUNDCOLOR)

                                                    HStack{
                                                        Text("\(group.memberAmount) \(group.memberAmount == 1 ? "member" : "members")").foregroundColor(FOREGROUNDCOLOR)


                                                    }
                                                }

                                                Spacer(minLength: 0)
                                            }.padding(10).background(Rectangle().foregroundColor(Color("Color")))


                                        }.cornerRadius(10)

                                    }.shadow(color: Color.black, radius: 5).frame(width: width - widthAdd, height: height/heightDivide).padding(.top,30)





                                })

                            }

                        }

                    else {
                        if userVM.timedOut{
                            ZStack{
                            Button(action:{
                                userVM.startFetch = true
                                userVM.timedOut.toggle()
                                
                            },label:{
                                VStack{
                                Text("Unable to fetch groups")
                                  Text("Refresh")
                                }
                             
                            })
                            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        }else{
                       
                            ZStack{
                                ProgressView()
                            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                           
                        
                        }
                    }
                    
                 


                }.padding(.bottom, UIScreen.main.bounds.height/4)

            }.onReceive(userVM.$startFetch) { output in
                userVM.refresh()
            }
            .edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
        }
    }


//
//  HomeScreen.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/3/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Foundation
import SwiftUIPullToRefresh


struct ShowGroups : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var selectedGroupVM: SelectedGroupViewModel
    @Environment(\.refresh) private var refresh
    @Binding var selectedGroup : Group
    @Binding var users: [User]
    @Binding var openGroupHomescreen : Bool
    
    var widthAdd : CGFloat = 50
    var heightDivide: CGFloat = 3
    var width : CGFloat = UIScreen.main.bounds.width
    var height : CGFloat = UIScreen.main.bounds.height
    
    
    
    var body: some View{
        VStack(alignment: .leading){
            Text("You are in \(userVM.groups.count) \(userVM.groups.count > 1 ? "groups" : "group")").fontWeight(.bold)
            ScrollView(showsIndicators: false){
                VStack(spacing: 40){
                    
                    if userVM.connected {
                        ForEach(userVM.groups, id: \.id){ group in
                            Button(action:{
                                
                                let dispatchGroup = DispatchGroup()
                                
                                
                                
                                dispatchGroup.enter()
                                self.selectedGroup = group
                                selectedGroupVM.changeCurrentGroup(groupID: group.id){ finishedFetching in
                                    if finishedFetching{
                                        dispatchGroup.leave()
                                    }
                                }

                                dispatchGroup.notify(queue: .main, execute:{
                                    openGroupHomescreen.toggle()
                                })
                                
                            },label:{
                                VStack(spacing: 0){
                                        
                                        
                                        
                                    WebImage(url: URL(string: group.groupProfileImage)).resizable().scaledToFill().clipped()
                                        
                                        
                                        HStack(alignment: .top){
                                            
                                            VStack(alignment: .leading,spacing:10){
                                                Text(group.groupName).font(.headline).bold().foregroundColor(FOREGROUNDCOLOR)
                                                
                                                HStack{
                                                    Text(group.motd)
                                                }.foregroundColor(FOREGROUNDCOLOR)
                                                
                                                HStack{
                                                    Text("\(group.memberAmount) \(group.memberAmount == 1 ? "member" : "members")").foregroundColor(FOREGROUNDCOLOR)
                                                    
                                                    
                                                }
                                                
                                                Spacer()
                                            }.padding(10)
                                            
                                            Spacer(minLength: 0)
                                        }.frame(height: 150).background(Rectangle().foregroundColor(Color("Color")))
                                        
                                        
                                    }.frame(width: width - widthAdd).clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            })
                            
                        }
                        
                    }else{
                        Text("Unable to connect!").foregroundColor(Color.gray)
                    }
                    
                   
                    
                    
                    
                }.padding(.bottom, UIScreen.main.bounds.height/4)
                
            }
        }
       
        .edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
}


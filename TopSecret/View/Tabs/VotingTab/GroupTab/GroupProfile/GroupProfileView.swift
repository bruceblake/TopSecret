//
//  GroupProfileView.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/26/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupProfileView: View {
    
    @Binding var group : Group
    @State var editBio : Bool = false
    @EnvironmentObject var userVM : UserViewModel
    @ObservedObject var groupVM = GroupViewModel()
    
    
    
    @State var selectedView = 0
    
     var options = ["Posts","Members","Info","Settings"]
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                //STORY
                Circle().frame(width: 50, height: 50)
                
                //GROUP NAME
                Text("\(group.groupName)").font(.largeTitle).foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                
                //BIO
                if(group.users?.contains(userVM.user?.id ?? " ") ?? false){
                    HStack(alignment: .center){
                        
                        Spacer()
                        
                        HStack(alignment: .firstTextBaseline){
                            Spacer()
                            Text("\(group.bio ?? "GROUP_BIO")").foregroundColor(FOREGROUNDCOLOR).font(.body)
                        

                            Button(action:{
                                editBio.toggle()
                            },label:{
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                    Image(systemName: "pencil").foregroundColor(FOREGROUNDCOLOR).font(.body)
                                }
                            }).sheet(isPresented: $editBio) {
                                GroupEditBio(bio: group.bio ?? "GROUP_BIO", group: $group)
                            }
                            
                            Spacer()
                        }
                        
                       
                        
                            
                        
                        Spacer()
                    }
                }else{
                    Text("\(group.bio ?? "GROUP_BIO")").foregroundColor(FOREGROUNDCOLOR).font(.body)
                }
                
                //BADGES
                
                
                
                VStack{
                    HStack(spacing: 30){
                        
                        ForEach(0..<4){ i in
                            Button(action:{
                                withAnimation(.easeIn){
                                    selectedView = i
                                }
                            
                            },label:{
                                    Text("\(options[i])").fontWeight(.bold).font(.body)
                            }).foregroundColor(selectedView == i ? Color("AccentColor") : FOREGROUNDCOLOR)
                        }
                         
                        
                    }.padding(.vertical).padding(.leading,5).padding(.horizontal,15)
                    
                    HStack{
                        RoundedRectangle(cornerRadius: 16).frame(width: (UIScreen.main.bounds.width/5) * CGFloat((selectedView + 2)),height: 4).foregroundColor(Color("AccentColor"))
                        Spacer()
                    }
               
                        
                }
            
                
                
                TabView(selection: $selectedView){
                   Text("Posts").tag(0)
                   Text("Members").tag(1)
                   Text("Info").tag(2)
                    Text("Settings").tag(3)
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                Spacer()
                
                Button(action:{
                    groupVM.leaveGroup(groupID: group.id, userID: userVM.user?.id ?? " ")
                },label:{
                    Text("Leave Group")
                })
                
            }
            
            
        
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
    }
    
    
//    struct GroupProfileView_Previews: PreviewProvider {
//        static var previews: some View {
//            GroupProfileView(group: Group()).colorScheme(.dark)
//        }
//    }
    
    

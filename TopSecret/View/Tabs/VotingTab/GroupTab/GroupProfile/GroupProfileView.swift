//
//  GroupProfileView.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/26/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupProfileView: View {
    
    var group : Group
    var isInGroup : Bool
    @EnvironmentObject var userVM : UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var selectedView = 0
    
   
    var body: some View {
      
        ZStack{
            Color("Background")
            VStack{
                VStack(spacing: 4){
                    HStack(alignment: .top){
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                        
                        Spacer()
                        
                        WebImage(url: URL(string: group.groupProfileImage))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width:80,height:80)
                                            .clipShape(Circle())
                        Spacer()
                        
                        if isInGroup {
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "gear").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                        }else{
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                        }

                    }.padding(.top,50).padding(.horizontal)
                    
                    VStack{
                        Text("\(group.groupName)").font(.title2).bold().foregroundColor(FOREGROUNDCOLOR)
                        Text("\(group.bio)").font(.body).foregroundColor(FOREGROUNDCOLOR)
                        
                        HStack(alignment: .center){
                            HStack{
                                
                            Spacer()
                            
                            VStack(spacing: 3){
                                Text("20").foregroundColor(FOREGROUNDCOLOR).bold().font(.system(size: 20))
                                Text("Posts").foregroundColor(Color.gray).font(.system(size: 16))
                            }
                                
                                Spacer()
                        }
                            HStack{
                                Divider().frame(width: 2, height: 30)
                                
                                Spacer()
                                VStack(spacing: 3){
                                    Text("\(group.users.count)").foregroundColor(FOREGROUNDCOLOR).bold().font(.system(size: 20))
                                    Text("Members").foregroundColor(Color.gray).font(.system(size: 16))
                                }
                                Spacer()
                                
                                Divider().frame(width: 2, height: 30)
                            }
                         
                            
                            HStack{
                                Spacer()
                                VStack(spacing: 3){
                                    Text("\(group.followersID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).bold().font(.system(size: 20))
                                    Text("Followers").foregroundColor(Color.gray).font(.system(size: 16))
                                }
                                
                                Spacer()
                            }
                         
                        }
                    }
                    
                    
                    if isInGroup{
                        
                        Text("In Group").foregroundColor(Color.gray).font(.body)
                    }else{
                        
                        if group.followersID?.contains(userVM.user?.id ?? " ") ?? false{
                            Button(action:{
                                userVM.unfollowGroup(groupID: group.id, userID: userVM.user?.id ?? " ")
                            },label:{
                                Text("Unfollow").padding(10).foregroundColor(FOREGROUNDCOLOR).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                            }).padding(10)
                        }else{
                            Button(action:{
                                userVM.followGroup(groupID: group.id, userID: userVM.user?.id ?? " ")
                                
                            },label:{
                                Text("Follow").padding(10).foregroundColor(FOREGROUNDCOLOR).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                            }).padding(10)
                        }
                  
                        
                    }
                    
                }
               
                
                Spacer()
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
            
            
    }
}


//    struct GroupProfileView_Previews: PreviewProvider {
//        static var previews: some View {
//            GroupProfileView(group: Group()).colorScheme(.dark)
//        }
//    }



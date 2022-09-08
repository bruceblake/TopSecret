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
    @Environment(\.presentationMode) var presentationMode
    var isInGroup : Bool
    @Binding var showProfileView : Bool
    @State var selectedView = 0
    
   
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                
                HStack{
                    Button(action:{
                        withAnimation(.spring()){
                            if isInGroup{
                                showProfileView.toggle()
                            }else{
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    },label:{
                        Image(systemName: "x.circle").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                    }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(.leading,10)
                    Spacer()
                    
                        
                       
                        
                    
                }.padding(.top,50)
                
                //STORY
                Button(action:{
                    //TODO - OPEN STORY
                },label:{
                    WebImage(url: URL(string: group.groupProfileImage ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:80,height:80)
                        .clipShape(Circle())
                })
                
                
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
                                    Circle().foregroundColor(Color("Color")).frame(width: 30, height: 30)
                                    Image(systemName: "pencil").foregroundColor(FOREGROUNDCOLOR).font(.body)
                                }
                            }).sheet(isPresented: $editBio) {
                            
                            }
                            
                            Spacer()
                        }
                        
                        
                        
                        
                        
                        Spacer()
                    }
                }else{
                    Text("\(group.bio ?? "GROUP_BIO")").foregroundColor(FOREGROUNDCOLOR).font(.body)
                }
                
                //BADGES
                
                ScrollView(.horizontal, showsIndicators: false){
                    
                    HStack{
                        
                        Button(action:{
                            
                        },label:{
                            Image("firstPlaceMedal").resizable().frame(width: 30, height: 30)
                        })
                        
                        Button(action:{
                            
                        },label:{
                            Image("secondPlaceMedal").resizable().frame(width: 30, height: 30)
                        })
                        
                        Button(action:{
                            
                        },label:{
                            Image("thirdPlaceMedal").resizable().frame(width: 30, height: 30)
                        })
                        
                        
                    }.padding(0)
                }.padding(.leading)
                
                HStack(spacing: 70){
                    
                    Button(action:{
                        
                    },label:{
                        VStack(spacing: 5){
                            Text("Followers").foregroundColor(FOREGROUNDCOLOR).font(.title3).fontWeight(.bold)
                            Text("407").foregroundColor(Color("AccentColor")).font(.headline)

                        }
                    }).padding(.leading)
                    
                    
                    
                    Button(action:{
                        
                    },label:{
                        VStack(spacing: 5){
                            Text("Strength").foregroundColor(FOREGROUNDCOLOR).font(.title3).fontWeight(.bold)
                            Text("88%").foregroundColor(Color("AccentColor")).font(.headline)

                        }
                    }).padding(.trailing)
                    
                    
                }.padding(.bottom)
                
                
                
                
                HStack(spacing: UIScreen.main.bounds.width/2.8){
                    
                    Button(action:{
                            withAnimation(.easeIn){
                                selectedView = 0
                            }
                        },label:{
                            
                            VStack{
                                Text("Posts").foregroundColor(selectedView == 0 ? Color("AccentColor") : FOREGROUNDCOLOR).fontWeight(.bold).font(.body)
                                
                                RoundedRectangle(cornerRadius: 16).frame(width: 100, height: 4).foregroundColor(selectedView == 0 ? Color("AccentColor") : FOREGROUNDCOLOR)
                            }
                        })
                    
                    
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 1
                        }
                    },label:{
                        
                        VStack{
                            Text("Info").foregroundColor(selectedView == 1 ? Color("AccentColor") : FOREGROUNDCOLOR).fontWeight(.bold).font(.body)
                            
                            RoundedRectangle(cornerRadius: 16).frame(width: 100, height: 4).foregroundColor(selectedView == 1 ? Color("AccentColor") : FOREGROUNDCOLOR)
                        }
                        
                    })
                    
                }.padding(.top)
                

                TabView(selection: $selectedView){
                    
                    VStack{
                        
                    }
                    
                    Text("Posts").tag(0)
                    Text("Info").tag(1)
                    
                    
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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



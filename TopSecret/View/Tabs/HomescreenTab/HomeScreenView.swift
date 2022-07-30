//
//  HomeScreenView.swift
//  TopSecret
//
//  Created by nathan frenzel on 8/31/21.
//

import SwiftUI
import SDWebImageSwiftUI
import MediaCore
import MediaSwiftUI

struct HomeScreenView: View {
    
    
    
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    @StateObject var groupRepository = GroupRepository()
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel

    @State var options = ["Home","Chat","Map","Profile","Games"]
    @State var selectedView : Int = 0
    @State var goBack = false
    @State var showAddContent = false
    @Binding var group : Group
    @State var offset : CGSize = .zero
    @State var showProfileView : Bool = false
    @State var showGalleryView : Bool = false
    @State var showTabButtons : Bool = false

    
    @Environment(\.presentationMode) var presentationMode

            
    var body: some View {
        
        ZStack{
            
            Color("Background").opacity(showAddContent ? 0.2 : 1).zIndex(0)
            
            VStack{
                
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                       
                        HStack(spacing: 2){
                                Image(systemName: "chevron.left")
                                    .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                                Image(systemName: "house")
                                    .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }.padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                     
                        
                    }).padding(.leading)
                    

                    Text(selectedGroupVM.group?.groupName ?? "GROUP_NAME").font(.title2).fontWeight(.heavy).minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    HStack{
                        
                        Button(action:{
                            showAddContent.toggle()
                        },label:{
                            Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                        }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        
                        Button(action: {
                            

                                withAnimation(.spring()){
                                    self.showProfileView.toggle()
                                }
                        },label:{
                                Image(systemName: "person.3.fill").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        
                        NavigationLink(destination: GroupSettingsView(group: group).environmentObject(selectedGroupVM)){
                            Image(systemName: "gear").foregroundColor(FOREGROUNDCOLOR).font(.title3).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        }
                        
                        
                        
   

                    }.padding(.trailing,12)
                    
           
                
                }.padding(.top,60)
                
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false){
                
                HStack(spacing: 20){
                     
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 0
                        }
                    
                    },label:{
                        VStack{
                            Text("Home").fontWeight(.bold)
                            Rectangle().frame(width: UIScreen.main.bounds.width/5,height:2)
                        }
                    }).foregroundColor(selectedView == 0 ? Color("AccentColor") : FOREGROUNDCOLOR)
                   
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 1
                        }
                     
                    },label:{
                            VStack{
                                Text("Gallery").fontWeight(.bold)
                                Rectangle().frame(width: UIScreen.main.bounds.width/5,height:2)
                            }
                        
                       
                    }).foregroundColor(selectedView == 1 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    

              
                    
                    
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 2
                        }
                       
                    },label:{
                        VStack{
                            Text("Games").fontWeight(.bold)
                            Rectangle().frame(width:UIScreen.main.bounds.width/5,height:2)
                        }
                    }).foregroundColor(selectedView == 2 ? Color("AccentColor") : FOREGROUNDCOLOR)
                   
                    
                    Button(action:{
                        withAnimation(.easeIn){
                            selectedView = 3
                        }
                       
                    },label:{
                        VStack{
                            Text("Map").fontWeight(.bold)
                            Rectangle().frame(width:UIScreen.main.bounds.width/5,height:2)
                        }
                    }).foregroundColor(selectedView == 3 ? Color("AccentColor") : FOREGROUNDCOLOR)
               
                    
                }.padding(.leading,5).padding(.top,10)
                
                }
                
                TabView(selection: $selectedView){
                    ActivityView(group: $group).tag(0)
                 
                
                    GroupGalleryView().tag(1)
        
                    
                    Text("Games").tag(2)

                    
                    MapView(group: $group).tag(3)
                    
                        
                    
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
              
                
            }.zIndex(1).opacity(showAddContent ? 0.2 : 1).onTapGesture {
                if(showAddContent){
                    showAddContent.toggle()
                }
            }.disabled(showAddContent)
            
            BottomSheetView(isOpen: $showAddContent, maxHeight: UIScreen.main.bounds.height * 0.45) {
                
                    AddContentView(showAddContentView: $showAddContent, group: $group)
                
            }.zIndex(2)
            
            if showProfileView{
                GroupProfileView(group: $group, isInGroup: group.users?.contains(userVM.user?.id ?? " ") ?? false, showProfileView: $showProfileView).zIndex(3)
            }
         
            

            
        
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            selectedGroupVM.fetchGroup(userID: userVM.user?.id ?? " ", groupID: group.id) { fetched in
                if fetched {
                    print("fetched \(group.groupName ?? "")")

                }
            }
        }
    }
    
    
    
    
    
    
}







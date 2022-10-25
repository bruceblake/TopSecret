//
//  TopBar.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/14/22.
//

import SDWebImageSwiftUI
import SwiftUI


struct TopBar : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var user : User = User()
    @State var selectedColorIndex : Int = 0
    var icons : [Image] = [Image("FinishedIcon"),Image("Icon")]
    @Binding var showSearch : Bool
    var tabIndex : Tab

    var body : some View {

        HStack{
            
            HStack(spacing: 5){
                
                
                
                NavigationLink(destination: CurrentUserProfilePage()) {
                    WebImage(url: URL(string: userVM.user?.profilePicture ?? " "))
                        .resizable()
                        .scaledToFill()
                        .frame(width:35,height:35)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("AccentColor"), lineWidth: 1))
                }
                
                
                Button(action:{
                    withAnimation(.easeIn){
                        
                        showSearch.toggle()
                    }
                    
                },label:{
                    
                    ZStack{
                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                        
                        
                        Image(systemName: "magnifyingglass").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        
                    }
                })
            }.padding(.leading)
            
            
          
            
            
            Spacer()
            
            if tabIndex == .home {
                Button(action:{
                    if selectedColorIndex == icons.count-1{
                        selectedColorIndex = 0
                    }else{
                        selectedColorIndex = selectedColorIndex + 1
                    }
                },label:{
                    icons[selectedColorIndex].resizable().scaledToFit().frame(width: 70, height:70)
                })
            }
            else if tabIndex == .friends{
                Text("Friends").bold().font(.title3)
            }
            else if  tabIndex == .schedule {
                Text("Schedule").bold().font(.title3)
            }
            else if tabIndex == .notifications {
                Text("Notifications").bold().font(.title3)
            }
            
          
            
            
            Spacer()
             
                Button(action: {
                  //todo
                    userVM.hideTabButtons.toggle()
                    userVM.showAddContent.toggle()
                 },label:{
                     
                     ZStack{
                         Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                         
                         
                         if tabIndex == .friends {
                             
                         Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                         }else {
                         Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                         }

                     }
       
                 })
            .padding(.trailing)
              
                
            
            
            
            
            
            
        }.frame(width: UIScreen.main.bounds.width).padding(.top,50).onChange(of: userVM.user ?? User()) { newValue in
            self.user = newValue
        }
    }
}

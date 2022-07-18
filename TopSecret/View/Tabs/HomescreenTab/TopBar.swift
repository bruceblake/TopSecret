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
    
    var body : some View {
        
        HStack{
            
            Spacer()
            
            NavigationLink(destination:{
                UserProfilePage(user: Binding(get: {userVM.user ?? User()}, set: {_ in}), isCurrentUser: true)
            },label:{
                
                
                WebImage(url: URL(string: userVM.user?.profilePicture ?? " ")).resizable().frame(width: 40, height: 40).clipShape(Circle()).padding(.trailing,30)
                
            })
            
            
            Image("FinishedIcon").resizable().scaledToFit().frame(width: 70, height:70).padding(.horizontal,60)
            
            
            
            
            
            
            HStack(spacing: 10){
                
                NavigationLink {
                    SearchView()
                } label: {
                    ZStack{
                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                        
                        
                        Image(systemName: "magnifyingglass").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        
                    }
                }
                
                NavigationLink(destination: {
                    CreateGroupView()
                },label:{
                    
                    ZStack{
                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                        
                        
                        Image(systemName: "plus").font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        
                    }
                    
                })
                
            }
            
            
            
            Spacer()
            
            
            
        }.padding(.horizontal,25).padding(.top,45)
    }
}

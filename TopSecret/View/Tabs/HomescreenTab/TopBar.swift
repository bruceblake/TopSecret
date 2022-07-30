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
    
    var body : some View {
        
        HStack{
            
            
            
            NavigationLink {
                SearchView()
            } label: {
                ZStack{
                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                    
                    
                    Image(systemName: "magnifyingglass").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                    
                }
            }.padding(.leading,85)
            
            Spacer()
            
            Image("FinishedIcon").resizable().scaledToFit().frame(width: 70, height:70)
            
            
            Spacer()
             
                
                NavigationLink(destination: {
                    CreateGroupView()
                },label:{
                    
                    ZStack{
                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                        
                        
                        Image(systemName: "plus").font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        
                    }
                    
                }).padding(.trailing,85)
                
            
            
            
            
            
            
        }.padding(.top,45).onChange(of: userVM.user ?? User()) { newValue in
            self.user = newValue
        }
    }
}

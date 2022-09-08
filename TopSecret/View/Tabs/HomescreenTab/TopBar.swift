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

    var body : some View {

        HStack{
            
            
            Button(action:{
                withAnimation(.easeIn){
                    
                    showSearch.toggle()
                }
                
            },label:{
                
                ZStack{
                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                    
                    
                    Image(systemName: "magnifyingglass").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                    
                }
            }).padding(.leading)
            
            
            Spacer()
            
            Button(action:{
                if selectedColorIndex == icons.count-1{
                    selectedColorIndex = 0
                }else{
                    selectedColorIndex = selectedColorIndex + 1
                }
            },label:{
                icons[selectedColorIndex].resizable().scaledToFit().frame(width: 70, height:70)
            })
            
            
            Spacer()
             
                
                NavigationLink(destination: {
                  UserNotificationView()
                },label:{
                    
                    ZStack{
                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                        
                        
                        
                        Image(systemName: "envelope.fill").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        
                     
                            ZStack{
                                Circle().foregroundColor(Color("AccentColor")).frame(width: 20, height: 20)
                                Text("3").foregroundColor(Color.yellow).font(.body)
                            }.offset(x: 15, y: -17)
                        
                        
                        
                    }
          
                    
                }).padding(.trailing)
                
            
            
            
            
            
            
        }.frame(width: UIScreen.main.bounds.width).padding(.top,50).onChange(of: userVM.user ?? User()) { newValue in
            self.user = newValue
        }
    }
}

//
//  HomescreenAddContentView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/9/22.
//

import SwiftUI

struct HomescreenAddContentView: View {
    
    var texts : [String] = ["Create a Group","Create Poll","Create Event"]
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ZStack(alignment: .top){
            Color("Color")
            VStack{
                HStack{
                    Spacer()
                    Text("Create").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                    Spacer()
                }
                VStack(alignment: .leading){
                    
                        
                      
                        NavigationLink {
                            CreateGroupView()
                        } label: {
                            VStack(spacing: 10){
                           
                                HStack(alignment: .center, spacing: 20){
                                Image(systemName: "person.3.fill").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                    Text("Create a Group").foregroundColor(FOREGROUNDCOLOR)
                                
                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                                Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(Color.gray)

                            
                        }.padding(.vertical,10).frame(width: UIScreen.main.bounds.width).padding(.leading,30)
                            
                        }
                  
                    
                   
                    
                    
                    NavigationLink {
                        CreateEventView(isGroup: false)

                    } label: {
                        VStack(spacing: 10){
                       
                            HStack(alignment: .center, spacing: 20){
                                Image(systemName: "party.popper.fill").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                    Text("Create a Event").foregroundColor(FOREGROUNDCOLOR)
                                
                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                            Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(Color.gray)

                        }.padding(.vertical,10).frame(width: UIScreen.main.bounds.width).padding(.leading,30)
                        
                    }
                    
                    
                    NavigationLink {
                        CreatePollView()
                    } label: {
                        
                        VStack(spacing: 10){
                        
                            HStack(alignment: .center, spacing: 20){
                                Image(systemName: "questionmark.bubble.fill").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                Text("Create a Poll").foregroundColor(FOREGROUNDCOLOR)

                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                            
                            Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(Color.gray)
                        }.padding(.top,10).frame(maxWidth: UIScreen.main.bounds.width).padding(.leading,30)
                    }

                    
                    
                }
             
            
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).resizeToScreenSize()
    }
}


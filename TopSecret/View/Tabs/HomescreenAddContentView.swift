//
//  HomescreenAddContentView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/9/22.
//

import SwiftUI

struct HomescreenAddContentView: View {
    
    var texts : [String] = ["Create a Group","Create a Post","Create Poll","Create Event"]
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ZStack(alignment: .top){
            Color("Color")
            VStack(){
                
                ForEach(texts, id: \.self){ text in
                    NavigationLink {
                        switch(text){
                            
                        case "Create a Group":
                            CreateGroupView()
                        case "Create a Post":
                            CreateGroupPostView()
                        case "Create Event":
                            CreateEventView(isGroup: false)
                        case "Create Poll":
                            CreatePollView(group: Group())
                            
                        default:
                            EmptyView()
                        }
                    } label: {
                        Text(texts[texts.firstIndex(of: text) ?? 0]).fontWeight(.bold).foregroundColor(Color("AccentColor")).padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("Background")).cornerRadius(15)
                    }.padding(.vertical,5).padding(.top,5)
                    
                }
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}


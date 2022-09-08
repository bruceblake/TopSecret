//
//  FullCountdownView.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/6/22.
//

import SwiftUI

struct FullCountdownView: View {
    @Binding var group: Group
    @Binding var countdown : CountdownModel
    @Binding var showCountdown: Bool
    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                
             
                HStack{
                    Button(action:{
                        withAnimation(.spring()){
                            showCountdown.toggle()
                        }
                    },label:{
                        Image(systemName: "x.circle").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                    }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(.leading,10)
                    Spacer()
                }.padding(.top,50)
                
                
                VStack(alignment: .leading){
                    Text(countdown.countdownName ?? "COUNTDOWN_NAME").foregroundColor(FOREGROUNDCOLOR).font(.largeTitle).fontWeight(.bold)
                    
                }
                
                Spacer()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct FullCountdownView_Previews: PreviewProvider {
//    static var previews: some View {
//        FullCountdownView()
//    }
//}

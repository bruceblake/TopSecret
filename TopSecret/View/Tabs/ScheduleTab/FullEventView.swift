//
//  FullEventView.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/22/22.
//

import SwiftUI

struct FullEventView: View {
    
    @Binding var event : EventModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                
                HStack{
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary)
                        .frame(
                            width: 60,
                            height: 6
                        ).padding().onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }

                    Spacer()
                }
             
                
                
                VStack(alignment: .leading){
                    Text(event.eventName ?? "EVENT_NAME").foregroundColor(FOREGROUNDCOLOR).font(.largeTitle).fontWeight(.bold)
                    
                }
                
                Spacer()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct FullEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        FullEventView(event: .constant(EventModel()))
//    }
//}

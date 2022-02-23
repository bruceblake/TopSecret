//
//  SearchBar.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/1/22.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var text : String
    var placeholder: String = ""
    
    var body: some View {
        HStack(spacing: 15){
            
            Image(systemName: "magnifyingglass").font(.system(size: 23, weight: .bold))
                .foregroundColor(.gray)
            
            TextField("\(placeholder)", text: $text).autocapitalization(.none)
            
            Spacer()
            
            Button(action:{
                self.text = ""
            },label:{
                Image(systemName: "xmark.circle").foregroundColor(Color("Foreground"))
            })
            
        }.padding(.vertical,10).padding(.horizontal).background(Color("Color")).cornerRadius(16).padding(.horizontal)
        
    }
}

//struct SearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBar(text: .constant("hello world"))
//    }
//}

//
//  TestView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/1/22.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Button(action:{
                    
                },label:{
                    Text("Back")
                })
            }.background(Color("Background"))
        ScrollView{
            Text("Hello World!").foregroundColor(.black)
        }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView().colorScheme(.dark)
    }
}

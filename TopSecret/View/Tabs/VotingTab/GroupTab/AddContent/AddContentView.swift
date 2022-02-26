//
//  AddContentView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/21/22.
//

import SwiftUI

struct AddContentView: View {
    
    @Binding var showAddContentView: Bool
    var group: Group
    
    
    var body: some View {
        if showAddContentView {
            VStack(spacing: 20){
                HStack{
                    Spacer()
                }
                NavigationLink(destination: CreateCountdownView(group: group)) {
                        Text("Create Countdown")
                    }
                    NavigationLink(destination: EmptyView()) {
                        Text("Create Poll")
                    }
                    NavigationLink(destination: EmptyView()) {
                        Text("Create Event")
                    }
                    NavigationLink(destination: EmptyView()) {
                        Text("Add to Story")
                    }
                NavigationLink(destination: CreateGalleryPostView(group: group)) {
                        Text("Create Gallery Post")
                    }
                
          
            
            }
        }
    }
}

//struct AddContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddContentView()
//    }
//}

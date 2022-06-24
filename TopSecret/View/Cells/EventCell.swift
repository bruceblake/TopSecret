//
//  EventCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/17/22.
//

import SwiftUI

struct EventCell: View {
    
    @Binding var eventName: String?
    @Binding var eventLocation: String?
    
    var body: some View {
            VStack{
                Text(eventName ?? "EVENT_NAME").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                Text(eventLocation ?? "EVENT_LOCATION").foregroundColor(FOREGROUNDCOLOR)
                Text("3 hours remaining").foregroundColor(Color.gray).font(.caption)
            }.padding(10).background(Color("Color")).cornerRadius(16)
        
    }
}

//struct EventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        EventCell()
//    }
//}

//
//  CountdownCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/17/22.
//

import SwiftUI

struct CountdownCell: View {
    
    @Binding var countdownName : String
    @Binding var countdownTime : String
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                Text(countdownName).foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                Text(countdownTime).foregroundColor(FOREGROUNDCOLOR)
            }
        }
    }
}

//struct CountdownCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CountdownCell()
//    }
//}

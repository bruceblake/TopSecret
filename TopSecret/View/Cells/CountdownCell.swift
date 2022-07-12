//
//  CountdownCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/17/22.
//

import SwiftUI

struct CountdownCell: View {
    
   var countdown : CountdownModel
    
    func daysUntil() -> DateComponents {
        let userDate = Calendar.current.dateComponents([.day,.month,.year], from: countdown.endDate?.dateValue() ?? Date())
        
        let userDateComponents = DateComponents(calendar: Calendar.current, year: userDate.year!, month: userDate.month!, day: userDate.day!).date!
        
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: userDateComponents)
        
        return daysUntil
    }
    
    var body: some View {
        VStack{
            Text(countdown.countdownName ?? "COUNTDOWN_NAME").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
            Text("\(daysUntil().day!) Days Left!").foregroundColor(Color.gray).font(.caption)
        }.padding(10).background(Color("Color")).cornerRadius(16)
        
    }
}

//struct CountdownCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CountdownCell()
//    }
//}

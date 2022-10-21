//
//  EventCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/17/22.
//

import SwiftUI
import SDWebImageSwiftUI
struct EventCell: View {
    
    var event : EventModel
    var currentDate: Date = Date()
    var action : Bool
    var isHomescreen : Bool
    var showBarIndicator : Bool = true
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var eventVM = EventViewModel()
    func getTimeRemaining() -> Int {
        let interval = (event.eventStartTime?.dateValue() ?? Date()) - Date()
        
        return interval.hour ?? 0
    }
    
    
    func isCurrentHour(date: Date) -> Bool{
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        let currentHour = calendar.component(.hour, from: Date())
        
        return hour == currentHour
    }
    
    func getZIndex(index: Int) -> Int{
        if index == 1 {
            return 2
        }else{
            return index
        }
    }
    
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 30){
            if showBarIndicator{
            Rectangle().fill(Color("AccentColor")).frame(width: 3)
            }
            

            
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 5){
                        Text(event.eventName ?? "").font(.title2).bold().foregroundColor(FOREGROUNDCOLOR)
                        HStack(alignment: .center){
                            Image(systemName: "clock").font(.footnote).foregroundColor(Color.gray)
                            Text(event.eventStartTime?.dateValue() ?? Date(), style: .time).font(.headline)
                            Text("-").font(.headline)
                            Text(event.eventEndTime?.dateValue() ?? Date(), style: .time).font(.headline)
                        }.foregroundColor(FOREGROUNDCOLOR)
                       
                        HStack{
                            HStack(alignment: .center){
                                Image(systemName: "mappin.and.ellipse").foregroundColor(Color.gray).font(.footnote)
                                Text(event.eventLocation ?? "").font(.footnote)
                            }
                            Text("|")
                        Text("4 attending").font(.footnote)
                        }.foregroundColor(FOREGROUNDCOLOR.opacity(0.7))
                    }
                    
                 
                }
            }.foregroundColor(self.isCurrentHour(date: event.eventStartTime?.dateValue() ?? Date()) ? FOREGROUNDCOLOR : .gray).padding(15).frame(maxWidth: .infinity, alignment: .leading).background(RoundedRectangle(cornerRadius: 25).fill(isHomescreen ? Color("Color") : Color("Background"))).overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("AccentColor"), lineWidth: self.isCurrentHour(date: event.eventStartTime?.dateValue() ?? Date()) ? 1.5 : 0))
            
        }.frame(maxWidth: .infinity, alignment: .leading).padding()
        
        
    }
}


extension Date {
    
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
        
        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
}



//struct EventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        EventCell()
//    }
//}

//
//  EventCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/17/22.
//

import SwiftUI

struct EventCell: View {
    
    var event : EventModel
    var currentDate : Date
    var isHomescreen : Bool
    
    func getTimeRemaining() -> Int {
        let interval = (event.eventTime?.dateValue() ?? Date()) - Date()
        
        return interval.hour ?? 0
    }
    
    
    func isCurrentHour(date: Date) -> Bool{
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        let currentHour = calendar.component(.hour, from: Date())
        
        return hour == currentHour
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 30){
                VStack(spacing: 10){
                    Circle()
                        .fill(self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? Color("AccentColor") : .clear)
                        .frame(width: 15, height: 15)
                        .background(Circle().stroke(FOREGROUNDCOLOR,lineWidth: 1).padding(-3))
                        .scaleEffect(!self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? 0.8 : 1)
                    
                    Rectangle()
                        .fill(self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? Color("AccentColor") : Color("Color"))
                        .frame(width: 3)
                }
                
                VStack{
                    
                  
                    HStack(alignment: .top, spacing: 10){
                        VStack(alignment: .leading, spacing: 12){
                            
                            Text("\(event.eventName ?? "EVENT_NAME")")
                                .font(.title2.bold())
                            
                            Text("\(event.eventLocation ?? "EVENT_LOCATION")")
                                .font(.callout)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 12){
                            Text("\(event.eventTime?.dateValue() ?? Date(), style: .time)")
                            
                            if !self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()){
                                Text("\(getTimeRemaining()) hours remaining!").foregroundColor(Color("AccentColor")).fontWeight(.bold)
                            }
                        }
                        
                    }
                }.foregroundColor(self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? FOREGROUNDCOLOR : .gray).padding(self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? 15 : 0).frame(maxWidth: .infinity, alignment: .leading).background(isHomescreen ? Color("Color").cornerRadius(25).opacity(self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? 1 : 0) : Color("Background").cornerRadius(25).opacity(self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? 1 : 0))
                
        }.frame(maxWidth: .infinity, alignment: .leading).padding().onAppear{
            print("event: \(event.eventName ?? "DICK")")
        }
        
      
        
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

//
//  EventCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/17/22.
//

import SwiftUI
import SDWebImageSwiftUI
struct EventCell: View {
    
    @Binding var event : EventModel
    var currentDate : Date
    var isHomescreen : Bool
    @Binding var group: Group
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var eventVM = EventViewModel()
    @Binding var action : Bool
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
    
    func getZIndex(index: Int) -> Int{
        if index == 1 {
            return 2
        }else{
            return index
        }
    }
    
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 30){
            
            
            VStack{
                
                
                HStack(alignment: .top, spacing: 10){
                    VStack(alignment: .leading, spacing: 12){
                        
                        
                        VStack(alignment: .leading, spacing: 7){
                            
                            Text("\(event.eventName ?? "EVENT_NAME")")
                                .font(.title2.bold())
                            
                            HStack(alignment: .center, spacing: 5){
                                VStack(alignment: .leading, spacing: 10){
                                    Image(systemName: "mappin.and.ellipse").foregroundColor(Color.gray)
                                    
                                    Image(systemName: "clock").font(.footnote).foregroundColor(Color.gray)
                                    
                                    Image(systemName: "person.3.fill").font(.footnote).foregroundColor(Color.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 10){
                                    Text("\(event.eventLocation ?? "EVENT_LOCATION")")
                                        .font(.callout)
                                    Text("\(event.eventTime?.dateValue() ?? Date(), style: .time)") .font(.callout)
                                    Text("(\(event.usersAttendingID?.count ?? 0)/\(group.users?.count ?? 0))").font(.callout).foregroundColor(FOREGROUNDCOLOR)
                                }
                            }
                            
                         
                            
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .trailing, spacing: 12){
                       
                        
                        Text("\(self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? "Active Event" : "4 hours remaining")").foregroundColor(Color("AccentColor")).bold().font(.title3)
            
                        
                        Spacer()
 
                        
                        Button(action:{
                            if event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false {
                                eventVM.leaveEvent(eventID: event.id, groupID: group.id, userID: userVM.user?.id ?? " ")
                            }else{
                                eventVM.joinEvent(eventID: event.id, groupID: group.id, userID: userVM.user?.id ?? " ")
                            }
                            action.toggle()

                            
                        },label:{
                            Text(event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false ? "Leave" : "Join").foregroundColor(FOREGROUNDCOLOR)
                        }).padding(7).padding(.horizontal,10).background(Capsule().fill( Color("AccentColor"))).cornerRadius(20)
                        
                        
                        
                        
                    }
                    
                }
            }.foregroundColor(self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? FOREGROUNDCOLOR : .gray).padding(15).frame(maxWidth: .infinity, alignment: .leading).background(RoundedRectangle(cornerRadius: 25).fill(isHomescreen ? Color("Color") : Color("Background"))).overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("AccentColor"), lineWidth: self.isCurrentHour(date: event.eventTime?.dateValue() ?? Date()) ? 1.5 : 0))
            
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

//
//  CustomDatePicker.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI

struct CustomDatePicker: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var currentDate: Date
    @Binding var group : Group
    
    @State var currentMonth: Int = 0
    
    @Binding var selectedMonth: Int
    @Binding var selectedDay: Int
    @Binding var selectedYear : Int
    
    let days: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var body: some View {
        VStack(){
            
            VStack(spacing: 15){
            HStack(spacing: 20){
                
                HStack{

                    Text(extraDate()[1])
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
            
                
                    Spacer(minLength: 0)
                    
                HStack{
                    Button(action:{
                        withAnimation{
                            currentMonth -= 1
                        }
                    },label:{
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    })
                    
                    Button(action:{
                        withAnimation{
                            currentMonth += 1
                        }
                    },label:{
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    })
                }
                 
                
            }.padding(.horizontal)
            
            HStack(spacing: 0){
                ForEach(days,id:\.self){ day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        
                }
            }
            
        }
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 10){
                ForEach(extractDate()){ value in
                    CardView(eventList: group.events ?? [],value: value, selectedDay: selectedDay, completion: { day in
                        
                       
                        selectedDay = day
                        
                 
                        
                    })
                }
            }
        }.onChange(of: currentMonth) { newValue in
            currentDate = getCurrentMonth()
            selectedMonth = Calendar.current.dateComponents([.month], from: getCurrentMonth()).month ?? 0
            selectedDay = 1
            
        }.padding(10).background(Color("Color")).cornerRadius(20)
    }
    
    @ViewBuilder
    func CardView(eventList: [EventModel],value: DateValue, selectedDay: Int, completion: @escaping (Int) ->()) -> some View {
        
       
        
        VStack{
            if value.day != -1{
                Button(action:{
                    return completion(value.day)
                },label:{
                    VStack{
                        Text("\(value.day)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(selectedDay == value.day ? Color("AccentColor") : .white)
                        
                        if hasEvent(eventList: eventList, selectedDay: value.day, selectedMonth: getDateComponents(date: value)[0], selectedYear: getDateComponents(date: value)[2]){
                                Text("*")
                            }else{
                                Text("")
                            }
                        
                       
                        
                    }
                   
                })
                
            }
        }
    }
    
    func getDateComponents(date: DateValue) -> [Int] //first is month, second is day, third is year
                    {
        let component = Calendar.current.dateComponents([.year,.month,.day], from: date.date)
        return [component.month ?? 0,component.day ?? 0,component.year ?? 0]
    }
    
    func hasEvent(eventList: [EventModel], selectedDay: Int, selectedMonth: Int, selectedYear: Int) -> Bool{
        
        var hasEvent = false
        
        for event in eventList{
            let components = Calendar.current.dateComponents([.month,.day,.year], from: event.eventStartTime?.dateValue() ?? Date())
            let year = components.year ?? 0
            let month = components.month ?? 0
            let day = components.day ?? 0
            
            if selectedDay == day && selectedMonth == month && selectedYear == year{
                hasEvent = true
            }
        }
       
        return hasEvent
        
        
    }
    
    func extraDate()->[String]{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth()-> Date{
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
        }
        
        return currentMonth
    }
    
    func extractDate()-> [DateValue] {
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        
        var days =  currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

//
//struct CustomDatePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomDatePicker()
//    }
//}


extension Date{
    
    func getAllDates()-> [Date] {
        
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: self)!
        return range.compactMap { (day) -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

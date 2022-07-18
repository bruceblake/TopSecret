//
//  GroupCalendarView.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/17/22.
//

import SwiftUI

struct GroupCalendarView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var group: Group
    
    @State var showCreateEvent: Bool = false
    @State var currentDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectedIndex = 0
    @State var selectedMonth = 1
    @State var selectedDay = 1
    @State var selectedYear = 0
    @State var currentEvents : [EventModel] = []
    @State var hasEvents : Bool = false
    @StateObject var homeCalendarVM = HomeCalendarViewModel()
    
    var options = ["All","Events","Countdowns","Polls"]
    @State var selectedOptionIndex = 0
    @State var selectedBottomCardIndex = 0
    

    
    func getDateComponents(date: Date) -> [String]{ // month, day, year
        let components = Calendar.current.dateComponents([.month,.day,.year], from: date)
        let month = String(components.month ?? 0)
        let day = String(components.day ?? 0)
        let year = String(components.year ?? 0)
        
        return [month,day,year]
    }
    
    func getDate(year: Binding<Int>, month: Binding<Int>, day: Binding<Int>) -> Binding<Date>{
        let dateComponent = DateComponents(year: year.wrappedValue, month: month.wrappedValue, day: day.wrappedValue)

        return Binding(get: {Calendar.current.date(from: dateComponent) ?? Date()}, set: {_ in})

    }
    
    func getMonth(monthNumber: Int) -> String{
        switch monthNumber {
        case 1: return "January"
        case 2: return "Feburary"
        case 3: return "March"
        case 4: return "April"
        case 5: return "May"
        case 6: return "June"
        case 7: return "July"
        case 8: return "August"
        case 9: return "September"
        case 10: return "October"
        case 11: return "November"
        case 12: return "December"
        default:
            return "fail"
        }
    }
    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                
          
                
                VStack(alignment: .leading){
                    
                    VStack(spacing: 30){
                        HStack{
                            
                            Button(action:{
                                presentationMode.wrappedValue.dismiss()
                            },label:{
                                ZStack{
                                    
                                    
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)

                                    Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                    
                                }
                            }).padding(.leading,10)
                            Spacer()
                            Text("Calendar").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.largeTitle)
                            Spacer()
                            Button(action:{
                                
                            },label:{
                                ZStack{
                                    
                                    
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)

                                    Image(systemName: "gear").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                    
                                }
                            }).padding(.trailing,10)
                        }
                        
                        CustomDatePicker(currentDate: $currentDate, group: $group, selectedMonth: $selectedMonth, selectedDay: $selectedDay, selectedYear: $selectedYear)
                        
                    }
                    
          
                    
                    VStack{
                        HStack{
                            
                            

                            Text("\(getMonth(monthNumber: selectedMonth))").fontWeight(.bold).font(.title2)
                            Text("\(selectedDay)").font(.title2).fontWeight(.bold)
                            Spacer()
                            Button(action:{

                            },label:{
                                Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                            }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))


                        }
                        
                        HStack{
                            Button(action:{
                                withAnimation {
                                    selectedBottomCardIndex = 0
                                }
                            },label:{
                                Text("Plans")
                            }).foregroundColor(selectedBottomCardIndex == 0 ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.leading,10)
                            
                            Spacer()
                            
                            Button(action:{
                                withAnimation {
                                    selectedBottomCardIndex = 1
                                }
                            },label:{
                                Text("Availability")
                            }).foregroundColor(selectedBottomCardIndex == 1 ? Color("AccentColor") : FOREGROUNDCOLOR).padding(.trailing,10)
                            
                        }
                        
                        if selectedBottomCardIndex == 0 {
                            PlansView(currentDate: getDate(year: $selectedYear, month: $selectedMonth, day: $selectedDay), group: $group)
                        }else {
                            AvailabilityView()
                        }
                        
                        
                    
                        


                    }.padding().background(Color("Color")).cornerRadius(16).frame(height: UIScreen.main.bounds.height / 3)
                  
                    
                    
                }.frame(height: UIScreen.main.bounds.height/2)
                
               
                
                 

                
                

                
            }.padding(.horizontal)
            
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
    
}

//struct GroupCalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupCalendarView()
//    }
//}


struct PlansView : View {
    @Binding var currentDate : Date
    @Binding var group: Group
    @StateObject var homeCalendarVM = HomeCalendarViewModel()
    
    var options = ["All","Events","Countdowns","Polls"]
    @State var selectedOptionIndex = 0
    
    
    var body: some View {
        VStack{
        HStack(spacing: 20){
            
            ForEach(0..<options.count) { option in
                Button(action:{
                    withAnimation(.easeInOut){
                        self.selectedOptionIndex = option
                    }
                },label:{
                    Text("\(options[option])").foregroundColor(FOREGROUNDCOLOR).font(.callout)
                }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(selectedOptionIndex == option ? Color("AccentColor") : Color("Background")))
            }
            
            
            
            
        }
        
        
        
        
        ScrollView(showsIndicators: false){
            VStack{
                switch self.selectedOptionIndex {
                    
                case 0:
                    
                    if homeCalendarVM.eventsReturnedResults.isEmpty && homeCalendarVM.countdownReturnedResults.isEmpty {
                        Text("Nothing for Today!")
                    }
                    ForEach(homeCalendarVM.eventsReturnedResults, id: \.id){ event in
                        EventCell(event: event, currentDate: currentDate, isHomescreen: false)
                    }
                    
                    
                    
                    ForEach(homeCalendarVM.countdownReturnedResults, id: \.id){ countdown in
                        CountdownCell(countdown: countdown)
                    }
                    
                     
                case 1:
                    if homeCalendarVM.eventsReturnedResults.isEmpty {
                        Text("No Events for Today!")
                    }else{
                        ForEach(homeCalendarVM.eventsReturnedResults, id: \.id){ event in
                            EventCell(event: event, currentDate: currentDate, isHomescreen: false)
                        }
                    }
                    
                    
                case 2:
                    if homeCalendarVM.countdownReturnedResults.isEmpty {
                        Text("No Countdowns for Today!")
                    }else{
                        ForEach(homeCalendarVM.countdownReturnedResults, id: \.id){ countdown in
                            CountdownCell(countdown: countdown)
                        }
                    }
                    
                    
                default:
                    Text("Hello World")

                }
                
            }
            
        }.padding()
        
    }.onAppear{
        homeCalendarVM.startSearch(groupID: group.id)
    }.onChange(of: self.currentDate) { newDate in
        let groupD = DispatchGroup()
        
        groupD.enter()
        homeCalendarVM.setCurrentDate(currentDate: newDate)
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            homeCalendarVM.startSearch(groupID: group.id)
            print("current date: \(newDate)")
            print("started search!")
        })
    }
        
    }
}

struct AvailabilityView : View{
    
    var body: some View {
        Text("Hello  World")
    }
}

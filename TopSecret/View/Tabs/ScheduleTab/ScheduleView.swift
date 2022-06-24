//
//  EventView.swift
//  TopSecret
//
//  Created by nathan frenzel on 8/31/21.
//

import SwiftUI
import Firebase

struct ScheduleView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    
    @State var showCreateEvent: Bool = false
    @State var currentDate: Date = Date()
    
    @State private var options = ["Calendar","Events List"]
    
    @State var selectedIndex = 0
    @State var selectedMonth = 0
    @State var selectedDay = 0
    @State var selectedYear = 0
    @State var hasEvents : Bool = false
    @State var currentEvents : [EventModel] = []
    
    
    func getDateComponents(date: Date) -> [String]{ // month, day, year
        let components = Calendar.current.dateComponents([.month,.day,.year], from: date)
        let month = String(components.month ?? 0)
        let day = String(components.day ?? 0)
        let year = String(components.year ?? 0)
        
        return [month,day,year]
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
        ZStack(alignment: .topLeading){
            Color("Background")
            VStack{
                
                
                VStack{
                    
                    Picker("Options",selection: $selectedIndex){
                        ForEach(0..<options.count){ index in
                            Text(self.options[index]).tag(index)
                        }
                    }.pickerStyle(SegmentedPickerStyle()).padding(10)
                    //List of groups
                    if selectedIndex == 0 {
                        
                        VStack{
                            CustomDatePicker(currentDate: $currentDate, selectedMonth: $selectedMonth, selectedDay: $selectedDay, selectedYear: $selectedYear)
                            
                            VStack{
                                HStack{
                                    
                                    Text("\(getMonth(monthNumber: selectedMonth))").fontWeight(.bold).font(.title2)
                                    Text("\(selectedDay)").font(.title2).fontWeight(.bold)
                                    Spacer()
                                    Button(action:{
                                        //TODO
                                    },label:{
                                        Image(systemName: "info.circle")
                                    })
                                    
                                }
                                
                                ShowEvent(selectedDay: $selectedDay, selectedMonth: $selectedMonth, events: userVM.events, currentEvents: $currentEvents, hasEvents: $hasEvents, showCreateEvent: $showCreateEvent).onChange(of: [selectedDay,selectedMonth]) { _ in
                                    currentEvents.removeAll()
                                    hasEvents = false

                                    for event in userVM.events {
                                        let components = Calendar.current.dateComponents([.month,.day], from: event.eventTime?.dateValue() ?? Date())
                                        let month = components.month ?? 0
                                        let day = components.day ?? 0

                                        if selectedDay == day && selectedMonth == month{
                                            hasEvents = true
                                            currentEvents.append(event)
                                        }

                                    }




                                }
                                
                                

                                
                            }.padding().background(Color("Color")).cornerRadius(16)
                            
                            
                            
                            
                        }.padding(.horizontal)
                    }else{
                        ScrollView{
                            ForEach(userVM.events, id: \.id) { event in
                                EventListCell(eventName: event.eventName ?? "", eventLocation: event.eventLocation ?? "", eventTime: event.eventTime ?? Timestamp())
                            }
                        }
                        
                    }
                    
                }
                
                
            }.padding(.vertical,120)
            
            HStack{
                
                Button(action:{
                    
                },label:{
                    Text("[]")
                }).padding(.leading,20)
                
                Spacer()
                
                Text("Events").font(.largeTitle).fontWeight(.bold)
                Spacer()
                
                Button(action:{
                    showCreateEvent.toggle()
                },label:{
                    Image(systemName: "plus.circle")
                }).sheet(isPresented: $showCreateEvent, content: {
                   EmptyView()
                }).padding(.trailing,20)
                
            }.padding(.top,60)
            
            
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            let component = Calendar.current.dateComponents([.month,.day], from: Date())
            let month = component.month ?? 0
            let day = component.day ?? 0
            selectedMonth = month
            selectedDay = day
        }
    }
}


struct ShowEvent : View {
    
    @Binding var selectedDay : Int
    @Binding var selectedMonth: Int
    @State var events : [EventModel] = []
    @Binding var currentEvents : [EventModel]
    @Binding var hasEvents : Bool
    @Binding var showCreateEvent: Bool
    
    
    var body: some View {
        ZStack{
            if hasEvents {
                VStack(){
                    ScrollView(showsIndicators: false){
                    ForEach(currentEvents){ event in
                        
                 
                            
                            VStack(spacing: 7){
                                
                                HStack{
                                    Text("\(event.eventName ?? "")").bold().foregroundColor(FOREGROUNDCOLOR)
                                    
                                    
                                    
                                    Spacer()
                                    Text("\(event.eventTime?.dateValue() ?? Date(), style: .time)").foregroundColor(FOREGROUNDCOLOR)
                                }
                                
                                HStack{
                                    Text("@\(event.eventLocation ?? "")").foregroundColor(.gray)
                                    Spacer()
                                    Button(action:{
                                        //TODO
                                    },label:{
                                        Text("See Details")
                                    })
                                }
                                
                                
                            }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background")))
    
                        
                        
                    }
                }
                }
            }else{
                VStack(){
                    Text("You have no plans for today").padding(.top)
                    
                    Spacer()
                    
                    Button(action:{
                        showCreateEvent.toggle()
                    },label:{
                        Text("Create Hangout!").foregroundColor(FOREGROUNDCOLOR).padding(.vertical).frame(width: UIScreen.main.bounds.width/2).background(Color("AccentColor")).cornerRadius(15)
                    })
                }
                
                
                
                
            }
        }
        
    }
    
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}

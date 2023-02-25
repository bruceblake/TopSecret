import Foundation
import SwiftUI




struct ScheduleView : View {
    
    private let calendar : Calendar
    private let monthDayFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    
    @State private var selectedDate = Self.now
    @State var showSelectedDay : Bool = false
    private static var now = Date()
    
    init(calendar: Calendar){
        self.calendar = calendar
        self.monthDayFormatter = DateFormatter(dateFormat: "MMM, dd yyy", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE",calendar: calendar)
    }
 
    
    var body: some View {
        
       
        
   

        
        ZStack{
            Color("Background")
            VStack{
         
                
            
                UserCalendarWeekListView(calendar: calendar,
                                         date: $selectedDate,
                                        showSelectedDay: $showSelectedDay,
                                         content: { date in
                    Button(action:{ selectedDate = date
                    },label:{
                        Text("00")
                            .foregroundColor(.clear)
                            .overlay(
                                Text(dayFormatter.string(from: date))
                                    .foregroundColor(
                                        calendar.isDate(date, inSameDayAs: selectedDate)
                                        ? FOREGROUNDCOLOR
                                        : calendar.isDateInToday(date) ? Color("AccentColor")
                                        : .gray
                                    )
                               
                            )
                           
                    }).onTapGesture(count: 2) {
                        showSelectedDay.toggle()
                    }
                }, header : { date in
                    Text("00")
                        .foregroundColor(.clear)
                        .overlay(
                            Text(weekDayFormatter.string(from: date))
                                .foregroundColor(FOREGROUNDCOLOR)
                        )
                }, title: { date in
                    HStack{
                        Text(monthDayFormatter.string(from: selectedDate)).foregroundColor(FOREGROUNDCOLOR).bold()
                        Spacer()
                    }.foregroundColor(FOREGROUNDCOLOR)
                }, weekSwitcher : { date in
                    Button(action:{
                        withAnimation{
                            guard let newDate = calendar.date(
                                byAdding: .weekOfMonth,
                                value: -1,
                                to: selectedDate
                            ) else {
                                return
                            }
                            selectedDate = newDate
                        }
                    },label:{
                        Label(
                            title: {Text("Previous")},
                            icon: {Image(systemName: "chevron.left")}
                        ).labelStyle(IconOnlyLabelStyle())
                    })
                    
                    Button(action:{
                        withAnimation{
                            guard let newDate = calendar.date(
                                byAdding: .weekOfMonth,
                                value: 1,
                                to: selectedDate
                            ) else {
                                return
                            }
                            selectedDate = newDate
                        }
                        
                    },label:{
                        Label(title: {Text("Next")},
                              icon: {Image(systemName: "chevron.right")}
                        ).labelStyle(IconOnlyLabelStyle())
                    })
                }, fullScreenButton: { date in
                    Button(action:{
                        
                    }, label:{
                        ZStack{
                            Circle().foregroundColor(Color("Background")).frame(width: 30, height: 30)
                            Image(systemName: "arrow.down.right.and.arrow.up.left").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                }
                                         
                                         
                )
                
              
                
                Spacer()
            }
        }.frame(width: UIScreen.main.bounds.width)
       
    }
}

struct UserCalendarWeekListView<Day: View, Header: View, Title: View, WeekSwitcher : View, FullScreenButton: View> : View {
    private var calendar: Calendar
    @Binding var showSelectedDay : Bool
    @Binding private var date: Date
    @StateObject var calendarVM = UserCalendarViewModel()
    @State var topHeaderOffset : CGFloat = 0
    @EnvironmentObject var userVM : UserViewModel
    private let content : (Date) -> Day
    private let header : (Date) -> Header
    private let title: (Date) -> Title
    private let weekSwitcher : (Date) -> WeekSwitcher
    private let fullScreenButton : (Date) -> FullScreenButton
    
    private let daysInWeek = 7
    
    init(
        calendar: Calendar,
        date: Binding<Date>,
        showSelectedDay: Binding<Bool>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title,
        @ViewBuilder weekSwitcher: @escaping (Date) -> WeekSwitcher,
        @ViewBuilder fullScreenButton: @escaping (Date) -> FullScreenButton
        
        
    ){
        self.calendar = calendar
        self._date = date
        self.content = content
        self.header = header
        self.title = title
        self.weekSwitcher = weekSwitcher
        self.fullScreenButton = fullScreenButton
        self._showSelectedDay = showSelectedDay
    }
    
    func dayHasEvent(date: Date) -> Bool {
        for event in calendarVM.eventsResults {
            if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
                return true
            }
        }
       return false
    }
    
    func getNumberOfEventsOfDay(events: [EventModel], date: Date) -> Int {
        var eventCount : Int = 0
        for event in events {
            if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
           eventCount = eventCount + 1
            }
        }
        
        return eventCount
    }
    
    func checkIfSameDay(date1: Date, date2: Date) -> Bool {
        let dateComponents1 = Calendar.current.dateComponents([.day], from: date1)
        let dateComponents2 = Calendar.current.dateComponents([.day], from: date2)
        
        return dateComponents1.day ?? 0 == dateComponents2.day ?? 0

    }
    
    var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays(selectedDate: date)
        
        ZStack{
            
            ScrollView(showsIndicators: false){
                
                HStack{
                    Spacer()
                }.overlay (
                    
                    GeometryReader{ proxy -> Color in
                        let minY = proxy.frame(in: .global).minY
                        
                        DispatchQueue.main.async {
                            if topHeaderOffset == 0{
                                withAnimation(.easeIn){
                                topHeaderOffset = minY
                                }
                            }
                        }
                        
                       return Color.clear
                        
                    }.frame(width: 0, height: 0)
                
                    , alignment: .bottom
                )
                VStack{
                    
                    VStack{
                        HStack{
                            self.weekSwitcher(month)
                            self.title(month)
                            self.fullScreenButton(month)
                        }.padding(5)
                        
                        Divider()
                        HStack(spacing: 10){
                            ForEach(days.prefix(daysInWeek), id: \.self){ date in
                                
                                Button(action:{
                               
                                    self.date = date
                                },label:{
                                    VStack(spacing: 5){
                                        
                                        VStack(spacing: 1){
                                            header(date).foregroundColor(FOREGROUNDCOLOR)
                                            content(date)
                                        }
                                       
                                        VStack(spacing: 3){
                                        ForEach(calendarVM.eventsResults){ event in
                                            if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
                                                Circle().foregroundColor(checkIfSameDay(date1: self.date, date2: date) ? Color("Color") : Color("AccentColor")).frame(width: 8, height: 8).opacity(1)
                                            }
                                        }
                                        }

                                   
                                        
                                        Spacer()

                                       
                                        
                                    }.frame(width: UIScreen.main.bounds.width / 12).padding(5).background(RoundedRectangle(cornerRadius: 8).fill(calendar.isDate(date, inSameDayAs: self.date) ? Color("AccentColor") : Color("Background")))
                                })
                                
                               
                            }
                            
                        }
                         
                        Spacer()
                      
                       
                    }.frame(height: UIScreen.main.bounds.height/3.5).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
                    
                  
                    
                    ScrollView(){
                        
                      
                      
                        
                        
                        VStack(spacing: 40){
                            
                            GeometryReader { proxy -> AnyView in
                                
                                let minY = proxy.frame(in: .global).minY
                                let offset = minY - topHeaderOffset
                                
                                print(offset)
                                
                              
                                    
                                    if offset < 160 {
                                        
                                        return AnyView (
                                            HStack{
                                                
                                                Text("You have \(getNumberOfEventsOfDay(events: calendarVM.eventsResults, date: date)) \(getNumberOfEventsOfDay(events:calendarVM.eventsResults, date:date) == 1 ? "event" : "events")").bold().font(.title3).foregroundColor(FOREGROUNDCOLOR)
                                                
                                                Spacer()

                                                
                                                Text(date, style: .date).foregroundColor(FOREGROUNDCOLOR).font(.headline).padding(.leading)
                                                

                                                
                                           
                                            
                                        } .padding(10).background(Rectangle().fill(getNumberOfEventsOfDay(events: calendarVM.eventsResults, date: date) == 0 ? FOREGROUNDCOLOR : Color("AccentColor"))).offset(y: -offset)
                                    
                                        
                                 )
                                    }else {
                                        
                                        return AnyView(
                                            HStack{
                                                
                                                Text("You have \(getNumberOfEventsOfDay(events: calendarVM.eventsResults, date: date)) \(getNumberOfEventsOfDay(events:calendarVM.eventsResults, date:date) == 1 ? "event" : "events")").bold().font(.title3).foregroundColor(FOREGROUNDCOLOR)
                                                
                                                Spacer()

                                                
                                                Text(date, style: .date).foregroundColor(FOREGROUNDCOLOR).font(.subheadline).padding(.leading)
                                                

                                                
                                           
                                            
                                        }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(getNumberOfEventsOfDay(events: calendarVM.eventsResults, date: date) == 0 ? Color("Color") : Color("AccentColor"))).padding(.horizontal))
                                        
                                        
                                    
                                    }
                                  
                                
                                
                             
                            }.zIndex(4)
                            
                            VStack{
                            ForEach(calendarVM.eventsResults){ event in
//                                if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
//                                    EventCell(event: event, currentDate: date, action: false, isHomescreen: true)
//                                }
                            }
                            }
                            
                        }.padding(.bottom,UIScreen.main.bounds.height/4)
                    }
                    
                }
            }
           
            
            NavigationLink(isActive: $showSelectedDay) {
                SelectedDayView(date: date, events: calendarVM.eventsResults)
            } label: {
                EmptyView()
            }

        }.onReceive(userVM.$user, perform: { userID in
            calendarVM.startSearch(userID: userVM.user?.id ?? " ", startDay: makeDays(selectedDate: date).prefix(daysInWeek)[0], endDay: makeDays(selectedDate: date).prefix(daysInWeek)[6])
        })
        .onChange(of: date) { newDate in
                                            
            calendarVM.startSearch(userID: userVM.user?.id ?? " ", startDay: makeDays(selectedDate: date).prefix(daysInWeek)[0], endDay: makeDays(selectedDate: date).prefix(daysInWeek)[6])

        }.onAppear{
            print(date)
        }
    }
}


private extension UserCalendarWeekListView {
    func makeDays(selectedDate: Date) -> [Date]{
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: selectedDate),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: firstWeek.end - 1)
        else{
            return []
        }
        
        let dateInterval = DateInterval(start: firstWeek.start, end: lastWeek.end)
        
        return calendar.generateDays(for: dateInterval)
    }
}


private extension Calendar{
    func generateDays(for dateInterval: DateInterval,
                      matching components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]
        
        enumerateDates(startingAfter: dateInterval.start,
                       matching: components,
                       matchingPolicy: .nextTime
                ){ date, _, stop in
            guard let date = date else {return}
            
            guard date < dateInterval.end else {
                stop = true
                return
            }
            
            dates.append(date)
        }
        
        return dates
    }
    
    func generateDays(for dateInterval: DateInterval) -> [Date]{
        generateDays(for: dateInterval, matching: dateComponents([.hour, .minute, .second], from: dateInterval.start))
    }
}

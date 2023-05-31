import Foundation
import SwiftUI




struct ScheduleView : View {
    
    private let calendar : Calendar
    private let monthDayFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    @ObservedObject var calendarVM : UserCalendarViewModel
    @State var selectedDate = Self.now
    @State var showSelectedDay : Bool = false
    @State var showWeekView : Bool = false
    @State var currentDate: Date = Date()
    @EnvironmentObject var userVM: UserViewModel
    private static var now = Date()

    
    init(calendar: Calendar, calendarVM: UserCalendarViewModel){
        self.calendar = calendar
        self.monthDayFormatter = DateFormatter(dateFormat: "MMM, dd yyy", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE",calendar: calendar)
        self.calendarVM = calendarVM
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
    
    var body: some View {
        
       
        
   

        
        ZStack{
            Color("Background")
            VStack{
         
                
                if showWeekView{
                    UserCalendarWeekListView(calendar: calendar, calendarVM: calendarVM,
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
                            showWeekView = false
                        }, label:{
                            ZStack{
                                Circle().foregroundColor(Color("Background")).frame(width: 30, height: 30)
                                Image(systemName: "arrow.down.right.and.arrow.up.left").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                    }
                                             
                                             
                    )
                }else{
                    
                    CustomDatePicker(calendarVM: calendarVM, currentDate: $currentDate, selectedDate: $selectedDate, showWeekView: $showWeekView).padding(10)
                    
                }
               
                HStack{
                    
                    Text("You have \(getNumberOfEventsOfDay(events: calendarVM.eventsResults, date: selectedDate)) \(getNumberOfEventsOfDay(events:calendarVM.eventsResults, date:selectedDate) == 1 ? "event" : "events")").bold().font(.title3).foregroundColor(getNumberOfEventsOfDay(events:calendarVM.eventsResults, date:selectedDate) == 0 ? Color.white : Color.yellow)
                    
                    Spacer()

                    
                    Text(selectedDate, style: .date).foregroundColor(getNumberOfEventsOfDay(events:calendarVM.eventsResults, date:selectedDate) == 0 ? Color.white : Color.yellow).font(.headline).padding(.leading)
                    

                    
                
                } .padding(10).background(RoundedRectangle(cornerRadius: 12).fill(getNumberOfEventsOfDay(events: calendarVM.eventsResults, date: selectedDate) == 0 ? Color("Color") : Color("AccentColor").opacity(0.9))).padding(.horizontal)
                
                if calendarVM.isLoading{
                    ProgressView()
                }else{
                    ScrollView(){
                        
                        VStack(spacing: 40){

                            VStack(spacing: 15){
                            ForEach(calendarVM.eventsResults){ event in
                                if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: selectedDate){
                                    NavigationLink {
                                        UserCalendarDetailView(event: event)
                                    } label: {
                                        UserCalendarEventCell(event: event)
                                    }

                                }
                            }
                            }.padding(.top,5)
                            
                        }.padding(.bottom,UIScreen.main.bounds.height/4)
                    }
                }
        
                 
              
                
                Spacer()
            }
        }.frame(width: UIScreen.main.bounds.width).onChange(of: selectedDate) { newDate in
            
            UIDevice.vibrate()

        }
       
    }
}

struct UserCalendarWeekListView<Day: View, Header: View, Title: View, WeekSwitcher : View, FullScreenButton: View> : View {
    private var calendar: Calendar
    @Binding var showSelectedDay : Bool
    @Binding private var date: Date
    @ObservedObject var calendarVM : UserCalendarViewModel
    @EnvironmentObject var userVM : UserViewModel
    private let content : (Date) -> Day
    private let header : (Date) -> Header
    private let title: (Date) -> Title
    private let weekSwitcher : (Date) -> WeekSwitcher
    private let fullScreenButton : (Date) -> FullScreenButton
    @State var topHeaderOffset : CGFloat = 0

    private let daysInWeek = 7
    
    init(
        calendar: Calendar,
        calendarVM: UserCalendarViewModel,
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
        self.calendarVM = calendarVM
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
                         
                      
                       
                    }.frame(height: UIScreen.main.bounds.height/3.5).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
                    
                 
                    
                
            
           
            
            NavigationLink(isActive: $showSelectedDay) {
                SelectedDayView(date: date, events: calendarVM.eventsResults)
            } label: {
                EmptyView()
            }

        }
        .onAppear{
            print(date)
        }
    }
}

struct UserCalendarDetailView : View {
    
    @State var event: EventModel
    @Environment(\.presentationMode) var presentationMode
    
    
    
    func isSameDay(start: Date, end: Date) -> Bool{
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year,.month,.day], from: start)
        let components2 = calendar.dateComponents([.year,.month,.day], from: end)
        return calendar.dateComponents([.day], from: components1, to: components2).day == 0

    }
    var body: some View{
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("\(event.eventName ?? " ")").foregroundColor(FOREGROUNDCOLOR).font(.title).fontWeight(.bold)
                    Spacer()
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal)
                
                HStack{
                VStack(alignment: .leading){
                    
                    if isSameDay(start: event.eventStartTime?.dateValue() ?? Date(), end: event.eventEndTime?.dateValue() ?? Date()){
                        VStack(alignment: .leading){
                            Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.title2).fontWeight(.bold)
                            HStack(spacing: 2){
                                Text("From:").font(.headline)
                                Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .time)").foregroundColor(FOREGROUNDCOLOR).font(.headline).fontWeight(.bold)
                            }
                            HStack(spacing: 2){
                                Text("To:").font(.headline)
                                Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .time)").foregroundColor(FOREGROUNDCOLOR).font(.headline).fontWeight(.bold)
                            }
                        }
                    }else{
                        HStack(spacing: 2){
                            Text("From:").font(.headline)
                            Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.headline).fontWeight(.bold)
                        }
                        HStack(spacing: 2){
                            Text("To:").font(.headline)
                            Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.headline).fontWeight(.bold)
                        }
                    }
                    
                    
                    
                }
                    Spacer()
                }.padding()
                
                Text(event.description ?? "")
                
                Button {
                    
                } label: {
                    HStack{
                        Spacer()
                        Text("Attending")
                        Image(systemName: "chevron.down")
                        Spacer()
                    }.foregroundColor(FOREGROUNDCOLOR).padding(5).padding(.horizontal).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor"))).padding()
                 
                }

                
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct UserCalendarEventCell : View{
    var event : EventModel
    var body: some View {
        HStack{
            RoundedRectangle(cornerRadius: 12).frame(width: 5).foregroundColor(Color.gray)
            VStack(alignment: .leading){
                HStack{
                    Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .time)").fontWeight(.bold).foregroundColor(FOREGROUNDCOLOR)
                    Text("-").foregroundColor(FOREGROUNDCOLOR)
                    Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .time)").fontWeight(.bold).foregroundColor(FOREGROUNDCOLOR)
                }
                Text("\(event.eventName ?? " ")").foregroundColor(FOREGROUNDCOLOR)
                
            }
            Spacer()
            
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }.padding(.horizontal)
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




import SwiftUI
import Foundation
import Combine
import CoreLocation
import SDWebImageSwiftUI


struct DiscoverView : View{
    @State var selectedEvent: EventModel = EventModel()
    @State var selectedOption : Int = 0
    @State var selectedRadiusOption : Int = 0
    @State var radius: Int = 100
    @State var type : String = "restaurant"
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var eventVM = EventsTabViewModel()
    let options = ["Open to Friends", "Invite Only"]
    let radiusOptions = ["Within 1 mile", "Within 5 miles", "Within 10 miles", "Any"]
    @State var searchText : String = ""
    @State var showAddEventView: Bool = false
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    func getRadiusInMiles(radius: Int) -> Double{
        round(Double(radius / 1609))
    }
    
    let columns : [GridItem] = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5)
    ]
    var body: some View {
        ZStack{
            VStack{
             
    
                //Events
                    ScrollView(showsIndicators: false){
                        VStack(spacing: 20){
                            
                            VStack(alignment: .leading){
                                Text("Attending").font(.title2).bold().padding(.leading,5)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        if eventVM.isLoadingAttendingEvents {
                                            ProgressView()
                                        }else{
                                            
                                            if eventVM.attendingEvents.isEmpty{
                                                Text("Currently there are no events, come back later?").padding(.leading,5).foregroundColor(Color.gray)
                                            }else{
                                                ForEach(eventVM.attendingEvents.uniqued(), id: \.id) { event in
                                                    Button(action:{
                                                        self.selectedEvent = event
                                                        self.showAddEventView.toggle()
                                                    },label:{
                                                        EventTabEventCell(event: event, userIsAttending: event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false)
                                                    })
                                                 
                                                   
                                                }
                                            }
                                           
                                        }
                                       
                                    }
                                    
                                }
                            }
                            
                            VStack(alignment: .leading){
                                Text("Invited To").font(.title2).bold().padding(.leading,5)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        if eventVM.isLoadingInviteOnlyEvents {
                                            ProgressView()
                                        }else{
                                            
                                            if eventVM.inviteOnlyEvents.isEmpty{
                                                Text("Currently there are no events, come back later?").padding(.leading,5).foregroundColor(Color.gray)
                                            }else{
                                                ForEach(eventVM.inviteOnlyEvents.uniqued(), id: \.id) { event in
                                                    
                                                    Button(action:{
                                                        self.selectedEvent = event
                                                        self.showAddEventView.toggle()
                                                    },label:{
                                                        EventTabEventCell(event: event, userIsAttending: event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false)
                                                    })
                                                 
                                                   
                                                }
                                            }
                                           
                                        }
                                       
                                    }
                                    
                                }
                            }
                            
                            VStack(alignment: .leading){
                                Text("Open To Friends").font(.title2).bold().padding(.leading,5)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        if eventVM.isLoadingOpenToFriends {
                                            ProgressView()
                                        }else{
                                            if eventVM.openToFriendsEvents.isEmpty{
                                                Text("Currently there are no events, come back later?").padding(.leading,5).foregroundColor(Color.gray)
                                            }else{
                                                ForEach(eventVM.openToFriendsEvents.uniqued(), id: \.id) { event in
                                                    Button(action:{
                                                        self.selectedEvent = event
                                                        self.showAddEventView.toggle()
                                                    },label:{
                                                        EventTabEventCell(event: event, userIsAttending: event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false)
                                                    })
                                                 
                                                   
                                                }
                                            }
                                           
                                        }
                                       
                                    }
                                    
                                }
                            }
                        }.padding(.bottom, UIScreen.main.bounds.width/3)
                      
                       
                    }.padding(10)
            
                    
                    
                
                
                
                
                Spacer()
                
            }
            NavigationLink(destination: EventDetailView(event: selectedEvent, showAddEventView: $showAddEventView), isActive: $showAddEventView) {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all).frame(width: UIScreen.main.bounds.width).onAppear{
            eventVM.fetchAttendingEvents(user: userVM.user ?? User())
            eventVM.fetchOpenToFriendsEvents(user: userVM.user ?? User())
            eventVM.fetchInvitedToEvents(user: userVM.user ?? User())
        }
    }
}



struct EventTabEventCell : View {
    @State var event: EventModel
    @State var friendsAttending: [User] = []
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var eventsVM = EventsTabViewModel()
    @State var userIsAttending: Bool
    @State var usersAttendingID: [String] = []
   
    var eventLocationName : String {
        event.location?.name ?? ""
    }
    
    var body: some View {
        
    
        VStack(spacing: 0){
           
                WebImage(url: URL(string: event.eventImage ?? " ")).resizable().frame(height: 225).scaledToFit()
                
                
                HStack(alignment: .top){
                    
                    VStack(alignment: .leading,spacing:5){
                        
                        HStack{
                            Text(event.eventName ?? " ").font(.title3).bold().foregroundColor(FOREGROUNDCOLOR)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading){
                            Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                            HStack{
                                Text(event.eventStartTime?.dateValue() ?? Date(), style: .time).foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                Text("-")
                                Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .time)").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                            }.foregroundColor(FOREGROUNDCOLOR)
                        }
                        
                        Text("\(eventLocationName == "" ? "No Location Specified" : eventLocationName)").foregroundColor(Color.gray).font(.callout)
                        
                       
                        Spacer()
                        if friendsAttending.count != 0 {
                            HStack{
                                HStack(spacing: -10){
                                    ForEach(friendsAttending.prefix(3)){ friend in
                                            WebImage(url: URL(string: friend.profilePicture ?? " ")).resizable().frame(width: 30, height: 30).clipShape(Circle())
                                        
                                       
                                    }
                                }
                                
                                if friendsAttending.count < 4 {
                                    Text("\(friendsAttending.count) friends attending").foregroundColor(Color.gray).font(.callout)

                                }else{
                                    Text("+\(friendsAttending.count - 3) friends attending").foregroundColor(Color.gray).font(.callout)

                                }
                               
                            }
                        }
                    }.padding(10)
                    
                    Spacer(minLength: 0)
                }.background(Rectangle().foregroundColor(Color("Color")))
            
           
            
            
        }.frame(width: (UIScreen.main.bounds.width/1.5)).clipShape(RoundedRectangle(cornerRadius: 16)).onAppear{
            friendsAttending = eventsVM.getFriendsAttending(event: event, user: userVM.user ?? User())
        }
    }
}



extension CLLocation {
    func distance(from location: EventModel.Location) -> CLLocationDistance {
        let eventLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return distance(from: eventLocation)
    }
}


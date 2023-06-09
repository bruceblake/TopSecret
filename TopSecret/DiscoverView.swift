import SwiftUI
import Foundation
import Combine
import CoreLocation
import SDWebImageSwiftUI


struct DiscoverView : View{
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
                                Text("Invited To").font(.title2).bold().padding(.leading,5)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        if eventVM.isLoadingInviteOnlyEvents {
                                            ProgressView()
                                        }else{
                                            ForEach(eventVM.inviteOnlyEvents.uniqued(), id: \.id) { event in
                                                EventTabEventCell(event: event)
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
                                            ForEach(eventVM.openToFriendsEvents.uniqued(), id: \.id) { event in
                                                EventTabEventCell(event: event)
                                            }
                                        }
                                       
                                    }
                                    
                                }
                            }
                        }.padding(.bottom, UIScreen.main.bounds.width/3)
                      
                       
                    }.padding(10)
            
                    
                    
                
                
                
                
                Spacer()
                
            }
        }.edgesIgnoringSafeArea(.all).frame(width: UIScreen.main.bounds.width).onAppear{
            eventVM.fetchOpenToFriendsEvents(user: userVM.user ?? User())
            eventVM.fetchInvitedToEvents(user: userVM.user ?? User())
        }
    }
}



struct EventTabEventCell : View {
    var event: EventModel
    var body: some View {
        VStack(spacing: 0){
            
            
            
            WebImage(url: URL(string: event.eventImage ?? " ")).resizable().frame(height: 225).scaledToFit()
            
            
            HStack(alignment: .top){
                
                VStack(alignment: .leading,spacing:7){
                    
                    HStack{
                        Text(event.eventName ?? " ").font(.title3).bold().foregroundColor(FOREGROUNDCOLOR)
                        Spacer()
                        VStack{
                            Text("Host").font(.callout)
                            Text("@\(event.creator?.username ?? " ")").foregroundColor(Color.gray).font(.callout)
                        }
                      
                    }
                    
                    VStack(alignment: .leading){
                        Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                        HStack{
                            Text(event.eventStartTime?.dateValue() ?? Date(), style: .time).foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                            Text("-")
                            Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .time)").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                        }.foregroundColor(FOREGROUNDCOLOR)
                    }
                    
                    Text("\(event.location?.name ?? " ")").foregroundColor(Color.gray).font(.callout)
                    
                    Button(action:{
                        
                    },label:{
                        Text("RSVP").padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor"))).foregroundColor(FOREGROUNDCOLOR)
                    })
                    
                    Spacer()
                    
                }.padding(10)
                
                Spacer(minLength: 0)
            }.frame(height: 175).background(Rectangle().foregroundColor(Color("Color")))
            
            
        }.frame(width: (UIScreen.main.bounds.width/1.5)).clipShape(RoundedRectangle(cornerRadius: 16))
    }
}



extension CLLocation {
    func distance(from location: EventModel.Location) -> CLLocationDistance {
        let eventLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return distance(from: eventLocation)
    }
}


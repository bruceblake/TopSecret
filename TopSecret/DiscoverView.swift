import SwiftUI
import Foundation
import Combine
import CoreLocation


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
    var body: some View {
        ZStack{
            VStack{
                //search bar
                SearchBar(text: $searchText, placeholder: "search for events", onSubmit: {
                    //todo
                })
                HStack(spacing: 10){
                    
                    Spacer()
                    Menu {
                        VStack{
                            ForEach(options, id: \.self){ option in
                                Button(action:{
                                    if option == options[0]{
                                        withAnimation{
                                            selectedOption = 0
                                            eventVM.invitationType = options[selectedOption]
                                        }
                                    }
                                    else if option == options[1]{
                                        withAnimation{
                                            selectedOption = 1
                                            eventVM.invitationType = options[selectedOption]
                                        }
                                    }
                            
                                },label:{
                                    Text(option)
                                })
                            }
                        }
                    } label: {
                        HStack{
                            Text("\(options[selectedOption])").foregroundColor(FOREGROUNDCOLOR)
                            Image(systemName: "chevron.down")
                        }.padding(5).background(RoundedRectangle(cornerRadius: 12).stroke(Color("Color"), lineWidth: 2))
                    }

                    Button(action:{

                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "slider.horizontal.3").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                }.padding(5)
                
             
                VStack{
                    ScrollView{
                      //place here
                        if eventVM.isLoading{
                            VStack{
                                ProgressView()
                                Text("loading events...")
                            }
                        }else{
                            ForEach(eventVM.events.uniqued(), id: \.id) { event in
                                EventTabEventCell(event: event)
                            }
                        }

                    }
                }
            }
        }.edgesIgnoringSafeArea(.all).frame(width: UIScreen.main.bounds.width).onAppear{
            eventVM.fetchOpenToFriendsEvents(user: userVM.user ?? User())
        }
    }
}



struct EventTabEventCell : View {
    var event: EventModel
    var body: some View {
        VStack{
            Image(uiImage: event.image ?? UIImage()).resizable().frame(height: 100)
            VStack(alignment: .leading){
                Text(event.eventStartTime?.dateValue() ?? Date(), style: .time)
                Text(event.eventName ?? "EVENT_NAME")
                Text(event.description ?? "")
            }.padding(10)
        }.frame(width: 100).cornerRadius(16)
    }
}



extension CLLocation {
    func distance(from location: EventModel.Location) -> CLLocationDistance {
        let eventLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return distance(from: eventLocation)
    }
}


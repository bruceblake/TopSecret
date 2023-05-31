//
//  CreateEventView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import CoreLocation
import MapKit


struct CreateEventView: View {
    
    @State var eventName: String = ""
    @State var eventLocation: String = ""
    @State var eventStartTime : Date = Date()
    @State var membersCanInviteGuests : Bool = false
    @State var isAllDay : Bool = false
    @State var eventEndTime : Date = Date()
    @State var selectedFriends : [User] = []
    @State var selectedGroups : [Group] = []
    @State var openFriendsList : Bool = false
    @State var openGroupsList : Bool = false
    @State var searchLocationView : Bool = false
    @State var openImagePicker: Bool = false
    @State var image = UIImage(named: "topbarlogo")!
    var isGroup : Bool
    @StateObject var eventVM = EventViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    let options = ["Open to Friends", "Invite Only"]
    @State var selectedOption : Int = 0
    @State var invitationType : String = "Open to Friends"
    @State var showLocationPicker: Bool = false
    @State var location = EventModel.Location()
    @EnvironmentObject var locationManager : LocationManager
    @State var openDescriptionView : Bool = false
    @State var description: String = ""
    @State var openInviteMembersView : Bool = false
    @State var invitedMembers : [User] = []
    @State var openExcludeMembersView : Bool = false
    @State var excludedMembers: [User] = []
    @State var isShowingPhotoPicker:Bool = false
    @State var avatarImage = UIImage(named: "AppIcon")!
    @State var pickedAnImage: Bool = false
    @State var createEventChat : Bool = false
    @State var createGroupFromEvent: Bool = false
    @State var nonSpecifiedEndDate: Bool = false
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack(alignment: .center){
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                    
                    
                    
                  

                    Spacer()
                    
                    Button(action:{
                        
                        eventVM.createEvent(group: selectedGroupVM.group, eventName: eventName, eventLocation: eventLocation, eventStartTime: eventStartTime , eventEndTime: eventEndTime, usersVisibleTo:selectedGroupVM.group.realUsers , user: userVM.user ?? User(), image: image, invitationType: invitationType, location: location, membersCanInviteGuests: membersCanInviteGuests, invitedMembers: invitedMembers, excludedMembers: excludedMembers, description: description, createEventChat: createEventChat, createGroupFromEvent: createGroupFromEvent)
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Create").foregroundColor(FOREGROUNDCOLOR).padding(.horizontal,10).padding(.vertical,5).background(RoundedRectangle(cornerRadius: 16).fill(eventName == "" ? Color("Color") : Color("AccentColor"))).disabled(eventName == "")
                        
                    }).disabled(eventName == "")
                }.padding(.top,50).padding(.horizontal,10)
                
                
                ScrollView{
                    
                    
                    VStack(alignment: .leading, spacing: 20){
                        //Event Name
                        
                        VStack(){
                            
                            TextField("Event Name",text: $eventName).multilineTextAlignment(.center).font(.system(size: 25, weight: .bold))
                            Rectangle().frame(width: UIScreen.main.bounds.width-50, height: 2).foregroundColor(Color.gray)
                            
                        }.padding(10)
                        HStack{
                            
                            Text("Invitation Type").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            Divider()
                            Menu {
                                VStack{
                                    ForEach(options, id: \.self){ option in
                                        Button(action:{
                                            if option == options[0]{
                                                withAnimation{
                                                    selectedOption = 0
                                                    invitationType = "Open to Friends"
                                                }
                                            }
                                           
                                            else if option == options[2]{
                                                withAnimation{
                                                    selectedOption = 2
                                                    invitationType = "Invite Only"
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
                                    Image(systemName: "chevron.down").foregroundColor(Color.gray)
                                }
                            }
                            
                            
                        }.padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(.horizontal)
                        
                        
                        //place here
                        
                        VStack(alignment: .leading){
                            Text("Event Details").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            VStack{
                                HStack{
                                    Toggle(isOn: $isAllDay) {
                                        Text("All Day")
                                    }
                                }
                                Divider()
                                
                                
                                
                                HStack{
                                    Text("Start")
                                    if isAllDay{
                                        DatePicker("", selection: $eventStartTime, displayedComponents: .date)
                                    }else{
                                        DatePicker("", selection: $eventStartTime)
                                    }
                                    
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading){
                                    if !nonSpecifiedEndDate{
                                        HStack{
                                            Text("End")
                                            if isAllDay{
                                                DatePicker("", selection: $eventEndTime, displayedComponents: .date)
                                            }else{
                                                DatePicker("", selection: $eventEndTime)
                                            }
                                            Spacer()
                                        }
                                    }
                                  
                                    
                                    Toggle(isOn: $nonSpecifiedEndDate) {
                                        Text("Non-Specified End Date")
                                    }
                                }
                               
                                
                                
                                Divider()
                                
                                Button(action:{
                                    let dp = DispatchGroup()
                                    dp.enter()
                                    if location.id == nil {
                                        self.location = EventModel.Location()
                                    }
                                 
                                    dp.leave()
                                    dp.notify(queue: .main, execute:{
                                        self.showLocationPicker = true
                                    })
                                },label:{
                                    HStack{
                                        Image(systemName: "mappin").foregroundColor(FOREGROUNDCOLOR)
                                        if location.id == nil {
                                            Text("Add Location").foregroundColor(FOREGROUNDCOLOR)
                                            Spacer()
                                            Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                        }else{
                                            Text("\(location.address.isEmpty ? "Add Location" : location.address)").foregroundColor(location.address.isEmpty ? FOREGROUNDCOLOR : Color.blue).lineLimit(1)
                                            Spacer()
                                            Button(action:{
                                                location = EventModel.Location()
                                            },label:{
                                                Image(systemName: "xmark").foregroundColor(Color.gray)
                                            })
                                        }
                                        
                                        
                                    }
                                }).sheet(isPresented: $showLocationPicker, content: {
                                    LocationPickerView(location: $location)
                                })
                                
                                
                                
                                Divider()
                                
                                Button(action:{
                                    openDescriptionView = true
                                },label:{
                                    HStack{
                                        Image(systemName: "text.alignleft").foregroundColor(FOREGROUNDCOLOR)
                                        Text("\(description == "" ? "Description" : description)").lineLimit(2).foregroundColor(description == "" ? FOREGROUNDCOLOR : Color.gray)
                                        
                                        Spacer()
                                        Button(action:{
                                            
                                        },label:{
                                            Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                        })
                                    }
                                }).sheet(isPresented: $openDescriptionView, content: {
                                    AddEventDescriptionView(description: $description)
                                })
                                
                              
                              
                                
                                
                            }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        }.padding(.horizontal)
                        
                        VStack(alignment: .leading){
                            Text("Participants").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            VStack{
                                
                                Button {
                                    openInviteMembersView = true
                                } label: {
                                    HStack{
                                        VStack(alignment: .leading){
                                            HStack{
                                                Text("Invite Members").foregroundColor(FOREGROUNDCOLOR)
                                                Text("\(invitedMembers.count) invited").foregroundColor(Color.gray)
                                            }
                                            HStack{
                                                ForEach(invitedMembers) { member in
                                                    WebImage(url: URL(string: member.profilePicture ?? " "))
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width:25,height:25)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color("AccentColor"), lineWidth: 1))
                                                }
                                            }
                                           
                                        }
                                        Spacer()
                                        Button(action:{
                                            
                                        },label:{
                                            Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                        })
                                    }.padding(.bottom,5)
                                }.sheet(isPresented: $openInviteMembersView, content: {
                                    InviteMembersToEventView(selectedUsers: $invitedMembers, selectedGroups: $selectedGroups, openInviteFriendsView: $openInviteMembersView)
                                })

                                if selectedOption == 0 {
                                    Divider()
                                    Button {
                                        
                                        openExcludeMembersView = true
                                    } label: {
                                        HStack{
                                            VStack(alignment: .leading){
                                                HStack{
                                                    Text("Exclude Members").foregroundColor(FOREGROUNDCOLOR)
                                                    Text("\(excludedMembers.count) invited").foregroundColor(Color.gray)
                                                }
                                                HStack{
                                                    ForEach(excludedMembers) { member in
                                                        WebImage(url: URL(string: member.profilePicture ?? " "))
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width:25,height:25)
                                                            .clipShape(Circle())
                                                            .overlay(Circle().stroke(Color("AccentColor"), lineWidth: 1))
                                                    }
                                                }
                                               
                                            }
                                            Spacer()
                                            Button(action:{
                                                
                                            },label:{
                                                Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                            })
                                        }.padding(.bottom,5)
                                        
                                        
                                    }.sheet(isPresented: $openExcludeMembersView, content: {
                                        ExcludeMembersToEventView(selectedUsers: $excludedMembers, openInviteFriendsView: $openExcludeMembersView)
                                    })
                                }
                            
                                Divider()
                                
                                Toggle(isOn: $membersCanInviteGuests) {
                                    Text("Members Can Invite Guests")
                                }
                                
                                Divider()
                                
                                Toggle(isOn: $createEventChat) {
                                    Text("Create a Group Chat for the Event")
                                }
                                
                                Divider()
                                
                                Toggle(isOn: $createGroupFromEvent) {
                                    Text("Create a Group from this Event")
                                }
                                
                                
                                
                                
                            }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        }.padding(.horizontal)
                        
                        
                        
                        
                        
                    }.padding(.vertical,10)
                    
                    
                    
                }
                
                
                
                
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            self.invitedMembers.append(userVM.user ?? User())
        }
    }
}



struct LocationPickerView: View {
    
    @Binding var location: EventModel.Location
    @Environment(\.presentationMode) var presentationMode
    @State private var mapRegion = MKCoordinateRegion()
    @StateObject var placeVM = PlaceViewModel()
    let regionSize = 500.0 //meters
    @State var annotations: [Annotation] = []
    struct Annotation : Identifiable{
        let id = UUID().uuidString
        var name : String
        var coordinate: CLLocationCoordinate2D
        var address: String
    }
    @State private var searchText = ""
    @State private var selectedPlace : Place = Place(mapItem: MKMapItem())
    @State private var showMap : Bool = true
    @EnvironmentObject var locationManager : LocationManager
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(alignment: .center){
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                    
                    SearchBar(text: $searchText, placeholder: "Enter location", onSubmit: {
                        
                    })
                    
                    
                    
                    Spacer()
                    
                    
                }.padding(10)
                
                if showMap {
                    ZStack{
                        MapViewSelection(selectedPlace: $selectedPlace, location: location)
                        
                        
                        VStack{
                            Spacer()
                          
                                HStack{
                                    VStack(alignment: .leading){
                                        Text("Select this place").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title3)
                                        Text("\(selectedPlace.name)").foregroundColor(.gray).font(.subheadline)
                                        Text("\(selectedPlace.address)").foregroundColor(.gray).font(.subheadline)
                                    }
                                    Spacer()
                                    Button(action:{
                                        presentationMode.wrappedValue.dismiss()
                                            self.location = EventModel.Location(name: selectedPlace.name, id: nil, address: selectedPlace.address, latitude: selectedPlace.latitue, longitude: selectedPlace.longitude)
                                    },label:{
                                     
                                        Image(systemName: "chevron.right").foregroundColor(FOREGROUNDCOLOR).frame(width: 50, height: 50).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                                    })
                                   
                                }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).padding().padding(.bottom)
                            
                           
                        }
                        
                        
                    }
                    .edgesIgnoringSafeArea(.all).navigationBarHidden(false)
                    .onAppear{
                        if location.id == nil{
                            if let coordinate = locationManager.userLocation?.coordinate{
                                locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                locationManager.addDraggablePin(coordinate: coordinate)
                                locationManager.pickedLocation = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                                
                            }
                        }else{
                            locationManager.mapView.region = .init(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                            locationManager.addDraggablePin(coordinate: location.coordinate)
                        }


                    }.onChange(of: searchText, perform: { text in
                        if !text.isEmpty {
                            placeVM.search(text: text, region: MKCoordinateRegion(center: selectedPlace.coordinate, latitudinalMeters: 0.1, longitudinalMeters: 0.1))
                            if showMap {
                                showMap = false
                            }
                        }else{
                            showMap = true
                        }
                    })
                }else{
                    List(placeVM.places) { place in
                        Button(action:{
                            
                            locationManager.pickedLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                            locationManager.updatePlacemark(location: .init(latitude: place.coordinate.latitude , longitude: place.coordinate.longitude))
                         
                            showMap = true
                            selectedPlace = place
                            searchText = place.name
                            location = EventModel.Location(name: selectedPlace.name, id: selectedPlace.id, latitude: selectedPlace.latitue, longitude: selectedPlace.longitude)
                            
                        },label:{
                            VStack(alignment: .leading){
                                Text(place.name).foregroundColor(FOREGROUNDCOLOR).font(.title2)
                                Text(place.address).foregroundColor(FOREGROUNDCOLOR).font(.callout)
                            }
                        })
                       
                    }
                }
            }
        }
    }
}
            
            

        
        
        struct Place: Identifiable {
            let id = UUID().uuidString
            private var mapItem: MKMapItem
            
            init(mapItem: MKMapItem){
                self.mapItem = mapItem
            }
            
            
            var name: String {
                self.mapItem.name ?? ""
            }
            
            var address: String {
                let placemark = self.mapItem.placemark
                var cityAndState = ""
                var address = ""
                
                cityAndState = placemark.locality ?? "" //city
                if let state = placemark.administrativeArea {
                    // show either state or city, state
                    cityAndState = cityAndState.isEmpty ? state : "\(cityAndState), \(state)"
                }
                
                address = placemark.subThoroughfare ?? "" //address #
                if let street = placemark.thoroughfare {
                    //just show street unless there is a street # then add space + street
                    address = address.isEmpty ? street : "\(address) \(street)"
                }
                
                if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
                    //no address? then just city and state with no space
                    address = cityAndState
                }else{
                    //no cityandstate then just address, otherwise address, cityandstate
                    address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
                    
                }
                
                return address
            }
            
            var latitue : Double {
                self.mapItem.placemark.coordinate.latitude
            }
            
            var longitude : Double {
                self.mapItem.placemark.coordinate.longitude
            }
            
            var coordinate : CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: latitue, longitude: longitude)
            }
        }
        
        
        
        class PlaceViewModel : ObservableObject {
            @Published var places : [Place] = []
            
            func search(text: String, region: MKCoordinateRegion) {
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = text
                searchRequest.region = region
                let search = MKLocalSearch(request: searchRequest)
                
                search.start { response, err in
                    guard let response = response else {
                        print("ERROR")
                        return
                    }
                    
                    self.places = response.mapItems.map(Place.init)
                }
            }
        }
        

struct MapViewSelection: View {
    @EnvironmentObject var locationManager : LocationManager
    @Binding var selectedPlace: Place
    @State var location: EventModel.Location
    var body : some View {
        ZStack{
            MapViewHelper()
            
        }.onReceive(locationManager.$pickedPlaceMark, perform: { newPlaceMark in
            if let newPlaceMark = newPlaceMark{
                let placeMark = MKPlacemark(placemark: newPlaceMark)
                
                    selectedPlace = Place(mapItem: MKMapItem(placemark: placeMark))
                
            }
         
        })
    }
}

struct MapViewHelper : UIViewRepresentable {
    @EnvironmentObject var locationManager : LocationManager
    func makeUIView(context: Context) -> some UIView {
        return locationManager.mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

//
//  MapView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct MapView: View {
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var tapped: Bool = false
    @Binding var group : Group
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @State var followUser : Bool = false
    @State var selectedUser : User = User()
    
    @StateObject private var locationManager = LocationManager()
    
    func convertToBinding(users: [User]) -> Binding<[User]>{
        
        
        return Binding(get: {users}, set: {_ in})
    }
    
    
    
    
    
    var body: some View {
        
        
        ZStack(alignment: .bottomTrailing){
            
            
            //map start
            Map(coordinateRegion: $locationManager.region , interactionModes: .all, showsUserLocation: true, annotationItems: locationManager.userAnnotations){ annotation in
                MapAnnotation(coordinate: annotation.coordinate){

                    Button(action:{
                        locationManager.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: annotation.user.latitude ?? 0, longitude: annotation.user.longitude ?? 0), latitudinalMeters: 5000, longitudinalMeters: 5000)
                        self.selectedUser = annotation.user
                        self.followUser.toggle()
                    },label:{
                        WebImage(url: URL(string: annotation.user.profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("AccentColor"),lineWidth: 2))
                    })


                }
            }.edgesIgnoringSafeArea(.all)
            
            
      
                
                ScrollView(){
                    VStack(spacing: 20){
                        VStack{
                            HStack(alignment: .top){
                                VStack(alignment: .leading){
                                    HStack(spacing: 3){
                                        Text("Location Sharing").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                                        Text("On").foregroundColor(Color.green).font(.system(size: 14))
                                    }
                                    Text("5629 Hobsons Choice Loop").lineLimit(1).foregroundColor(Color.gray).font(.system(size: 12))
                                    
                            
                                Text("you have been location sharing since 8:09 am").lineLimit(1).foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                             
                                    
                                }
                                
                                Spacer()
                                
                                Button(action:{
                                    
                                },label:{
                                    Image(systemName: "gear").foregroundColor(FOREGROUNDCOLOR)
                                })
                            }
                          
                                    
                                
                                
                                
                               
                                
                            
                        }

                        //0 -> Binding
                        //1 -> Not Binding

                        ForEach(selectedGroupVM.group.realUsers){ user in
                            VStack{
                                Divider()
                            Button(action:{
                                locationManager.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: user.latitude ?? 0, longitude: user.longitude ?? 0), latitudinalMeters: 5000, longitudinalMeters: 5000)
                                self.selectedUser = user
                                self.followUser.toggle()
                            },label:{
                                HStack(spacing: 4){
                                    WebImage(url: URL(string: user.profilePicture ?? " "))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 1){
                                        Text("\(user.id ?? "" == userVM.user?.id ?? "" ? "Me" : "\(user.nickName ?? "")")").foregroundColor(FOREGROUNDCOLOR).font(.caption).bold()
                                        Text("Bruce's House").foregroundColor(FOREGROUNDCOLOR).font(.caption)
                                        Text("Since 8:09 am").foregroundColor(FOREGROUNDCOLOR).font(.caption)
                                    }

                                    Spacer()
                                }
                            })
                            }





                        }
                    }
                    
                    
                }.padding().background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/3)
                
            

            NavigationLink(destination: SelectedUserMapView(user: $selectedUser, followUser: $followUser, locationManager: locationManager), isActive: $followUser) {
                EmptyView()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            
            locationManager.setCurrentUser(userID: userVM.user?.id ?? " ")
            locationManager.setCurrentGroup(groupID: group.id)
            locationManager.fetchLocations(usersID: group.users ?? [])
        }
        
        
    }
    
    
    
    
}





//
//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}

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
  
    @StateObject private var locationManager = LocationManager()
   
    func convertToBinding(users: [User]) -> Binding<[User]>{
        
        
        return Binding(get: {users}, set: {_ in})
    }
    
    
    
    
    
    var body: some View {
      
           
            ZStack{
          
                Map(coordinateRegion: locationManager.region.getBinding()!, interactionModes: .all, showsUserLocation: true, annotationItems: locationManager.userAnnotations){ annotation in
                    MapAnnotation(coordinate: annotation.coordinate){
                        
                        Button(action:{
                            
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

                

                VStack{
                    
                 
                    
                    
                    Spacer()
                    
                    ScrollView(.horizontal){
                        HStack(spacing: 20){
                            
                            //0 -> Binding
                            //1 -> Not Binding
                            ForEach(selectedGroupVM.group.realUsers){ user in
                                
                                Button(action:{
                                    locationManager.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: user.latitude ?? 0, longitude: user.longitude ?? 0), latitudinalMeters: 5000, longitudinalMeters: 5000)
                                },label:{
                                    VStack(spacing: 5){
                                        WebImage(url: URL(string: user.profilePicture ?? " "))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width:40,height:40)
                                            .clipShape(Circle())

                                        
                                        Text("\(user.nickName ?? "TOP SECRET USER")").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                                        
                                        Text("\(user.latitude ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.caption)
                                    }
                                })
                                
                             

                                  
                                   
                            }
                        }
                       
                     
                    }.padding().background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding().padding(.bottom,UIScreen.main.bounds.height/8)
                   
                }
              
                
            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
               
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

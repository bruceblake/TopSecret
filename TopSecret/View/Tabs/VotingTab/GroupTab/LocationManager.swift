//
//  LocationManager.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/19/22.
//

import Foundation
import CoreLocation
import Firebase
import GeoFire
import GeoFireUtils
import SwiftUI

final class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation : CLLocation?
    @Published var userID: String = " "
    @Published var groupID: String = " "
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 20, longitude: 37), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @Published var userAnnotations : [UserAnnotations] = []

    private let locationManager = CLLocationManager()
    let userVM = UserViewModel.shared
    
    override init() {
           super.init()
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.distanceFilter = kCLDistanceFilterNone
           locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
           locationManager.startUpdatingLocation()
           locationManager.delegate = self
        locationManager.requestLocation()

       }
    
    

 
    
    func setCurrentUser(userID: String){
        self.userID = userID
    }
    
    func setCurrentGroup(groupID: String){
        self.groupID = groupID
    }
    
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
      
              guard let location = locations.last else { return }
              DispatchQueue.main.async {
                  self.userLocation = location
//                  self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 0.03, longitudinalMeters: 0.03)
                  let latitude = location.coordinate.latitude
                  let longitude = location.coordinate.longitude
                  
             
                  COLLECTION_USER.document(self.userID).updateData(["latitude":latitude, "longitude":longitude])
                  
                  COLLECTION_GROUP.document(self.groupID).getDocument { snapshot, err in
                      if err != nil {
                          print("ERROR")
                          return
                      }
                      
                      var value = snapshot?.get("ping") as? Bool ?? false
                      COLLECTION_GROUP.document(self.groupID).updateData(["ping":value == true ? false : true])
                      
                  }
                  
              }
        
      }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user???s location
        print("ERROR: \(error.localizedDescription)")
        return
    }
    
    func fetchLocations(usersID: [String]){
        
        var annotationsToReturn : [UserAnnotations] = []
        
       

        for user in usersID {
            COLLECTION_USER.document(user).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                
                let latitude = data["latitude"]
                let longitude = data["longitude"]
                
                print("latitude: \(latitude as! CLLocationDegrees)")
                
                self.userAnnotations.append(UserAnnotations(user: User(dictionary: data), coordinate: CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)))
                

                
                
            }

        }


        
     
    }
}


struct UserAnnotations : Identifiable{
    var id = UUID().uuidString
    var user: User
    var coordinate : CLLocationCoordinate2D
}



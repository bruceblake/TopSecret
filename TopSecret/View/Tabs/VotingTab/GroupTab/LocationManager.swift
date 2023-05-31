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

final class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate, MKMapViewDelegate {
    @Published var userLocation : CLLocation?
    @Published var userID: String = " "
    @Published var groupID: String = " "
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 20, longitude: 37), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @Published var userAnnotations : [UserAnnotations] = []
    @Published var city = ""
    @Published var state = ""
    @Published var mapView : MKMapView = .init()
    @Published var pickedLocation : CLLocation?
    @Published var pickedPlaceMark: CLPlacemark?
    private let locationManager = CLLocationManager()
    let userVM = UserViewModel.shared
    
    override init() {
           super.init()
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.distanceFilter = kCLDistanceFilterNone
           locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
           locationManager.stopUpdatingLocation()
           locationManager.delegate = self
            locationManager.requestLocation()
        mapView.delegate = self

       }
    
    

    func addDraggablePin(coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        
        annotation.title = "Hold and drag to desired location"
        
        
        if mapView.annotations.isEmpty{
            mapView.addAnnotation(annotation)
        }else{
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKPointAnnotation {
            let identifier = "User"
            var view: CustomAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.isDraggable = true
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
            }
            
            return view
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        guard let newLocation = view.annotation?.coordinate else {return}
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlacemark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
    }
    
    func updatePlacemark(location: CLLocation){
        Task{
            do{
                guard let place = try await reverseLocationCoordinates(location: location) else {return}
                await MainActor.run(body: {
                    self.pickedPlaceMark = place
                })
            }
            catch{
                
            }
        }
        
    }
    
    func reverseLocationCoordinates(location: CLLocation)async throws->CLPlacemark?{
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
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
                  let geocoder = CLGeocoder()
                  geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                      print(error)
                      return
                    }

                    if let placemark = placemarks?.first {
                        self.city = placemark.locality ?? "City"
                      self.state = placemark.administrativeArea ?? "State"
                    }
                  }
                  self.userLocation = location
                  self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 0.03, longitudinalMeters: 0.03)
                  let latitude = location.coordinate.latitude
                  let longitude = location.coordinate.longitude
                  
             
                  COLLECTION_USER.document(self.userID).updateData(["latitude":latitude, "longitude":longitude])
                  
                  COLLECTION_GROUP.document(self.groupID).getDocument { snapshot, err in
                      if err != nil {
                          print("ERROR")
                          return
                      }
                      
                  }
                  
              }
        
      }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
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
                
                
                self.userAnnotations.append(UserAnnotations(user: User(dictionary: data), coordinate: CLLocationCoordinate2D(latitude: latitude as? CLLocationDegrees ?? CLLocationDegrees(), longitude: longitude as? CLLocationDegrees ?? CLLocationDegrees())))
                

                
                
            }

        }


        
     
    }
}


struct UserAnnotations : Identifiable{
    var id = UUID().uuidString
    var user: User
    var coordinate : CLLocationCoordinate2D
}


class CustomAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            if let annotation = annotation as? MKPointAnnotation {
                // Set the image and center offset for the annotation view
                // Assume "originalImage" is the original image you want to resize
                var originalImage = UIImage(named: "MapPin")
                originalImage = originalImage?.withTintColor(UIColor(Color("AccentColor")))
                
                let newSize = CGSize(width: 60, height: 60) // Define the size you want
                UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                originalImage?.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.image = resizedImage
                
                
                
                self.centerOffset = CGPoint(x: 0, y: -self.image!.size.height / 2)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            // Create a custom callout view
            let calloutView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            calloutView.backgroundColor = UIColor.white
            
            let calloutLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 180, height: 80))
            calloutLabel.numberOfLines = 1
            calloutLabel.text = "Custom Callout View"
            calloutView.addSubview(calloutLabel)
            
            // Set the callout view for the annotation view
            self.detailCalloutAccessoryView = calloutView
        } else {
            self.detailCalloutAccessoryView = nil
        }
    }
}

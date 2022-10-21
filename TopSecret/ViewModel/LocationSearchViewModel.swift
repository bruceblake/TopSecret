//
//  LocationSearchViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/11/22.
//

import Foundation
import SwiftyJSON

// This file was generated from JSON Schema using codebeautify, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let response = try Response(json)

import Foundation
import CoreLocation
import CoreLocation
import SwiftUI
import MapKit


class LocationSearchViewModel : ObservableObject{
    
    @Published var region : MKCoordinateRegion = MKCoordinateRegion.goldenGateRegion()
    var apiKey = "c91c3f9851aa4a18a65c4f77650f5dce"
    
    
   
    
    func fetchLocations(){
         guard let url = URL(string: "https://iosacademy.io/api/v1/courses/index.php") else {
                print("Invalid URL")
                return
            }
            
            let request = URLRequest(url: url)
           
            URLSession.shared.dataTask(with: request) { data,response, error in
               
                if let data = data {
                               do {

//                                   let results = try! JSONDecoder().decode([Courses].self, from: data)
//                                   DispatchQueue.main.async{
//                                       self.results = results
//                                       for result in results {
//                                           print("result: \(result.name)")
//                                       }
//                                   }
                               }
                               catch {
                                   print(error)
                               }
                           }
                

              
                
            }.resume()
        }
    
}

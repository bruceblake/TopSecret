////
////  LocationSearchViewModel.swift
////  Top Secret
////
////  Created by Bruce Blake on 10/11/22.
////
//
//import Foundation
//import SwiftyJSON
//
////struct FeatureCollection : Codable {
////    var type: String
////    var features : [Features]
////
////    enum CodingKeys : String , CodingKey {
////        case type, features
////    }
////}
////
////struct Features : Codable{
////    var type: String
////    var properties : [FeatureProperties]
////    var geometry: [FeatureGeometry]
////
////    enum CodingKeys : String , CodingKey {
////        case type, properties, geometry
////    }
////}
////
////struct FeatureGeometry : Codable {
////    var type: String
////    var coordinates : [Double]
////}
////
////struct FeatureProperties : Codable {
////    var name: String
////    var country: String
////    var state: String
////    var postcode: String
////    var city: String
////    var street: String
////    var housenumber: String
////    var lat: Double
////    var lon: Double
////    var formatted: String
////    var address_line1: String
////    var address_line2: String
////    var place_id: String
////    var categories : [String]
////
////}
//
//
//
//class LocationSearchViewModel : ObservableObject {
//    
//    @Published var locations : [Features] = []
//    var apiKey = "c91c3f9851aa4a18a65c4f77650f5dce"
//    
//    func fetchLocations(){
//         guard let url = URL(string: "https://api.geoapify.com/v2/places?categories=entertainment.museum&filter=rect:2.3380862086841603,48.861868995221684,2.357539944586165,48.850557094041235&limit=20&apiKey=\(apiKey)"
//) else {
//                print("Invalid URL")
//                return
//            }
//            
//            let request = URLRequest(url: url)
//           
//            URLSession.shared.dataTask(with: request) { data,response, error in
//               
//                if let data = data {
//                               do {
//                                   let results = try JSONDecoder().decode(Response.self, from: data)
//                                   DispatchQueue.main.async {
//                                       self.locations = results.features
//                                       for feature in results.features {
//                                           print("type: \(feature.type)")
//                                       }
//                                   }
//                               }
//                               catch {
//                                   print(error)
//                               }
//                           }
//                
//
//              
//                
//            }.resume()
//        }
//    
//}

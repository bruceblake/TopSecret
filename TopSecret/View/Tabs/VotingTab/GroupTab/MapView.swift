//
//  MapView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import MapKit


struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var tapped: Bool = false
    @Binding var showMapView : Bool
    @Binding var showTabButtons : Bool
    
    private func getNearByLandmarks() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
                
            }
        }
    }
    
    func calculateOffset() -> CGFloat {
        if self.landmarks.count > 0 && !self.tapped {
            return UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 4
        }
        else if self.tapped {
            return 100
        }else {
            return UIScreen.main.bounds.size.height
        }
    }
    
    
    var body: some View {
      
          
           
            VStack{
                Spacer()
                Button(action:{
                    withAnimation(.spring()){
                        self.showMapView.toggle()
                        self.showTabButtons.toggle()
                    }
                },label:{
                    Text("X").foregroundColor(FOREGROUNDCOLOR)
                }).padding(.top,40)
                MapViewUtility(landmarks: landmarks).padding(.top,50)
                
            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all).navigationBarHidden(true)
             
            
          
   
        
    }
}
//
//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}

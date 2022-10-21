//
//  LocationSearchView.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/11/22.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    @StateObject var locationSearchVM = LocationSearchViewModel()
    @StateObject var searchResultsVM = SearchResultsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State var search: String = ""
    var body: some View {
        ZStack{
            Color("Background")
            NavigationView{
               
                VStack{
                    List(searchResultsVM.places){ place in
                        Text(place.name)
                    }
                }.searchable(text: $search)
                    .onChange(of: search) { searchText in
                        searchResultsVM.search(text: searchText, region: locationSearchVM.region)
                    }
            }
        }.edgesIgnoringSafeArea(.all).onAppear{
            locationSearchVM.fetchLocations()
        }
    }
}

@MainActor
class SearchResultsViewModel: ObservableObject {
    
    @Published var places = [PlaceViewModel]()
    
    func search(text: String, region: MKCoordinateRegion){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response , error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "ERROR")")
                return
            }
            self.places = response.mapItems.map(PlaceViewModel.init)
        }
    }
}

struct PlaceViewModel: Identifiable {
    let id = UUID()
    private var mapItem : MKMapItem
    
    init(mapItem: MKMapItem){
        self.mapItem = mapItem
    }
    
    var name: String {
        mapItem.name ?? ""
    }
}

//
//  HomeCalendarViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/14/22.
//

import Foundation
import SwiftUI
import Combine


class HomeCalendarViewModel : ObservableObject {
    
 
    @Published var eventsResults : [EventModel] = []
    @Published var eventsReturnedResults : [EventModel] = []
    @Published var countdownResults : [CountdownModel] = []
    @Published var countdownReturnedResults : [CountdownModel] = []
    @Published var selectedOption : String = ""
    @Published var currentDate : Date = Date()
    
    private var cancellables = Set<AnyCancellable>()
    

    func startSearch(groupID: String){
        self.fetchEvents(groupID: groupID)
        self.fetchCountdowns(groupID: groupID)
    }
    
    func setCurrentDate(currentDate: Date){
        self.currentDate = currentDate
    }
    
   
    
    private func filterResults(selectedOption: String, eventsResults: [EventModel], countdownResults: [CountdownModel]) -> [[Any]]{
        
        var res : [[Any]] = []
        
        res.append(eventsResults.filter {
            let eventDate = $0.eventTime?.dateValue() ?? Date()
            
            let dateComponents = Calendar.current.dateComponents([.day, .hour, .second], from: eventDate)
            
    
            
            return dateComponents.day ?? 0 == Calendar.current.dateComponents([.day, .hour, .second], from: currentDate).day! && dateComponents.hour ?? 0 >= Calendar.current.dateComponents([.day, .hour], from: currentDate).hour!
        })
        
        res.append(countdownResults.filter {
            let countdownDate = $0.endDate?.dateValue() ?? Date()
            
            let dateComponents = Calendar.current.dateComponents([.day, .hour], from: countdownDate)
            
            return dateComponents.day ?? 0 == Calendar.current.dateComponents([.day], from: currentDate).day! && dateComponents.hour ?? 0 > Calendar.current.dateComponents([.day], from: currentDate).hour!
        })
        
        
        return res
        
    }
    
    func fetchEvents(groupID: String) {
        COLLECTION_GROUP.document(groupID).collection("Events").order(by: "eventTime", descending: false).getDocuments { snapshot, err in
         
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.eventsResults = documents.map({ (queryDocumentSnapshot) -> EventModel in
                let data = queryDocumentSnapshot.data()
                
                return EventModel(dictionary: data)
            })
            
        }
        
        $selectedOption
            .combineLatest($eventsResults, $countdownResults)
            .map(self.filterResults)
            .sink { [self](returnedResults) in
                eventsReturnedResults = returnedResults[0] as? [EventModel] ?? []
                countdownReturnedResults = returnedResults[1] as? [CountdownModel] ?? []
            }
            .store(in: &self.cancellables)
        
      
            
        
    }
    
    func fetchCountdowns(groupID: String) {
        COLLECTION_GROUP.document(groupID).collection("Countdowns").order(by: "endDate", descending: false).getDocuments { snapshot, err in
         
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.countdownResults = documents.map({ (queryDocumentSnapshot) -> CountdownModel in
                let data = queryDocumentSnapshot.data()
                
                return CountdownModel(dictionary: data)
            })
            
        }
        
        $selectedOption
            .combineLatest($eventsResults, $countdownResults)
            .map(self.filterResults)
            .sink { [self](returnedResults) in
                eventsReturnedResults = returnedResults[0] as? [EventModel] ?? []
                countdownReturnedResults = returnedResults[1] as? [CountdownModel] ?? []
            }
            .store(in: &self.cancellables)

            
        
    }
    
    
    
    func isCurrentHour(date: Date) -> Bool{
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        let currentHour = calendar.component(.hour, from: Date())
        
        return hour == currentHour
    }
    
    
}


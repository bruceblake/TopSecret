//
//  GroupCalendarViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/16/22.
//

import Foundation
import SwiftUI
import Combine


struct DayWeather : Identifiable, Decodable{
    var id: Int
    var city : City
    
    struct City : Decodable{
        var id: Int
        var name: String
        var coord: Coordinate
    }
    
    struct Coordinate : Decodable{
        var lat : Double
        var lon : Double
    }
    
    
}




class GroupCalendarViewModel : ObservableObject {
    
    @Published var eventsResults : [EventModel] = []
    @Published var selectedOption : String = ""
    @Published var weatherOfDays : [DayWeather] = []
    
    func getWeather(user: User){
        guard let url = URL(string: "api.openweathermap.org/data/2.5/forecast/daily?lat=\(user.latitude ?? 40.0)&lon=\(user.longitude ?? 40.0)&cnt=\(7)&appid=\("47a659429631a1f4bb57c1a2507e0e26")") else {fatalError("error getting weather")}
    
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: \(error)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {return}

            if response.statusCode == 200 {
                guard let data = data else {return}
                DispatchQueue.main.async {
                    do{
                        print("fetching JSON")
                        let decodedData = try JSONDecoder().decode([DayWeather].self, from: data)
                        self.weatherOfDays = decodedData
                    }catch let err{
                        print("Error decoding: \(err)")
                    }
                }
            }
            
        }
        
    }
    
    
   
    private var cancellables = Set<AnyCancellable>()
    
    func startSearch(groupID: String, startDay: Date, endDay: Date){
        self.fetchEvents(groupID: groupID, startDay: startDay, endDay: endDay)
    }
    
    

    
    func fetchEventUsersAttending(usersAttendingID: [String], eventID: String , groupID: String, completion: @escaping ([User]) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).getDocument { snapshot, err in
            
            if err != nil {
                print("ERROR")
                return
            }
            var usersToReturn : [User] = []
            
            
            let groupD = DispatchGroup()
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            let users = data["usersAttendingID"] as? [String] ?? []
            
            for user in users {
                groupD.enter()
                COLLECTION_USER.document(user).getDocument { userSnapshot, err in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    let userData = userSnapshot?.data() as? [String:Any] ?? [:]
                    
                    usersToReturn.append(User(dictionary: userData))
                    groupD.leave()
                }
            }
            
            groupD.notify(queue: .main, execute: {
                return completion(usersToReturn)
            })
            
        }
        
        
    }
    
    func fetchEvents(groupID: String, startDay: Date, endDay: Date) {
        COLLECTION_GROUP.document(groupID).collection("Events").order(by: "eventStartTime", descending: false).getDocuments { snapshot, err in
         
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            var eventsToReturn : [EventModel] = []
            
            var groupD = DispatchGroup()
            
           
            groupD.enter()
            
            for document in documents {
                groupD.enter()

                var data = document.data()
                var startTime = data["eventStartTime"] as? Date ?? Date()
                let users = data["usersAttendingID"] as? [String] ?? []
                self.fetchEventUsersAttending(usersAttendingID: users, eventID: data["id"] as? String ?? " ", groupID: groupID) { fetchedUsers in
                    data["usersAttending"] = fetchedUsers
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    eventsToReturn.append(EventModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
         
            
            groupD.notify(queue: .main, execute: {
                self.eventsResults = eventsToReturn
            })
            
        }
        
      
            
        
    }
    
    
}

extension Date {
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
}
//
//  EventViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import Foundation
import Firebase
import SwiftUI
import Combine


class EventViewModel: ObservableObject {
    
    @ObservedObject var eventRepository = EventRepository()
    
    
    func createEvent(groupID: String, eventName: String, eventLocation: String, eventTime: Date, usersVisibleTo: [String], user: User){
        eventRepository.createEvent(groupID: groupID, eventName: eventName, eventLocation: eventLocation, eventTime: eventTime, usersVisibleTo: usersVisibleTo, user: user)
    }
    
    func deleteEvent(eventID: String){
        eventRepository.deleteEvent(eventID: eventID)
    }
    
    func editEvent(){
        eventRepository.editEvent()
    }
    
    func addUserToVisibilityList(userID: String, eventID: String){
        eventRepository.addUserToVisibilityList(eventID: eventID, userID: userID)
    }
    
    func fetchEvent(eventID: String, completion: @escaping (EventModel) -> ()) -> (){
        eventRepository.fetchEvent(eventID: eventID) { event in
            return completion(event)
        }
    }
}

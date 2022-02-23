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
    
    
    func createEvent(eventName: String, eventLocation: String, eventTime: Date, usersVisibleTo: [String], userID: String){
        eventRepository.createEvent(eventName: eventName, eventLocation: eventLocation, eventTime: eventTime, usersVisibleTo: usersVisibleTo, userID: userID)
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
}

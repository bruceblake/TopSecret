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
    
    
    func createEvent(group: Group, eventName: String, eventLocation: String, eventTime: Date, usersVisibleTo: [User], user: User){
        eventRepository.createEvent(group: group, eventName: eventName, eventLocation: eventLocation, eventTime: eventTime, usersVisibleTo: usersVisibleTo, user: user)
        
    }
    
    
    func joinEvent(eventID: String, groupID: String, userID: String){
        eventRepository.joinEvent(eventID: eventID, groupID: groupID, userID: userID)
    }
    
    func leaveEvent(eventID: String, groupID: String, userID: String){
        eventRepository.leaveEvent(eventID: eventID, groupID: groupID, userID: userID)
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

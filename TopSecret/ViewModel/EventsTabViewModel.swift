//
//  EventsTabViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/20/23.
//

import Foundation

class EventsTabViewModel : ObservableObject {
    @Published var events : [EventModel] = []
    
    
    func fetchOpenToFriendsEvents(userID: String){
        
    }
    
    func rsvpForEvent(userID: String){
        
    }
    
    func leaveEvent(userID: String){
        
    }
}

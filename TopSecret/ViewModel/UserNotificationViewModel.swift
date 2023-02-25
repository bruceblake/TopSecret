//
//  UserNotificationViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/27/22.
//

import Foundation

class UserNotificationViewModel: ObservableObject{
    
    
    func getTimeSinceNotification(date: Date) -> String{
       let interval = (Date() - date)
        
        
        var seconds = interval.second ?? 0
        var minutes = (seconds / 60)
        var hours = (minutes / 60)
        var days = (hours / 24)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
        }
        if time == "0s"{
            return "now"
        }
        else{
        return time
        }
        
    }
}

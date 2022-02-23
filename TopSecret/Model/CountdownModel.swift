//
//  CountdownModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/18/22.
//

import Foundation
import Firebase


struct CountdownModel : Identifiable {
    
    var id: String?
    var countdownName: String?
    var startDate: Timestamp?
    var endDate: Timestamp?
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? " "
        self.countdownName = dictionary["countdownName"] as? String ?? ""
        self.startDate = dictionary["startDate"] as? Timestamp ?? Timestamp()
        self.endDate = dictionary["endDate"] as? Timestamp ?? Timestamp()

     }
    
}

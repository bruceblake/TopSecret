//
//  PollRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/10/21.
//

import Foundation
import Firebase
import Combine
import SwiftUI

class PollRepository : ObservableObject {
    
    
    
   
    
    func createPoll(creator: String, question: String, group: Group, pollType: String, days: Int, hours: Int, minutes: Int, choices: [String], completionType: String, users: [String], id: String){
        let newDay = Calendar.current.date(byAdding: .day, value: days, to: Date())
        let newHour = Calendar.current.date(byAdding: .hour, value: hours, to: newDay ?? Date())
        let endDate = Calendar.current.date(byAdding: .minute, value: minutes, to: newHour ?? Date())

        let data = ["creator":creator,"question":question,"dateCreated":Timestamp(),"id":id, "groupID":group.id, "groupName":group.groupName,"users":users ,"pollType":pollType,"totalUsers":users.count, "choices":choices,"completionType":completionType, "endDate":endDate ?? Timestamp(),"finished":false] as [String : Any]
        COLLECTION_POLLS.document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR")
                return
            }
            
        }
        
        
        COLLECTION_GROUP.document(group.id).collection("Polls").document(UUID().uuidString).setData(data){ err in
            if err != nil {
                print("ERROR")
                return
            }
        }
        
    }
    
    func endPoll(pollID: String){
        //TODO
        COLLECTION_POLLS.document(pollID).updateData(["finished":true])
    }
    
    func deletePoll(pollID: String){
        COLLECTION_POLLS.document(pollID).delete()
        print("Deleted Poll!")
    }
    
    func selectAnswer(pollID: String, selection: String, userNickName: String){
        COLLECTION_POLLS.document(pollID).updateData(["usersAnswered":FieldValue.arrayUnion([[userNickName:selection]])])
        COLLECTION_POLLS.document(pollID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            let totalUsers = snapshot?.get("totalUsers") as? Int ?? 0
            let usersAnswered = snapshot?.get("usersAnswered") as? [[String:String]] ?? []
           
     
        
            
            if totalUsers == usersAnswered.count{
                self.endPoll(pollID: pollID)
            }
        }
        
        
    }
    
    
 
    
    
    

    
}

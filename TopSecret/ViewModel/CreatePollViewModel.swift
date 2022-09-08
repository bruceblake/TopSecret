//
//  CreatePollViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/1/22.
//

import Foundation
import Firebase

class CreatePollViewModel : ObservableObject {
    
    func createPoll(creatorID: String, pollOptions: [PollOptionModel], groupID: String = " ", question: String, usersVisibleToID: [String]){
        
        let pollID = UUID().uuidString
        
        let pollData = ["id":pollID,"question":question,"creatorID":creatorID,"groupID":groupID,"finished":false, "usersVisibleToID":usersVisibleToID, "startDate":Timestamp()] as [String:Any]
        
        COLLECTION_GROUP.document(groupID).collection("Polls").document(pollID).setData(pollData)
        for option in pollOptions {
            let pollOptionData = ["id":option.id ?? "","choice":option.choice ?? ""] as [String:Any]
            COLLECTION_GROUP.document(groupID).collection("Polls").document(pollID).collection("Options").document(option.id ?? " ").setData(pollOptionData)
        }
    }
    
    func makePollChoice(pollID: String, choiceID: String, userID: String, groupID: String){
        
        //add user to poll option choice list
        COLLECTION_GROUP.document(groupID).collection("Polls").document(pollID).collection("Options").document(choiceID).updateData(["pickedUsersID":FieldValue.arrayUnion([userID])])
        
        //add user to poll users answered list
        COLLECTION_GROUP.document(groupID).collection("Polls").document(pollID).updateData(["usersAnsweredID":FieldValue.arrayUnion([userID])])
    }
    
  
  
}

//
//  PollViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 10/4/21.
//

import SwiftUI
import Firebase

class PollViewModel : ObservableObject{
    
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var pollRepository = PollRepository()
    
    
    init(){
    }
    
    
    func createPoll(creator: String, question: String, group: Group, pollType: String, days: Int, hours: Int, minutes: Int, choices: [String],completionType: String, users: [String], id: String){
        pollRepository.createPoll(creator: creator, question: question, group: group, pollType: pollType, days: days, hours: hours, minutes: minutes, choices: choices, completionType: completionType, users: users, id: id)
    }
    
    func endPoll(pollID: String){
        pollRepository.endPoll(pollID: pollID)
    }
    
    func deletePoll(pollID: String){
        pollRepository.deletePoll(pollID: pollID)
    }
    
    func selectAnswer(pollID: String, selection: String, userNickName: String){
        pollRepository.selectAnswer(pollID: pollID, selection: selection, userNickName: userNickName)
    }
    
    
    func getTimeRemaining(startDate: Date){
        let diffComponents = Calendar.current.dateComponents([.day,.hour,.minute,.second], from: startDate, to: Date())
        
        let days = diffComponents.day
        let hours = diffComponents.hour
        let minutes = diffComponents.minute
        let seconds = diffComponents.second
        
        print("time between \(startDate) and \(Date()) is:  \(days ?? 0) days, \(hours ?? 0) hours, \(minutes ?? 0) minutes, \(seconds ?? 0) seconds")
    }
    
    
    func getPercentageVoted(pollID: String, choice: String, completion: @escaping (Double) -> () ) -> () //first value is choice 1, second value is choice 2 percentage
            
    {
        var choiceOneAnswerCount : Double = 0.0
        var choiceOnePercentage : Double = 0.0
        
        COLLECTION_POLLS.document(pollID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            let totalUsers = snapshot?.get("totalUsers") as? Double ?? 0.0
            let usersAnswered = snapshot?.get("usersAnswered") as? [[String:String]] ?? []
            
         
            for maps in usersAnswered{
                for value in maps.values{
                    if value == choice{
                        choiceOneAnswerCount += 1
                    }
                }
            }
         

            
            choiceOnePercentage = (choiceOneAnswerCount / totalUsers) * 100
            
          
            
            return completion(choiceOnePercentage)
            
        }
        
        
        
    }
}

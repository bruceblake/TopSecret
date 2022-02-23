//
//  SearchRepository.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/3/22.
//

import SwiftUI
import Foundation
import Combine



class SearchRepository : ObservableObject {
    @Published var searchText : String = ""
    @Published var userResults : [User] = []
    @Published var userReturnedResults : [User] = []
    @Published var groupResults : [Group] = []
    @Published var groupReturnedResults : [Group] = []
    
    
    
    private var cancellables = Set<AnyCancellable>()
    
    
 
    
    func startSearch(searchRequest: String, id: String){
        if searchRequest == "allUsers"{
            self.getUsers()

        }else if searchRequest == "allGroups"{
            self.getGroups()

        }else if searchRequest == "allGroupsAndUsers"{
            self.getUsers()
            self.getGroups()
        }else if searchRequest == "groupUsersFollowers"{
            self.getGroupFollowers(groupID: id)

        }else{
            //TODO
        }
        
    
        
    
    }
    
    
    private func filterResults(text: String, results1: [User], results2: [Group]) -> [[Any]]{
        
        var res : [[Any]] = []
        let lowercasedText = text.lowercased()
        
        res.append(results1.filter {
            let username = $0.username ?? ""
            let email = $0.email ?? ""
            let nickName = $0.nickName ?? ""
            
            return username.lowercased().contains(lowercasedText)  || email.lowercased().contains(lowercasedText)  || nickName.lowercased().contains(lowercasedText)
        })
        res.append(results2.filter {
            
            let groupName = $0.groupName
            
            return groupName.lowercased().contains(lowercasedText)
        })
        
        return res
        
    }
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()!
            
            return completion(User(dictionary: data))
        }
    }
    
    
    private func getGroupFollowers(groupID: String){
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let followers = snapshot!.get("followers") as? [String] ?? []
            
        
            for follower in followers {
                self.fetchUser(userID: follower) { fetchedUser in
                    self.userResults.append(fetchedUser)
                    
                }
               

            }
            
            
                
           
        }
        
            self.$searchText
                .combineLatest(self.$userResults, self.$groupResults)
                .map(self.filterResults)
                .sink { [self](returnedResults) in
                    userReturnedResults = returnedResults[0] as? [User] ?? []
                    groupReturnedResults = returnedResults[1] as? [Group] ?? []
                    
                }
                .store(in: &self.cancellables)
            
          
        
        
    
    }
    
    private func getGroupsThatGroupsFollow(groupID: String){
        
    }
    
    
    
    
    
    private func getUsers(){
        COLLECTION_USER.getDocuments{ (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            
            
            self.userResults = documents.map({ (queryDocumentSnapshot) -> User in
                let data = queryDocumentSnapshot.data()
                
                return User(dictionary: data)
            })
        }
        
        $searchText
            .combineLatest($userResults, $groupResults)
            .map(filterResults)
            .sink { [self](returnedResults) in
                userReturnedResults = returnedResults[0] as? [User] ?? []
                groupReturnedResults = returnedResults[1] as? [Group] ?? []
                
            }
            .store(in: &cancellables)
    }
    
    private func getGroups(){
        COLLECTION_GROUP.addSnapshotListener{ (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            
            
            self.groupResults = documents.map({ (queryDocumentSnapshot) -> Group in
                let data = queryDocumentSnapshot.data()
                
                return Group(dictionary: data)
            })
        }
        
        $searchText
            .combineLatest($userResults, $groupResults)
            .map(filterResults)
            .sink { [self](returnedResults) in
                userReturnedResults = returnedResults[0] as? [User] ?? []
                groupReturnedResults = returnedResults[1] as? [Group] ?? []
                
            }
            .store(in: &cancellables)
    }
    
}

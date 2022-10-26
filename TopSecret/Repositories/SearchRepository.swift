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
    @Published var userFriendsResults : [User] = []
    @Published var userFriendsReturnedResults : [User] = []
    @Published var groupResults : [Group] = []
    @Published var groupReturnedResults : [Group] = []
    @Published var userGroupResults : [Group] = []
    @Published var userGroupReturnedResults: [Group] = []
    @Published var isRefreshing : Bool = false
    @Published var hasSearched : Bool = false
    
    
    
    private var cancellables = Set<AnyCancellable>()
    
    
 
    init(){
        
        userHasSearched
            .receive(on: RunLoop.main)
            .assign(to: \.hasSearched, on: self)
            .store(in: &cancellables)
    }
    
    func startSearch(searchRequest: String, id: String){
        if searchRequest == "allUsers"{
            self.getUsers()

        }else if searchRequest == "allGroups"{
            self.getGroups()

        }else if searchRequest == "allUsersAndGroups"{
            self.getUsers()
            self.getGroups()
            self.getFriends(userID: id)
        }else if searchRequest == "allUsersFriends"{
            self.getFriends(userID: id)
        }else if searchRequest == "allUserGroups"{
            self.getUserGroups(userID: id)
        }else if searchRequest == "allUserFriendsAndGroups"{
            self.getFriends(userID: id)
            self.getUserGroups(userID: id)
        }else if searchRequest == "allUsersAndUsersFriends"{
            self.getUsers()
            self.getFriends(userID: id)
        }
        
    
        
    
    }
    
    private var userHasSearched : AnyPublisher<Bool,Never> {
        $searchText
            .removeDuplicates()
            .map{ text in
                return text != ""
            }
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func filterFriendsResults(text: String, result: [User]) -> [User]{
        var res : [User] = []
        let lowercasedText = text.lowercased()
        
        res = result.filter {
            let username = $0.username ?? ""
            let email = $0.email ?? ""
            let nickName = $0.nickName ?? ""
            
            return username.lowercased().contains(lowercasedText)  || email.lowercased().contains(lowercasedText)  || nickName.lowercased().contains(lowercasedText)
        }
        return res
    }
    
    private func filterUserGroupsResults(text: String, result: [Group]) -> [Group]{
        var res : [Group] = []
        let lowercasedText = text.lowercased()
        
        res = result.filter {
            let groupName = $0.groupName
            
            return groupName.lowercased().contains(lowercasedText)
        }
        
        return res
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
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            let friendsListID = data["friendsListID"] as? [String] ?? []
            let dp = DispatchGroup()
            
            dp.enter()
            
            self.fetchUsersFriends(friendsListID: friendsListID) { fetchedFriends in
                data["friendsList"] = fetchedFriends
                dp.leave()
            }
            
            
            dp.notify(queue: .main, execute: {
                
            return completion(User(dictionary: data))
            })
            
            
            
           
        }
    }
    
    func fetchUsersFriends(friendsListID: [String], completion: @escaping ([User]) -> ()) -> () {
        var users : [User] = []
        var groupD = DispatchGroup()
        
        
        for userID in friendsListID {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                users.append(User(dictionary: data))
                groupD.leave()
            }
        }
        groupD.notify(queue: .main, execute: {
            return completion(users)
        })
    }
    
    func fetchGroup(groupID: String, completion: @escaping (Group) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(Group(dictionary: data))
            
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
    
    private func getUserGroups(userID: String){
        
        self.isRefreshing = true
        let dp = DispatchGroup()
        dp.enter()
        
      
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            var groupsToReturn : [Group] = []
            let groupD = DispatchGroup()
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            let groupsID = data["groupsID"] as? [String] ?? []
            
            for groupID in groupsID{
                groupD.enter()
                self.fetchGroup(groupID: groupID) { fetchedGroup in
                    groupsToReturn.append(fetchedGroup)
                    groupD.leave()
                }
            }
            
            groupD.notify(queue: .main, execute:{
                self.userGroupResults = groupsToReturn
            })
            
            
        }
        
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            self.isRefreshing = false
        })
        
        
        self.$searchText
            .combineLatest($userGroupResults)
            .map(self.filterUserGroupsResults)
            .sink { [self](returnedResults) in
                userGroupReturnedResults = returnedResults 
                
            }
            .store(in: &self.cancellables)
    }
    
    
    private func getFriends(userID: String){
        
        self.isRefreshing = true
        let dp = DispatchGroup()
        dp.enter()
        
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var usersToReturn : [User] = []
            let groupD = DispatchGroup()
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            let friendsID = data["friendsListID"] as? [String] ?? []
            
            groupD.enter()
            for friend in friendsID {
                self.fetchUser(userID: friend) { fetchedUser in
                    usersToReturn.append(fetchedUser)
                }
            }
                                groupD.leave()

            
            groupD.notify(queue: .main, execute:{
                self.userFriendsResults = usersToReturn
            })
            
        }
        
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            self.isRefreshing = false
        })
        
        self.$searchText
            .combineLatest($userFriendsResults)
            .map(self.filterFriendsResults)
            .sink { [self](returnedResults) in
                userFriendsReturnedResults = returnedResults as? [User] ?? []
                
            }
            .store(in: &self.cancellables)
        
    }
    
    private func getUsers(){
        
        self.isRefreshing = true
        let dp = DispatchGroup()
        dp.enter()
        
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
        
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            self.isRefreshing = false
        })
        
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
        
        self.isRefreshing = true
        let dp = DispatchGroup()
        dp.enter()
        
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
        
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            self.isRefreshing = false
        })
        
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

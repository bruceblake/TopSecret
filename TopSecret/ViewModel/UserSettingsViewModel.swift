//
//  UserSettingsViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/31/22.
//

import Foundation



class UserSettingsViewModel : ObservableObject {
    
    @Published var blockedAccounts : [User] = []
    
    
    func fetchBlockedAccounts(blockedAccountIDS: [String]){
        var usersToReturn : [User] = []
        let dp = DispatchGroup()
        dp.enter()
        for userID in blockedAccountIDS {
            var user : User = User()
            dp.enter()
            self.fetchUser(userID: userID) { fetchedUser in
                user = fetchedUser
                dp.leave()
            }
            dp.notify(queue: .main, execute:{
                usersToReturn.append(user)
            })
        }
        dp.leave()
        dp.notify(queue: .main, execute:{
            self.blockedAccounts = usersToReturn
        })
    }
    
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(User(dictionary: data))
        }
    }
    
}

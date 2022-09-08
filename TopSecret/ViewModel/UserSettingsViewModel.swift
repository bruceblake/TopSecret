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
        blockedAccounts.removeAll()
        for userID in blockedAccountIDS {
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot!.data()
                self.blockedAccounts.append(User(dictionary: data ?? [:]))
                
            }
        }
    }
    
    
    
    
}

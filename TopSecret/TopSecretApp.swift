//
//  TopSecretApp.swift
//  TopSecret
//
//  Created by Bruce Blake on 4/2/21.
//

import SwiftUI
import Firebase

@main
struct TopSecretApp: App {
    
    init(){
        
        FirebaseApp.configure()
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(UserViewModel()).environmentObject(NavigationHelper()).environmentObject(TabViewModel())
        }
    }
}

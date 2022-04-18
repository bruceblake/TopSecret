//
//  TopSecretApp.swift
//  TopSecret
//
//  Created by Bruce Blake on 4/2/21.
//
import SwiftUI
import Firebase
import SCSDKCoreKit
import UIKit
import SCSDKLoginKit

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

class AppDelegate: UIResponder, UIApplicationDelegate {

 
    func application(
      _ app: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if SCSDKLoginClient.application(app, open: url, options: options) {
          return true
        }
          return false
    }

}


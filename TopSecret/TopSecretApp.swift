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
import UserNotifications
import FirebaseMessaging
import CoreData

@main
struct TopSecretApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared
   
    var body: some Scene {
        
        WindowGroup {
            ContentView().environmentObject(UserViewModel()).environmentObject(NavigationHelper()).environmentObject(TabViewModel())
        }
    }
}



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

@main
struct TopSecretApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
   
    var body: some Scene {
        
        WindowGroup {
            ContentView().environmentObject(UserViewModel()).environmentObject(NavigationHelper()).environmentObject(TabViewModel())
        }
    }
}



//
//  SceneDelegate.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/4/22.
//

import Foundation
import SCSDKLoginKit
import UIKit
import SwiftUI


@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate{
    var window : UIWindow?
    
      func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let url = urlContext.url
            var options: [UIApplication.OpenURLOptionsKey : Any] = [:]
            options[.openInPlace] = urlContext.options.openInPlace
            options[.sourceApplication] = urlContext.options.sourceApplication
            options[.annotation] = urlContext.options.annotation
            SCSDKLoginClient.application(UIApplication.shared, open: url, options: options)
        }
    }
    

}

class LoginViewController: UIViewController {
    @EnvironmentObject var userVM: UserViewModel
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = SCSDKLoginButton {success, error in
            guard success, error == nil else {return}
            
            print("success: \(success)")
         
//            let builder = SCSDKUserDataQueryBuilder().withDisplayName().withBitmojiTwoDAvatarUrl()
//            let userDataQuery = builder.build()
//
//            // Call fetch API
////            SCSDKLoginClient.fetchUserData(with:userDataQuery,
////                                        success:{ (userData: SCSDKUserData?, partialError: Error?) in
////                let displayName = userData?.displayName ?? ""
////                print("displayName: \(displayName)")
////                          let bitmojiAvatarURL = userData?.bitmojiTwoDAvatarUrl
////                    },
////                                        failure:{ (error: Error?, isUserLoggedOut: Bool) in
////                                    // Handle error
////                print("error")
////                    })
        }
        loginButton?.sizeToFit()
        loginButton?.center = view.center
        if let button = loginButton {
            view.addSubview(button)
        }
        
//        SCSDKBitmojiClient.fetchAvatarURL { avatarURL , error in
//            COLLECTION_USER.document(self.userVM.user?.id ?? " ").updateData(["profilePicture":avatarURL])
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.userVM.fetchUser(userID: self.userVM.user?.id ?? " ") { fetchedUser in
//                    self.userVM.user = fetchedUser
//                }
//            }
//        }

        
    }
    
    
    
   
}


struct LoginCVWrapper: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        return LoginViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //Unused in demonstration
    }
}

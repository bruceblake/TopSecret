//
//  Constants.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/18/21.
//

import Foundation
import Firebase
import SwiftUI


let COLLECTION_USER = Firestore.firestore().collection("Users")
let COLLECTION_POST = Firestore.firestore().collection("Posts")
let COLLECTION_GROUP = Firestore.firestore().collection("Groups")
let COLLECTION_CHAT = Firestore.firestore().collection("Chats")
let COLLECTION_POLLS = Firestore.firestore().collection("Polls")
let COLLECTION_EVENTS = Firestore.firestore().collection("Events")
let COLLECTION_PERSONAL_CHAT = Firestore.firestore().collection("Personal Chats")

let FOREGROUNDCOLOR : Color = Color("Foreground")
let BACKGROUNDCOLOR : Color = Color("Background")

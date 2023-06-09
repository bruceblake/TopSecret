//
//  UserGroupsListView.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/8/23.
//

import SwiftUI

struct UserGroupsListView: View {
    var group: Group
        @EnvironmentObject var userVM: UserViewModel
        @Environment(\.presentationMode) var presentationMode
        @StateObject var searchVM = SearchRepository()
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
            }
        }
    }
}



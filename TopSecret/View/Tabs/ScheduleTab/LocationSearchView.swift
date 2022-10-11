//
//  LocationSearchView.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/11/22.
//

import SwiftUI

struct LocationSearchView: View {
//    @StateObject var locationSearchVM = LocationSearchViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Leave")
                    })
                }.padding(.top,50)
                Spacer()
                
//                ForEach(locationSearchVM.locations, id: \.id){ location in
//                    Text("Location: \(location.properties[0].name)").foregroundColor(FOREGROUNDCOLOR)
//                }
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
//            locationSearchVM.fetchLocations()
        }
    }
}


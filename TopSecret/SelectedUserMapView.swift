//
//  SelectedUserMapView.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/5/22.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct SelectedUserMapView: View {
    @Binding var user: User
    @Binding var followUser: Bool
    @ObservedObject var locationManager : LocationManager
    
    var body: some View {
        ZStack{
            Map(coordinateRegion: locationManager.region.getBinding()!, interactionModes: .all, showsUserLocation: false, annotationItems: locationManager.userAnnotations){ annotation in
                MapAnnotation(coordinate: annotation.coordinate){
                    
                    Button(action:{
                        locationManager.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: annotation.user.latitude ?? 0, longitude: annotation.user.longitude ?? 0), latitudinalMeters: 5000, longitudinalMeters: 5000)
                    },label:{
                        WebImage(url: URL(string: annotation.user.profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("AccentColor"),lineWidth: 2))
                    })
                    
                    
                }
            }.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading){
                HStack(alignment: .top){
                    Button {
                        self.followUser.toggle()
                    } label: {
                        ZStack{
                            Circle().frame(width:40 ,height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }
                    
                    Spacer()
                    VStack(spacing: 1){
                        WebImage(url: URL(string: user.profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                        Text("Bruce").bold().font(.body).foregroundColor(FOREGROUNDCOLOR)
                        Text("Last updated now").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                    }.padding(.bottom,5)
                    
                    Spacer()
                    
                    Circle().frame(width:40 ,height: 40).foregroundColor(Color.clear)


                }.padding(.top,50).padding(.horizontal,40).background(Rectangle().fill(Color("Background")))
                
                Spacer()
                
                HStack(alignment: .bottom){
                    VStack(alignment: .leading){
                        Text("Distance").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                        Text("5629 Hobsons Choice Loop").foregroundColor(FOREGROUNDCOLOR).font(.footnote)
                        Text("2 hr, 24 min drive to Bruce").font(.footnote)
                    }.padding(.leading,15)
                    
                    Spacer()
                    Button(action:{
                        
                    },label:{
                        Text("Get Directions").foregroundColor(FOREGROUNDCOLOR).padding(5).padding(.horizontal,25).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                    }).padding(.trailing,15)
                }.frame(width: UIScreen.main.bounds.width).padding(.bottom,10).padding(25).background(Rectangle().fill(Color("Background")))
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}



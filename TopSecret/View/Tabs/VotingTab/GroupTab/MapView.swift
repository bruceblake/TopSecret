//
//  MapView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var tapped: Bool = false
    @Binding var group : Group
    @Binding var groupUsers : [User]
    
    private func getNearByLandmarks() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
                
            }
        }
    }
    
    func calculateOffset() -> CGFloat {
        if self.landmarks.count > 0 && !self.tapped {
            return UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 4
        }
        else if self.tapped {
            return 100
        }else {
            return UIScreen.main.bounds.size.height
        }
    
    }
    
    func convertToBinding(users: [User]) -> Binding<[User]>{
        
        
        return Binding(get: {users}, set: {_ in})
    }
    
    
    
    var body: some View {
      
           
            ZStack{
                MapViewUtility(landmarks: landmarks)

                VStack{
                    
                 
                    
                    
                    Spacer()
                    
                    ScrollView(.horizontal){
                        HStack(spacing: 20){
                            
                            //0 -> Binding
                            //1 -> Not Binding
                            ForEach(self.convertToBinding(users: groupUsers)){ user in
                                
                                NavigationLink(destination: UserProfilePage(user: user, isCurrentUser: false), label:{
                                    
                                    VStack(spacing: 5){
                                        WebImage(url: URL(string: user.wrappedValue.profilePicture ?? " "))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width:40,height:40)
                                            .clipShape(Circle())
//                                                .overlay(Circle().stroke(chat.usersIdling.contains(user.id ?? "") ? Color(getColor(userID: user.id ?? "", groupChat: chat)) : Color.gray,lineWidth: 2))
                                        
                                        Text("\(user.wrappedValue.nickName ?? "TOP SECRET USER")").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                                        
                                        Text("Lukyan's House").foregroundColor(FOREGROUNDCOLOR).font(.caption)
                                    }
                                 
                                    
                                    
                                })
                                
                             

                                  
                                   
                            }
                        }
                       
                     
                    }.padding().background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding().padding(.bottom,UIScreen.main.bounds.height/8)
                   
                }
              
                
            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    
        
    }
            
          
   
        
    }

//
//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}

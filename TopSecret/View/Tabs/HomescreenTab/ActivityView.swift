//
//  ActivityView.swift
//  Top Secret
//
//  Created by Bruce Blake on 4/16/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ActivityView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    
    @Binding var group: Group
    @Binding var groupMembers : [User]
    @Binding var groupEvents : [EventModel]
    @State var showEvent : Bool = false
    @ObservedObject var groupVM = GroupViewModel()
    
    var body: some View {
        ZStack{
            Color("Background")
            ScrollView{
                VStack(spacing: 20){
               
                
                VStack{
                    HStack{
                        HStack{
                            Text("Events").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title2)
                            if(group.events?.count == 1){
                                Text("\(group.events?.count ?? 0) event today").foregroundColor(Color.gray).font(.footnote)
                            }else{
                                Text("\(group.events?.count ?? 0) events today").foregroundColor(Color.gray).font(.footnote)
                            }
                         
                        }.padding(.leading,10)
                  
                            Spacer()
                    
                    }
                    HStack{
                        Button(action:{
                            //TODO
                        },label:{
                            ZStack{
                                Circle().frame(width:25,height:25).foregroundColor(Color("AccentColor"))
                                Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR)
                            }
                        }).padding(.leading,7)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                          
                            ForEach($groupEvents){ event in
                                Button(action:{
                                    //TODO
                                    showEvent.toggle()
                                },label:{
                                    EventCell(eventName: event.eventName, eventLocation: event.eventLocation)
                                }).sheet(isPresented: $showEvent) {
                                    
                                } content: {
                                    FullEventView(event: event)
                                }
                            }
                        }
                    }
                }
                }
                
                VStack{
                    HStack{
                        Text("Countdowns").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).padding(.leading,10).font(.title2)
                        HStack(spacing: 4){
                            if(group.events?.count == 1){
                                Text("\(group.events?.count ?? 0) countdowns").foregroundColor(Color.gray).font(.footnote)
                            }else{
                                Text("\(group.events?.count ?? 0) countdowns").foregroundColor(Color.gray).font(.footnote)
                            }
                            Button(action:{
                                //TODO
                            },label:{
                                HStack(spacing: 2){
                                
                                    Text("today").foregroundColor(Color("AccentColor")).font(.body)
                                    Image(systemName: "chevron.down").font(.body)
                                }
                            })
                        }
                    
                    
                        Spacer()
                    }
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            Button(action:{
                                //TODO
                            },label:{
                                ZStack{
                                    Circle().frame(width:25,height:25).foregroundColor(Color("AccentColor"))
                                    Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR)
                                }
                            }).padding(.leading,7)
                            ForEach($groupEvents){ event in
                                Button(action:{
                                    //TODO
                                    showEvent.toggle()
                                },label:{
                                    EventCell(eventName: event.eventName, eventLocation: event.eventLocation)
                                }).sheet(isPresented: $showEvent) {
                                    
                                } content: {
                                    FullEventView(event: event)
                                }

                            }
                        }
                    }
                }
                
            
            }
        }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView().environmentObject(UserViewModel()).colorScheme(.dark)
//    }
//}

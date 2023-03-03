//
//  PickInterestsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 1/9/23.
//

import SwiftUI

struct PickInterestsView: View {
    @State var isPresented: Bool = false
    @State var selectedInterests: [String] = []
    @EnvironmentObject var userVM: UserViewModel
    @State var goToCreatePasswordView: Bool = false
    private var interests : [String] = ["Skateboarding", "MMA", "Fun", "Gas"]
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(alignment: .center){
                        BackButton(isPresented: $isPresented)
                    Spacer()
                    Text("Pick (at least) 3 Interests").foregroundColor(FOREGROUNDCOLOR).font(.title3).bold()
                    Spacer()
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal)
                
                ScrollView{
                    VStack(alignment: .leading){
                        ForEach(interests, id: \.self){ interest in
                            Button(action:{
                                if !selectedInterests.contains(interest){
                                    selectedInterests.append(interest)
                                }else{
                                    selectedInterests.removeAll(where: {$0 == interest})
                                }
                            },label:{
                                Text("\(interest)").foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(selectedInterests.contains(interest) ? Color("AccentColor") : Color("Background")))
                           
                            })
                        }
                    }
               
                }.frame(width: UIScreen.main.bounds.width/2.5, height: UIScreen.main.bounds.height/2).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                
                ScrollView(.horizontal){
                    HStack{
                        ForEach(selectedInterests, id: \.self) {interest in
                            Button(action: {
                                selectedInterests.removeAll(where: {$0 == interest})
                            }, label: {
                                Text("\(interest)").foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                            })
                        }
                    }
                }.padding()
                Spacer()
                
                Button {
                    //todo
                    self.goToCreatePasswordView.toggle()
                } label: {
                    Text("Next").foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(selectedInterests.count < 3 ? Color("Color") : Color("AccentColor")).cornerRadius(15).disabled(selectedInterests.count < 3)
                }.padding()

            }.padding()
            
            NavigationLink(destination: CreatePassword(interests: selectedInterests), isActive: $goToCreatePasswordView) {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}


struct BackButton : View{
    @Binding var isPresented: Bool
    var body: some View {
        
            Button(action:{
                self.isPresented.toggle()
            },label:{
                ZStack{
                    Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                    Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                }
            })
            
    }
}

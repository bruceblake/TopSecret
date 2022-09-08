////
////  VotingView.swift
////  TopSecret
////
////  Created by nathan frenzel on 8/31/21.
////
//
//import SwiftUI
//import Firebase
//
//struct VotingView: View {
//    @EnvironmentObject var userVM: UserViewModel
//    @EnvironmentObject var navigationHelper: NavigationHelper
//    @State var goToAddPoll : Bool = false
//    @State var timer : Timer? = nil
//    @State var showOpenScreen : Bool = false
//    @State var showInfoScreen : Bool = false
//    @State var currentPoll : PollModel = PollModel()
//    @StateObject var pollVM = PollViewModel()
//    
//    
//    
//    
//    var body: some View {
//        ZStack{
//            Color("Background")
//            if userVM.polls.count != 0{
//                VStack{
//                    HStack(spacing: 20){
//                        Button(action: {  }, label: {
//                            Image(systemName: "clock")
//                                .resizable()
//                                .frame(width: 32, height: 32)
//                        }).padding(.leading,20)
//                        Spacer()
//                        
//                        Text("Voting").font(.largeTitle).fontWeight(.bold)
//                        Spacer()
//                        Button(action: {
//                            self.goToAddPoll.toggle()
//                        }, label: {
//                            Image(systemName: "plus")
//                        })
//                        .padding(.trailing,20
//                    )
//                        
//                       
//                        
//                        
//                        
//                    }.padding(.top,50)
//                    
//                    
//                    
//                    
//                    
//                    ScrollView(showsIndicators: false){
//                        VStack{
//                            ForEach(userVM.polls){ poll in
//                                PollCell(poll: poll, showInfoScreen: $showInfoScreen).padding(.vertical,15)
//                                
//                                
//                            }
//                        }.padding()
//                        
//                        
//                    }.padding(.bottom,50)
//                    
//                }.padding()
//            }else{
//                VStack{
//                    HStack(spacing: 20){
//                        Button(action: {  }, label: {
//                            Image(systemName: "clock")
//                                .resizable()
//                                .frame(width: 32, height: 32)
//                        }).padding(.leading,20)
//                        Spacer()
//                        
//                        Text("Voting").font(.largeTitle).fontWeight(.bold)
//                        Spacer()
//                        Button(action: {
//                            self.goToAddPoll.toggle()
//                        }, label: {
//                            Text("+")
//                        })
//                        .padding(.trailing,20)
//                        
//                    }.padding(.top,50)
//                    Spacer()
//                    
//                    Text("It appears there are not polls!")
//                    Spacer()
//                }.padding()
//                
//            }
//            NavigationLink(
//                destination: AddPollView(pollVM: pollVM, groups: userVM.groups, creator: userVM.user?.id ?? ""),
//                isActive: $goToAddPoll,
//                label: {
//                    EmptyView()
//                })
//            
//            if showOpenScreen{
//                OpenVotingView()
//            }
//            
//            if showInfoScreen {
//                GeometryReader{ _ in
//                    
//                    PollInfoOverlay(poll: $currentPoll)
//                    
//                }.padding(.vertical,300).background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all).onTapGesture {
//                    self.showInfoScreen = false
//                }
//            }
//            
//        }.frame(width: UIScreen.main.bounds.width).edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
//            
//            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
//                userVM.pollDurationTimer += 1
//            }
//            
//          
//            
//        }.onDisappear{
//            timer?.invalidate()
//            timer = nil
//        }
//    }
//}
//
//
//struct VotingView_Previews: PreviewProvider {
//    static var previews: some View {
//        VotingView()
//    }
//}
//struct OpenVotingView : View {
//    
//    
//    var body: some View {
//        ZStack{
//            Color("Background")
//            
//            Text("Voting").font(.largeTitle).fontWeight(.bold).foregroundColor(Color("AccentColor"))
//        }
//    }
//}

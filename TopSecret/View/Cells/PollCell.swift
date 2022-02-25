//
//  PollCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 10/4/21.
//

import SwiftUI
import Foundation
import Firebase

struct PollCell: View {
    
    
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var pollVM = PollViewModel()
    @State var currentPoll : PollModel = PollModel()
    
    //actual
    @State var poll: PollModel = PollModel()
    @State var creator: User = User()
    @State var daysRemaining: Int = 0
    @State var hoursRemaining: Int = 0
    @State var minutesRemaining: Int = 0
    @State var secondsRemaining: Int = 0
    @Binding var showInfoScreen : Bool

    
    
    
    
    
 
    
    
    var body: some View {
        ZStack(alignment: .top){
            VStack(spacing: 0){
                
                    switch poll.pollType {
                    case "Two Choices":
                        TwoChoicePollCell(poll: $poll)
                    case "Three Choices":
                        ThreeChoicePollCell(poll: $poll)
                    case "Four Choices":
                        FourChoicePollCell(poll: $poll)
                    case "Free Response":
                        FreeReponsePollCell(poll: $poll)
                    default:
                        Text("Hello World!")
                    }
                
                
                
                
                
            }.frame(width: 350,height:250).background(Rectangle().stroke(FOREGROUNDCOLOR,lineWidth: 3))
            PollInfoCell(showInfoScreen: $showInfoScreen, creator: creator, poll: poll, currentPoll: $currentPoll).padding(0)
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            userVM.fetchUser(userID: poll.creator ?? " "){ creator in
                self.creator = creator
            }
                
                self.currentPoll = poll
               
            
   
            
                
         
            

            
        }
    }
}


//struct PollCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PollCell(poll: PollModel(), creator: User()).preferredColorScheme(.dark)
//    }
//}


struct TwoChoicePollCell : View {
    @Binding var poll: PollModel
    @StateObject var pollVM = PollViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @State var hadAnswered : Bool = false
    
    
    func alreadyAnswered(usersAnswered: [[String:String]], userNickName: String, completion: @escaping (Bool) -> ()) -> (){
        usersAnswered.forEach { maps in
            if maps.keys.contains(userNickName){
                return completion(true)
            }
        }
        
    }
    
    var body: some View {
        
        
        if !hadAnswered {
        VStack(spacing: 0){
            
            VStack{
                Text("\(poll.question ?? "")").foregroundColor(FOREGROUNDCOLOR)
                Divider()
            }.padding(.top,60)
            
            
            
            HStack(alignment: .center, spacing: 0){
                Spacer(minLength: 0)
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[0] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                    
                },label:{
                    Text("\(poll.choices?[0] ?? "left")")
                }).padding(.leading)
                Divider()
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[1] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                
                },label:{
                    Text("\(poll.choices?[1] ?? "right")")
                }).padding(.trailing)
                Spacer(minLength: 0)
            }
            
            Spacer()
        }.background(Color("Color")).onAppear{
            alreadyAnswered(usersAnswered: poll.usersAnswered ?? [], userNickName: userVM.user?.nickName ?? "") { answered in
                self.hadAnswered = answered
            }
        }
        }else if poll.finished == true || hadAnswered{
            TwoChoicePollCellAnswer(poll: $poll)
        }
        
        
        
    }
}

struct ThreeChoicePollCell: View {
    
    @Binding var poll: PollModel
    @StateObject var pollVM = PollViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @State var hadAnswered : Bool = false
    
    
    func alreadyAnswered(usersAnswered: [[String:String]], userNickName: String, completion: @escaping (Bool) -> ()) -> (){
        usersAnswered.forEach { maps in
            if maps.keys.contains(userNickName){
                return completion(true)
            }
        }
        
    }
    
    var body: some View {
        
        if !hadAnswered{
        VStack(spacing: 0){
            
            VStack{
                Text("\(poll.question ?? "")").foregroundColor(FOREGROUNDCOLOR)
                Divider()
            }.padding(.top,60)
            
            
            
            HStack(alignment: .center, spacing: 0){
                Spacer(minLength: 0)
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[0] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                    
                },label:{
                    Text("\(poll.choices?[0] ?? "left")")
                }).padding(.leading)
                Divider()
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[2] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                    
                },label:{
                    Text("\(poll.choices?[2] ?? "left")")
                })
                Divider()
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[1] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                
                },label:{
                    Text("\(poll.choices?[1] ?? "right")")
                }).padding(.trailing)
                
                Spacer(minLength: 0)
            }
            
            Spacer()
        }.background(Color("Color")).onAppear{
            alreadyAnswered(usersAnswered: poll.usersAnswered ?? [], userNickName: userVM.user?.nickName ?? "") { answered in
                self.hadAnswered = answered
            }
        }
        }else{
            ThreeChoicePollCellAnswer(poll: $poll)
        }
        
    }
}

struct FourChoicePollCell : View {
    
    @Binding var poll: PollModel
    @StateObject var pollVM = PollViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @State var hadAnswered : Bool = false
    
    
    func alreadyAnswered(usersAnswered: [[String:String]], userNickName: String, completion: @escaping (Bool) -> ()) -> (){
        usersAnswered.forEach { maps in
            if maps.keys.contains(userNickName){
                return completion(true)
            }
        }
        
    }
    var body: some View {
        if !hadAnswered{
        VStack(spacing: 0){
            
            VStack{
                Text("\(poll.question ?? "")").foregroundColor(FOREGROUNDCOLOR)
                Divider()
            }.padding(.top,60)
            
            
            
            HStack(alignment: .center, spacing: 0){
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[0] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                    
                },label:{
                    Text("\(poll.choices?[0] ?? "left")")
                }).padding(.leading)
                Divider()
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[2] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                    
                },label:{
                    Text("\(poll.choices?[2] ?? "left")")
                })
                Divider()
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[3] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                    
                },label:{
                    Text("\(poll.choices?[3] ?? "left")")
                })
                Divider()
                Button(action:{
                    
                    self.pollVM.selectAnswer(pollID: poll.id ?? "", selection: poll.choices?[1] ?? "", userNickName: userVM.user?.nickName ?? "")
                    self.hadAnswered = true
                
                },label:{
                    Text("\(poll.choices?[1] ?? "right")")
                }).padding(.trailing)
                
            }
            
            
            Spacer()
        }.background(Color("Color")).onAppear{
            alreadyAnswered(usersAnswered: poll.usersAnswered ?? [], userNickName: userVM.user?.nickName ?? "") { answered in
                self.hadAnswered = answered
            }
        }
        }else{
            FourChoicePollCellAnswer(poll: $poll)
        }
        
    }
}

struct FreeReponsePollCell : View {
    
    @Binding var poll: PollModel
    @State var response: String = ""
    @State var hadAnswered : Bool = false
    @EnvironmentObject var userVM : UserViewModel

    
    func alreadyAnswered(usersAnswered: [[String:String]], userNickName: String, completion: @escaping (Bool) -> ()) -> (){
        usersAnswered.forEach { maps in
            if maps.keys.contains(userNickName){
                return completion(true)
            }
        }
        
    }
    
    var body: some View {
        
        if !hadAnswered{
        VStack(spacing: 0){
            
            VStack{
                Text("\(poll.question ?? "")").foregroundColor(FOREGROUNDCOLOR)
                Divider()
            }.padding(.top,60)
            
            
            
            TextField("Response", text: $response)
            Button(action:{
                
            },label:{
                
            })
            
            
            Spacer()
        }.background(Color("Color")).onAppear{
            alreadyAnswered(usersAnswered: poll.usersAnswered ?? [], userNickName: userVM.user?.nickName ?? "") { answered in
                self.hadAnswered = answered
            }
        }
        }else{
            FourChoicePollCellAnswer(poll: $poll)
        }
        
    }
}


struct FreeRepsonsePollCellAnswer: View {
    
    @Binding var poll: PollModel
    
    var body: some View {
        EmptyView()
    }
}

struct FourChoicePollCellAnswer : View{
    @Binding var poll: PollModel
    
    @StateObject var pollVM = PollViewModel()
    @State var choiceOneFillAmount : Double = 0.0
    @State var choiceTwoFillAmount : Double = 0.0
    @State var choiceThreeFillAmount : Double = 0.0
    @State var choiceFourFillAmount : Double = 0.0
    var body: some View {
        VStack(spacing: 0){
            VStack{
                Text("\(poll.question ?? "")")
                Divider()
            }.padding(.top,60)
            HStack(spacing: 0){
                
                //1 choice
                ZStack{
                ZStack(alignment: .bottom){
                    
                   

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceOneFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    
                    VStack{
                        Text("\(poll.choices?[0] ?? "")")
                        Text("\(String(format: "%.1f",choiceOneFillAmount))%")
                    }
                    


                }
                    
                    if choiceOneFillAmount > choiceTwoFillAmount && poll.finished == true {
                        VStack{
                            Rectangle().stroke(Color("orange"),lineWidth: 3).frame(height: 2).padding(.leading,2)
                            Spacer()
                        }
                       
                    }
                    
                }
                Divider()
                //2 choice
                ZStack{
                ZStack(alignment: .bottom){
                    
                   

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceThreeFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    
                    VStack{
                        Text("\(poll.choices?[2] ?? "")")
                        Text("\(String(format: "%.1f",choiceThreeFillAmount))%")
                    }
                    


                }
                    
                    if choiceThreeFillAmount > choiceTwoFillAmount && choiceThreeFillAmount > choiceOneFillAmount && poll.finished == true {
                        VStack{
                            Rectangle().stroke(Color("orange"),lineWidth: 3).frame(height: 2).padding(.leading,2)
                            Spacer()
                        }
                       
                    }
                    
                }
                Divider()
                
                //right choice
                ZStack{
                ZStack(alignment: .bottom){
                    
                    

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceTwoFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    VStack{
                        Text("\(poll.choices?[1] ?? "")")
                        Text("\(String(format: "%.1f",choiceTwoFillAmount))%")
                    }
                    
                    
                }
                    if choiceTwoFillAmount > choiceOneFillAmount && poll.finished == true{
                        Rectangle().stroke(Color("AccentColor"),lineWidth: 3)
                    }
            }
                Divider()
                ZStack{
                ZStack(alignment: .bottom){
                    
                   

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceFourFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    
                    VStack{
                        Text("\(poll.choices?[3] ?? "")")
                        Text("\(String(format: "%.1f",choiceFourFillAmount))%")
                    }
                    


                }
                    
                    if choiceFourFillAmount > choiceTwoFillAmount && choiceFourFillAmount > choiceOneFillAmount && choiceFourFillAmount > choiceThreeFillAmount && poll.finished == true {
                        VStack{
                            Rectangle().stroke(Color("orange"),lineWidth: 3).frame(height: 2).padding(.leading,2)
                            Spacer()
                        }
                       
                    }
                    
                }
                
            }
            
        }.background(Color("Color")).onAppear{
        

                pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[0] ?? "", completion: { amount in
                    self.choiceOneFillAmount = amount
                    print(choiceOneFillAmount)

                })
                pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[1] ?? "", completion: { amount in
                    self.choiceTwoFillAmount = amount
                    print(choiceTwoFillAmount)

                })
            pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[2] ?? "", completion: { amount in
                self.choiceThreeFillAmount = amount
                print(choiceThreeFillAmount)

            })
            pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[3] ?? "", completion: { amount in
                self.choiceFourFillAmount = amount
                print(choiceFourFillAmount)

            })
                


            
        

            
        
        }
    }
}

struct ThreeChoicePollCellAnswer : View {
    
    @Binding var poll: PollModel
    
    @StateObject var pollVM = PollViewModel()
    @State var choiceOneFillAmount : Double = 0.0
    @State var choiceTwoFillAmount : Double = 0.0
    @State var choiceThreeFillAmount : Double = 0.0
    
    var body: some View {
        VStack(spacing: 0){
            VStack{
                Text("\(poll.question ?? "")")
                Divider()
            }.padding(.top,60)
            HStack(spacing: 0){
                
                //left choice
                ZStack{
                ZStack(alignment: .bottom){
                    
                   

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceOneFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    
                    VStack{
                        Text("\(poll.choices?[0] ?? "")")
                        Text("\(String(format: "%.1f",choiceOneFillAmount))%")
                    }
                    


                }
                    
                    if choiceOneFillAmount > choiceTwoFillAmount && poll.finished == true {
                        VStack{
                            Rectangle().stroke(Color("orange"),lineWidth: 3).frame(height: 2).padding(.leading,2)
                            Spacer()
                        }
                       
                    }
                    
                }
                Divider()
                //middle choice
                ZStack{
                ZStack(alignment: .bottom){
                    
                   

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceThreeFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    
                    VStack{
                        Text("\(poll.choices?[2] ?? "")")
                        Text("\(String(format: "%.1f",choiceThreeFillAmount))%")
                    }
                    


                }
                    
                    if choiceThreeFillAmount > choiceTwoFillAmount && choiceThreeFillAmount > choiceOneFillAmount && poll.finished == true {
                        VStack{
                            Rectangle().stroke(Color("orange"),lineWidth: 3).frame(height: 2).padding(.leading,2)
                            Spacer()
                        }
                       
                    }
                    
                }
                Divider()
                //right choice
                ZStack{
                ZStack(alignment: .bottom){
                    
                    

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceTwoFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    VStack{
                        Text("\(poll.choices?[1] ?? "")")
                        Text("\(String(format: "%.1f",choiceTwoFillAmount))%")
                    }
                    
                    
                }
                    if choiceTwoFillAmount > choiceOneFillAmount && poll.finished == true{
                        VStack{
                            Rectangle().stroke(Color("orange"),lineWidth: 3).frame(height: 2).padding(.leading,2)
                            Spacer()
                        }
                    }
            }
                
            }
            
        }.background(Color("Color")).onAppear{
        

                pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[0] ?? "", completion: { amount in
                    self.choiceOneFillAmount = amount
                    print(choiceOneFillAmount)

                })
                pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[1] ?? "", completion: { amount in
                    self.choiceTwoFillAmount = amount
                    print(choiceTwoFillAmount)

                })
            pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[2] ?? "", completion: { amount in
                self.choiceThreeFillAmount = amount
                print(choiceThreeFillAmount)

            })
                


            
        

            
        
        }
    }
}

struct TwoChoicePollCellAnswer : View {
    
    @Binding var poll: PollModel
    
    @StateObject var pollVM = PollViewModel()
    @State var choiceOneFillAmount : Double = 0.0
    @State var choiceTwoFillAmount : Double = 0.0

    
    
    var body: some View {
        VStack(spacing: 0){
            VStack{
                Text("\(poll.question ?? "")")
                Divider()
            }.padding(.top,60)
            HStack(spacing: 0){
                
                //left choice
                ZStack{
                ZStack(alignment: .bottom){
                    
                   

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceOneFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    
                    VStack{
                        Text("\(poll.choices?[0] ?? "")")
                        Text("\(String(format: "%.1f",choiceOneFillAmount))%")
                    }
                    


                }
                    
                    if choiceOneFillAmount > choiceTwoFillAmount && poll.finished == true {
                        VStack{
                            Rectangle().stroke(Color("orange"),lineWidth: 3).frame(height: 2).padding(.leading,2)
                            Spacer()
                        }
                       
                    }
                    
                }
                Divider()
                
                //right choice
                ZStack{
                ZStack(alignment: .bottom){
                    
                    

                    Rectangle().frame(height:156)
                        .foregroundColor(Color("Color"))
                    Rectangle().frame(height:CGFloat((choiceTwoFillAmount * (156) / 100)))
                        .foregroundColor(Color("AccentColor"))
                    VStack{
                        Text("\(poll.choices?[1] ?? "")")
                        Text("\(String(format: "%.1f",choiceTwoFillAmount))%")
                    }
                    
                    
                }
                    if choiceTwoFillAmount > choiceOneFillAmount && poll.finished == true{
                        VStack{
                            Rectangle().stroke(Color("orange"),lineWidth: 3).frame(height: 2).padding(.leading,2)
                            Spacer()
                        }
                    }
            }
                
            }
            
        }.background(Color("Color")).onAppear{
        

                pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[0] ?? "", completion: { amount in
                    self.choiceOneFillAmount = amount
                    print(choiceOneFillAmount)

                })
                pollVM.getPercentageVoted(pollID: poll.id ?? "", choice: poll.choices?[1] ?? "", completion: { amount in
                    self.choiceTwoFillAmount = amount
                    print(choiceTwoFillAmount)

                })
                


            
        

            
        
        }
    }
}




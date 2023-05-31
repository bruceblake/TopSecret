import Firebase
import SwiftUI
import Foundation
import SDWebImageSwiftUI


struct PollCell : View {
    @State var poll : PollModel
    @Binding var selectedPoll : PollModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var shareVM: ShareViewModel
    @State var fullWidth = CGFloat(100)
    var hideControls : Bool = false
    
    func getTimeSincePoll(date: Date) -> String{
        let interval = (Date() - date)
        
        
        var seconds = interval.second ?? 0
        var minutes = (seconds / 60)
        var hours = (minutes / 60)
        var days = (hours / 24)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
        }
        if time == "0s"{
            return "now"
        }else{
            return time
        }
        
    }
    
    var body: some View {
            ZStack{

                Color("Color")
                
                VStack{
                    
                    VStack{
                        HStack(alignment: .top){
                            HStack(alignment: .center){
                                ZStack(alignment: .bottomTrailing){
                                    
                                    NavigationLink(destination: GroupProfileView(group: poll.group ?? Group(), isInGroup: poll.group?.users.contains(userVM.user?.id ?? " ") ?? false)) {
                                        WebImage(url: URL(string: poll.group?.groupProfileImage ?? "")).resizable().frame(width: 40, height: 40).clipShape(Circle())
                                    }
                                    
                                    NavigationLink(destination: UserProfilePage(user: poll.creator ?? User())) {
                                        WebImage(url: URL(string: poll.creator?.profilePicture ?? "")).resizable().frame(width: 18, height: 18).clipShape(Circle())
                                    }.offset(x: 3, y: 2)
                                    
                                }
                                
                                VStack(alignment: .leading, spacing: 1){
                                    HStack(alignment: .center, spacing: 3){
                                        Text("\(poll.group?.groupName ?? "" )").font((.system(size: 15))).bold()
                                        HStack(spacing: 3){
                                            Circle().frame(width: 3, height: 3)
                                            Text("\(getTimeSincePoll(date:poll.timeStamp?.dateValue() ?? Date()))").font(.system(size: 15))
                                        }.foregroundColor(Color.gray)
                                        
                                        
                                    }
                                    
                                    HStack(spacing: 3){
                                        Text("asked by").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                                        NavigationLink(destination: UserProfilePage(user: poll.creator ?? User())) {
                                            Text("\(poll.creator?.username ?? "")").foregroundColor(Color.gray).font(.system(size: 12))
                                        }
                                    }
                                    
                                }
                            }
                            
                            Spacer()
                            
                            if !self.hideControls{
                                Menu(content:{
                                    Button(action:{
//                                        self.selectedPost = post
//                                        self.showEditScreen.toggle()
//                                        userVM.hideBackground.toggle()
                                        
                                    },label:{
                                        Text("Edit")
                                    })
                                    
                                    Button(action:{
//                                        withAnimation{
//                                            self.selectedPost = post
//                                            shareVM.showShareMenu.toggle()
//                                            userVM.hideTabButtons.toggle()
//                                            userVM.hideBackground.toggle()
//                                        }
                                        
                                    },label:{
                                        Text("Share")
                                    })
                                    Button(action:{
                                        self.selectedPoll = poll
                                        userVM.deletePoll(pollID: poll.id ?? " ")
                                    },label:{
                                        Text("Delete")
                                    })
                                },label:{
                                    Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR).padding(5)
                                })
                                
                            }
                        }.padding([.horizontal,.top],5)
                        
                        VStack(spacing: 3){
                            Text("\(poll.question ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 15)).bold()
                            Divider()
                        }
                    }
                    
                    
                    
                    if poll.finished ?? false {
                        //finished poll cell
                    }
                    else if poll.usersAnsweredID?.contains(userVM.user?.id ?? " ") ?? false{
                        AnsweredChoices(poll: $poll, fullWidth: $fullWidth).padding(.top,5)
                    }else{
                        // unanswered poll cell
                        UnansweredChoices(poll: $poll)
                    }
                    
                    
                    HStack(alignment: .bottom){
                        
                        HStack(alignment: .center){
                            Text("\(poll.usersAnsweredID?.count ?? 0) votes").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            Text("2 hours left").foregroundColor(Color.gray).font(.system(size: 10))
                        }
                        Spacer()
                        
                        HStack(alignment: .top, spacing: 15){
                            
                            Button(action:{
                                
                            },label:{
                                VStack(spacing: 2){
                                    Image(systemName: "message").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 16))
                                    Text("3").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                                }
                            })
                            
                            Button(action:{
                                withAnimation{
                                    shareVM.selectedPoll = poll
                                    shareVM.shareType = "poll"
                                    shareVM.showShareMenu.toggle()
                                    userVM.hideBackground.toggle()
                                    userVM.hideTabButtons.toggle()
                                }
                            },label:{
                                Image(systemName: "arrowshape.turn.up.right").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 22))
                            })
                            
                            
                            
                        }
                        
                    }.padding(10)
                }
            
            }.cornerRadius(16).overlay(
                GeometryReader{ proxy in
                    Color.clear.onAppear{
                        self.fullWidth = proxy.size.width
                    }
                }
            )
        
          
        
       
        
    }
}

struct UnansweredChoices : View {
    @Binding var poll: PollModel
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        
        
        
        VStack(spacing: 10){
            
            ForEach(poll.pollOptions, id: \.id){ pollOption in
                Button(action:{
                    userVM.answerPollOption(poll: poll, pollOption: pollOption, userID: userVM.user?.id ?? " ") { fetchedPoll in
                        self.poll = fetchedPoll
                    }
                },label:{
                    PollOption(pollOption: pollOption)
                })
            }
            
        }
        
        
        
        
    }
}

struct AnsweredChoices: View {
    @Binding var poll: PollModel
    @EnvironmentObject var userVM: UserViewModel
    @Binding var fullWidth: CGFloat
    func isWinningPollOption(pollOption: PollOptionModel) -> Bool {
        var winner : PollOptionModel = poll.pollOptions[0]
        var maxPercent = 0.00
        for option in poll.pollOptions {
            var percent = round(Double(option.pickedUsersID?.count ?? 1) / (Double(poll.usersAnsweredID?.count ?? 1) * 100 ))
            
            
            
            if percent > maxPercent {
                maxPercent = percent
                winner = option
            }
            
        }
        
        return winner.id ?? "" == pollOption.id ?? ""
    }
    
    
    
    func getPercentage(usersAnswered: Int, pickedUsers: Int) -> Double{
        if usersAnswered == 0 || pickedUsers == 0 {
            return 0
        }
        var percentage = Double(Double(pickedUsers) / Double(usersAnswered))
        if percentage.isNaN || percentage.isInfinite{
            return 0
        }else{
            return percentage * 100
        }
    }
    
    
    var body: some View {
            HStack{

                VStack(alignment: .leading){
                    ForEach(poll.pollOptions){ pollOption in
                        ZStack(alignment: .leading){
                       
                            RoundedRectangle(cornerRadius: 8).frame(width: (fullWidth - 50) * (getPercentage(usersAnswered: poll.usersAnsweredID?.count ?? 1, pickedUsers: pollOption.pickedUsersID?.count ?? 1 ) / 100.0), height: 35).foregroundColor(isWinningPollOption(pollOption: pollOption) ? Color("AccentColor") : Color.gray)
                            HStack(spacing: 10){
                                Text( "\( getPercentage(usersAnswered: poll.usersAnsweredID?.count ?? 1, pickedUsers: pollOption.pickedUsersID?.count ?? 1 ), specifier: "%.1f")%")
                                ZStack{
                                    Circle().frame(width: 20, height: 20).foregroundColor((pollOption.pickedUsersID?.contains(userVM.user?.id ?? " ") ?? false ) ? Color("Color") : Color.clear)
                                    Image(systemName: "checkmark").foregroundColor((pollOption.pickedUsersID?.contains(userVM.user?.id ?? " ") ?? false ) ? FOREGROUNDCOLOR : Color.clear).font(.system(size: 10))
                                }
                                
                                Text("\(pollOption.choice ?? "")").foregroundColor(FOREGROUNDCOLOR)
                            }.padding(.leading,5)
                        }
                        
                        
                        
                    }
                }
            
                Spacer()

        }.padding(.horizontal)
    
        
    }
}


struct PollOption : View {
    var pollOption: PollOptionModel
    var body: some View {
        HStack{
            Spacer()
            Text("\(pollOption.choice ?? "")").foregroundColor(FOREGROUNDCOLOR)
            Spacer()
        }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor"))).cornerRadius(12).padding(.horizontal)
    }
}


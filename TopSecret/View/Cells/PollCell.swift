import Firebase
import SwiftUI
import Foundation
import SDWebImageSwiftUI

struct PollCell : View {
    @State var poll : PollModel
    @Binding var showUsers: Bool
    @Binding var selectedPoll : PollModel
    @StateObject var createPollVM = CreatePollViewModel()
    @StateObject var pollVM = PollViewModel()
    @EnvironmentObject var userVM: UserViewModel
    
 
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Text(poll.question ?? "").font(.title3).bold()
            }.padding(10)
            Divider()
         
            VStack(spacing: 0){
                
                if poll.usersAnsweredID?.contains(userVM.user?.id ?? " ") ?? false {
                    AnsweredChoice(pollOption: poll.pollOptions[0] ?? PollOptionModel(), userID: userVM.user?.id ?? " ", poll: poll)
                }else{
                    UnansweredChoice(pollOption: poll.pollOptions[0] ?? PollOptionModel(), userID: userVM.user?.id ?? " ", poll: poll)
                }
              
                Divider()
              
                if poll.usersAnsweredID?.contains(userVM.user?.id ?? " ") ?? false {
                    AnsweredChoice(pollOption: poll.pollOptions[1] ?? PollOptionModel(), userID: userVM.user?.id ?? " ", poll: poll)
                }else{
                    UnansweredChoice(pollOption: poll.pollOptions[1] ?? PollOptionModel(), userID: userVM.user?.id ?? " ", poll: poll)
                }
                    
                
                Divider()
                if poll.usersAnsweredID?.contains(userVM.user?.id ?? " ") ?? false {
                    AnsweredChoice(pollOption: poll.pollOptions[2] ?? PollOptionModel(), userID: userVM.user?.id ?? " ", poll: poll)
                }else{
                    UnansweredChoice(pollOption: poll.pollOptions[2] ?? PollOptionModel(), userID: userVM.user?.id ?? " ", poll: poll)
                }
                
                Divider()
                if poll.usersAnsweredID?.contains(userVM.user?.id ?? " ") ?? false {
                    AnsweredChoice(pollOption: poll.pollOptions[3] ?? PollOptionModel(), userID: userVM.user?.id ?? " ", poll: poll)
                }else{
                    UnansweredChoice(pollOption: poll.pollOptions[3] ?? PollOptionModel(), userID: userVM.user?.id ?? " ", poll: poll)
                }
            }
            Divider()
            HStack{
                HStack(spacing: 5){
                    HStack(spacing: 1){
                        WebImage(url: URL(string: poll.creator?.profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:25,height:25)
                            .clipShape(Circle())
                        
                        Text("\(poll.creator?.nickName ?? "")").font(.body)
                    }
                    HStack(alignment: .center, spacing: 3){
                        
                    Text("\(poll.usersAnsweredID?.count ?? 0) \(poll.usersAnsweredID?.count ?? 0 == 1 ? "vote" : "votes")").foregroundColor(.gray).font(.footnote)
                        Button(action:{
                            selectedPoll = pollVM.poll
                            showUsers.toggle()
                        },label:{
                            Text("See Users").foregroundColor(Color("AccentColor")).font(.caption)
                        })
                    }
                }.padding(.leading,5)
                Spacer()
                Text("\(poll.startDate?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.caption).padding(.trailing,5)
            }.padding(.vertical,5)
        }.background(RoundedRectangle(cornerRadius: 12).fill((Color("Color")))).onAppear{
            pollVM.fetchPoll(groupID: poll.groupID ?? " ", pollID: poll.id ?? " ") { fetchedPoll in
                self.poll = fetchedPoll
            }
        }
    }
}


struct GeometryGetter : View {
    @Binding var rect: CGRect
    
    var body: some View {
        return GeometryReader{ geometry in
            self.makeView(geometry: geometry)
        }
    }
    
    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }
        return Rectangle().fill(Color.clear)
    }
}

struct UnansweredChoice : View {
    @State var choiceBoxRect : CGRect = CGRect()
    var pollOption : PollOptionModel
    @StateObject var pollVM = CreatePollViewModel()
    var userID: String
    var poll: PollModel
    var body: some View {
       
        HStack{
            Spacer()
            Button(action:{
                pollVM.makePollChoice(pollID: poll.id ?? " ", choiceID: pollOption.id ?? " ", userID: userID, groupID: poll.groupID ?? " ")
            },label:{
                Text("\(pollOption.choice ?? "" )").foregroundColor(Color("AccentColor"))
            }).padding(.leading,5)
            Spacer()
        }.padding(.vertical,5)
            
    }
}

struct AnsweredChoice : View {
    @State var choiceBoxRect : CGRect = CGRect()
    var pollOption : PollOptionModel
    var userID: String
    var poll: PollModel
    
    func calculateWidth(totalUsers: Int, usersAnswered: Int, widthBounds: Int) -> CGFloat{
   
       
       var oldRange = totalUsers
       var newRange = widthBounds
       var newValue = ((usersAnswered * widthBounds ) / totalUsers)
        return CGFloat(newValue)
    }
    
    func calculatePercentage(totalUsers: Int, usersAnswered: Int) -> Int {
        return ((usersAnswered * 100) / totalUsers)
    }
    var body: some View {
        ZStack(alignment: .leading){
            
                Rectangle().frame(width: self.calculateWidth(totalUsers: poll.usersAnsweredID?.count ?? 1, usersAnswered: pollOption.pickedUsersID?.count ?? 1, widthBounds: Int(choiceBoxRect.width))).foregroundColor(Color("AccentColor"))
              
            
                
            
        HStack{
            
            if pollOption.pickedUsersID?.contains(userID) ?? false {
                ZStack{
                    Circle().frame(width: 20, height: 20).foregroundColor(Color("Background"))
                    Image(systemName: "checkmark").font(.footnote)
                }.padding(.trailing,5)
            }
            
            Text("\(self.calculatePercentage(totalUsers: poll.usersAnsweredID?.count ?? 1, usersAnswered: pollOption.pickedUsersID?.count ?? 1))%")
            Text("\(pollOption.choice ?? "" )").foregroundColor(FOREGROUNDCOLOR)
            Spacer()
        }.padding([.vertical, .leading],5)
        }.background(GeometryGetter(rect: $choiceBoxRect))
    }
}

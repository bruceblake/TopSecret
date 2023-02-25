import SwiftUI
import SDWebImageSwiftUI


struct GroupPostCell : View {
    @State var post: GroupPostModel
    @EnvironmentObject var userVM: UserViewModel
    @State var showLike : Bool = false
    @Binding var selectedPost: GroupPostModel
    @State var showComments: Bool = false
    @State private var truncated: Bool = false
    @State private var expanded: Bool = false
    @State var seeMedia: Bool = false
    @State var editText: String = ""
    @State var showEditScreen: Bool = false
    @Binding var shareType: String
    @EnvironmentObject var shareVM : ShareViewModel
    private var moreLessText: String {
        if !truncated {
            return ""
        }else{
            return self.expanded ? "read less" : "... read more"
        }
    }
    
    
    
    
    
    
    func userHasLiked() -> Bool{
        return post.likedListID?.contains(userVM.user?.id ?? "") ?? false
    }
    
    func userHasDisliked() -> Bool{
        return post.dislikedListID?.contains(userVM.user?.id ?? "") ?? false
        
    }
    
    func getTimeSincePost(date: Date) -> String{
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
            if days > 1 {
                let formatter = DateFormatter()
                formatter.dateFormat = "E, MMM dd yyyy"
                return formatter.string(from: date)
            }
        }
        if time == "0s"{
            return "now"
        }
        else{
            return time
        }
        
    }
    
    
    func showLikeAnimation(){
        withAnimation(.easeInOut) {
            self.showLike = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:{
                withAnimation(.easeInOut){
                    self.showLike = false
                }
            })
        }
    }
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                //top bar
                HStack(alignment: .top){
                    HStack(alignment: .center){
                        ZStack(alignment: .bottomTrailing){
                            
                            NavigationLink(destination: GroupProfileView(group: post.group ?? Group(), isInGroup: post.group?.users.contains(userVM.user?.id ?? " ") ?? false)) {
                                WebImage(url: URL(string: post.group?.groupProfileImage ?? "")).resizable().frame(width: 40, height: 40).clipShape(Circle())
                            }
                            
                            NavigationLink(destination: UserProfilePage(user: post.creator ?? User())) {
                                WebImage(url: URL(string: post.creator?.profilePicture ?? "")).resizable().frame(width: 18, height: 18).clipShape(Circle())
                            }.offset(x: 3, y: 2)
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 1){
                            HStack(alignment: .center, spacing: 3){
                                Text("\(post.group?.groupName ?? "")").font(.system(size: 15)).bold().foregroundColor(FOREGROUNDCOLOR)
                                
                                HStack(spacing: 4){
                                    Circle().frame(width: 3, height: 3).foregroundColor(Color.gray)
                                    Text("\(getTimeSincePost(date:post.timeStamp?.dateValue() ?? Date()))").font(.system(size: 15))
                                }.foregroundColor(Color.gray)
                                
                            }
                            HStack(spacing: 3){
                                Text("posted by").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                                NavigationLink(destination: UserProfilePage(user: post.creator ?? User())) {
                                    if post.creatorID ?? "" == userVM.user?.id ?? "" {
                                        Text("ME").foregroundColor(Color.gray).font(.system(size: 12))
                                    }else{
                                        Text("\(post.creator?.username ?? "")").foregroundColor(Color.gray).font(.system(size: 12))
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                    
                    Spacer()
                    Menu(content:{
                        Button(action:{
                            self.selectedPost = post
                            self.showEditScreen.toggle()
                            userVM.hideBackground.toggle()
                            
                        },label:{
                            Text("Edit")
                        })
                        
                        Button(action:{
                            withAnimation{
                                self.selectedPost = post
                                shareVM.showShareMenu.toggle()
                                userVM.hideTabButtons.toggle()
                                userVM.hideBackground.toggle()
                            }
                            
                        },label:{
                            Text("Share")
                        })
                        Button(action:{
                            self.selectedPost = post
                            userVM.deletePost(postID: post.id ?? "")
                        },label:{
                            Text("Delete")
                        })
                    },label:{
                        Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR).padding(5)
                    })
                    
                    
                }.padding([.horizontal,.top],5)
                
                
                Image(uiImage: post.image ?? UIImage()).resizable().scaledToFill()
                
                
                //bottom bar
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        ExpandableText(post.description ?? "", lineLimit: 2, username: post.creator?.username ?? "")
                        
                    }
                    
                    
                    
                    Spacer()
                    
                    HStack(alignment: .top, spacing: 15){
                        
                        
                        
                        
                        Button(action:{
                            userVM.updateGroupPostLike(postID: post.id ?? " ", userID: userVM.user?.id ?? " ", actionToLike: true) { list in
                                if !(post.likedListID?.contains(userVM.user?.id ?? "") ?? false){
                                    self.showLikeAnimation()
                                }
                                self.post.likedListID = list[0]
                                self.post.dislikedListID = list[1]
                            }
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: self.userHasLiked() ? "heart.fill" :  "heart").foregroundColor(self.userHasLiked() ? Color("AccentColor") : FOREGROUNDCOLOR).font(.system(size: 22))
                                Text("\(post.likedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })
                        
                        Button(action:{
                            userVM.updateGroupPostLike(postID: post.id ?? " ", userID: userVM.user?.id ?? " ", actionToLike: false) { list in
                                self.post.likedListID = list[0]
                                self.post.dislikedListID = list[1]
                            }
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: self.userHasDisliked() ? "heart.slash.fill" :  "heart.slash").foregroundColor(self.userHasDisliked() ? Color("AccentColor") :  FOREGROUNDCOLOR).font(.system(size: 20))
                                Text("\(post.dislikedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })
                        
                        Button(action:{
                            self.showComments.toggle()
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: "message").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 20))
                                Text("\(post.commentsCount ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })
                        
                        Button(action:{
                            withAnimation{
                                self.selectedPost = post
                                self.shareType = "post"
                                shareVM.showShareMenu.toggle()
                                userVM.hideBackground.toggle()
                                userVM.hideTabButtons.toggle()
                            }
                        },label:{
                                Image(systemName: "arrowshape.turn.up.right").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 22))
                        })
                        
                        
                        
                    }.padding(.trailing,5)
                    
                }.padding([.horizontal,.bottom],5)
            }
            if showLike{
                
                Image(systemName: "heart.fill").foregroundColor(Color("AccentColor")).font(.system(size: 65))
                
            }
            
            
            
            NavigationLink(destination: GroupPostCommentsView(showComments: $showComments, post: $post), isActive: $showComments) {
                EmptyView()
            }
            
        }.cornerRadius(12)
        //            .onTapGesture(count: 2, perform: {
        //            UIDevice.vibrate()
        //
        //            userVM.updateGroupPostLike(postID: post.id ?? " ", userID: userVM.user?.id ?? " ", actionToLike: true) { list in
        //                if !(post.likedListID?.contains(userVM.user?.id ?? "") ?? false){
        //                    self.showLikeAnimation()
        //                }
        //                self.post.likedListID = list[0]
        //                self.post.dislikedListID = list[1]
        //
        //            }
        //        })
        
    }
}

struct ShowShareMenu: View {
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var personalChatVM = PersonalChatViewModel()
    @Binding var selectedPost: GroupPostModel
    @Binding var selectedPoll: PollModel
    @Binding var selectedEvent: EventModel
    @State var showSendView: Bool = false
    @State var selectedChats: [ChatModel] = []
    @Binding var shareType: String
    @EnvironmentObject var shareVM : ShareViewModel
    func getPersonalChatUser(chat: ChatModel) -> User{
        
        for user in chat.users {
            if user.id ?? "" != userVM.user?.id ?? " "{
                return user
            }
        }
        
        return User()
    }
    
    var body: some View{
        
        VStack{
            HStack{
                Text("Share to friends and groups")
                
            }
            HStack{
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 10){
                        
                        ForEach(userVM.groups){ group in
                            Button(action:{
                                withAnimation{
//                                    //this is just for testing
//                                    selectedChats.append(ChatModel(dictionary: ["id":group.chatID ?? ""])
                                    
                                    
                                    if !self.showSendView{
                                        self.showSendView.toggle()
                                    }
                                    if shareVM.sendStatus == .sent{
                                        shareVM.sendStatus = .notSending
                                    }
                                }
                            },label:{
                                VStack{
                                    WebImage(url: URL(string: group.groupProfileImage ?? "")).resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                        .overlay{
                                            if showSendView && selectedChats.contains(where: {
                                                $0.id == group.chatID ?? ""
                                            }){
                                                Circle().frame(width: 40,height:40).foregroundColor( Color.black.opacity(0.6))
                                                Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                                            }
                                        }
                                    
                                    
                                    
                                    
                                    
                                    
                                    Text("\(group.groupName)").foregroundColor(FOREGROUNDCOLOR)
                                }
                            })
                        }
                        
                        ForEach(userVM.personalChats) { chat in
                            Button(action:{
                                
                                withAnimation{
                                    if selectedChats.contains(where: {
                                        $0.id == chat.id
                                    }){
                                        selectedChats.removeAll(where: {
                                            $0.id == chat.id
                                        })
                                    }else{
                                        selectedChats.append(chat)
                                    }
                                    if !self.showSendView{
                                        self.showSendView.toggle()
                                    }
                                    if selectedChats.isEmpty{
                                        self.showSendView = false
                                    }
                                    if shareVM.sendStatus == .sent{
                                        shareVM.sendStatus = .notSending
                                    }
                                }
                            },label:{
                                VStack{
                                    WebImage(url: URL(string: self.getPersonalChatUser(chat: chat).profilePicture ?? "")).resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                        .overlay{
                                            if showSendView && selectedChats.contains(where: {
                                                $0.id == chat.id
                                            }){
                                                Circle().frame(width: 40,height:40).foregroundColor( Color.black.opacity(0.6))
                                                Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                                            }
                                        }
                                    
                                    
                                    
                                    
                                    
                                    
                                    Text("\(self.getPersonalChatUser(chat: chat).nickName ?? "")").foregroundColor(FOREGROUNDCOLOR)
                                }
                            })
                            
                            
                        }
                        
                    }
                    
                }
            }.padding(10)
            
            if showSendView{
                Button(action:{
                    for chat in selectedChats{
                        switch shareType{
                            case "post":
                                shareVM.sendPostMessage(postID: selectedPost.id ?? " ", user: userVM.user ?? User(), chatID: chat.id)
                            case "poll":
                                shareVM.sendPollMessage(pollID: selectedPoll.id ?? " ", user: userVM.user ?? User(), chatID: chat.id)
                            case "event":
                            shareVM.sendEventMessage(eventID: selectedEvent.id , user: userVM.user ?? User(), chatID: chat.id)
                        default: break
                            //nada
                        }
                       
                    }
                   
                   
                },label:{
                    if shareVM.sendStatus == .sending{
                        Text("Sending").foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                    }else if shareVM.sendStatus == .sent{
                        Text("Sent!").foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(Color("Background")).cornerRadius(15)
                    }else if shareVM.sendStatus == .notSending{
                        Text("Send").foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                    }
                   
                })
            }
        }.padding(.bottom,20).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).frame(width: UIScreen.main.bounds.width).cornerRadius(12)
        
    }
}


struct FullScreenGroupPostView : View {
    @State var post: GroupPostModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var showLike: Bool = false
    
    func userHasLiked() -> Bool{
        return post.likedListID?.contains(userVM.user?.id ?? "") ?? false
    }
    
    func userHasDisliked() -> Bool{
        return post.dislikedListID?.contains(userVM.user?.id ?? "") ?? false
        
    }
    func showLikeAnimation(){
        withAnimation(.easeInOut) {
            self.showLike = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:{
                withAnimation(.easeInOut){
                    self.showLike = false
                }
            })
        }
    }
    
    func getTimeSincePost(date: Date) -> String{
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
            if days > 1 {
                let formatter = DateFormatter()
                formatter.dateFormat = "E, MMM dd yyyy"
                return formatter.string(from: date)
            }
        }
        if time == "0s"{
            return "now"
        }
        else{
            return time
        }
        
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Photo")
                    Spacer()
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                    
                }.padding(.top,50).padding(.horizontal)
                HStack(alignment: .top){
                    HStack(alignment: .center){
                        ZStack(alignment: .bottomTrailing){
                            
                            NavigationLink(destination: GroupProfileView(group: post.group ?? Group(), isInGroup: post.group?.users.contains(userVM.user?.id ?? " ") ?? false)) {
                                WebImage(url: URL(string: post.group?.groupProfileImage ?? "")).resizable().frame(width: 40, height: 40).clipShape(Circle())
                            }
                            
                            NavigationLink(destination: UserProfilePage(user: post.creator ?? User())) {
                                WebImage(url: URL(string: post.creator?.profilePicture ?? "")).resizable().frame(width: 18, height: 18).clipShape(Circle())
                            }.offset(x: 3, y: 2)
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 1){
                            HStack(alignment: .center, spacing: 3){
                                Text("\(post.group?.groupName ?? "")").font(.system(size: 15)).bold().foregroundColor(FOREGROUNDCOLOR)
                                
                                HStack(spacing: 4){
                                    Circle().frame(width: 3, height: 3).foregroundColor(Color.gray)
                                    Text("\(getTimeSincePost(date:post.timeStamp?.dateValue() ?? Date()))").font(.system(size: 15))
                                }.foregroundColor(Color.gray)
                                
                            }
                            HStack(spacing: 3){
                                Text("posted by").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                                NavigationLink(destination: UserProfilePage(user: post.creator ?? User())) {
                                    if post.creatorID ?? "" == userVM.user?.id ?? "" {
                                        Text("ME").foregroundColor(Color.gray).font(.system(size: 12))
                                    }else{
                                        Text("\(post.creator?.username ?? "")").foregroundColor(Color.gray).font(.system(size: 12))
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                    
                    Spacer()
                    Menu(content:{
                        //                            Button(action:{
                        //                                self.selectedPost = post
                        //                                self.showEditScreen.toggle()
                        //                                self.hideBackground.toggle()
                        //
                        //                            },label:{
                        //                                Text("Edit")
                        //                            })
                        //
                        //                            Button(action:{
                        //                                withAnimation{
                        //                                    self.selectedPost = post
                        //                                    self.showShareMenu.toggle()
                        //                                    self.hideBackground.toggle()
                        //                                    userVM.hideTabButtons.toggle()
                        //                                }
                        //
                        //                            },label:{
                        //                                Text("Share")
                        //                            })
                        //                            Button(action:{
                        //                                self.selectedPost = post
                        //                                userVM.deletePost(postID: post.id ?? "")
                        //                            },label:{
                        //                                Text("Delete")
                        //                            })
                    },label:{
                        Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR).padding(5)
                    })
                    
                    
                }.padding([.horizontal,.top],5)
                
                Image(uiImage: post.image ?? UIImage()).resizable().scaledToFit()
                HStack(alignment: .top){
                    
                    VStack(alignment: .leading){
                        ExpandableText(post.description ?? "", lineLimit: 2, username: post.creator?.username ?? "")
                        
                    }
                    
                    
                    
                    Spacer()
                    HStack(alignment: .top, spacing: 15){
                        
                        
                        
                        
                        Button(action:{
                            userVM.updateGroupPostLike(postID: post.id ?? " ", userID: userVM.user?.id ?? " ", actionToLike: true) { list in
                                if !(post.likedListID?.contains(userVM.user?.id ?? "") ?? false){
                                    self.showLikeAnimation()
                                }
                                self.post.likedListID = list[0]
                                self.post.dislikedListID = list[1]
                            }
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: self.userHasLiked() ? "heart.fill" :  "heart").foregroundColor(self.userHasLiked() ? Color("AccentColor") : FOREGROUNDCOLOR).font(.system(size: 22))
                                Text("\(post.likedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })
                        
                        Button(action:{
                            userVM.updateGroupPostLike(postID: post.id ?? " ", userID: userVM.user?.id ?? " ", actionToLike: false) { list in
                                self.post.likedListID = list[0]
                                self.post.dislikedListID = list[1]
                            }
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: self.userHasDisliked() ? "heart.slash.fill" :  "heart.slash").foregroundColor(self.userHasDisliked() ? Color("AccentColor") :  FOREGROUNDCOLOR).font(.system(size: 20))
                                Text("\(post.dislikedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })
                        
                        Button(action:{
                            //                        self.showComments.toggle()
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: "message").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 20))
                                Text("\(post.commentsCount ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })
                        
                        Button(action:{
                            withAnimation{
                                //                                self.selectedPost = post
                                //                                self.showShareMenu.toggle()
                                //                                self.hideBackground.toggle()
                                //                                userVM.hideTabButtons.toggle()
                            }
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: "arrowshape.turn.up.right").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 22))
                                Text("\(post.commentsCount ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })
                        
                        
                    }.padding(.trailing,5)
                }.padding([.horizontal,.bottom],5)
                Spacer()
            }
            
            
            
        }.navigationBarHidden(true).edgesIgnoringSafeArea(.all).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
    }
}


struct ExpandableText: View {
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false
    @State private var shrinkText: String
    private var text: String
    let username: String
    let font: UIFont
    let lineLimit: Int
    private var moreLessText: String {
        if !truncated {
            return ""
        } else {
            return self.expanded ? " read less" : "...read more"
        }
    }
    
    init(_ text: String, lineLimit: Int, font: UIFont = UIFont.systemFont(ofSize: 13), username: String) {
        self.text = text
        self.lineLimit = lineLimit
        _shrinkText =  State(wrappedValue: text)
        self.font = font
        self.username = username
    }
    
    var body: some View {
        
        
        ZStack(alignment: .bottomLeading) {
            ZStack {
                Text("\(username) ").bold().foregroundColor(FOREGROUNDCOLOR) + Text(self.expanded ? text : shrinkText).foregroundColor(FOREGROUNDCOLOR)
                + Text(moreLessText)
                    .bold()
                    .foregroundColor(.blue)
                
            }.animation(.easeInOut)
                .lineLimit(expanded ? nil : lineLimit)
                .background(
                    // Render the limited text and measure its size
                    Text(text).font(.system(size: 13)).lineLimit(lineLimit)
                        .background(GeometryReader { visibleTextGeometry in
                            Color.clear.onAppear() {
                                let size = CGSize(width: visibleTextGeometry.size.width, height: .greatestFiniteMagnitude)
                                let attributes:[NSAttributedString.Key:Any] = [NSAttributedString.Key.font: font]
                                ///Binary search until mid == low && mid == high
                                var low  = 0
                                var heigh = shrinkText.count
                                var mid = heigh ///start from top so that if text contain we does not need to loop
                                while ((heigh - low) > 1) {
                                    let attributedText = NSAttributedString(string: shrinkText + moreLessText, attributes: attributes)
                                    let boundingRect = attributedText.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                                    if boundingRect.size.height > visibleTextGeometry.size.height {
                                        truncated = true
                                        heigh = mid
                                        mid = (heigh + low)/2
                                        
                                    } else {
                                        if mid == text.count {
                                            break
                                        } else {
                                            low = mid
                                            mid = (low + heigh)/2
                                        }
                                    }
                                    shrinkText = String(text.prefix(mid))
                                }
                                if truncated {
                                    shrinkText = String(shrinkText.prefix(shrinkText.count - 2))  //-2 extra as highlighted text is bold
                                }
                            }
                        })
                        .hidden() // Hide the background
                ).font(Font(font))
            if truncated {
                Button(action: {
                    expanded.toggle()
                }, label: {
                    HStack { //taking tap on only last line, As it is not possible to get 'see more' location
                        Spacer()
                        Text("")
                    }.opacity(0)
                })
            }
        }
    }
    
}

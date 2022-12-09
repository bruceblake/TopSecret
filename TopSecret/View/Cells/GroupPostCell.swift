import SwiftUI
import SDWebImageSwiftUI


struct GroupPostCell : View {
    var post: GroupPostModel
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                //top bar
                HStack(alignment: .top){
                    ZStack(alignment: .bottomTrailing){
                        
                        NavigationLink(destination: GroupProfileView(group: post.group ?? Group(), isInGroup: post.group?.users.contains(userVM.user?.id ?? " ") ?? false)) {
                            WebImage(url: URL(string: post.group?.groupProfileImage ?? "")).resizable().frame(width: 40, height: 40).clipShape(Circle())
                        }
                   
                        NavigationLink(destination: UserProfilePage(user: post.creator ?? User())) {
                            WebImage(url: URL(string: post.creator?.profilePicture ?? "")).resizable().frame(width: 20, height: 20).clipShape(Circle())
                        }.offset(x: 5)
                      
                    }
                    
                    VStack(alignment: .leading, spacing: 2){
                        HStack{
                            Text("\(post.group?.groupName ?? "")").font(.system(size: 15)).bold()
                            Text("\(post.timeStamp?.dateValue() ?? Date() ,style: .time)").font(.system(size: 12))
                        }
                        HStack(spacing: 3){
                            Text("posted by").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                            NavigationLink(destination: UserProfilePage(user: post.creator ?? User())) {
                                Text("\(post.creator?.username ?? "")").foregroundColor(Color.gray).font(.system(size: 12))
                            }
                           
                        }
                    }
                    
                    Spacer()
                    
                    Button(action:{
                        
                    },label:{
                        Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR)
                    })
                }.padding([.horizontal,.top],5)
                
                Spacer()
                
                Image(uiImage: post.image ?? UIImage()).resizable().scaledToFit()
                
                Spacer()
                
                //bottom bar
                HStack{
                    VStack(alignment: .leading, spacing: 2){
                        HStack{
                            Text("\(post.creator?.username ?? "")").font(.system(size: 14)).bold()
                            Text("\(post.description ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                        }
                        HStack(alignment: .bottom){
                            Text("12 comments").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                            Button(action:{
                                
                            },label:{
                                Text("Add a comment..").foregroundColor(Color.gray).font(.system(size: 10))
                            })
                        }
                    }
                    Spacer()
                    
                    HStack{
                        VStack{
                            
                        }
                        
                        VStack{
                            
                        }
                    }
                }.padding([.horizontal,.bottom],5)
            }
        }.frame(width: UIScreen.main.bounds.width - 20).cornerRadius(12)
       
    }
}

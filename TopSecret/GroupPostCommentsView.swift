//
//  GroupPostCommentsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/15/22.
//
import OmenTextField
import SDWebImageSwiftUI
import SwiftUI
import Combine


class KeyboardViewModel : ObservableObject{
    @Published var enteredNewLine : Bool = false
    static var shared = KeyboardViewModel()
}

//reply comment architecture

struct GroupPostCommentsView: View {
    @ObservedObject var commentsVM = GroupPostCommentViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var shareVM: ShareViewModel
    @ObservedObject var keyboardVM = KeyboardViewModel()
    @Binding var showComments : Bool
    @State var text: String = ""
    @State var focused : Bool = false
    @State var placeholder = "Add Comment.."
    @State var keyboardHeight: CGFloat = 0
    @State var isReplying: Bool = false
    @State var selectedComment: GroupPostCommentModel = GroupPostCommentModel()
    @State var canAddAnotherLine : Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var post: GroupPostModel
    
    
    var comments : [GroupPostCommentModel] {
        commentsVM.comments.filter({
            ($0.parentCommentID ?? "nil") == "nil"
        })
    }
    
    func userHasLikedComment() -> Bool{
        return post.commentsLikedListID?.contains(userVM.user?.id ?? "") ?? false
    }
    
    func userHasDislikedComment() -> Bool{
        return post.commentsDislikedListID?.contains(userVM.user?.id ?? "") ?? false
        
    }
    
    func userHasLikedPost() -> Bool{
        return post.likedListID?.contains(userVM.user?.id ?? "") ?? false
    }
    
    func userHasDislikedPost() -> Bool{
        return post.dislikedListID?.contains(userVM.user?.id ?? "") ?? false
        
    }
    
    func initKeyboardGuardian(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification , object: nil, queue: .main) { data in
            let height1 = data.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            withAnimation(.easeOut(duration: 0.25)){
                self.keyboardHeight = height1.cgRectValue.height + 80
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.25)){
                self.keyboardHeight = 0
            }
        }

    }
    
    var body: some View {
        ZStack(alignment: .bottom){
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
                    
                    Text("\(post.commentsCount ?? 0) Comments").font(.title3)
                    
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal,10)
                Spacer()
                
                VStack(spacing: 10){
                    Image(uiImage: post.image ?? UIImage()).resizable().scaledToFit().cornerRadius(16)
                    HStack(alignment: .top){
                        VStack(alignment: .leading){
                            ExpandableText(post.description ?? "", lineLimit: 2, username: post.creator?.username ?? "")
                            
                        }
                        Spacer()
                    }.padding(.leading,10)
                }
                Divider()

                if commentsVM.hasFetchedComments{
                    
                    if commentsVM.comments.isEmpty{
                        VStack{
                            Spacer()
                            Text("This post has no comments :(")
                            Spacer()
                        }
                    }else{
                       
                        ScrollView(showsIndicators: false){
                                VStack{
                                    ForEach(comments){ comment in
                                        GroupPostCommentCell(comment: comment, focusKeyboard: $focused, placeholder: $placeholder, isReplying: $isReplying, selectedComment: $selectedComment)
                                    }
                                    Spacer()
                                }.padding(.bottom, UIScreen.main.bounds.height/5)
                                
                            }
                    
                    }
                }else{
                    VStack{
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
              
                   
                
            }.frame(width: UIScreen.main.bounds.width)
          
            VStack{
                Spacer()
                VStack{
                    Divider()
                    HStack{
                        Spacer()
                        OmenTextField("\(placeholder)",text: $text, isFocused: $focused, canAddAnotherLine: $canAddAnotherLine).padding(10)
                           .background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                        
                        Button(action:{
                            let dp = DispatchGroup()
                            dp.enter()
                            if isReplying{
                                commentsVM.addComment(postID: post.id ?? " ", userID: userVM.user?.id ?? " ", text: text, parentCommentID: selectedComment.id ?? " ")
                                    
                            }else{
                            commentsVM.addComment(postID: post.id ?? " ", userID: userVM.user?.id ?? " ", text: text)
                            }
                            dp.leave()
                            dp.notify(queue: .main, execute:{
                                commentsVM.fetchComments(postID: post.id ?? " ")
                                text = ""
                            })
                        },label:{
                            Text("Send").padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                        }).disabled(text == "")
                       
                        Spacer()
                    }.padding().padding(.bottom)
                 
                }.background(Color("Color"))
            }

           
          
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            self.initKeyboardGuardian()
            commentsVM.fetchComments(postID: post.id ?? " ")
        }.simultaneousGesture(DragGesture().onChanged { _ in
            UIApplication.shared.keyWindow?.endEditing(true)
            self.isReplying = false
            self.placeholder = "Add Comment.."
            if self.focused{
                self.focused = false
            }
        }).onChange(of: isReplying, perform:{ newValue in
            if newValue{
                self.focused = true
            }
        })    }
}

//
//extension Notification {
//    var keyboardHeight: CGFloat {
//        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
//    }
//}
//
//extension Publishers {
//    // 1.
//    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
//        // 2.
//        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
//            .map { $0.keyboardHeight }
//
//        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification).map{
//            $0.keyboardHeight
//        }
//
//
//
//        // 3.
//        return MergeMany(willShow, willHide)
//            .eraseToAnyPublisher()
//    }
//}
//
//
//
//struct KeyboardAdaptive: ViewModifier {
//    @State private var bottomPadding: CGFloat = 0
//
//    func body(content: Content) -> some View {
//        // 1.
//        GeometryReader { geometry in
//            content
//                .padding(.bottom, self.bottomPadding)
//                // 2.
//                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
//                    // 3.
//
//                        if keyboardHeight > 0 && self.bottomPadding > 0  {return}
//
//                            let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
//                            // 4.
//                            let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
//                            // 5.
//                            self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom)
//
//
//
//
//                }
//            // 6.
//            .animation(.easeOut(duration: 0.16))
//        }
//    }
//}
//
//extension View {
//    func keyboardAdaptive() -> some View {
//        ModifiedContent(content: self, modifier: KeyboardAdaptive())
//    }
//}
//
//
//extension UIResponder {
//    static var currentFirstResponder: UIResponder? {
//        _currentFirstResponder = nil
//        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
//        return _currentFirstResponder
//    }
//
//    private static weak var _currentFirstResponder: UIResponder?
//
//    @objc private func findFirstResponder(_ sender: Any) {
//        UIResponder._currentFirstResponder = self
//    }
//
//    var globalFrame: CGRect? {
//        guard let view = self as? UIView else { return nil }
//        return view.superview?.convert(view.frame, to: nil)
//    }
//}

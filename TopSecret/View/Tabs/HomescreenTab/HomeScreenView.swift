//
//  HomeScreenView.swift
//  TopSecret
//
//  Created by nathan frenzel on 8/31/21.
//

import SwiftUI
import SDWebImageSwiftUI
import MediaCore
import MediaSwiftUI

struct HomeScreenView: View {
    
    
    
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @StateObject var keyboardVM = KeyboardViewModel()
    @State var goBack = false
    @State var showAddContent = false
    @Binding var group : Group
    @State var offset : CGSize = .zero
    @State var showProfileView : Bool = false
    @State var showGalleryView : Bool = false

    
    @Environment(\.presentationMode) var presentationMode

    
            
    var body: some View {
        
        ZStack{
            
            Color("Background").opacity(showAddContent ? 0.2 : 1).zIndex(0)
            
            VStack{
            
           
                
                HStack(alignment: .center){
                    
                   
                    
                    HStack(alignment: .center){
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            
                            
                            ZStack{
                                
                                HStack(spacing: 1){
                                        Image(systemName: "chevron.left")
                                            .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                                        Image(systemName: "house")
                                            .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                                }.padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                                
                                if self.userVM.user?.personalChatNotificationCount ?? 0 != 0 {
                                    ZStack{
                                        Circle().foregroundColor(Color("AccentColor")).frame(width: 20, height: 20)
                                        Text("\(self.userVM.user?.personalChatNotificationCount ?? 0)").foregroundColor(Color.yellow).font(.body)
                                    }.offset(x: 20, y: -18)
                                }
                                
                                
                            }
                           
                           
                         
                            
                        })
                        
                        Button(action:{
                            showAddContent.toggle()
                        },label:{
                            Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                        }).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        
                        
                        
                    }.padding(.leading)
                    
                    
                  
                    
                    Spacer()

                
                            
                        Text(selectedGroupVM.group.groupName ).font(.title2).fontWeight(.heavy).minimumScaleFactor(0.5)
                    
                   
                    
                    Spacer()
                    
                    HStack{
                        
                        NavigationLink {
                            GroupGalleryView()
                        } label: {
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                
                                
                                
                                Image(systemName: "photo.on.rectangle.angled").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                
                              
                                
                                
                            }
                        }

                 
                      
                      
                        
                        NavigationLink(destination: GroupSettingsView().environmentObject(selectedGroupVM)){
                            Image(systemName: "gear").foregroundColor(FOREGROUNDCOLOR).font(.title3).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        }
                        
                        
                        
   

                    }.padding(.trailing,12)
                    
           
                    
                }.padding(.top,60)
                
                
                Spacer()
                
                PagerTabView(showLabels: true, tint: Color("AccentColor"), selection: $keyboardVM.selectedView, labels: ["Home","Chat","Calendar","Map"]) {
                    ActivityView(group: $group, selectedView: $keyboardVM.selectedView).environmentObject(selectedGroupVM).pageView(ignoresSafeArea: true, edges: .bottom)
                 
                    GroupChatView(keyboardVM: keyboardVM, userID: userVM.user?.id ?? " ", groupID: group.id, chatID: selectedGroupVM.group.chat.id).environmentObject(selectedGroupVM).pageView(ignoresSafeArea: true, edges: .bottom)
                
        
                    
                    GroupCalendarView(calendar: Calendar(identifier: .gregorian)).environmentObject(selectedGroupVM).pageView(ignoresSafeArea: true, edges: .bottom)

                    
                    MapView(group: $group).environmentObject(selectedGroupVM).pageView(ignoresSafeArea: true, edges: .bottom)
                    
                }.padding(.top)
                    .ignoresSafeArea(.container, edges: .bottom )
           
                
              
                
            }.zIndex(2).opacity(showAddContent ? 0.2 : 1).onTapGesture {
                if(showAddContent){
                    showAddContent.toggle()
                }
            }.disabled(showAddContent)
            
         
            
            BottomSheetView(isOpen: $showAddContent, maxHeight: UIScreen.main.bounds.height * 0.45) {
                
                AddContentView(showAddContentView: $showAddContent, group: $group).environmentObject(selectedGroupVM)
                
            }.zIndex(3)
            
            if showProfileView{
                GroupProfileView(group: $group, isInGroup: group.users.contains(userVM.user?.id ?? " "), showProfileView: $showProfileView).zIndex(3)
            }
         
            

            
        
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            selectedGroupVM.listenToGroup(userID: userVM.user?.id ?? " ", groupID: group.id) { fetched in
            }
        }.onDisappear{
            for listener in selectedGroupVM.listeners{
                listener.remove()
            }
            selectedGroupVM.groupFeed = []
        }
        .onTapGesture {
            if showAddContent{
            self.showAddContent.toggle()
            }
        }
    }
    
    
    
    
    
    
}





struct PagerTabView<Content: View>: View {
    
    var content: Content
    var labels: [String]
    var showLabels : Bool
    
    var tint: Color
    
    @Binding var selection: Int
    init(showLabels: Bool,tint: Color,selection: Binding<Int>,labels: [String],@ViewBuilder content: @escaping ()->Content){
        self.content = content()
        self.labels = labels
        self.tint = tint
        self._selection = selection
        self.showLabels = showLabels
    }
    @State var offset: CGFloat = 0
    
    @State var maxTabs : CGFloat = 1
    
    @State var tabOffset : CGFloat = 0
    
    @State var scrollSelection : Int = 0
    
    var body: some View{
        VStack(spacing: 0){
            if showLabels{
                
            HStack{
                
                ForEach(0..<labels.count, id: \.self){ index in
                    Button(action:{
                        selection = index
                        scrollSelection = index
                        let newOffset = CGFloat(index) * getScreenBounds().width
                        self.offset = newOffset
                    },label:{
                        Text(labels[index]).font(.headline).bold().foregroundColor(selection == index || scrollSelection == index ? Color("AccentColor") : FOREGROUNDCOLOR)
                    }).pageLabel()
                }
            }
               .foregroundColor(tint)
            
            
            RoundedRectangle(cornerRadius: 16)
                .fill(tint).frame(width: maxTabs == 0 ? 0 : (getScreenBounds().width / maxTabs), height: 3).padding(.top,10).frame(maxWidth: .infinity, alignment: .leading).offset(x:tabOffset)
            }
            
            OffsetPageTabView(tabCount: labels.count,buttonSelection: $selection, scrollSelection: $scrollSelection, offset: $offset){
                HStack(spacing: 0){
                    content
                }
                .overlay (
                
                    GeometryReader{ proxy in
                        Color.clear
                            .preference(key: TabPreferenceKey.self, value: proxy.frame(in: .global))
                    }
                
                )
                .onPreferenceChange(TabPreferenceKey.self) { proxy in
                    let minX = -proxy.minX
                    let maxWidth = proxy.width
                    let screenWidth = getScreenBounds().width
                    let maxTabs = (maxWidth / screenWidth).rounded()
                    
                    let progress = minX / screenWidth
                    let tabOffset = progress * (screenWidth / maxTabs)
                    
                    self.tabOffset = tabOffset
                    self.maxTabs = maxTabs
                }
            }
            
        }
    }
}


struct TabPreferenceKey : PreferenceKey{
    static var defaultValue : CGRect = .init()
    
    static func reduce(value: inout CGRect, nextValue : () -> CGRect){
        value = nextValue()
    }
}

struct OffsetPageTabView<Content: View>: UIViewRepresentable {
    var content : Content
    var tabCount : Int
    @Binding var offset: CGFloat
    @Binding var scrollSelection : Int
    @Binding var buttonSelection : Int
    
    func makeCoordinator() -> Coordinator {
        return OffsetPageTabView.Coordinator(parent: self)
    }
    
    init(tabCount: Int, buttonSelection: Binding<Int>, scrollSelection: Binding<Int>, offset: Binding<CGFloat>, @ViewBuilder content: @escaping ()->Content){
        self.content = content()
        self._offset = offset
        self._scrollSelection = scrollSelection
        self._buttonSelection = buttonSelection
        self.tabCount = tabCount
    }
    
    func makeUIView(context: Context) -> some UIScrollView {
        let scrollview = UIScrollView()
        let hostview = UIHostingController(rootView: content)
        hostview.view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            hostview.view.topAnchor.constraint(equalTo: scrollview.topAnchor),
            hostview.view.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor),
            hostview.view.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor),
            hostview.view.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
            
            hostview.view.heightAnchor.constraint(equalTo: scrollview.heightAnchor)
        ]
        
        scrollview.addSubview(hostview.view)
        scrollview.addConstraints(constraints)
        
        scrollview.isPagingEnabled = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        
        scrollview.delegate = context.coordinator
        return scrollview
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let currentOffset = uiView.contentOffset.x
        if currentOffset != offset {
            uiView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        var parent: OffsetPageTabView
        
        init(parent: OffsetPageTabView){
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.x
            
            let maxSize = scrollView.contentSize.width
            parent.offset = offset
            parent.scrollSelection = Int(offset / (maxSize / CGFloat(parent.tabCount)))
            parent.buttonSelection = parent.scrollSelection
            
        }
    }
}

extension View {
    func pageLabel()->some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
        
    }
    
    func pageView(ignoresSafeArea: Bool = false, edges: Edge.Set = [])->some View{
        self
            .frame(width: getScreenBounds().width, alignment: .center)
            .ignoresSafeArea(ignoresSafeArea ? .container : .init(), edges: edges)
    }
    
    func getScreenBounds()->CGRect{
        return UIScreen.main.bounds
    }
    
    
}

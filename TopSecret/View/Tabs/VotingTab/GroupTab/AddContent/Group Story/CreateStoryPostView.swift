//
//  CreateStoryPostView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/26/22.
//

import SwiftUI

struct CreateStoryPostView: View {
    
    @StateObject var imagePickerVM = ImagePickerViewModel()
    @StateObject var groupVM = GroupViewModel()
    @StateObject var cameraVM = CameraViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM: UserViewModel
    
    @State var avatarImage = UIImage(named: "topbarlogo")!
    @State var selectedGroup : Group = Group()
    @State var showImageSendView: Bool = false
    @State var posts : [UIImage] = []
    @State var showEditStory = false
    
    var body: some View {
        
        let longPressDrag = LongPressGesture(minimumDuration: 0.1)
            .onEnded { _ in
                print("long press start")
                cameraVM.startRecording()
            }
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onEnded { _ in
                cameraVM.stopRecording()
                cameraVM.showVideoPreview.toggle()
            }
        
        ZStack{
            
            GeometryReader{ proxy in
                let size = proxy.size
                Color("Background")
//                CameraPreview(size: size).environmentObject(cameraVM)
                
                ZStack(alignment: .leading){
                    Rectangle()
                        .fill(.black.opacity(0.25))
                    
                    Rectangle()
                        .fill(Color("AccentColor"))
                        .frame(width: size.width * (cameraVM.recordedDuration / cameraVM.maxDuration))
                }.edgesIgnoringSafeArea(.all).frame(height: 8).frame(maxHeight: .infinity, alignment: .top).offset(y: 60)
                
            }
            
            if cameraVM.photoHasBeenTaken {
                HStack{
                    HStack{
                        Spacer()
                        
                        
                        Button(action:{
                            cameraVM.savePicture()
                        },label:{
                            Text(cameraVM.hasSavedPhoto ? "Saved" : "Save")
                                .foregroundColor(FOREGROUNDCOLOR)
                                .fontWeight(.semibold)
                                .padding(.vertical,10)
                                .padding(.horizontal)
                                .background(Color("AccentColor"))
                                .clipShape(Capsule())
                            
                        }).padding(.trailing)
                    }
                    
                    Button(action:{
                        cameraVM.retakePicture()
                    },label:{
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .foregroundColor(FOREGROUNDCOLOR)
                            .padding()
                            .background(Color("AccentColor"))
                            .clipShape(Circle())
                        
                    }).padding(.leading)
                }
            }
            
            else{
                VStack{
                    HStack{
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                            
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                                
                                Image(systemName: "chevron.left")
                                    .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                            }
                        }).padding(.leading,10)
                        
                        Spacer()
                        Text("Create Story Post").font(.title2).fontWeight(.bold)
                        
                        
                        Spacer()
                        
                    }.padding(.top,50)
                    
                    
                    Spacer()
                    
                    HStack{
                        Button(action:{
                            self.showImageSendView.toggle()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "photo.on.rectangle")
                            }
                        })
                        
                        
                        ZStack{
                            Circle().fill(cameraVM.isRecording ? Color("AccentColor") : Color.white).frame(width: 65, height: 65)
                            
                            Circle().stroke(Color("AccentColor"), lineWidth: 4)
                                .frame(width: cameraVM.isRecording ? 85 : 75, height: cameraVM.isRecording ? 85 : 75)
                            
                            
                        }.onTapGesture {
                            cameraVM.takePicture()
                        }.gesture(longPressDrag)
                        
                        
                    }.padding(30).padding(.bottom,10).offset(x: -20)
                    
                    
                }
                
            }
            
            
            
            ZStack {
                if let url = cameraVM.previewURL, cameraVM.showVideoPreview {
                    NavigationLink(destination:VideoPreview(url: url, showPreview: $cameraVM.showVideoPreview).transition(.move(edge: .trailing))
                                   , isActive: $cameraVM.showVideoPreview, label: {EmptyView()})
                }
            }.animation(.easeInOut, value: cameraVM.showVideoPreview)
            
            NavigationLink(destination: EditStoryPost(image: $avatarImage), isActive: $showEditStory, label: {EmptyView()})
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            cameraVM.checkPermission()
        }.onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()){ _ in
            if cameraVM.recordedDuration <= cameraVM.maxDuration && cameraVM.isRecording {
                cameraVM.recordedDuration += 0.01
            }
            
            if cameraVM.recordedDuration >= cameraVM.maxDuration && cameraVM.isRecording {
                cameraVM.stopRecording()
                cameraVM.isRecording = false
            }
        }.onChange(of: self.avatarImage) { _ in
            self.showEditStory.toggle()
        }
    }
}





struct CreateStoryPostView_Previews: PreviewProvider {
    static var previews: some View {
        CreateStoryPostView()
    }
}

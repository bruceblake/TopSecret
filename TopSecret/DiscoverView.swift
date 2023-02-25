//
//  DiscoverView.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/24/22.
//

import SwiftUI
import MediaPicker
import AVKit

struct DiscoverView: View {
    @State var showMediaPicker: Bool = false
    @ObservedObject var searchVM = SearchRepository()
    @State private var medias : [Media] = []
    var maxCount = 14
    @State private var mediaPickerMode = MediaPickerMode.albums
    @State var showPlayerView : Bool = false
    @State var data : Data = Data()
    @State var urlString = ""
    let columns = [GridItem(.flexible(), spacing: 1),
                   GridItem(.flexible(), spacing: 1),
                   GridItem(.flexible(), spacing: 1)]
    
    var body: some View {
        ZStack{
            VStack{
                
                HStack{
                    Spacer()
                    SearchBar(text: $searchVM.searchText, placeholder: "search for friends and groups", onSubmit: {
                        print("submitted")
                    })
                    
                    Spacer()
                   
                }.padding(.top,50).frame(width: UIScreen.main.bounds.width)
                
                Spacer()
             
                
            }
        }
        
//     .overlay{
//            if self.showPlayerView{
//                NavigationLink(destination: Video(player: AVPlayer(url: URL(string: "https://file-examples.com/storage/fefe3c760763a87999556e8/2017/04/file_example_MP4_480_1_5MG.mp4")!)), isActive: $showPlayerView) {
//                EmptyView()
//            }
//            }
//        }
        
    }
}


//Button(action:{
//    self.showMediaPicker.toggle()
//},label:{
//    Text("Show Media")
//}).sheet(isPresented: $showMediaPicker) {
//    CustomizedMediaPicker(isPresented: $showMediaPicker,
//                          mediaPickerMode: $mediaPickerMode, medias: $medias, maxCount: maxCount)
//}
//
//if !medias.isEmpty{
//    Section {
//        LazyVGrid(columns: columns, spacing: 1) {
//            ForEach(medias) { media in
//                    Button(action:{
//
//                        let dp = DispatchGroup()
//                        dp.enter()
//
//                        Task{
//                               self.data =  await media.getData() ?? Data()
//
//                        }
//                        dp.leave()
//                        dp.notify(queue: .main, execute:{
//                            guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
//                            url.appendPathExtension("mp4")
//                         do { try data.write(to: url)} catch {print("Failed")}
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//                                print("url: \(url.absoluteString)")
//                                self.urlString = url.absoluteString
//                                showPlayerView.toggle()
//                            })
//
//
//                        })
//
//
//
//                    },label:{
//                        MediaCell(media: media)
//                            .aspectRatio(1, contentMode: .fill)
//
//                    })
//
//
//
//            }
//        }
//    }
//}

struct MediaCell: View {
    
    var media: Media
    @State var url: URL?
    
    var body: some View {
        
//        GeometryReader { g in
//            if let url = url {
//                AsyncImage(
//                    url: url,
//                    content: { image in
//                        image.resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: g.size.width, height: g.size.width)
//                            .clipped()
//                    },
//                    placeholder: {
//                        ProgressView()
//                    }
//                )
//            }
//        }
        Text("Media")
        .task {
            url = await media.getUrl()
        }
    }
}



struct CustomizedMediaPicker: View {
    
    
    @Binding var isPresented: Bool
    @Binding var mediaPickerMode: MediaPickerMode
    @Binding var medias: [Media]
    
    @State private var selectedMedia: [Media] = []
    @State private var albums: [Album] = []
    
    @State private var showAlbumsDropDown: Bool = false
    @State private var selectedAlbum: Album?
    
    var maxCount: Int
    
    
    
    var body: some View {
        VStack {
            
            
            MediaPicker(
                isPresented: $isPresented,
                limit: maxCount,
                onChange: { selectedMedia = $0 }
            )
            .albums($albums)
            .pickerMode($mediaPickerMode)
            .selectionStyle(.count)
            .mediaPickerTheme(
                main: .init(
                    background: Color("Background")
                ),
                selection: .init(
                    emptyTint: .white,
                    emptyBackground: .black.opacity(0.25),
                    selectedTint: Color("AccentColor")
                )
            ).padding(.top,5)
            
            
            Spacer()
            
            footerView
        }
        .background(Color("Background"))
        .foregroundColor(FOREGROUNDCOLOR)
    }
    
    
    
    var footerView: some View {
        HStack {
            Button {
                isPresented = false
            } label: {
                Text("Cancel")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button {
                medias = selectedMedia
                isPresented = false
            } label: {
                HStack {
                    Text("Add")
                    
                    Text("\(selectedMedia.count)")
                    
                }
                .font(.headline)
                
            }.padding(10).padding(.horizontal)
                .background {
                    Color("AccentColor")
                        .cornerRadius(16)
                }
        }
        .padding(.horizontal)
    }
    
    var albumsDropdown: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(albums) { album in
                    Button(album.title ?? "") {
                        selectedAlbum = album
                        mediaPickerMode = .album(album)
                        showAlbumsDropDown = false
                    }
                }
            }
            .padding(15)
        }
        .frame(maxHeight: 300)
    }
}

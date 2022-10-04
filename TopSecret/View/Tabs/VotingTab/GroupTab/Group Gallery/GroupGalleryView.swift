//
//  GroupGalleryView.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/30/22.
//

import SwiftUI
import Photos
import MediaCore
import MediaSwiftUI



struct GroupGalleryView: View {
    
    @State var isShowingPhotoPicker = false
    @State var selectedImages : [UIImage] = []
    @StateObject var groupGalleryVM = GroupGalleryViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @State var openImageToEdit : Bool = false
    @State var selectedImageToEdit : GroupGalleryImageModel = GroupGalleryImageModel()
    @StateObject var searchRepository = SearchRepository()
    @State var readyToPost : Bool = false
    
    let columns : [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
        
        
    ]
    
    var body: some View {
        
        
        ZStack{
            Color("Background")
            VStack{
                
                
                
                HStack{
                    
                    Button(action:{
                        self.isShowingPhotoPicker.toggle()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "lock").font(.headline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading).padding(.trailing,0)
                    
                    
              
                    
                    SearchBar(text: $searchRepository.searchText, placeholder: "Gallery", onSubmit: {})
                    
                       
                    
                    
                    Button(action:{
                        self.isShowingPhotoPicker.toggle()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "photo.on.rectangle.angled").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.trailing)
                    
                }.padding(.top).padding(.bottom,10)
                
           
                Spacer()
                
                
                //Gallery
                
                    
                  
                        
                        if !groupGalleryVM.retrievedImages.isEmpty{
                            ScrollView(showsIndicators: false){
                            LazyVGrid(columns: columns, spacing: 1) {
                                ForEach(groupGalleryVM.retrievedImages, id: \.id){ image in
                                    Button(action:{
                                        self.selectedImageToEdit = image
                                        withAnimation(.spring()){
                                            self.openImageToEdit.toggle()
                                        }
                                    },label:{
                                        
                                        Image(uiImage: image.image ?? UIImage(named: "Icon")!)
                                            .resizable()
                                            .frame(width: UIScreen.main.bounds.width/3, height: 150)
                                            .aspectRatio(contentMode: .fit)
                                            .overlay(Rectangle().stroke(Color("Background"), lineWidth: 2))
                                    }).fullScreenCover(isPresented: $openImageToEdit) {
                                        
                                    } content: {
                                        EditGalleryImageView(galleryImage: $selectedImageToEdit)
                                    }

                                    
                                }
                            }
                        }
                        }
                        
                    
                    
                    
                
                
                
                
                
            }
            


        }.onAppear{
            DispatchQueue.main.async {
                groupGalleryVM.fetchPhotos(userID: userVM.user?.id ?? " ", groupID: selectedGroupVM.group?.id ?? " ")
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).sheet(isPresented: $isShowingPhotoPicker) {
                
            for image in selectedImages {
                groupGalleryVM.uploadPhoto(image: image, userID: userVM.user?.id ?? " ", group: selectedGroupVM.group ?? Group())
                print("uploaded")
            }
            
        } content: {
            GroupGalleryPhotoPicker(selectedImages: $selectedImages, picker: $isShowingPhotoPicker, readyToPost: $readyToPost)
        }
        
        
        
        
    }
}





struct EditGalleryImageView : View {
    
    @Binding var galleryImage : GroupGalleryImageModel
    @Environment(\.presentationMode) var presentationMode
    let imageSaver = ImageSaver()
    
    var body: some View {
        GeometryReader { geo in
            ZStack{
                Image(uiImage: galleryImage.image ?? UIImage(named: "Icon")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                
                VStack{
                    HStack{
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                            }
                        }).padding(.leading)
                        
                        Button(action:{
                            imageSaver.writeToPhotoAlbum(image: galleryImage.image ?? UIImage(named: "Icon")!)
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: "square.and.arrow.up").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                            }
                        })
                        
                        
                        
                        Spacer()
                    }.padding(.top,50)
                    Spacer()
                }
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
  
        
    }
}

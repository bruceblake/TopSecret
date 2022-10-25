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
import PhotosUI




struct GroupGalleryView: View {
    
    @StateObject var groupGalleryVM = GroupGalleryViewModel()
    @State var images : [UIImage] = []
    @State var picker = false
    @StateObject var imagePickerVM = ImagePickerViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var openImageToEdit : Bool = false
    @State var selectedImageToEdit : GroupGalleryImageModel = GroupGalleryImageModel()
    @StateObject var searchRepository = SearchRepository()
    @State var readyToPost : Bool = false
    @State var selectedOptionIndex : Int = 0
    
    let columns : [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
        
        
    ]
    
    var options = ["All","Favorites","Videos","Screenshots","Photos"]
    
    var body: some View {
        
        
        ZStack{
            Color("Background")
            VStack{
                
                
                
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "chevron.left").font(.headline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading).padding(.trailing,0)
                    
                    Spacer()
              
                    
                    Text("\(selectedGroupVM.group.groupName)'s Gallery")
                       
                    Spacer()
                    
                    Button(action:{
                        self.picker.toggle()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.trailing).sheet(isPresented: $picker){
                        MultipleAssetPicker(images: $images, picker: $picker, userID: userVM.user?.id ?? " ", groupGalleryVM: groupGalleryVM)
                    }
                    
                }.padding(.top,50)
                
                    ScrollView(.horizontal){
                        HStack{
                        ForEach(options.indices){ index in
                            
                            Spacer()
                            
                                Button(action: {
                                    selectedOptionIndex = index
                                },label:{
                                    Text("\(options[index])").foregroundColor(selectedOptionIndex == index ? Color("AccentColor") : FOREGROUNDCOLOR)
                                })
                            
                           
                        
                        }
                        }
                }
                
                if selectedOptionIndex == 0 {
                    ScrollView(showsIndicators: false){
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(groupGalleryVM.retrievedImages, id: \.id){ image in
                            Button(action:{
                                self.openImageToEdit.toggle()
                                self.selectedImageToEdit = image
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
                }else if selectedOptionIndex == 1 {
                    
                }else if selectedOptionIndex == 2 {
                    
                }
                else if selectedOptionIndex == 3 {
                    
                }else if selectedOptionIndex == 4 {
                    
                }
                
                //Gallery
                
                    
                  
                        
                           
                        
                        
                    
                    
                    
                
                
                
                
                
            }
            


        }.onAppear{
            DispatchQueue.main.async {
                groupGalleryVM.fetchPhotos(userID: userVM.user?.id ?? " ", groupID: selectedGroupVM.group.id)
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
        
        
        
    }
}


struct MultipleAssetPicker : UIViewControllerRepresentable {
    
    
    func makeCoordinator() -> Coordinator {
        return MultipleAssetPicker.Coordinator(parent1: self)
    }
    
    @Binding var images: [UIImage]
    @Binding var picker : Bool
    var userID: String
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @StateObject var groupGalleryVM : GroupGalleryViewModel
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        
        config.selectionLimit = 0
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    
    
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        var parent : MultipleAssetPicker
        
        init(parent1: MultipleAssetPicker){
            parent = parent1
        }
        
        
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            parent.picker.toggle()
            for img in results {
                
                if img.itemProvider.canLoadObject(ofClass: UIImage.self){
                    
                    img.itemProvider.loadObject(ofClass: UIImage.self) { image, err in
                        guard let image1 = image else {
                            print(err)
                            return
                        }
                        
                        
                        self.parent.images.append(image1 as! UIImage)
                        self.parent.groupGalleryVM.uploadPhoto(image: image1 as! UIImage, userID: self.parent.userID, group: self.parent.selectedGroupVM.group)
                    }
                }else{
                    print("Cannot be loaded")
                }
            }
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

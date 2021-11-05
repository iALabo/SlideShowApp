//
//  SaveModal.swift
//  SlideShowApp
//
//  Created by 坂田直也 on 2021/07/28.
//

import SwiftUI
import PhotosUI

struct SaveModal: View {
    @ObservedObject var imageData: ImageData
    @ObservedObject var album: albumProparties
    @Binding var isSave: Bool
    
    @State var SelectPHAsset: PHAsset = PHAsset()
    @State var picker: Bool = false
    @State var Name: String = ""
    
    init(imageData: ImageData, album: albumProparties, isSave: Binding<Bool>)
    {
        self.imageData = imageData
        self.album = album
        self._isSave = isSave
        if(imageData.items.count > 0){
            _SelectPHAsset = State(initialValue: imageData.items[0].phassets)
        }
    }
    
    var body: some View {
        NavigationView{
        VStack{
            
            Spacer()
            ScrollView{
            VStack{
                                        
                VStack{
                    Text("TitleImage")
                    Button(action: {
                        picker.toggle()
                    }, label: {
                        Image(uiImage: getAssetThumbnail(asset: SelectPHAsset))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 500)
                    })
                    .sheet(isPresented: $picker, content: {
                        ImagePicker_single(didFinishPicking: {_ in (() -> Void).self; picker = false}, image: $SelectPHAsset, picker: $picker)
                    })
                }
                
                VStack{
                    
                    TextField("AlbumName", text: $Name)
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .padding(.top, 20)
                    
                    Text("Please Write Name")
                        
                }
            }
            
            Spacer()
            
            Button {
                
                album.append(item: albumStatus(ins_image: imageDataToArray(), ins_title: SelectPHAsset, ins_name: Name))
                
                isSave = false
            } label: {
                Text("Save")
                    .foregroundColor(.black)
                    .padding(.vertical, 10.0)
                    .padding(.horizontal, 35.0)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.bottom, 15.0)
            }

        }
        .navigationBarItems(leading:
            Button(action: {
                isSave = false
            }, label: {
                Image(systemName: "xmark")
            }))
        }
        }
    }
    
    func imageDataToArray() -> [PHAsset]
    {
        var images: [PHAsset] = []
        imageData.items.forEach{
            item in
            images.append(item.phassets)
        }
        
        return images
    }
}

struct SaveModal_Previews: PreviewProvider {
    static var previews: some View {
        SaveModal(imageData: ImageData(), album: albumProparties(), isSave: .constant(false))
    }
}



struct ImagePicker_single : UIViewControllerRepresentable {
    var didFinishPicking: (_ didSelectItem: Bool) -> Void
    @Binding var image: PHAsset
    @Binding var picker: Bool
    

    
    func makeCoordinator() -> Coordinator {
        return ImagePicker_single.Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        
        // 静止画を選択
        configuration.filter = .images
        // 複数選択可能（上限枚数なし）
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject,PHPickerViewControllerDelegate {
        var parent: ImagePicker_single
        
        
        init(parent: ImagePicker_single) {
            self.parent = parent
        }
        
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.didFinishPicking(!results.isEmpty)
            
            guard !results.isEmpty else {
                return
            }
            
            let identifiers = results.compactMap(\.assetIdentifier)
            let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
            
            /*
            fetchResult.enumerateObjects({ asset, _, _ in
                self.parent.image = asset
            })
 */
            if fetchResult.count > 0{
                self.parent.image = fetchResult.objects(at: IndexSet(0...fetchResult.count - 1))[0]
            }
            parent.picker = false
            
        }
    }
}

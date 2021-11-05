//
//  ImagePicker.swift
//  SlideShowApp
//
//  Created by 坂田直也 on 2021/07/20.
//

import SwiftUI
import PhotosUI

struct ImagePicker : UIViewControllerRepresentable {
    var didFinishPicking: (_ didSelectItem: Bool) -> Void
    @ObservedObject var imageData: ImageData
    @Binding var picker: Bool 
    

    
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        
        // 静止画を選択
        configuration.filter = .images
        // 複数選択可能（上限枚数なし）
        configuration.selectionLimit = 0
        configuration.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject,PHPickerViewControllerDelegate {
        var parent: ImagePicker
        var images: [UIImage] = []
        var phasset: [PHAsset] = []
        var localIdentifer: [String] = []
        
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        private func getPhoto(from itemProvider: NSItemProvider) {
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) {
                    object, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
         
                    if let image = object as? UIImage {
                        self.images.append(image)
                    }
                }
            }
 
        }
        
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.didFinishPicking(!results.isEmpty)
            guard !results.isEmpty else {
                return
            }
            
            //guard let provider = results.first?.itemProvider else { return }
            //guard let typeIdentifer = provider.registeredTypeIdentifiers.first else { return }
            
            let identifiers = results.compactMap(\.assetIdentifier)
            
            
            for i in 0..<identifiers.count{
                let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: [identifiers[i]], options: nil)
                self.phasset.append(fetchResult[0])
                self.localIdentifer.append(fetchResult[0].localIdentifier)
                self.images.append(self.getAssetThumbnail(asset: fetchResult[0]))
            }
            
            /*
            for result in results {
                self.getPhoto(from: result.itemProvider)
            }
            */
            
            for i in 0..<phasset.count
            {
                parent.imageData.append(item: ImageAttribute(ins_phasset: phasset[i], ins_image: images[i], ins_isPressed: false, ins_isSelect: false, ins_localidentifer: localIdentifer[i]))
            }
            
            parent.picker = false
            //getPhoto_PhAsset()
            
        }
        
        func getAssetThumbnail(asset: PHAsset) -> UIImage {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var thumbnail = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
            })
            return thumbnail
        }
        
    }
}

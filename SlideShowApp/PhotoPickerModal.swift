//
//  PhotoPickerModal.swift
//  SlideShowApp
//
//  Created by 坂田直也 on 2021/07/25.
//

import SwiftUI
import Photos


//-----------------------------------------------------------------------------------------------

struct ImageAttribute{
    var phassets: PHAsset = PHAsset()
    var image: UIImage = UIImage()
    var isPressed: Bool = false
    var isSelect: Bool = false
    var localidentifer: String = ""
    
    init(ins_phasset: PHAsset, ins_image: UIImage, ins_isPressed: Bool, ins_isSelect: Bool, ins_localidentifer: String)
    {
        self.phassets = ins_phasset
        self.image = ins_image
        self.isPressed = ins_isPressed
        self.isSelect = ins_isSelect
        self.localidentifer = ins_localidentifer
    }
}

class ImageData: ObservableObject{
    @Published var items = [ImageAttribute]()
    
    func append(item: ImageAttribute) {
        items.append(item)
    }
    
    
}

//----------------------------------------------------------------------------------------------

struct albumStatus: Equatable{
    static func == (lhs: albumStatus, rhs: albumStatus) -> Bool {
        return lhs.isSelect == rhs.isSelect && lhs.Name == rhs.Name
    }
    
    var titleImage: PHAsset? = PHAsset()
    var Name: String?
    var isSelect: Bool? = false
    @ObservedObject var images = Images()
    
    init(ins_image: [PHAsset], ins_title: PHAsset, ins_name: String)
    {
        self.titleImage = ins_title
        self.Name = ins_name
        
        ins_image.forEach{
            image in
            images.append(item: image_propaties(ins_image: image))
        }
    }
    
    func isFault() -> Bool
    {
        if titleImage == nil && Name == nil && isSelect == nil{
            return true
        }
        else{
            return false
        }
    }
    
}

class albumProparties: ObservableObject{
    @Published var items: [albumStatus]? = [albumStatus]()
    
    func append(item: albumStatus) {
        items!.append(item)
    }
    
    
    func remove(at: Int)
    {
        self.items!.remove(at: at)
        /*
        if let index = self.items.firstIndex(of: items[at]){
            self.items.remove(at: index)
        }
 */
    }
 
}

//----------------------------------------------------------------------------------------------
struct image_propaties: Equatable{
    var image: PHAsset = PHAsset()
    
    init(ins_image: PHAsset)
    {
        self.image = ins_image
    }
}

class Images: ObservableObject{
    @Published var items = [image_propaties]()
    
    func append(item: image_propaties) {
        items.append(item)
    }
}

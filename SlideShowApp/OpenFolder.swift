//
//  OpenFolder.swift
//  SlideShowApp
//
//  Created by 坂田直也 on 2021/07/28.
//

import SwiftUI
import Photos

struct OpenFolder: View {
    @ObservedObject var imageData: ImageData
    @ObservedObject var albums: albumProparties
    @Binding var isOpen: Bool
    @Binding var CurrentAlbum: Int
    
    @State var albumName: [String] = []
    @State var isTrash: Bool = false
    
    
    
    init(ins_imageData: ImageData ,ins_albums: albumProparties, isOpen: Binding<Bool>, ins_CurrentAlbum: Binding<Int>)
    {
        albums = ins_albums
        imageData = ins_imageData
        _isOpen = isOpen
        _CurrentAlbum = ins_CurrentAlbum
    }
    
    var body: some View {

            NavigationView{
                ScrollView{
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))]) {
                        ForEach(Array(self.albums.items!.enumerated()), id: \.offset){
                            index, album in
                            VStack{
                                Button(action: {

                                    if isTrash == false{
                                        self.imageData.items.removeAll()
                                        album.images.items.forEach{
                                            image in
                                            
                                            imageData.append(item: ImageAttribute(ins_phasset: image.image, ins_image: getAssetThumbnail(asset: image.image), ins_isPressed: false, ins_isSelect: false, ins_localidentifer: image.image.localIdentifier))
                                        }
                                        CurrentAlbum = index
                                        isOpen = false
                                    }
                                    else{
                                        self.albums.items![index].isSelect!.toggle()
                                    }
                                    
                                }, label: {
                                    ZStack(alignment: .bottomTrailing){
                                        Image(uiImage: getAssetThumbnail(asset: album.titleImage!))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 250, height: 250)
                                            .cornerRadius(25)
                                            .colorMultiply(album.isSelect! ? Color.gray : Color.white)
                                    
                                    
                                        if isTrash == true{
                                            Image(systemName: "checkmark.circle")
                                                .resizable()
                                                .frame(width: 250/5, height: 250/5)
                                                .cornerRadius(25)
                                                .foregroundColor(album.isSelect! ? Color.blue : Color.gray.opacity(0.5))
                                                
                                        }
                                        
                                    }
                                    .padding(50)

                                })
                                
                                Text(album.Name!)
                                .multilineTextAlignment(.center)
                                .font(.title)
                                .padding(.top, 15)

                            }
                        }
                    }
                }
                .navigationTitle("AlbumOpen")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: HStack{
                    Button(action: {
                        isOpen = false
                    }, label: {
                        Image(systemName: "xmark")
                    })
                    if(isTrash == false)
                    {
                        Button(action: {
                            isTrash = true
                        }, label: {
                            Image(systemName: "trash")
                        })
                    }
                    else{
                        Button(action: {
                            removeSelectalbum()
                            isTrash = false
                            
                        }, label: {
                            Text("Remove")
                        })
                    }
                })
            }
            
        
    }
    
    func removeSelectalbum()
    {
        for i in (0..<self.albums.items!.count).reversed(){
            if self.albums.items![i].isSelect == true
            {
                if let index = self.albums.items!.firstIndex(of: albums.items![i]){
                    self.albums.remove(at: index)
                }
            }
        }
    }
    
}

struct OpenFolder_Previews: PreviewProvider {
    static var previews: some View {
        OpenFolder(ins_imageData: ImageData() ,ins_albums: albumProparties(), isOpen: .constant(false), ins_CurrentAlbum: .constant(0))
    }
}


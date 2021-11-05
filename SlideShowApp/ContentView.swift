//
//  ContentView.swift
//  SlideShowApp
//
//  Created by 坂田直也 on 2021/07/20.
//

import SwiftUI
//import URLImage
import Photos
//import Foundation
extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
extension View {
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

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @State var picker = false
    @State var Start = false
    
    @AppStorage("Random_Bool") var Random: Bool = true
    @AppStorage("WaitTime_Float") private var WaitTime: Double = 180
    @AppStorage("WaitEdit_String") var WaitEdit: String = "180"
    @AppStorage("LastLocalIdentifer_[String]")var LastLocalIdentifer: [String] = []
    @AppStorage("SavedLocalIdentifer_[[String]]") var SavedLocalIdentifer: [[String]] = [[]]
    @AppStorage("SavedLINames_[String]") var SavedLINames: [String] = []
    @AppStorage("SavedTitleImages_[String]") var SaveTitleImages: [String] = []
    
    @EnvironmentObject var model: Model
    
    weak var countLabel: UILabel!
    var time = 5
    var timer = Timer()
    
    @State var isTrash: Bool = false
    @State var isOpen: Bool = false
    @State var isSave: Bool = false
    @State var buttons: [UIButton] = []
    @State var screenSize_w: CGFloat = 0
    @State var screenSize_h: CGFloat = 0
    @AppStorage("LastAlbumNumber_Int") var CurrentAlbum: Int = 0
    
    @ObservedObject var imageData = ImageData()
    @ObservedObject var albums = albumProparties()
    
    
    init()
    {
        localIdentiferToimageData()
        localIdentiferToalbums()
        _screenSize_w = State(initialValue: UIScreen.main.bounds.size.width)
        _screenSize_h = State(initialValue: UIScreen.main.bounds.size.height)
    }
    
    var body: some View {
        NavigationView {
            
            VStack {
                //Spacer()
                

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: screenSize_h/5))]) {

                        ForEach(Array(imageData.items.enumerated()), id: \.offset) {
                            index, data in
                            Button(action: {
                                if isTrash == false{
                                    imageData.items[index].isPressed = true
                                }
                                else{
                                    imageData.items[index].isSelect.toggle()
                                }
                            },
                            label: {
                                ZStack(alignment: .bottomTrailing){
                                    if isStarted(){
                                        Image(uiImage: (data.image))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: screenSize_h/5, height: screenSize_h/5)
                                                .cornerRadius(screenSize_h/50)
                                                .colorMultiply(imageData.items[index].isSelect ? Color.gray : Color.white)
                                        
                                        
                                        if isTrash == true{
                                            Image(systemName: "checkmark.circle")
                                                .resizable()
                                                .frame(width: screenSize_h/25, height: screenSize_h/25)
                                                .cornerRadius(screenSize_h/50)
                                                .foregroundColor(imageData.items[index].isSelect ? Color.blue : Color.gray.opacity(0.5))
                                                
                                        }
                                    }
                                }
                                .onChange(of: scenePhase){
                                    scene in
                                    switch scene{
                                    case .active: break
                                        
                                    case .inactive:
                                        LastLocalIdentifer = SaveLocalIdentifer()
                                        SaveAlbums()
                                        break
                                            
                                    case .background: break
                                        
                                    @unknown default: break
                                    }
                                }
                            })
                            .sheet(isPresented: $imageData.items[index].isPressed, content: {
                                if index < imageData.items.count{
                                    ImageModal(image: imageData.items[index].image, isPressed: $imageData.items[index].isPressed)
                                }
                            })
                        }
                        
                    }
 
                }
                
                
                Spacer()
                
                HStack{
                    
                    Button(action: {
                        picker.toggle()
                    }) {
                        Text("Select")
                            .foregroundColor(.white)
                            .padding(.vertical, 10.0)
                            .padding(.horizontal, 35.0)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                    .padding([.leading, .bottom, .trailing], 16.0)
                        
                    VStack {
                        HStack{
                            Text("WaitTime")
                            
                            TextField("", text: Binding(
                                    get: {WaitEdit},
                                    set: {WaitEdit = $0.filter{"0123456789".contains($0)}})
                                    ,onEditingChanged:
                                    {begin in
                                    
                                    if begin{

                                    }
                                    else{
                                        //WaitTime = NSString(string: WaitEdit).floatValue
                                    }
                                    
                            })
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: WaitEdit, perform: { value in
                                WaitTime = NSString(string: WaitEdit).doubleValue
                            })
                            
                        }
                        Slider(value: Binding(get: {
                            self.WaitTime
                        }, set: { (newVal) in
                            self.WaitTime = newVal
                            self.sliderChanged()
                        }), in: 0...180)
                            .padding([.leading, .bottom, .trailing], 16.0)
                    }
                    
                    VStack{
                        Text("Random")
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        Toggle(isOn: $Random) {
                            Text(Random ? "ON" : "OFF")
                        }
                        .padding([.leading, .bottom, .trailing], 16.0)
                    }
                    
                    
                    
                    NavigationLink(
                        destination: SlideShowView(imageData: imageData, WaitTime: WaitTime, Random: Random)
                    )
                    {
                        Text("Start")
                            .foregroundColor(!isStarted() ? Color.black : Color.white)
                            .padding(.vertical, 10.0)
                            .padding(.horizontal, 35.0)
                            .background(!isStarted() ? Color.gray : Color.pink)
                            .clipShape(Capsule())
                            .padding([.leading, .bottom, .trailing], 16.0)
                    }
                    .disabled(!isStarted())
 
                }
                .padding(.bottom)
                
                .sheet(isPresented: $picker, content: {
                    // Pickerを開く
                    ImagePicker(didFinishPicking: {_ in (() -> Void).self; picker = false} , imageData: imageData, picker: $picker)
                })
                
            }
            .navigationBarTitle("Shuffle Croquis")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: HStack{
                
                if isTrash == false{
                    ZStack{
                        Button(action: {
                            isTrash = true
                        }, label: {
                            Image(systemName: "trash")
                                .frame(alignment: .leading)
                        })

                        Button(action: {
                            isTrash = false
                            RemoveImages()
                        }, label:{
                            Text("Remove")
                                .frame(alignment: .leading)
                        })
                        .hidden()
                    }
                    Button(action: {
                        isTrash.toggle()
                    }, label:{
                        Text("Reset")
                            .padding(.leading, 18.0)
                    })
                    .hidden()
                }
                else{
                    ZStack{
                        Button(action: {
                            isTrash = true
                        }, label: {
                            Image(systemName: "trash")
                                .frame(alignment: .leading)
                        })
                        .hidden()
                        
                        Button(action: {
                            isTrash = false
                            RemoveImages()
                        }, label:{
                            Text("Remove")
                                .frame(alignment: .leading)
                        })
                        
                    }
                    Button(action: {
                        imageData.items.removeAll()
                        isTrash.toggle()
                    }, label:{
                        Text("Reset")
                            .padding(.leading, 18.0)
                    })
                }
                
            }, trailing: HStack{
                Button(action: {
                    isOpen.toggle()
                }, label: {
                    Text("Open")
                })
                .sheet(isPresented: $isOpen, onDismiss: {
                    LastLocalIdentifer = SaveLocalIdentifer()
                    SaveAlbums()
                }){
                    OpenFolder(ins_imageData: imageData, ins_albums: albums, isOpen: $isOpen, ins_CurrentAlbum: $CurrentAlbum)
                }
                
                Button(action: {
                    LastLocalIdentifer = SaveLocalIdentifer()
                    SaveCurrentAlbum()
                }, label: {
                    Text("Save")
                })
                
                Button(action: {
                    isSave.toggle()
                }, label: {
                    Text("New")
                })
                .sheet(isPresented: $isSave, onDismiss: {
                    LastLocalIdentifer = SaveLocalIdentifer()
                    SaveAlbums()
                }){
                    SaveModal(imageData: imageData ,album: albums, isSave: $isSave)
                }
            })

        }
        .navigationViewStyle(StackNavigationViewStyle())
 
        
    }
    
    func isStarted() -> Bool
    {
        var isStart = false
        if imageData.items.count > 0{
            if imageData.items[0].image == UIImage(systemName: "plus.circle"){
                return false
            }
            
            isStart = true
        }
        else{
            isStart = false
        }
        
        return isStart
    }
    func sliderChanged() {
        WaitEdit = NSString(format: "%u", Int(WaitTime)) as String
    }
    
    func RemoveImages()
    {
        for i in (0..<imageData.items.count).reversed(){
            if imageData.items[i].isSelect == true && imageData.items.count > i{
                imageData.items.remove(at: i)
            }
        }
    }
    
    func localIdentiferToimageData()
    {
        var assets: [PHAsset] = []
        
        var Number: Int = 0
        //let phResult = PHAsset.fetchAssets(withLocalIdentifiers: LastLocalIdentifer, options: nil)
        /*
        phResult.enumerateObjects({ asset, _, _ in
                assets.append(asset)
        })
 */
        assets.removeAll()
        for i in 0..<LastLocalIdentifer.count {
            let phResult = PHAsset.fetchAssets(withLocalIdentifiers: [LastLocalIdentifer[i]], options: nil)
            assets.append(phResult[0])
        }
        //var num: Int = assets.count
        //assets = Array(assets.reversed())
        if LastLocalIdentifer.count > 0{
            assets.forEach {
                ass in
                imageData.append(item: ImageAttribute(ins_phasset: ass, ins_image: getAssetThumbnail(asset: ass), ins_isPressed: false, ins_isSelect: false, ins_localidentifer: LastLocalIdentifer[Number]))
                Number += 1
            }
        }
    }
    
    mutating func localIdentiferToalbums()
    {
        var ins_images: [[PHAsset]] = [[]]
        var ins_title: [PHAsset]?
        ins_images.removeAll()
        self.SavedLocalIdentifer.forEach {
            album in
            
            ins_images.append(localIdentiferToPHAsset(localIdentifer: album))
        }
        ins_title = localIdentiferToPHAsset(localIdentifer: SaveTitleImages)
        //var num: Int = ins_images.count
        for i in 0..<ins_title!.count{
            albums.append(item: albumStatus(ins_image: ins_images[i], ins_title: ins_title![i], ins_name: SavedLINames[i]))
        }
    }
    
    func localIdentiferToPHAsset(localIdentifer: [String]) -> [PHAsset]
    {
        var assets: [PHAsset] = []
        //let phResult = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifer, options: nil)
        /*
        phResult.enumerateObjects({ asset, _, _ in
                assets.append(asset)
        })
        */
        assets.removeAll()
        
        for i in 0..<localIdentifer.count {
            let phResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifer[i]], options: nil)
            assets.append(phResult[0])
        }
    

        return assets

    }
    
    func SaveLocalIdentifer() -> [String]
    {
        var ins_localIdentifer: [String] = []
        imageData.items.forEach{
            item in
            ins_localIdentifer.append(item.localidentifer)
        }
        
        return ins_localIdentifer
    }
    
    func SaveCurrentAlbum()
    {

        var ins_images: [PHAsset] = []
        var ins_local: [String] = []
        ins_images.removeAll()
        ins_local.removeAll()
        imageData.items.forEach{
            item in
            ins_images.append(item.phassets)
            ins_local.append(item.localidentifer)
        }
            
        albums.items![CurrentAlbum] = albumStatus(ins_image: ins_images, ins_title: albums.items![CurrentAlbum].titleImage!, ins_name: albums.items![CurrentAlbum].Name!)
        //var num: Int = CurrentAlbum
        SavedLocalIdentifer[CurrentAlbum] = ins_local
    }
    
    func SaveAlbums()
    {
        var ins_SavedLocalIdentifer: [[String]] = [[]]
        var ins_titleimage: [String] = []
        var ins_names: [String] = []
        ins_SavedLocalIdentifer.removeAll()
        albums.items!.forEach{
            item in
        
            var ins_ImageLocalIdentifer: [String] = []
            
            item.images.items.forEach{
                image in
                ins_ImageLocalIdentifer.append(image.image.localIdentifier)
            }
            ins_SavedLocalIdentifer.append(ins_ImageLocalIdentifer)
            ins_titleimage.append(item.titleImage!.localIdentifier)
            ins_names.append(item.Name!)
        }
        //var num: Int = ins_SavedLocalIdentifer.count
        //var num2: Int = ins_titleimage.count
        SavedLocalIdentifer = ins_SavedLocalIdentifer
        SaveTitleImages = ins_titleimage
        SavedLINames = ins_names
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//githubで公開

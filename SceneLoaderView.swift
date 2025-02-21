//
//  SceneLoaderView.swift
//  DingDong
//
//  Created by Minh Huynh on 2/18/25.
//

import SwiftUI
import FirebaseStorage
import SceneKit

struct RoomLoaderView: View {
    @StateObject var sceneLoader = SceneLoader()
    @State var scene: SCNScene?
    @State var isGeneratedFirstTime = true
    @State var isGenerating = false
    @State var sceneView: RoomModelView?
    @State var isAutoEnablesDefaultLighting = true
    
    @StateObject var viewModel = ProductViewModel()
    
    var showOverlayOptions = true
//    let fileRef: StorageReference
    let url: URL?
    
    //    let chairModelURL = Bundle.main.url(forResource: "bisou-accent-chair", withExtension: "usdz")
    let chairModelURL = Bundle.main.url(forResource: "cullen-shiitake-dining-chair", withExtension: "usdz")
    //    let chairModelURL = Bundle.main.url(forResource: "68809180-ec29-bd3b-ef5c-b1b41b277823", withExtension: "glb")
    let tableModelURL = Bundle.main.url(forResource: "monarch-shiitake-dining-table", withExtension: "usdz")
    //    let storageModelURL = Bundle.main.url(forResource: "501439_West Natural Cane Bar Cabinet", withExtension: "usdz")
    let storageModelURL = Bundle.main.url(forResource: "annie-whitewashed-wood-storage-bookcase-with-shelves-by-leanne-ford", withExtension: "usdz")
//    let storageModelURL = Bundle.main.url(forResource: "elias-natural-elm-wood-open-bookcase", withExtension: "usdz")
    let doorModelURL = Bundle.main.url(forResource: "door", withExtension: "usdz")
    let televisionModelURL = Bundle.main.url(forResource: "television", withExtension: "usdz")
    let doorImage = UIImage(named: "door-white.png")
    let windowImage = UIImage(named: "window_PNG17640.png")
    
    let floorResource = MaterialResource(diffuse: UIImage(named: "concrete-floor.jpg"))
    let wallResource = MaterialResource(
        diffuse: UIImage(named: "CeramicPlainWhite001_COL_2K.jpg"),
        normal: UIImage(named: "CeramicPlainWhite001_NRM_2K.png"),
        gloss: UIImage(named: "CeramicPlainWhite001_GLOSS_2K.jpg"),
        reflection: UIImage(named: "CeramicPlainWhite001_REFL_2K.jpg")
    )
//        metalness: UIImage(named: "PlasterPlain001_METALNESS_1K_METALNESS.png"),
//        roughness: UIImage(named: "PlasterPlain001_ROUGHNESS_1K_METALNESS.png"))
    
    var body: some View {
        if let _ = sceneLoader.scene {
            ZStack {
                sceneView
                    .edgesIgnoringSafeArea(.all)
                if showOverlayOptions {
                    overlayOptionsView
                }
            }
            .onAppear {
//                self.sceneView = SceneView(sceneLoader: sceneLoader, isAutoEnablesDefaultLighting: $isAutoEnablesDefaultLighting)
            }
//            .customNavBar()
        } else {
            ProgressView()
                .onAppear() {
                    Task {
                        await self.sceneLoader.loadScene(from: url)
                    }
                }
        }
    }
    
    var overlayOptionsView: some View {
        GeometryReader {
            let size = $0.size
            VStack(alignment: .center) {
                Spacer()
                Button {
                    if !viewModel.products.isEmpty {
                        isGenerating = true
                        if isGeneratedFirstTime {
                            sceneView?.addLights()
                            self.isAutoEnablesDefaultLighting = false
                        }
                        sceneView?.sceneLoader.addFloor(infinity: true, from: floorResource)
                        //                        sceneView?.sceneLoader.addCeiling()
                        sceneLoader.styleWalls(with: wallResource)
                        // get local file URL
                        
                        if let product = viewModel.chairs.randomElement(), let modelURL = URL(string: product.modelURL) {
                            viewModel.downloadModelFile(from: modelURL)
                            { result in
                                switch result {
                                case .success(let localFileUrl):
                                    print(localFileUrl)
                                    DispatchQueue.main.async {
                                        sceneLoader.replaceObjects(ofType: .chair, with: localFileUrl)
                                    }
                                case .failure(let error):
                                    print("Error downloading file: \(error)")
                                }
                            }
                        }
                        if let product = viewModel.tables.randomElement(), let modelURL = URL(string: product.modelURL) {
                            viewModel.downloadModelFile(from: modelURL)
                            { result in
                                switch result {
                                case .success(let localFileUrl):
                                    print(localFileUrl)
                                    DispatchQueue.main.async {
                                        sceneLoader.replaceObjects(ofType: .table, with: localFileUrl)
                                    }
                                case .failure(let error):
                                    print("Error downloading file: \(error)")
                                }
                            }
                        }
                        if let product = viewModel.storages.randomElement(), let modelURL = URL(string: product.modelURL) {
                            viewModel.downloadModelFile(from: modelURL)
                            { result in
                                switch result {
                                case .success(let localFileUrl):
                                    print(localFileUrl)
                                    DispatchQueue.main.async {
                                        sceneLoader.replaceObjects(ofType: .storage, with: localFileUrl, scale: 1)
                                    }
                                case .failure(let error):
                                    print("Error downloading file: \(error)")
                                }
                            }
                        }
                        if let product = viewModel.beds.randomElement(), let modelURL = URL(string: product.modelURL) {
                            viewModel.downloadModelFile(from: modelURL)
                            { result in
                                switch result {
                                case .success(let localFileUrl):
                                    print(localFileUrl)
                                    DispatchQueue.main.async {
                                        sceneLoader.replaceObjects(ofType: .bed, with: localFileUrl)
                                    }
                                case .failure(let error):
                                    print("Error downloading file: \(error)")
                                }
                            }
                        }
                        //                    sceneLoader.replaceObjects(ofType: .chair, with: chairModelURL)
                        //                    sceneLoader.replaceObjects(ofType: .table, with: tableModelURL)
                        //                    sceneLoader.replaceObjects(ofType: .storage, with: storageModelURL, scale: 1)
                        
                        // Hide Doors, Windows, and TV
                        sceneLoader.sceneModel?.doorsClosed?.forEach({ door in
                            door.opacity = 0
                        })
                        sceneLoader.sceneModel?.windows?.forEach({ window in
                            window.opacity = 0
                        })
                        sceneLoader.sceneModel?.televisions?.forEach({ tv in
                            tv.opacity = 0
                        })
                        
                        //                        sceneLoader.replaceSurfaces(ofType: .door(isOpen: true), with: doorImage)
                        //                        sceneLoader.replaceSurfaces(ofType: .door(isOpen: false), with: doorImage)
                        //                        sceneLoader.replaceSurfaces(ofType: .window, with: windowImage)
                        //                        sceneLoader.replaceObjects(ofType: .television, with: televisionModelURL, scale: 0.018, onFloorLevel: false)
                        
                        isGenerating = false
                        isGeneratedFirstTime = false
                    }
                } label: {
                    if isGenerating == true {
                        ProgressView()
                    } else {
                        Text(isGeneratedFirstTime ? "Replace" : "Try Again")
                            .fontWeight(.bold)
                            .frame(width: size.width * 0.4)
                            .padding(.vertical, 15)
                            .background {
                                Capsule().fill(.secondary)
                            }
                            .disabled(isGenerating)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .onAppear(perform: {
                viewModel.getAllProducts()
            })
            .padding(20)
        }
    }
}

#Preview {
    //    NavigationStack {
    //        RoomLoaderView(fileRef: DataController.shared.storage.reference(withPath: "/usdz_files/33i3YtIe6TTzBx7uElHrNdbSq1z1/Room1.usdz"))
    //    }
    ContentView()
}


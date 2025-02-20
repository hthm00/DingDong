//
//  SceneTemplateView.swift
//  DingDong
//
//  Created by Minh Huynh on 2/19/25.
//

import SwiftUI
import FirebaseStorage
import SceneKit
import RoomPlan

struct SceneTemplateView: View {
    @StateObject var sceneLoader = SceneLoader()
    @State var scene: SCNScene?
    @State var isGeneratedFirstTime = true
    @State var isGenerating = false
    @State var sceneView: SceneView?
    @State var isAutoEnablesDefaultLighting = true
    
    @StateObject var viewModel = ProductViewModel()
    
    var showOverlayOptions = true
//    let fileRef: StorageReference
//    let url: URL?
    let url: URL? = Bundle.main.url(forResource: "Room-example", withExtension: "usdz")
    let urlRoomFurnished: URL? = Bundle.main.url(forResource: "Room-example_furnished", withExtension: "usdz")
    
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
                withAnimation(.easeIn) {
                    self.sceneView = SceneView(sceneLoader: sceneLoader, isAutoEnablesDefaultLighting: $isAutoEnablesDefaultLighting)
                }
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
                        withAnimation(.easeOut(duration: 1)) {
                            sceneView?.sceneLoader.scene?.rootNode.opacity = 0
                        }
                        Task {
                            await self.sceneLoader.loadScene(from: urlRoomFurnished, floor: floorResource)
                            let types: [CapturedRoom.Object.Category] = [.storage, .refrigerator, .stove, .bed, .sink, .washerDryer, .toilet, .bathtub, .oven, .dishwasher, .sofa, .chair, .fireplace, .television, .stairs, .table]
                            types.forEach {self.sceneLoader.animateAllNodes(ofType:$0)}
                            self.sceneLoader.animateAllNodes(ofType: .wall, onFloorLevel: false)
                            
                            if isGeneratedFirstTime {
                                self.isAutoEnablesDefaultLighting = false
                            }
                            self.sceneView?.addLights()
                            self.isGenerating = false
                            self.isGeneratedFirstTime = false
                        }
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


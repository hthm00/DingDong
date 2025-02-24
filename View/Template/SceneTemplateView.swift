//
//  SceneTemplateView.swift
//  DingDong
//
//  Created by Minh Huynh on 2/19/25.
//

import SwiftUI
import FirebaseStorage
import RealityKit
import RoomPlan
/// This package cause a crash when reopening the app after app installed
//import DotLottie

struct SceneTemplateView: View {
    @StateObject var sceneLoader = SceneLoader()
    @State var isGeneratedFirstTime = true
    @State var isGenerating = false
    @State var roomModelView: RoomModelView?
    @State var isAutoEnablesDefaultLighting = true
    
    @StateObject var viewModel = ProductViewModel()
    
    @State var arView = ARView(frame: .zero)
    @State var camera = GestureDrivenCamera()
    
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
    
    // Example rooms urls
    let roomFurnishedURL = Bundle.main.url(forResource: "Room-example_furnished", withExtension: "usdz")
    let roomFurnishedLayout1URL = Bundle.main.url(forResource: "Room-example_furnished_layout1", withExtension: "usdz")
    let roomFurnishedLayout2URL = Bundle.main.url(forResource: "Room-example_furnished_layout2", withExtension: "usdz")
    let roomFurnishedLayout3URL = Bundle.main.url(forResource: "Room-example_furnished_layout3", withExtension: "usdz")
    // Example rooms urls
//    let roomFurnishedURL =  URL(string: "https://firebasestorage.googleapis.com/v0/b/dingdong-251a1.firebasestorage.app/o/rooms%2FRoom-example_furnished.usdz?alt=media&token=441eb02a-8d09-423a-bdd0-141c792becdd")
//    let roomFurnishedLayout1URL = URL(string: "https://firebasestorage.googleapis.com/v0/b/dingdong-251a1.firebasestorage.app/o/rooms%2FRoom-example_furnished_layout1.usdz?alt=media&token=99312ba2-f654-4141-acde-8e4dc69dfa4f")
//    let roomFurnishedLayout2URL = URL(string: "https://firebasestorage.googleapis.com/v0/b/dingdong-251a1.firebasestorage.app/o/rooms%2FRoom-example_furnished_layout2.usdz?alt=media&token=de513235-a107-4ac7-8694-b5e2bfb48150")
//    let roomFurnishedLayout3URL = URL(string: "https://firebasestorage.googleapis.com/v0/b/dingdong-251a1.firebasestorage.app/o/rooms%2FRoom-example_furnished_layout3.usdz?alt=media&token=10fdc6d4-62fc-4598-8575-f786769c9fa0")
    
    // Orbit Parameters
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var rotationX: Float = -0.4966666  // Horizontal rotation
    @State private var rotationY: Float = 1.1266669  // Vertical rotation
    @State private var distance: Float = 15.0   // Distance from the center (target)
    
    // The point around which the camera will orbit (center of rotation)
    let orbitCenter = simd_float3(0, 0, 0)  // Set to whatever your target point is
    
    @State var exampleRoomState = ExampleRoomState.raw
    @State var heading: String = ""
    @State var bodyText: String = ""
    
    /// Instructional gif
    @State var zoomGesture = false
    @State var dragGesture = false
    
    /// Symbols animating
    @State private var count = 0
    @State private var isScaling = false
    
    var body: some View {
        if #available(iOS 17.0, *) {
            if let _ = sceneLoader.scene {
                ZStack {
                    roomModelView
                        .edgesIgnoringSafeArea(.all)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let deltaX = Float(value.translation.width - lastOffset.width) * 0.01
                                    let deltaY = Float(value.translation.height - lastOffset.height) * 0.01
                                    
                                    rotationX += deltaX
                                    rotationY += deltaY
                                    
                                    updateCameraPosition()
                                    
                                    lastOffset = value.translation
                                }
                                .onEnded { _ in
                                    lastOffset = .zero
                                }
                        )
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    let zoomAmount = Float(value.magnification - scale) * 5.0 // Zoom sensitivity
                                    distance -= zoomAmount
                                    
                                    updateCameraPosition()
                                    
                                    scale = value.magnification
                                }
                                .onEnded { _ in
                                    scale = 1.0
                                }
                        )
                    VStack {
                        if dragGesture {
                            GifImageView("drag-gesture")
                                .frame(width: 100, height: 100)
                                .onAppear(perform: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation(.easeInOut) {
                                            zoomGesture = true
                                            dragGesture = false
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                        withAnimation(.easeInOut) {
                                            zoomGesture = false
                                        }
                                    }
                                })
                        }
                    }
                    .clipShape(Circle())
                    
                    if showOverlayOptions {
                        overlayOptionsView
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut) {
                        self.isGenerating = true
                    }
                    if let roomURL = roomFurnishedURL {
                        viewModel.downloadModelFile(from: roomURL) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let localFileUrl):
                                    withAnimation(.easeInOut) {
                                        heading = "Nice Bedroom!"
                                        bodyText = "I'm furnishing the room with matching dimension furnitures..."
                                        self.roomModelView = RoomModelView(sceneLoader: sceneLoader, isAutoEnablesDefaultLighting: $isAutoEnablesDefaultLighting, camera: $camera, arView: $arView, roomFurnishedURL: localFileUrl)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                        withAnimation(.easeInOut) {
                                            self.heading = "The Room Needs Improvements!!"
                                            self.bodyText = "\u{2022} Bed is blocking the walk way\n\u{2022} No access to sofa"
                                            self.isGenerating = false
                                            self.dragGesture = true
                                            exampleRoomState = .furnish
                                        }
                                    }
                                case .failure(let error):
                                    print("Error downloading file: \(error)")
                                }
                            }
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
                //            .customNavBar()
            } else {
                ProgressView()
                    .onAppear() {
                        Task {
                            await self.sceneLoader.loadScene(from: url)
                        }
                    }
            }
        } else {
            Text("Need ios 17 and above to run this scene")
        }
    }
    
    // Update camera position based on orbit parameters
    func updateCameraPosition() {
        let radius = distance // Distance from the orbit center
        let cameraPosition = simd_float3(
            radius * cos(rotationY) * sin(rotationX),
            radius * sin(rotationY),
            radius * cos(rotationY) * cos(rotationX)
        )
        
        camera.position = cameraPosition + orbitCenter
        print("Camera pos: \(camera.position)")
        print("RotX pos: \(rotationX)")
        print("RotY pos: \(rotationY)")
        camera.look(at: orbitCenter, from: camera.position, relativeTo: nil)
    }
    
    var overlayOptionsView: some View {
        GeometryReader {
            let size = $0.size
            VStack(alignment: .center) {
                if exampleRoomState == .furnish {
                    if #available(iOS 17.0, *) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color("AccentColor"), Color("SecondaryColor"))
                            .symbolEffect(.bounce, value: count)
                            .onAppear() {
                                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                    count += 1
                                }
                            }
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color("AccentColor"), Color("SecondaryColor"))
                            .scaleEffect(isScaling ? 1.0 : 1.5)
                            .animation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true), value: isScaling)
                            .onAppear {
                                isScaling = true
                            }
                    }
                }
                
                H1Text(title: $heading)
                    .multilineTextAlignment(.center)
                Spacer()
                BodyText(text: $bodyText)
                    .multilineTextAlignment(.center)
                HStack(alignment: .center) {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut) {
                            isGenerating = true
                        }
                        updateRoomState(for: exampleRoomState)
                    } label: {
                        if isGenerating == true {
                            ProgressView()
                                .padding(.vertical, 15)
                                .padding(10)
                        } else {
                            switch exampleRoomState {
                            case .raw:
                                EmptyView()
                            case .furnish:
                                PrimaryButton(text: "Change Layout", size: size)
                            case .changeLayout1:
                                PrimaryButton(text: "Try Again", size: size)
                            case .changeLayout2:
                                PrimaryButton(text: "Try Again", size: size)
                            case .changeLayout3:
                                NavigationLink(destination: HomeView()) {
                                    PrimaryButton(text: "Now Try Your Own Room!", size: size, willSpan: true)
                                }
                            }
                            
                        }
                    }
                    Spacer()
                }
            }
            .disabled(isGenerating)
//            .frame(maxWidth: .infinity)
            .onAppear(perform: {
//                viewModel.getAllProducts()
            })
            .padding([.leading, .trailing, .top], 30)
        }
    }
    
    func updateRoomState(for state: ExampleRoomState) {
        switch state {
        case .raw:
            break
        case .furnish:
            roomModelView?.changeLayout(url: roomFurnishedLayout1URL)
            withAnimation(.easeInOut) {
                self.heading = heading
                self.bodyText = bodyText
            }
            self.isGenerating = false
            exampleRoomState = .changeLayout1
//            handleRoomStateChange(nextState: .changeLayout1, url: roomFurnishedLayout1URL, heading: "Best Layout", bodyText: "\u{2022} Bed is not blocking the walkway\n\u{2022} Easy access to sofa and desk\n\u{2022} Most living space")
        case .changeLayout1:
            roomModelView?.changeLayout(url: roomFurnishedLayout2URL)
            withAnimation(.easeInOut) {
                self.heading = heading
                self.bodyText = bodyText
            }
            self.isGenerating = false
            exampleRoomState = .changeLayout2
//            handleRoomStateChange(nextState: .changeLayout2, url: roomFurnishedLayout2URL, heading: "Less Space", bodyText: "\u{2022} Easy access to sofa\n\u{2022} Tight access to desk")
        case .changeLayout2:
            roomModelView?.changeLayout(url: roomFurnishedLayout3URL)
            withAnimation(.easeInOut) {
                self.heading = heading
                self.bodyText = bodyText
            }
            self.isGenerating = false
            exampleRoomState = .changeLayout3
//            handleRoomStateChange(nextState: .changeLayout3, url: roomFurnishedLayout3URL, heading: "Another One", bodyText: "\u{2022} Consider adding more storage at the corner")
        case .changeLayout3:
            break
        }
    }

    private func handleRoomStateChange(nextState: ExampleRoomState, url: URL?, heading: String, bodyText: String) {
        exampleRoomState = nextState
        guard let roomURL = url else { return }
        
        viewModel.downloadModelFile(from: roomURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let localFileUrl):
                    roomModelView?.changeLayout(url: localFileUrl)
                    withAnimation(.easeInOut) {
                        self.heading = heading
                        self.bodyText = bodyText
                    }
                case .failure(let error):
                    print("Error downloading file: \(error)")
                }
                self.isGenerating = false
            }
        }
    }
}

enum ExampleRoomState {
    case raw
    case furnish
    case changeLayout1
    case changeLayout2
    case changeLayout3
}

#Preview {
    //    NavigationStack {
    //        RoomLoaderView(fileRef: DataController.shared.storage.reference(withPath: "/usdz_files/33i3YtIe6TTzBx7uElHrNdbSq1z1/Room1.usdz"))
    //    }
    SceneTemplateView()
}


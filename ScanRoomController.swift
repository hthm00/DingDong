//
//  ScanRoomController.swift
//  DingDong
//
//  Created by Minh Huynh on 2/17/25.
//

import SwiftUI
import RoomPlan
//import FirebaseStorage
import SceneKit


/// Scan Room Controller in charge of capturing the room for a model
class ScanRoomController: RoomCaptureSessionDelegate, RoomCaptureViewDelegate, ObservableObject {
    func encode(with coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    /// The only instance
    static var instance = ScanRoomController()
    var captureView: RoomCaptureView
    let sessionConfig = RoomCaptureSession.Configuration()
    
    /// A 3d model of the final result
    var finalResult: CapturedRoom?
    
    // Setup RoomBuilder
    private var roomBuilder = RoomBuilder(options: [.beautifyObjects])
    
    // Export url
    @Published var url: URL?
    
    // Scene View to build model
    var sceneView: SCNView?
    
    /// Initializer
    init() {
        captureView = RoomCaptureView(frame: .zero)
        captureView.delegate = self
        captureView.captureSession.delegate = self
        
        // Setup scene
        sceneView = SCNView(frame: .zero)
        sceneView?.scene = SCNScene()
        sceneView?.scene?.rootNode.castsShadow = true
        sceneView?.allowsCameraControl = true
        sceneView?.autoenablesDefaultLighting = true
        // Add spot light to the scene
        addSpotLight(to: sceneView?.scene?.rootNode)
    }
    
    func addSpotLight(to rootNode: SCNNode?) {
        // Create a spot light
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.color = UIColor.white
        spotLight.intensity = 200 // Adjust intensity as needed
        spotLight.spotInnerAngle = 0 // Adjust inner angle of the spot light
        spotLight.spotOuterAngle = 60 // Adjust outer angle of the spot light
        
        // Create a node to attach the spot light
        let spotLightNode = SCNNode()
        spotLightNode.light = spotLight
        
        // Position and orient the spot light node
        spotLightNode.position = SCNVector3(x: 0, y: 50, z: 2) // Adjust position as needed
        spotLightNode.eulerAngles = SCNVector3(x: -105, y: 0, z: 0) // Point light downwards
        
        // Add the spot light node to the root node
        rootNode?.addChildNode(spotLightNode)
    }
    
    /// Capture the room
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
        if (error == nil) {
            return true
        }
        return false
    }
    
    /// Scans completed
    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
        if let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        finalResult = processedResult
        onModelReady()
    }
    
    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: (Error)?) {
        if let error {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
    
    func generateRoomURL(with captureRoomData: CapturedRoomData){
        print("Starting to generate URL")
        // Export to file and share
        Task {
            if let finalRoom = try? await roomBuilder.capturedRoom(from: captureRoomData) {
                if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let url = directory.appendingPathComponent("Room.usdz")
                    try finalRoom.export(to: url)
                    self.url = url
                    print("Successful Export URL for model")
                    print(url)
//                    uploadUSDZFile(fileURL: url)
                }
            }
        }
    }
  /*
    func uploadUSDZFile(fileURL: URL) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var usdzFiles: [StorageReference] = []
        do {
            let authDataResult = try AuthenticationController.shared.getAuthenticatedUser()
            UserManager.shared.fetchRooms { files in
                usdzFiles = files
                let fileUrl = "usdz_files/\(authDataResult.uid)/Room\(usdzFiles.count + 1).usdz"
                let fileRef = storageRef.child(fileUrl)
                
                // Upload the file to the path "usdz_files/Room.usdz"
                _ = fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
                    guard error == nil else {
                        // Handle error
                        print("Error uploading file: \(error!)")
                        return
                    }
                    // File uploaded successfully
                    print("USDZ file uploaded successfully")
                    
                    // Add to user's rooms
                    Task {
                        do {
                            let authDataResult = try AuthenticationController.shared.getAuthenticatedUser()
                            try await UserManager.shared.addToRooms(userId: authDataResult.uid, fileRef: fileUrl)
                        } catch {
                            print("Error")
                        }
                    }
                }
            }
        } catch {
            print("Error")
        }
        
    }
 */
    
    /// Start a session
    func startSession() {
        captureView.captureSession.run(configuration: sessionConfig)
    }
    
    /// Stops a session
    func stopSession() {
        captureView.captureSession.stop()
        print("Subviews \( captureView.subviews)")
    }
    
}

// MARK: - Scan Room Controller + SCNView - Custom Scene from scanned room
extension ScanRoomController {
    
    /// Construct scene when the model is ready
    func onModelReady() {
        print("Model Ready")
        sceneView?.scene = SCNScene()
        sceneView?.scene?.rootNode.castsShadow = true
        guard let model = finalResult else {
            print("Something went wrong. Model not found")
            return
        }
        let walls = getAllNodes(for: model.walls,
                                length: 0.2,
                                contents: UIImage(named: "White-Marble-Diffuse"))
        walls.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let doors = getAllNodes(for: model.doors,
                                length: 0.3,
                                contents: UIImage(named: "doorTexture"))
//        doors.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let windows = getAllNodes(for: model.windows,
                                  length: 0.3,
                                  contents: UIImage(named: "windowTexture"))
//        windows.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let openings = getAllNodes(for: model.openings,
                                   length: 0.3,
                                   contents: UIColor.blue.withAlphaComponent(0.5))
//        openings.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let objects = getAllNodes(for: model.objects, contents: UIImage(named: "windowTexture"))
        objects.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        exportScene(sceneView?.scene)
    }
    
    /// Get all the nodes of any Surface
    private func getAllNodes(for surfaces: [CapturedRoom.Surface], length: CGFloat, contents: Any?) -> [SCNNode] {
        var nodes: [SCNNode] = []
        var name = ""
        switch surfaces.first?.category {
        case .door(isOpen: false):
            name = "DoorClosed"
        case .door(isOpen: true):
            name = "DoorOpened"
        case .floor:
            name = "Floor"
        case .window:
            name = "Window"
        case .opening:
            name = "Opening"
        case .wall:
            name = "Wall"
        default:
            name = "Unknown"
        }
        surfaces.enumerated().forEach { index, surface in
            let width = CGFloat(surface.dimensions.x)
            let height = CGFloat(surface.dimensions.y)
            let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
            let node = SCNNode(geometry: box)
            // Create a material for the box
                let boxMaterial = SCNMaterial()
            boxMaterial.metalness.contents = 0.2 // Need for shadows
            box.materials = [boxMaterial]
            node.name = "\(name)\(index)"
            node.transform = SCNMatrix4(surface.transform)
            nodes.append(node)
        }
        return nodes
    }
    
    /// Get all the nodes of any Object
    private func getAllNodes(for objects: [CapturedRoom.Object], contents: Any?) -> [SCNNode] {
        var nodes: [SCNNode] = []
        objects.enumerated().forEach { index, object in
            let name = SceneModel.getName(forCategory: object.category)
            let width = CGFloat(object.dimensions.x)
            let height = CGFloat(object.dimensions.y)
            let length = CGFloat(object.dimensions.z)
            let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
            let node = SCNNode(geometry: box)
            node.name = "\(name)\(index)"
            node.transform = SCNMatrix4(object.transform)
            nodes.append(node)
        }
        return nodes
    }
    
    /// Export scene to USDZ and upload to database
    func exportScene(_ scene: SCNScene?){
        if let scene = scene{
            print("Starting to generate URL")
            
            // Create a URL to save the scene to
            if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let sceneURL = directory.appendingPathComponent("Room.usdz")
                
                // Export the scene to the URL
                scene.write(to: sceneURL, delegate: nil)
                self.url = sceneURL
//                uploadUSDZFile(fileURL: sceneURL)
                print("Scene exported to \(sceneURL.path)")
            } else {
                print("Scene is nil, cannot export")
            }
        }
    }
}

/// A SwiftUI compatible view for Scan Room View
struct ScanRoomViewRepresentable: UIViewRepresentable {
    
    /// Get capture view
    func makeUIView(context: Context) -> RoomCaptureView {
        ScanRoomController.instance.captureView
    }
    
    /// Update the view when needed
    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
        
    }
}

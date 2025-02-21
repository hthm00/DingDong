//
//  SceneView.swift
//  DingDong
//
//  Created by Minh Huynh on 2/18/25.
//

import SwiftUI
import SceneKit
import RealityKit
import ARKit
import Combine

/// SceneView for SwiftUI with custom delegate
struct SceneView: UIViewRepresentable {
    // A SceneLoaderController Attached to this SceneView
    @ObservedObject var sceneLoader: SceneLoader
    // True for before furnishing the room
    @Binding var isAutoEnablesDefaultLighting: Bool
    
    @Binding var camera: GestureDrivenCamera
    @Binding var arView: ARView
    
    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
//        arView.renderOptions = .
//        arView.session = ARSession()
        arView.environment.background = .color(.blue)
//        arView.session.delegate = context.coordinator
//        arView.scene = sceneLoader.scene
        // Debug
//        view.debugOptions = [
//            .showWireframe, // Show wireframe
//            .showBoundingBoxes, // Show bounding boxes
//            .showCameras, // Show cameras
//            .showSkeletons,
//            .showLightInfluences, // Show lights
//            .showLightExtents // Show field of view cones
//        ]
//        view.backgroundColor = .grey

        // .loadModel will lose all children, use load instead
        let modelEntity = try! Entity.load(named: "Room-example.usdz")
//        modelEntity.
        
        print(modelEntity)
        if let bedEntity = modelEntity.findEntity(named: "Bed0") {
            print("Found Bed0")
//            bedEntity.position = [0, 0, 2]
        }
        
        // Iterate through all child entities of the model
        print(modelEntity.children.count)
        for child in modelEntity.children {
            print(child)
            if let model = child as? ModelEntity {
                print(model.name)
            }
        }
        
        // Create an anchor entity for the model
        let anchorEntity = AnchorEntity(world: .zero)
        anchorEntity.addChild(modelEntity)
        arView.scene.addAnchor(anchorEntity)

        // Create a camera and enable user controls
//        let camera = PerspectiveCamera()
//        camera.camera.fieldOfViewInDegrees = 0
//
        let cameraAnchor = AnchorEntity(world: [0, 0, 15])
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        
        animateEntityComplex(modelEntity)


        
        // Important for realistic environment
        sceneLoader.scene?.wantsScreenSpaceReflection = true
        sceneLoader.scene?.rootNode.castsShadow = true
        addSpotLight(to: sceneLoader.scene?.rootNode)
        //        visualizeLights()
//        arView.allowsCameraControl = true
//        arView.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
//        view.scene = sceneLoader.scene
//        view.autoenablesDefaultLighting = isAutoEnablesDefaultLighting
//        print("Auto lighting: \(view.autoenablesDefaultLighting)")
    }
    
    func eternalRotation(_ entity: Entity) {
        let from = Transform(rotation: .init(angle: .pi / 2, axis: [0, 1, 0]))

        let definition = FromToByAnimation(from: from,
                                       duration: 6,
                                         timing: .linear,
                                     bindTarget: .transform,
                                     repeatMode: .cumulative)

        if let animate = try? AnimationResource.generate(with: definition) {
            entity.playAnimation(animate)
        }
    }
    
    func animateEntityComplex(_ entity: Entity) {
        // Initial transform
        let startTransform = Transform(scale: [0, 0, 0], rotation: simd_quatf(angle: .pi / 2, axis: SIMD3(x: 0, y: 1, z: 0)), translation: [0, -10, 0])
        entity.transform = startTransform
        
        // Create animations for position, rotation, and scale
        let translation = SIMD3<Float>(x: 0, y: 0, z: 0)
        let rotation = simd_quatf(angle: -.pi / 2, axis: SIMD3(x: 0, y: 1, z: 0))
        let scale = SIMD3<Float>(x: 1.0, y: 1.0, z: 1.0)
        entity.move(to: Transform(scale: scale, translation: translation), relativeTo: nil, duration: 2)
        entity.move(to: Transform(rotation: rotation), relativeTo: nil, duration: 4)

    }
    
    func addSpotLight(to rootNode: SCNNode?) {
        // Create a spot light
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.color = UIColor.white
        spotLight.intensity = 300 // Adjust intensity as needed
        spotLight.spotInnerAngle = 0 // Adjust inner angle of the spot light
        spotLight.spotOuterAngle = 60 // Adjust outer angle of the spot light
        spotLight.castsShadow = true
        spotLight.shadowRadius = 10
        spotLight.shadowSampleCount = 40
        
        // Create a node to attach the spot light
        let spotLightNode = SCNNode()
        spotLightNode.light = spotLight
        
        // Position and orient the spot light node
        spotLightNode.position = SCNVector3(x: 2, y: 9, z: 4) // Adjust position as needed
        spotLightNode.eulerAngles = SCNVector3(x: .pi * 60 / 180, // Rotate around X-axis first
                                               y: -.pi * 70 / 180, // Rotate around Y-axis next
                                               z: -.pi * 160 / 180)  // Point light downwards
        
        
        // Add the spot light node to the root node
        rootNode?.addChildNode(spotLightNode)
    }
    
    /// Add lights to the scene for realistic environment
    func addLights() {
        guard let scene = sceneLoader.scene else {
            print("Couldn't add light. No scene were found")
            return
        }
        
        let waitAction = SCNAction.wait(duration: 0.5)
        
        for x in stride(from: -10, through: 10, by: 5) {
            for z in stride(from: -10, through: 10, by: 5) {
                let omniLight = SCNLight()
                omniLight.type = .omni
                omniLight.color = UIColor.white
                omniLight.intensity = 5
                omniLight.castsShadow = true
                omniLight.shadowMode = .forward
                
                let omniLightNode = SCNNode()
                omniLightNode.light = omniLight
                omniLightNode.position = SCNVector3(x: Float(x), y: 5, z: Float(z))
                omniLightNode.opacity = 0 // Start with opacity 0 to fade in
                scene.rootNode.addChildNode(omniLightNode)
                
                // Animate the opacity to fade in
                let fadeInSequence = SCNAction.sequence([waitAction, SCNAction.fadeIn(duration: 1.0)])
                omniLightNode.runAction(fadeInSequence)
            }
        }
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white // Adjust the intensity and color as needed
        ambientLight.intensity = 1200
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        ambientLightNode.position = SCNVector3(x: 0, y: 1000, z: 10) // Set the position of the light
        ambientLightNode.opacity = 0 // Start with opacity 0 to fade in
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Animate the opacity to fade in
        let fadeInActionForAmbient = SCNAction.fadeIn(duration: 10.0)
        //        DispatchQueue.main.async {
        ambientLightNode.runAction(fadeInActionForAmbient)
        //        }
        
        print("Lights added with animation")
    }
    
    /// Enable this will visualize where the lights are, however, all the light sources will be blocked
    func visualizeLights() {
        // Iterate through the scene's rootNode to find lights
        if let childNodes = sceneLoader.scene?.rootNode.childNodes {
            for node in childNodes {
                if let light = node.light {
                    // Create a visual representation for the light
                    let lightGeometry: SCNGeometry
                    switch light.type {
                    case .ambient:
                        // Visualize ambient light with a sphere
                        lightGeometry = SCNSphere(radius: 0.2)
                    case .directional:
                        // Visualize directional light with an arrow
                        lightGeometry = SCNCylinder(radius: 0.1, height: 1.0)
                        lightGeometry.firstMaterial?.diffuse.contents = UIColor.red // Set arrow color
                        let arrow = SCNNode(geometry: lightGeometry)
                        arrow.eulerAngles.x = -.pi / 2 // Point the arrow upward
                        node.addChildNode(arrow)
                        continue // Skip adding the light node itself
                    case .omni:
                        // Visualize point light with a sphere
                        lightGeometry = SCNSphere(radius: 0.2)
                    case .spot:
                        // Visualize spot light with a cone
                        lightGeometry = SCNCone(topRadius: 0, bottomRadius: 0.2, height: 0.5)
                        let lightNode = SCNNode(geometry: lightGeometry)
                        lightNode.eulerAngles.x = .pi / 2
                        node.addChildNode(lightNode)
                        continue
                    default:
                        continue // Skip other light types
                    }
                    
                    // Set the color of the light representation
                    lightGeometry.firstMaterial?.diffuse.contents = light.color
                    
                    // Create a node to hold the light representation geometry
                    let lightNode = SCNNode(geometry: lightGeometry)
                    node.addChildNode(lightNode)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        print("Coordinator made")
        return Coordinator(self)
    }
    
    /// SceneView delegate
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: SceneView
        
        init(_ parent: SceneView) {
            self.parent = parent
        }
        
        /// Scene updates
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            // Find and hide nearest wall
            if parent.sceneLoader.sceneModel?.walls?.count ?? 0 >= 4, let pointOfViewPos = renderer.pointOfView?.position {
                let nearestWall = parent.sceneLoader.findNearestWall(from: pointOfViewPos)
                parent.sceneLoader.hideWall(nearestWall)
            }
        }
    }
}

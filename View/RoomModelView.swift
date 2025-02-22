//
//  SceneView.swift
//  DingDong
//
//  Created by Minh Huynh on 2/18/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

/// SceneView for SwiftUI with custom delegate
struct RoomModelView: UIViewRepresentable {
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
        arView.environment.background = .color(.clear)
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
        loadModel(fileName: "Room-example.usdz")

        
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
    
    func cleanUpScene() {
        // Iterate through all anchors in the AR scene and remove their entities
        for anchor in arView.scene.anchors {
            // Remove all children (entities) attached to the anchor
            for entity in anchor.children {
                entity.removeFromParent()
            }
        }
    }
    
    /// Load new model into the scene with filename
    func loadModel(fileName: String) {
        let modelEntity = try! Entity.load(named: fileName)
        let newModelEntity = try! Entity.load(named: "Room-example_furnished.usdz")
        
        // Create an anchor entity for the model
        let anchorEntity = AnchorEntity(world: .zero)
        anchorEntity.addChild(modelEntity)
        arView.scene.addAnchor(anchorEntity)
        let cameraAnchor = AnchorEntity(world: [0, 0, 0])
        cameraAnchor.addChild(camera)
        camera.position = [-3.0710642, 13.544776, 5.666357]
        camera.look(at: [0, 0, 0], from: camera.position, relativeTo: nil)
        arView.scene.addAnchor(cameraAnchor)
        // Animate scene
        animateEntityZoomOut(modelEntity)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print("Replacing walls")
            if let newBedEntity = newModelEntity.findEntity(named: "Wall0"), let bedEntity = arView.scene.findEntity(named: "Wall0") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Wall1"), let bedEntity = arView.scene.findEntity(named: "Wall1") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Wall2"), let bedEntity = arView.scene.findEntity(named: "Wall2") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Wall3"), let bedEntity = arView.scene.findEntity(named: "Wall3") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Wall4"), let bedEntity = arView.scene.findEntity(named: "Wall4") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Wall5"), let bedEntity = arView.scene.findEntity(named: "Wall5") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Wall6"), let bedEntity = arView.scene.findEntity(named: "Wall6") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Wall7"), let bedEntity = arView.scene.findEntity(named: "Wall7") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("Replacing furniture")
            if let newBedEntity = newModelEntity.findEntity(named: "Bed0"), let bedEntity = arView.scene.findEntity(named: "Bed0") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Chair0"), let bedEntity = arView.scene.findEntity(named: "Chair0") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Sofa0"), let bedEntity = arView.scene.findEntity(named: "Sofa0") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
            if let newBedEntity = newModelEntity.findEntity(named: "Table0"), let bedEntity = arView.scene.findEntity(named: "Table0") {
                print("Bed: \(bedEntity.transform)")
                print("NewBed: \(newModelEntity.transform)")
                replaceObject(from: bedEntity, to: newBedEntity)
            }
        }
    }
    
    func replaceObject(from entity: Entity, to newEntity: Entity) {
        // Initial transform
        let entityTransform = entity.transform
        // Create animations for position, rotation, and scale
        let scale = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
        var newEntityTransform = entityTransform
        newEntityTransform.scale = [0.001, 0.001, 0.001]
        
        DispatchQueue.main.async {
            entity.move(to: newEntityTransform, relativeTo: entity.parent, duration: 2)
            //        entity.move(to: Transform(rotation: rotation), relativeTo: nil, duration: 4)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let newEntityAnchor = entity.anchor?.clone(recursive: false) {
//                    newEntityAnchor.addChild(newEntity)
                    if let roomEntity = arView.scene.findEntity(named: "Room") {
                        roomEntity.addChild(newEntity)
                        // Initial transform
                        newEntity.transform = entityTransform
                        newEntity.transform.scale = [0, 0, 0]
//                        
                        var newTransform = entityTransform
                        newTransform.scale = [1, 1, 1]
                        newEntity.move(to: newTransform, relativeTo: entity.parent, duration: 2)
                        entity.removeFromParent()

                    }
                }
            }
            
        }
    }
    
    func changeLayout(to fileName: String) {
        let modelEntity = try! Entity.load(named: fileName)
        if let newBedEntity = modelEntity.findEntity(named: "Bed0"), let bedEntity = arView.scene.findEntity(named: "Bed0") {
            print("Bed: \(bedEntity.transform)")
            print("NewBed: \(newBedEntity.transform)")
//            bedEntity.transform = newBedEntity.transform
            bedEntity.move(to: newBedEntity.transform, relativeTo: bedEntity.parent, duration: 2)
        }
        if let newBedEntity = modelEntity.findEntity(named: "Sofa0"), let bedEntity = arView.scene.findEntity(named: "Sofa0") {
            print("Sofa: \(bedEntity.transform)")
            print("NewSofa: \(newBedEntity.transform)")
//            bedEntity.transform = newBedEntity.transform
            bedEntity.move(to: newBedEntity.transform, relativeTo: bedEntity.parent, duration: 2)
        }
        if let newBedEntity = modelEntity.findEntity(named: "Table0"), let bedEntity = arView.scene.findEntity(named: "Table0") {
            print("Table0: \(bedEntity.transform)")
            print("NewTable0: \(newBedEntity.transform)")
//            bedEntity.transform = newBedEntity.transform
            bedEntity.move(to: newBedEntity.transform, relativeTo: bedEntity.parent, duration: 2)
        }
        if let newBedEntity = modelEntity.findEntity(named: "Chair0"), let bedEntity = arView.scene.findEntity(named: "Chair0") {
            print("Chair0: \(bedEntity.transform)")
            print("NewChair0: \(newBedEntity.transform)")
//            bedEntity.transform = newBedEntity.transform
            bedEntity.move(to: newBedEntity.transform, relativeTo: bedEntity.parent, duration: 2)
        }
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
    
    func animateEntityBottomToTop(_ entity: Entity) {
        DispatchQueue.main.async {
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
    }
    
    func animateEntityZoomOut(_ entity: Entity) {
        DispatchQueue.main.async {
            // Initial transform
            let startTransform = Transform(scale: [100, 100, 100], rotation: simd_quatf(angle: .pi / 2, axis: SIMD3(x: 0, y: 1, z: 0)), translation: [0, -10, 0])
            entity.transform = startTransform
            
            // Create animations for position, rotation, and scale
            let translation = SIMD3<Float>(x: 0, y: 0, z: 0)
            let rotation = simd_quatf(angle: -.pi / 2, axis: SIMD3(x: 0, y: 1, z: 0))
            let scale = SIMD3<Float>(x: 1.0, y: 1.0, z: 1.0)
            entity.move(to: Transform(scale: scale, translation: translation), relativeTo: nil, duration: 2)
            entity.move(to: Transform(rotation: rotation), relativeTo: nil, duration: 4)
        }
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
        var parent: RoomModelView
        
        init(_ parent: RoomModelView) {
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

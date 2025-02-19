//
//  SceneLoader+ObjectReplace.swift
//  DingDong
//
//  Created by Minh Huynh on 2/18/25.
//

import SceneKit
import RoomPlan

extension SceneLoader {
    /// Style all the walls
    func styleWalls(with resource: MaterialResource) {
        sceneModel?.walls?.forEach({ wall in
            styleNode(node: wall, with: resource)
        })
    }
    
    /// Replace all objects with given model url
    func replaceObjects(ofType type: CapturedRoom.Object.Category, with resourceUrl: URL?, scale: Float = 1, onFloorLevel: Bool = true) {
        var objectNodes: [SCNNode]? = nil
        
        switch type {
        case .storage, .refrigerator, .stove, .bed, .sink, .washerDryer, .toilet, .bathtub, .oven, .dishwasher, .sofa, .chair, .fireplace, .television, .stairs, .table:
            objectNodes = sceneModel?.nodes(forCategory: type)
        @unknown default:
            return
        }
        
        replaceObjects(objectNodes: &objectNodes, with: resourceUrl, scale: scale, onFloorLevel: onFloorLevel)
        sceneModel?.updateNodes(objectNodes ?? [], forCategory: type)
    }
    
    /// Replace all surfaces
    func replaceSurfaces(ofType type: CapturedRoom.Surface.Category, with image: UIImage?) {
        var objectNodes: [SCNNode]? = nil
        
        switch type {
        case .door(isOpen: false), .door(isOpen: true), .window, .wall:
            objectNodes = sceneModel?.nodes(forCategory: type)
        case .opening:
            return
        case .floor:
            return
        @unknown default:
            return
        }
        
        replaceSurfaces(surfaceNodes: &objectNodes, with: image)
        sceneModel?.updateNodes(objectNodes ?? [], forCategory: type)
    }
    
    /// Helper function to replace all surfaces
    private func replaceSurfaces(surfaceNodes: inout [SCNNode]?, with image: UIImage?) {
        guard let surfaceNodes = surfaceNodes, !surfaceNodes.isEmpty else {
            print("No surface nodes to replace")
            return
        }
        if let image = image {
            surfaceNodes.forEach { surfaceNode in
                surfaceNode.geometry?.firstMaterial?.diffuse.contents = image
            }
        }
    }
    
    /// Helper function to replace all object
    private func replaceObjects(objectNodes: inout [SCNNode]?, with resourceUrl: URL?, scale: Float = 1, onFloorLevel: Bool = true) {
        var newNodes: [SCNNode] = []
        if let newObjectUrl = resourceUrl,
           let newObjectScene = try? SCNScene(url: newObjectUrl),
           let newObjectNode = newObjectScene.rootNode.childNodes.first {
            objectNodes?.forEach { objectNode in
                //                DispatchQueue.main.async {
                let node = newObjectNode.clone()
                //                node.l
                // Initial state before animation
                node.name = objectNode.name
                node.opacity = 0.0
                node.transform = objectNode.transform
                node.scale = SCNVector3(scale, scale, scale)
                print("Scaled down by: \(scale)")
                node.position.y -= Float((node.boundingBox.max.y) - (node.boundingBox.min.y))
                newNodes.append(node)
                self.scene?.rootNode.addChildNode(node)
                
                // Start animating
                let randomAnimationTime = Double.random(in: 0.5...1)
                
                // Remove current nodes
                let fadeOut = SCNAction.fadeOut(duration: randomAnimationTime)
                var move = SCNAction.move(to: SCNVector3(objectNode.position.x, objectNode.position.y - Float((objectNode.boundingBox.max.y) - (objectNode.boundingBox.min.y)), objectNode.position.z) , duration: randomAnimationTime)
                objectNode.runAction(fadeOut)
                objectNode.runAction(move)
                
                // Add new nodes
                DispatchQueue.main.asyncAfter(deadline: .now() + randomAnimationTime + Double.random(in: 0...1)) {
                    let animationTime = Double.random(in: 0.5...1.0)
                    let fadeIn = SCNAction.fadeIn(duration: animationTime)
                    if onFloorLevel {
                        move = SCNAction.move(to: SCNVector3(node.position.x, self.groundLevel, node.position.z), duration: animationTime)
                    } else {
                        move = SCNAction.move(to: SCNVector3(node.position.x, objectNode.position.y, node.position.z), duration: animationTime)
                    }
                    
                    node.runAction(fadeIn)
                    node.runAction(move)
                }
                
                // Remove after animation ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                    objectNode.removeFromParentNode()
                }
                //                }
                
                print("Replaced \(String(describing: objectNode.name))")
                
            }
        } else {
            print("Cannot load file")
        }
        // Replace oldnodes with newnodes
        objectNodes = newNodes
    }
    
    /// Add floor to the scene with animation
    func addFloor(infinity: Bool = false, from resource: MaterialResource) {
        guard let roomNode = scene?.rootNode.childNodes.first else {
            print("Cannot add floor")
            return
        }
        let boundingBox = roomNode.boundingBox
        
        // Floor Geometry
        let floorGeometry = SCNFloor()
        floorGeometry.reflectivity = 0.05
        floorGeometry.reflectionFalloffEnd = 0.8
        
        // Floor Material
        let floorMaterial = SCNMaterial()
        if let diffuse = resource.diffuse {
            floorMaterial.diffuse.contents = diffuse
            floorMaterial.diffuse.wrapS = .repeat
            floorMaterial.diffuse.wrapT = .repeat
        }
        if let normal = resource.normal {
            floorMaterial.normal.contents = normal
        }
        floorMaterial.lightingModel = .physicallyBased
        
        floorGeometry.materials = [floorMaterial]
        print("Root \(String(describing: scene?.rootNode.childNodes.first))")
        print("Bounding box \(boundingBox)")
        if !infinity {
            floorGeometry.width = CGFloat(boundingBox.max.x - boundingBox.min.x) / 2
            floorGeometry.length = CGFloat(boundingBox.max.z - boundingBox.min.z) / 2
        }
        
        /// Animation
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position.y = -20
        floorNode.opacity = 0
        floorNode.name = "Floor"
        floorNode.scale = SCNVector3(0.1, 0.1, 0.1)
        sceneModel?.floors?.append(floorNode)
        
        DispatchQueue.main.async {
            self.rootNode?.addChildNode(floorNode)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2
            floorNode.opacity = 0.99 // 1 cause render issue for fading action for unknown reason
            floorNode.position.y = self.groundLevel // Position the floor at the lowest Y-coordinate
            SCNTransaction.commit()
            
            // Use rotation of the wall to rotate the room
            if let wallRotation = self.sceneModel?.walls?.first?.simdRotation {
                floorNode.simdRotation = wallRotation
            }
        }
        
    }
    
    /// Add ceiling to the scene
    func addCeiling() {
        guard let roomNode = scene?.rootNode.childNodes.first else {
            print("Cannot add ceiling")
            return
        }
        let boundingBox = roomNode.boundingBox
        
        let ceilingGeometry = SCNPlane(width: CGFloat(boundingBox.max.x - boundingBox.min.x), height: CGFloat(boundingBox.max.z - boundingBox.min.z))
        let ceilingMaterial = SCNMaterial()
        //        ceilingMaterial.diffuse.contents = .
        ceilingGeometry.materials = [ceilingMaterial]
        
        let ceilingNode = SCNNode(geometry: ceilingGeometry)
        ceilingNode.position.y = self.groundLevel + boundingBox.max.y - boundingBox.min.y // Position the ceiling 2.5 units above the ground level
        ceilingNode.opacity = 0
        self.rootNode?.addChildNode(ceilingNode)
        
        let animationTime = Double.random(in: 2...3.0)
        let fadeIn = SCNAction.fadeIn(duration: animationTime)
        ceilingNode.runAction(fadeIn)
        // Use rotation of the wall to rotate the room
        if let wallRotation = self.sceneModel?.walls?.first?.simdRotation {
            ceilingNode.simdRotation = wallRotation
        }
        ceilingNode.eulerAngles.x = .pi / 2
    }
    
    /// Style a node with a MaterialResource
    func styleNode(node: SCNNode, with resource: MaterialResource) {
        let pbrMaterial = SCNMaterial()
        if let diffuseImage = resource.diffuse {
            pbrMaterial.diffuse.contents = diffuseImage
        }
        if  let metalnessImage = resource.metalness {
            pbrMaterial.metalness.contents = metalnessImage
        }
        if let normalImage = resource.normal {
            pbrMaterial.normal.contents = normalImage
        }
        if let roughnessImage = resource.roughness {
            pbrMaterial.roughness.contents = roughnessImage
        }
        if let glossImage = resource.gloss {
            pbrMaterial.specular.contents = glossImage
        }
        if let reflectionImage = resource.reflection {
            pbrMaterial.reflective.contents = reflectionImage
        }
        pbrMaterial.lightingModel = .physicallyBased
        
        DispatchQueue.main.async {
            node.geometry?.materials = [pbrMaterial]
        }
    }
    
}

//
//  SceneLoader.swift
//  DingDong
//
//  Created by Minh Huynh on 2/18/25.
//

import SwiftUI
import SceneKit
import RealityKit
import RoomPlan
//import FirebaseStorage

/// A SceneLoader to load any scene
class SceneLoader: ObservableObject {
    
    /// Setup
    @Published var scene: SCNScene? // The only scene
    @Published var sceneModel: SceneModel? // The scene model associate with the scene
    @Published var isAutoenablesDefaultLighting = true
    
    private(set) lazy var rootNode = scene?.rootNode // Root node of the scene
    private(set) var groundLevel: Float = 0.0 // Ground level of the scene
    
    /// Load the scene
    func loadScene(from sceneURL: URL?, floor floorResource: MaterialResource? = nil) async {
//        let sceneURL = try? await UserManager.shared.downloadRoomAsync(fileRef: fileRef)
        
        guard let sceneURL = sceneURL, let scene = try? SCNScene(url: sceneURL, options: nil) else {
            return
        }
        // Do not async this so that the below code is execute after this line
        DispatchQueue.main.async {
            self.scene = scene
            // Access the root node of the scene
            let rootNode = scene.rootNode
            
            if let floorResource = floorResource {
                self.addFloor(infinity: true, from: floorResource)
            }
            
            self.groundLevel = self.findLowestYCoordinate(in: rootNode)
            
            let bathtubNodes = self.findNodes(withNamePrefix: "Bathtub", in: rootNode)
            let bedNodes = self.findNodes(withNamePrefix: "Bed", in: rootNode)
            let chairNodes = self.findNodes(withNamePrefix: "Chair", in: rootNode)
            let dishwasherNodes = self.findNodes(withNamePrefix: "Dishwasher", in: rootNode)
            let fireplaceNodes = self.findNodes(withNamePrefix: "Fireplace", in: rootNode)
            let ovenNodes = self.findNodes(withNamePrefix: "Oven", in: rootNode)
            let refrigeratorNodes = self.findNodes(withNamePrefix: "Refrigerator", in: rootNode)
            let sinkNodes = self.findNodes(withNamePrefix: "Sink", in: rootNode)
            let sofaNodes = self.findNodes(withNamePrefix: "Sofa", in: rootNode)
            let stairsNodes = self.findNodes(withNamePrefix: "Stairs", in: rootNode)
            let storageNodes = self.findNodes(withNamePrefix: "Storage", in: rootNode)
            let stoveNodes = self.findNodes(withNamePrefix: "Stove", in: rootNode)
            let tableNodes = self.findNodes(withNamePrefix: "Table", in: rootNode)
            let televisionNodes = self.findNodes(withNamePrefix: "Television", in: rootNode)
            let toiletNodes = self.findNodes(withNamePrefix: "Toilet", in: rootNode)
            let washerDryerNodes = self.findNodes(withNamePrefix: "WasherDryer", in: rootNode)
            let wallsNodes = self.findNodes(withNamePrefix: "Wall", in: rootNode)
            let doorClosedNodes = self.findNodes(withNamePrefix: "DoorClosed", in: rootNode)
            let doorOpenedNodes = self.findNodes(withNamePrefix: "DoorOpened", in: rootNode)
            let windowNodes = self.findNodes(withNamePrefix: "Window", in: rootNode)
            
            self.sceneModel = SceneModel(
                bathtubs: bathtubNodes,
                beds: bedNodes,
                chairs: chairNodes,
                dishwashers: dishwasherNodes,
                fireplaces: fireplaceNodes,
                ovens: ovenNodes,
                refridgerator: refrigeratorNodes,
                sinks: sinkNodes,
                sofas: sofaNodes,
                stairs: stairsNodes,
                storages: storageNodes,
                stoves: stoveNodes,
                tables: tableNodes,
                televisions: televisionNodes,
                toilets: toiletNodes,
                washerDryers: washerDryerNodes,
                walls: wallsNodes,
                windows: windowNodes,
                doorsClosed: doorClosedNodes,
                doorsOpened: doorOpenedNodes
            )
            print("Scene Loaded")
        }
    }

    /// Find lowest Y Coordinate in the scene
    func findLowestYCoordinate(in rootNode: SCNNode) -> Float {
        var lowestY: Float = Float.greatestFiniteMagnitude
        // Finding the lowest of all object gives false value (Walls bounding box is lower than expected), therefore only find the bounding box of Room node
        rootNode.childNodes.forEach { node in
            let boundingBox = node.boundingBox
            lowestY = min(lowestY, boundingBox.min.y)
        }
        return lowestY
    }

    /// Find all nodes within a node recursively with a prefix
    func findNodes(withNamePrefix namePrefix: String, in node: SCNNode) -> [SCNNode] {
        var foundNodes: [SCNNode] = []
        
        for child in node.childNodes {
            if child.name?.hasPrefix(namePrefix) == true, child.name?.hasSuffix("_grp") == false  {
                foundNodes.append(child)
            }
            
            foundNodes.append(contentsOf: findNodes(withNamePrefix: namePrefix, in: child))
        }
        
        return foundNodes
    }

    /// Find the nearest wall from a point
    func findNearestWall(from point: SCNVector3) -> SCNNode? {
        guard let walls = sceneModel?.walls else { return nil }
        
        var nearestWall: SCNNode?
        var shortestDistance: Float = .greatestFiniteMagnitude
        
        for wall in walls {
            let wallCenter = wall.position
            let distance = SCNVector3.distanceFrom(vector: wallCenter, toVector: point)
            
            if distance < shortestDistance {
                shortestDistance = distance
                nearestWall = wall
            }
        }
        
        return nearestWall
    }
    
    /// Hide a wall
    func hideWall(_ wall: SCNNode?) {
        if let wallToHide = wall {
            if wallToHide.opacity != 1 {
                return
            }
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            sceneModel?.walls?.forEach({ wall in
                if wall != wallToHide {
                    wall.opacity = 1
                }
            })
            wallToHide.opacity = 0
            SCNTransaction.commit()
        }
    }
    
    /// Hide all walls
    func hideWalls(_ walls: [SCNNode]?) {
        if let wallsToHide = walls {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            // Only unhide the wall not currently hidden
            sceneModel?.walls?.filter({!wallsToHide.contains($0)}).forEach({ wall in
                wall.opacity = 1
            })
            wallsToHide.filter({$0.opacity == 1}).forEach { wallToHide in
                wallToHide.opacity = 0.01
            }
            SCNTransaction.commit()
        }
    }
    
    /// Show all walls
    func showAllWalls() {
        sceneModel?.walls?.forEach({ wall in
            wall.opacity = 1
        })
    }
}


#Preview {
    ContentView()
}

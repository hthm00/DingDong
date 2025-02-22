//
//  SceneModel.swift
//  DingDong
//
//  Created by Minh Huynh on 2/17/25.
//

import RoomPlan
import SceneKit


struct SceneModel {
    var bathtubs: [SCNNode]?
    var beds: [SCNNode]?
    var chairs: [SCNNode]?
    var dishwashers: [SCNNode]?
    var fireplaces: [SCNNode]?
    var ovens: [SCNNode]?
    var refridgerator: [SCNNode]?
    var sinks: [SCNNode]?
    var sofas: [SCNNode]?
    var stairs: [SCNNode]?
    var storages: [SCNNode]?
    var stoves: [SCNNode]?
    var tables: [SCNNode]?
    var televisions: [SCNNode]?
    var toilets: [SCNNode]?
    var washerDryers: [SCNNode]?
    
    var walls: [SCNNode]?
    var floors: [SCNNode]?
    var ceilings: [SCNNode]?
    var windows: [SCNNode]?
    var doorsClosed: [SCNNode]?
    var doorsOpened: [SCNNode]?
}

extension SceneModel {
    func nodes(forCategory category: CapturedRoom.Object.Category) -> [SCNNode]? {
        switch category {
        case .storage: return storages
        case .refrigerator: return refridgerator
        case .stove: return stoves
        case .bed: return beds
        case .sink: return sinks
        case .washerDryer: return washerDryers
        case .toilet: return toilets
        case .bathtub: return bathtubs
        case .oven: return ovens
        case .dishwasher: return dishwashers
        case .table: return tables
        case .sofa: return sofas
        case .chair: return chairs
        case .fireplace: return fireplaces
        case .television: return televisions
        case .stairs: return stairs
        @unknown default:
            return nil
        }
    }
    
    func nodes(forCategory category: CapturedRoom.Surface.Category) -> [SCNNode]? {
        switch category {
        case .wall:
            return walls
        case .opening:
            return nil
        case .window:
            return windows
        case .door(isOpen: true):
            return doorsOpened
        case .door(isOpen: false):
            return doorsClosed
        case .floor:
            return floors
        @unknown default:
            return nil
        }
    }
    
    static func getName(forCategory category: CapturedRoom.Object.Category) -> String {
        switch category {
        case .storage: return "Storage"
        case .refrigerator: return "Refridgerator"
        case .stove: return "Stove"
        case .bed: return "Bed"
        case .sink: return "Sink"
        case .washerDryer: return "WasherDryer"
        case .toilet: return "Toilet"
        case .bathtub: return "Bathtub"
        case .oven: return "Oven"
        case .dishwasher: return "Dishwasher"
        case .table: return "Table"
        case .sofa: return "Sofa"
        case .chair: return "Chair"
        case .fireplace: return "Fireplace"
        case .television: return "Television"
        case .stairs: return "Stair"
        @unknown default:
            return ""
        }
    }
    
    mutating func updateNodes(_ nodes: [SCNNode], forCategory category: CapturedRoom.Object.Category) {
        switch category {
        case .storage: storages = nodes
        case .refrigerator: refridgerator = nodes
        case .stove: stoves = nodes
        case .bed: beds = nodes
        case .sink: sinks = nodes
        case .washerDryer: washerDryers = nodes
        case .toilet: toilets = nodes
        case .bathtub: bathtubs = nodes
        case .oven: ovens = nodes
        case .dishwasher: dishwashers = nodes
        case .table: tables = nodes
        case .sofa: sofas = nodes
        case .chair: chairs = nodes
        case .fireplace: fireplaces = nodes
        case .television: televisions = nodes
        case .stairs: stairs = nodes
        @unknown default:
            return
        }
    }
    
    mutating func updateNodes(_ nodes: [SCNNode], forCategory category: CapturedRoom.Surface.Category) {
        switch category {
        case .wall: walls = nodes
        case .opening:  return
        case .window: windows = nodes
        case .door(isOpen: true): doorsOpened = nodes
        case .door(isOpen: false): doorsClosed = nodes
        case .floor: floors = nodes
        @unknown default:
            return
        }
    }
}

struct MaterialResource {
    var diffuse: UIImage?
    var normal: UIImage?
    var metalness: UIImage?
    var roughness: UIImage?
    var gloss: UIImage?
    var reflection: UIImage?
}

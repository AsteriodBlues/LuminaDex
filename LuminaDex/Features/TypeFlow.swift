//
//  TypeFlow.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

struct TypeFlow: Identifiable, Hashable {
    let id = UUID()
    let startNode: RegionNode
    let endNode: RegionNode
    let dominantType: PokemonType
    let flowStrength: Float
    let typeColor: Color
    let phaseOffset: CGFloat
    let particleCount: Int
    let pulseFrequency: CGFloat
    
    static func generateFlows(between nodes: [RegionNode]) -> [TypeFlow] {
        var flows: [TypeFlow] = []
        
        for i in 0..<nodes.count {
            for j in (i+1)..<nodes.count {
                let nodeA = nodes[i]
                let nodeB = nodes[j]
                let strength = nodeA.connectionStrength(to: nodeB)
                
                if strength > 0.3 {
                    let sharedTypes = Set(nodeA.dominantTypes).intersection(Set(nodeB.dominantTypes))
                    
                    if let dominantType = sharedTypes.randomElement() ?? nodeA.dominantTypes.randomElement() {
                        let flow = TypeFlow(
                            startNode: nodeA,
                            endNode: nodeB,
                            dominantType: dominantType,
                            flowStrength: strength,
                            typeColor: nodeA.energyColor(for: dominantType),
                            phaseOffset: CGFloat.random(in: 0...(2 * .pi)),
                            particleCount: Int(strength * 5) + 2,
                            pulseFrequency: CGFloat.random(in: 0.8...2.0)
                        )
                        flows.append(flow)
                        
                        // Create bidirectional flow for strong connections
                        if strength > 0.6, let reverseType = nodeB.dominantTypes.randomElement() {
                            let reverseFlow = TypeFlow(
                                startNode: nodeB,
                                endNode: nodeA,
                                dominantType: reverseType,
                                flowStrength: strength * 0.7,
                                typeColor: nodeB.energyColor(for: reverseType),
                                phaseOffset: CGFloat.random(in: 0...(2 * .pi)),
                                particleCount: Int(strength * 3) + 1,
                                pulseFrequency: CGFloat.random(in: 1.0...2.5)
                            )
                            flows.append(reverseFlow)
                        }
                    }
                }
            }
        }
        
        return flows
    }
    
    func calculateFlowPath() -> Path {
        Path { path in
            path.move(to: startNode.position)
            
            let distance = sqrt(
                pow(endNode.position.x - startNode.position.x, 2) +
                pow(endNode.position.y - startNode.position.y, 2)
            )
            
            let curveIntensity = min(distance * 0.3, 120) * CGFloat(flowStrength)
            
            let midX = (startNode.position.x + endNode.position.x) / 2
            let midY = (startNode.position.y + endNode.position.y) / 2
            
            let perpX = -(endNode.position.y - startNode.position.y) / distance
            let perpY = (endNode.position.x - startNode.position.x) / distance
            
            let controlPoint1 = CGPoint(
                x: startNode.position.x + perpX * curveIntensity * 0.5,
                y: startNode.position.y + perpY * curveIntensity * 0.5
            )
            
            let controlPoint2 = CGPoint(
                x: endNode.position.x + perpX * curveIntensity * 0.5,
                y: endNode.position.y + perpY * curveIntensity * 0.5
            )
            
            path.addCurve(
                to: endNode.position,
                control1: controlPoint1,
                control2: controlPoint2
            )
        }
    }
    
    func flowIntensity(at time: CGFloat) -> CGFloat {
        let baseIntensity = CGFloat(flowStrength)
        let pulse = sin(time * pulseFrequency + phaseOffset) * 0.3 + 1.0
        return baseIntensity * pulse
    }
    
    func particlePositions(at time: CGFloat) -> [CGPoint] {
        var positions: [CGPoint] = []
        
        for i in 0..<particleCount {
            let particlePhase = CGFloat(i) / CGFloat(particleCount)
            let progress = (time * 0.1 + phaseOffset + particlePhase * 2 * .pi)
                .truncatingRemainder(dividingBy: 2 * .pi) / (2 * .pi)
            
            let position = interpolateAlongCurve(progress: progress)
            positions.append(position)
        }
        
        return positions
    }
    
    private func interpolateAlongCurve(progress: CGFloat) -> CGPoint {
        let t = max(0, min(1, progress))
        
        let distance = sqrt(
            pow(endNode.position.x - startNode.position.x, 2) +
            pow(endNode.position.y - startNode.position.y, 2)
        )
        
        let curveIntensity = min(distance * 0.3, 120) * CGFloat(flowStrength)
        let perpX = -(endNode.position.y - startNode.position.y) / distance
        let perpY = (endNode.position.x - startNode.position.x) / distance
        
        let controlPoint1 = CGPoint(
            x: startNode.position.x + perpX * curveIntensity * 0.5,
            y: startNode.position.y + perpY * curveIntensity * 0.5
        )
        
        let controlPoint2 = CGPoint(
            x: endNode.position.x + perpX * curveIntensity * 0.5,
            y: endNode.position.y + perpY * curveIntensity * 0.5
        )
        
        // Cubic Bezier interpolation
        let oneMinusT = 1 - t
        let x = oneMinusT * oneMinusT * oneMinusT * startNode.position.x +
                3 * oneMinusT * oneMinusT * t * controlPoint1.x +
                3 * oneMinusT * t * t * controlPoint2.x +
                t * t * t * endNode.position.x
        
        let y = oneMinusT * oneMinusT * oneMinusT * startNode.position.y +
                3 * oneMinusT * oneMinusT * t * controlPoint1.y +
                3 * oneMinusT * t * t * controlPoint2.y +
                t * t * t * endNode.position.y
        
        return CGPoint(x: x, y: y)
    }
}

struct FlowParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var size: CGFloat
    var opacity: CGFloat
    var color: Color
    var lifespan: CGFloat
    var age: CGFloat = 0
    
    mutating func update(deltaTime: CGFloat) {
        age += deltaTime
        position.x += velocity.dx * deltaTime
        position.y += velocity.dy * deltaTime
        
        let lifeProgress = age / lifespan
        opacity = max(0, 1 - lifeProgress * lifeProgress)
        size *= 0.998
    }
    
    var isAlive: Bool {
        age < lifespan && opacity > 0.01
    }
}
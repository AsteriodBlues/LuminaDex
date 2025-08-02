//
//  NeuralFlowMapView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

/// Main map view displaying Pokemon regions as interconnected neural network nodes
/// Features infinite space navigation, particle systems, living sprites, and interactive region exploration
struct NeuralFlowMapView: View {
    // MARK: - State Management
    @State private var regionNodes: [RegionNode] = []
    @State private var energyFlows: [TypeFlow] = []
    @State private var cameraOffset = CGSize.zero
    @State private var zoomScale: CGFloat = 1.0
    @State private var selectedRegion: RegionNode?
    @State private var animationPhase: CGFloat = 0
    @State private var isLoaded = false
    
    // MARK: - Sprite System
    @StateObject private var spriteManager = SpritePopulationManager()
    @State private var lastUpdateTime: TimeInterval = Date().timeIntervalSince1970
    
    // MARK: - Day 14 Features
    @StateObject private var migrationManager = MigrationManager()
    @StateObject private var guardianManager = LegendaryGuardianManager()
    
    var body: some View {
        ZStack {
            // Infinite void background
            ThemeManager.Colors.spaceGradient
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap background to deselect
                    withAnimation(ThemeManager.Animation.springBouncy) {
                        selectedRegion = nil
                    }
                }
            
            // Particle star field
            StarFieldView(
                offset: cameraOffset,
                zoom: zoomScale
            )
            
            // Neural network canvas
            Canvas { context, size in
                context.translateBy(x: cameraOffset.width, y: cameraOffset.height)
                context.scaleBy(x: zoomScale, y: zoomScale)
                
                // Draw energy streams between regions
                drawEnergyStreams(context: context, size: size)
                
                // Draw pulsing region nodes
                drawRegionNodes(context: context, size: size)
            }
            
            // Living sprite layer with 120fps updates
            TimelineView(.animation(minimumInterval: 1.0/120.0, paused: false)) { timeline in
                SpriteLayer(
                    sprites: spriteManager.getVisibleSprites(
                        cameraOffset: cameraOffset,
                        zoomScale: zoomScale,
                        screenSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    ),
                    cameraOffset: cameraOffset,
                    zoomScale: zoomScale
                )
                .onChange(of: timeline.date) { _ in
                    updateSpriteSystem()
                }
            }
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            zoomScale = max(0.5, min(3.0, value))
                        },
                    DragGesture()
                        .onChanged { value in
                            cameraOffset = CGSize(
                                width: cameraOffset.width + value.translation.width * 0.5,
                                height: cameraOffset.height + value.translation.height * 0.5
                            )
                        }
                )
            )
            
            // Floating region cards
            ForEach(regionNodes.filter { isNodeVisible($0) }) { node in
                RegionBubbleCard(
                    region: node,
                    isSelected: selectedRegion?.id == node.id,
                    activeSpriteCount: getSpriteCountForRegion(node.name),
                    spriteTypeDistribution: getSpriteTypeDistribution(node.name)
                )
                .position(
                    x: node.position.x * zoomScale + cameraOffset.width + (selectedRegion?.id == node.id ? adjustedXOffset(for: node) : 0),
                    y: node.position.y * zoomScale + cameraOffset.height + (selectedRegion?.id == node.id ? adjustedYOffset(for: node) : 0)
                )
                .scaleEffect(zoomScale * 0.8)
                .zIndex(selectedRegion?.id == node.id ? 1000 : Double(regionNodes.count - (regionNodes.firstIndex(of: node) ?? 0)))
                .onTapGesture {
                    withAnimation(ThemeManager.Animation.springBouncy) {
                        selectedRegion = selectedRegion?.id == node.id ? nil : node
                        
                        // Trigger sprite celebration when region is selected
                        if selectedRegion?.id == node.id {
                            spriteManager.celebrateRegion(node.name)
                        }
                    }
                }
            }
            
            // Control overlay
            VStack {
                HStack {
                    Button("Reset View") {
                        withAnimation(ThemeManager.Animation.springSmooth) {
                            cameraOffset = .zero
                            zoomScale = 1.0
                            selectedRegion = nil
                        }
                    }
                    .padding()
                    .background(ThemeManager.Colors.glassMaterial)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            setupNeuralNetwork()
            startAnimations()
            setupSpriteSystem()
        }
    }
    
    private func setupNeuralNetwork() {
        regionNodes = RegionNode.createNetworkLayout()
        energyFlows = TypeFlow.generateFlows(between: regionNodes)
        
        withAnimation(.easeInOut(duration: 1.5)) {
            isLoaded = true
        }
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
    }
    
    private func setupSpriteSystem() {
        // Populate regions with sprites after neural network is established
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            spriteManager.populateRegions(regionNodes)
        }
    }
    
    private func updateSpriteSystem() {
        let currentTime = Date().timeIntervalSince1970
        let deltaTime = min(currentTime - lastUpdateTime, 0.016) // Cap at 16ms for stability
        lastUpdateTime = currentTime
        
        // Update sprite physics and behaviors
        spriteManager.updateSprites(
            deltaTime: deltaTime,
            regions: regionNodes,
            flows: energyFlows
        )
    }
    
    private func isNodeVisible(_ node: RegionNode) -> Bool {
        true // Simplified for now - could add culling logic
    }
    
    /// Get active sprite count for a specific region
    private func getSpriteCountForRegion(_ regionName: String) -> Int {
        return spriteManager.sprites.filter { sprite in
            sprite.regionAffinity == regionName && sprite.isActive
        }.count
    }
    
    /// Get sprite type distribution for a specific region
    private func getSpriteTypeDistribution(_ regionName: String) -> [PokemonType: Int] {
        let regionSprites = spriteManager.sprites.filter { sprite in
            sprite.regionAffinity == regionName && sprite.isActive
        }
        
        var distribution: [PokemonType: Int] = [:]
        for sprite in regionSprites {
            distribution[sprite.type, default: 0] += 1
        }
        
        return distribution
    }
    
    private func adjustedXOffset(for node: RegionNode) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let currentX = node.position.x * zoomScale + cameraOffset.width
        
        // Push card away from screen edges when expanded
        if currentX < screenWidth * 0.3 {
            return 60 // Push right
        } else if currentX > screenWidth * 0.7 {
            return -60 // Push left
        }
        return 0
    }
    
    private func adjustedYOffset(for node: RegionNode) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let currentY = node.position.y * zoomScale + cameraOffset.height
        
        // Push card away from screen edges when expanded
        if currentY < screenHeight * 0.25 {
            return 80 // Push down
        } else if currentY > screenHeight * 0.75 {
            return -80 // Push up
        }
        return 0
    }
    
    private func drawEnergyStreams(context: GraphicsContext, size: CGSize) {
        for flow in energyFlows {
            let path = createFlowPath(from: flow.startNode.position, to: flow.endNode.position)
            
            // Animated gradient along the path
            let gradient = Gradient(colors: [
                flow.typeColor.opacity(0.0),
                flow.typeColor.opacity(0.8),
                flow.typeColor.opacity(0.3),
                flow.typeColor.opacity(0.0)
            ])
            
            context.stroke(
                path,
                with: .linearGradient(
                    gradient,
                    startPoint: flow.startNode.position,
                    endPoint: flow.endNode.position
                ),
                style: StrokeStyle(
                    lineWidth: 2.0 + sin(animationPhase + flow.phaseOffset) * 1.0,
                    lineCap: .round
                )
            )
            
            // Add flowing particles
            drawFlowParticles(context: context, flow: flow)
        }
    }
    
    private func createFlowPath(from start: CGPoint, to end: CGPoint) -> Path {
        Path { path in
            path.move(to: start)
            
            // Create curved connection with control points
            let midX = (start.x + end.x) / 2
            let midY = (start.y + end.y) / 2
            let distance = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
            let curveOffset = min(distance * 0.3, 100)
            
            let controlPoint1 = CGPoint(
                x: start.x + (end.y - start.y) * curveOffset / distance,
                y: start.y - (end.x - start.x) * curveOffset / distance
            )
            
            let controlPoint2 = CGPoint(
                x: end.x + (end.y - start.y) * curveOffset / distance,
                y: end.y - (end.x - start.x) * curveOffset / distance
            )
            
            path.addCurve(to: end, control1: controlPoint1, control2: controlPoint2)
        }
    }
    
    private func drawFlowParticles(context: GraphicsContext, flow: TypeFlow) {
        let particleCount = 3
        let pathLength = 1.0
        
        for i in 0..<particleCount {
            let progress = (animationPhase + flow.phaseOffset + CGFloat(i) * 0.3).truncatingRemainder(dividingBy: 2 * .pi) / (2 * .pi)
            let position = interpolateAlongPath(
                from: flow.startNode.position,
                to: flow.endNode.position,
                progress: progress
            )
            
            let particleSize: CGFloat = 4.0 + sin(animationPhase * 2 + CGFloat(i)) * 2.0
            let particleRect = CGRect(
                x: position.x - particleSize/2,
                y: position.y - particleSize/2,
                width: particleSize,
                height: particleSize
            )
            
            context.fill(
                Path(ellipseIn: particleRect),
                with: .color(flow.typeColor.opacity(0.8))
            )
        }
    }
    
    private func interpolateAlongPath(from start: CGPoint, to end: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(
            x: start.x + (end.x - start.x) * progress,
            y: start.y + (end.y - start.y) * progress
        )
    }
    
    private func drawRegionNodes(context: GraphicsContext, size: CGSize) {
        for node in regionNodes {
            let pulseScale = 1.0 + sin(animationPhase * 2 + node.phaseOffset) * 0.2
            let nodeSize = node.baseSize * pulseScale
            
            // Outer glow
            let glowRect = CGRect(
                x: node.position.x - nodeSize * 0.75,
                y: node.position.y - nodeSize * 0.75,
                width: nodeSize * 1.5,
                height: nodeSize * 1.5
            )
            
            context.fill(
                Path(ellipseIn: glowRect),
                with: .radialGradient(
                    Gradient(colors: [
                        node.primaryColor.opacity(0.3),
                        node.primaryColor.opacity(0.0)
                    ]),
                    center: node.position,
                    startRadius: 0,
                    endRadius: nodeSize * 0.75
                )
            )
            
            // Core node
            let coreRect = CGRect(
                x: node.position.x - nodeSize/2,
                y: node.position.y - nodeSize/2,
                width: nodeSize,
                height: nodeSize
            )
            
            context.fill(
                Path(ellipseIn: coreRect),
                with: .radialGradient(
                    Gradient(colors: [
                        node.primaryColor.opacity(0.9),
                        node.secondaryColor.opacity(0.6),
                        node.primaryColor.opacity(0.3)
                    ]),
                    center: node.position,
                    startRadius: 0,
                    endRadius: nodeSize/2
                )
            )
            
            // Inner highlight
            let highlightRect = CGRect(
                x: node.position.x - nodeSize * 0.3,
                y: node.position.y - nodeSize * 0.3,
                width: nodeSize * 0.6,
                height: nodeSize * 0.6
            )
            
            context.fill(
                Path(ellipseIn: highlightRect),
                with: .color(Color.white.opacity(0.3))
            )
        }
    }
}

#Preview {
    NeuralFlowMapView()
        .preferredColorScheme(.dark)
}
//
//  MapSprite.swift
//  LuminaDex
//

import SwiftUI

/// Represents a sprite entity on the neural network map
/// Handles position, movement, and visual representation
struct MapSprite: Identifiable, Equatable {
    let id = UUID()
    var pokemonId: Int
    var spriteURL: String
    var type: PokemonType
    
    // Spatial properties
    var position: CGPoint
    var velocity: CGPoint = .zero
    var targetPosition: CGPoint?
    
    // Visual properties
    var scale: CGFloat = 1.0
    var opacity: CGFloat = 1.0
    var rotation: Angle = .zero
    
    // Behavior properties
    var movementPattern: MovementPattern
    var regionAffinity: String
    var isActive: Bool = true
    var lastUpdateTime: TimeInterval = 0
    
    // Interaction states
    var isCelebrating: Bool = false
    var isHighlighted: Bool = false
    var celebrationStartTime: TimeInterval = 0
    
    // Physics constants
    static let maxSpeed: CGFloat = 30.0
    static let dampening: CGFloat = 0.98
    static let arrivalRadius: CGFloat = 15.0
    static let smoothingFactor: CGFloat = 0.1
    
    enum MovementPattern: CaseIterable {
        case orbiting      // Circles around neural nodes
        case wandering     // Random walk within region bounds
        case flowing       // Follows energy streams
        case stationed     // Stays near specific coordinates
        
        var baseSpeed: CGFloat {
            switch self {
            case .orbiting: return 20.0
            case .wandering: return 10.0
            case .flowing: return 25.0
            case .stationed: return 3.0
            }
        }
    }
    
    /// Update sprite physics and movement
    mutating func update(deltaTime: TimeInterval, regionNodes: [RegionNode], energyFlows: [TypeFlow]) {
        lastUpdateTime += deltaTime
        
        switch movementPattern {
        case .orbiting:
            updateOrbitalMovement(deltaTime: deltaTime, nodes: regionNodes)
        case .wandering:
            updateWanderingMovement(deltaTime: deltaTime, nodes: regionNodes)
        case .flowing:
            updateFlowingMovement(deltaTime: deltaTime, flows: energyFlows)
        case .stationed:
            updateStationedMovement(deltaTime: deltaTime)
        }
        
        // Apply smooth physics with interpolation
        let smoothDelta = min(deltaTime, 0.016) // Cap delta time for stability
        
        position.x += velocity.x * smoothDelta
        position.y += velocity.y * smoothDelta
        
        // Smooth dampening
        velocity.x *= Self.dampening
        velocity.y *= Self.dampening
        
        // Update visual properties based on movement
        updateVisualProperties()
        
        // Handle celebration animation
        if isCelebrating {
            updateCelebrationAnimation(deltaTime: deltaTime)
        }
    }
    
    private mutating func updateOrbitalMovement(deltaTime: TimeInterval, nodes: [RegionNode]) {
        guard let homeNode = nodes.first(where: { $0.name == regionAffinity }) else { return }
        
        let baseRadius: CGFloat = 80.0
        let radiusVariation = CGFloat(sin(lastUpdateTime * 0.5)) * 15.0
        let orbitRadius = baseRadius + radiusVariation
        
        // Smooth orbital speed
        let orbitSpeed = movementPattern.baseSpeed * 0.01 // Much slower for smooth rotation
        
        // Calculate smooth orbital position
        let angle = lastUpdateTime * orbitSpeed
        let targetX = homeNode.position.x + CGFloat(cos(angle)) * orbitRadius
        let targetY = homeNode.position.y + CGFloat(sin(angle)) * orbitRadius
        
        // Direct position update for smoother orbiting
        let lerpFactor: CGFloat = 0.05
        position.x = position.x + (targetX - position.x) * lerpFactor
        position.y = position.y + (targetY - position.y) * lerpFactor
    }
    
    private mutating func updateWanderingMovement(deltaTime: TimeInterval, nodes: [RegionNode]) {
        // Change direction periodically
        if Int(lastUpdateTime * 2) % 5 == 0 && targetPosition == nil {
            let randomAngle = Double.random(in: 0...(2 * .pi))
            let wanderDistance: CGFloat = 100.0
            
            targetPosition = CGPoint(
                x: position.x + CGFloat(cos(randomAngle)) * wanderDistance,
                y: position.y + CGFloat(sin(randomAngle)) * wanderDistance
            )
        }
        
        seekTarget(deltaTime: deltaTime)
        
        // Reset target when reached
        if let target = targetPosition,
           distance(from: position, to: target) < Self.arrivalRadius {
            targetPosition = nil
        }
    }
    
    private mutating func updateFlowingMovement(deltaTime: TimeInterval, flows: [TypeFlow]) {
        // Find compatible energy flow based on type
        let compatibleFlows = flows.filter { flow in
            // Sprites prefer flows that match their type
            return flow.startNode.dominantTypes.contains(type) || 
                   flow.endNode.dominantTypes.contains(type)
        }
        
        guard let nearestFlow = compatibleFlows.min(by: { flow1, flow2 in
            let dist1 = min(
                distance(from: position, to: flow1.startNode.position),
                distance(from: position, to: flow1.endNode.position)
            )
            let dist2 = min(
                distance(from: position, to: flow2.startNode.position),
                distance(from: position, to: flow2.endNode.position)
            )
            return dist1 < dist2
        }) else { return }
        
        // Move along the flow path
        let progress = sin(lastUpdateTime * 0.5) * 0.5 + 0.5
        targetPosition = interpolateAlongFlow(
            from: nearestFlow.startNode.position,
            to: nearestFlow.endNode.position,
            progress: progress
        )
        
        seekTarget(deltaTime: deltaTime)
    }
    
    private mutating func updateStationedMovement(deltaTime: TimeInterval) {
        // Gentle bobbing motion while stationed
        let bobAmount: CGFloat = 5.0
        let bobSpeed = lastUpdateTime * 2.0
        
        if targetPosition == nil {
            targetPosition = CGPoint(
                x: position.x,
                y: position.y + CGFloat(sin(bobSpeed)) * bobAmount
            )
        }
        
        seekTarget(deltaTime: deltaTime)
    }
    
    private mutating func seekTarget(deltaTime: TimeInterval) {
        guard let target = targetPosition else { return }
        
        let direction = CGPoint(
            x: target.x - position.x,
            y: target.y - position.y
        )
        
        let distance = sqrt(direction.x * direction.x + direction.y * direction.y)
        
        if distance > 0 {
            let normalizedDirection = CGPoint(
                x: direction.x / distance,
                y: direction.y / distance
            )
            
            let speed = min(movementPattern.baseSpeed, distance / deltaTime)
            
            velocity.x += normalizedDirection.x * speed * deltaTime
            velocity.y += normalizedDirection.y * speed * deltaTime
            
            // Clamp velocity
            let currentSpeed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            if currentSpeed > Self.maxSpeed {
                velocity.x = (velocity.x / currentSpeed) * Self.maxSpeed
                velocity.y = (velocity.y / currentSpeed) * Self.maxSpeed
            }
        }
    }
    
    private mutating func updateVisualProperties() {
        let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        
        // Scale based on movement speed and interaction states
        var baseScale: CGFloat = 0.8 + (speed / Self.maxSpeed) * 0.4
        
        // Enhance scale for highlighted or celebrating sprites
        if isHighlighted {
            baseScale *= 1.2
        }
        if isCelebrating {
            let celebrationTime = lastUpdateTime - celebrationStartTime
            baseScale *= 1.0 + sin(celebrationTime * 8) * 0.3
        }
        
        scale = baseScale
        
        // Rotation based on velocity direction
        if speed > 1.0 {
            rotation = Angle(radians: atan2(velocity.y, velocity.x))
        }
        
        // Opacity based on activity and interaction states
        var baseOpacity: CGFloat = isActive ? 1.0 : 0.6
        if isHighlighted {
            baseOpacity = min(baseOpacity * 1.3, 1.0)
        }
        opacity = baseOpacity
    }
    
    // Helper functions
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
    }
    
    private func interpolateAlongFlow(from start: CGPoint, to end: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(
            x: start.x + (end.x - start.x) * progress,
            y: start.y + (end.y - start.y) * progress
        )
    }
    
    static func == (lhs: MapSprite, rhs: MapSprite) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Interaction Methods
    
    /// Trigger celebration animation
    mutating func triggerCelebration() {
        isCelebrating = true
        celebrationStartTime = lastUpdateTime
        
        // Add upward velocity for celebration jump
        velocity.y -= 20.0
        
        // Celebration will auto-stop in updateCelebrationAnimation
    }
    
    /// Set highlight state for region interactions
    mutating func setHighlighted(_ highlighted: Bool) {
        isHighlighted = highlighted
    }
    
    /// Update celebration animation over time
    private mutating func updateCelebrationAnimation(deltaTime: TimeInterval) {
        let celebrationDuration: TimeInterval = 2.0
        let elapsed = lastUpdateTime - celebrationStartTime
        
        if elapsed > celebrationDuration {
            isCelebrating = false
        }
    }
}

/// Manages sprite population and spawning for regions with performance optimizations
class SpritePopulationManager: ObservableObject {
    @Published var sprites: [MapSprite] = []
    
    private var lastUpdateTime: TimeInterval = 0
    private let maxSpritesPerRegion = 8 // Reduced for better performance
    private let spawnCooldown: TimeInterval = 3.0
    private var lastSpawnTime: TimeInterval = 0
    
    // Performance optimization: sprite pooling
    private var spritePool: [MapSprite] = []
    private let maxPoolSize = 100
    
    // Culling optimization
    private var visibleSprites: [MapSprite] = []
    private var lastCullTime: TimeInterval = 0
    private let cullInterval: TimeInterval = 0.1 // Cull every 100ms
    
    /// Initialize sprites for all regions
    func populateRegions(_ regions: [RegionNode]) {
        sprites.removeAll()
        
        for region in regions {
            let spriteCount = min(maxSpritesPerRegion, region.pokemonCount / 10)
            spawnSpritesForRegion(region, count: spriteCount)
        }
    }
    
    /// Spawn sprites in a specific region using object pooling
    private func spawnSpritesForRegion(_ region: RegionNode, count: Int) {
        let regionTypes = Array(region.dominantTypes)
        
        for i in 0..<count {
            let randomType = regionTypes.randomElement() ?? .normal
            let movementPattern = MapSprite.MovementPattern.allCases.randomElement() ?? .wandering
            
            // Generate spawn position around region node
            let spawnRadius: CGFloat = 60.0
            let angle = Double(i) * (2.0 * .pi / Double(count)) + Double.random(in: -0.5...0.5)
            let spawnPosition = CGPoint(
                x: region.position.x + CGFloat(cos(angle)) * spawnRadius * CGFloat.random(in: 0.5...1.0),
                y: region.position.y + CGFloat(sin(angle)) * spawnRadius * CGFloat.random(in: 0.5...1.0)
            )
            
            // Try to reuse sprite from pool first
            var sprite: MapSprite
            if let pooledSprite = spritePool.popLast() {
                // Reuse existing sprite with fresh properties
                sprite = pooledSprite
                sprite.pokemonId = Int.random(in: 1...1010)
                sprite.spriteURL = "placeholder_sprite_\(randomType.rawValue)"
                sprite.type = randomType
                sprite.position = spawnPosition
                sprite.velocity = .zero
                sprite.targetPosition = nil
                sprite.scale = 1.0
                sprite.opacity = 1.0
                sprite.rotation = .zero
                sprite.movementPattern = movementPattern
                sprite.regionAffinity = region.name
                sprite.isActive = true
                sprite.lastUpdateTime = 0
            } else {
                // Create new sprite
                sprite = MapSprite(
                    pokemonId: Int.random(in: 1...1010),
                    spriteURL: "placeholder_sprite_\(randomType.rawValue)",
                    type: randomType,
                    position: spawnPosition,
                    movementPattern: movementPattern,
                    regionAffinity: region.name
                )
            }
            
            sprites.append(sprite)
        }
    }
    
    /// Update all sprites with physics and behaviors (optimized)
    func updateSprites(deltaTime: TimeInterval, regions: [RegionNode], flows: [TypeFlow]) {
        lastUpdateTime += deltaTime
        
        // Update only active sprites
        for i in sprites.indices where sprites[i].isActive {
            sprites[i].update(deltaTime: deltaTime, regionNodes: regions, energyFlows: flows)
        }
        
        // Optimized culling with pooling - only run every cullInterval
        if lastUpdateTime - lastCullTime > cullInterval {
            cullDistantSprites()
            lastCullTime = lastUpdateTime
        }
        
        // Spawn new sprites periodically
        if lastUpdateTime - lastSpawnTime > spawnCooldown {
            attemptRespawn(regions)
            lastSpawnTime = lastUpdateTime
        }
    }
    
    /// Cull distant sprites and return them to pool
    private func cullDistantSprites() {
        var indicesToRemove: [Int] = []
        
        for (index, sprite) in sprites.enumerated() {
            let distance = sqrt(sprite.position.x * sprite.position.x + sprite.position.y * sprite.position.y)
            
            if distance > 2000 || !sprite.isActive {
                // Return sprite to pool
                if spritePool.count < maxPoolSize {
                    var pooledSprite = sprite
                    pooledSprite.isActive = false
                    pooledSprite.velocity = .zero
                    spritePool.append(pooledSprite)
                }
                indicesToRemove.append(index)
            }
        }
        
        // Remove culled sprites (in reverse order to maintain indices)
        for index in indicesToRemove.reversed() {
            sprites.remove(at: index)
        }
    }
    
    private func attemptRespawn(_ regions: [RegionNode]) {
        let currentSpriteCount = sprites.count
        let targetSpriteCount = regions.count * (maxSpritesPerRegion / 2)
        
        if currentSpriteCount < targetSpriteCount {
            let regionToSpawn = regions.randomElement()!
            spawnSpritesForRegion(regionToSpawn, count: 1)
        }
    }
    
    /// Get sprites visible within camera bounds (optimized with caching)
    func getVisibleSprites(cameraOffset: CGSize, zoomScale: CGFloat, screenSize: CGSize) -> [MapSprite] {
        // Expand visible bounds slightly for smoother transitions
        let margin: CGFloat = 100.0
        let visibleBounds = CGRect(
            x: -cameraOffset.width / zoomScale - screenSize.width / (2 * zoomScale) - margin,
            y: -cameraOffset.height / zoomScale - screenSize.height / (2 * zoomScale) - margin,
            width: screenSize.width / zoomScale + margin * 2,
            height: screenSize.height / zoomScale + margin * 2
        )
        
        // Only check active sprites for visibility
        let activeSprites = sprites.filter { $0.isActive }
        
        // Batch visibility check with early exit for performance
        var visibleSprites: [MapSprite] = []
        visibleSprites.reserveCapacity(min(activeSprites.count, 50)) // Reserve reasonable capacity
        
        for sprite in activeSprites {
            if visibleBounds.contains(sprite.position) {
                visibleSprites.append(sprite)
                
                // Cap visible sprites for performance
                if visibleSprites.count >= 50 { break }
            }
        }
        
        return visibleSprites
    }
    
    /// Get performance metrics for debugging
    func getPerformanceMetrics() -> (totalSprites: Int, activeSprites: Int, pooledSprites: Int) {
        let activeCount = sprites.filter { $0.isActive }.count
        return (sprites.count, activeCount, spritePool.count)
    }
    
    /// Trigger celebration animation for sprites in a specific region
    func celebrateRegion(_ regionName: String) {
        for i in sprites.indices {
            if sprites[i].regionAffinity == regionName && sprites[i].isActive {
                sprites[i].triggerCelebration()
            }
        }
    }
    
    /// Make sprites react to region card hover
    func highlightRegion(_ regionName: String, isHighlighted: Bool) {
        for i in sprites.indices {
            if sprites[i].regionAffinity == regionName && sprites[i].isActive {
                sprites[i].setHighlighted(isHighlighted)
            }
        }
    }
}
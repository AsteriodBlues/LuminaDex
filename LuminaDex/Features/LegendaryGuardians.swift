//
//  LegendaryGuardians.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

// MARK: - Legendary Guardian System

class LegendaryGuardianManager: ObservableObject {
    @Published var guardians: [LegendaryGuardian] = []
    @Published var mysteryMarkers: [MysteryMarker] = []
    
    private var guardianTimer: Timer?
    private var animationPhase: CGFloat = 0
    
    init() {
        setupLegendaryGuardians()
        startGuardianAnimations()
    }
    
    private func setupLegendaryGuardians() {
        guardians = [
            LegendaryGuardian(
                id: UUID(),
                name: "Mewtwo",
                emoji: "🧬",
                region: "Kanto",
                position: CGPoint(x: 100, y: 150),
                primaryColor: .purple,
                secondaryColor: .pink,
                guardianType: .psychic,
                powerLevel: .legendary,
                isAwakened: false
            ),
            LegendaryGuardian(
                id: UUID(),
                name: "Lugia",
                emoji: "🌊",
                region: "Johto",
                position: CGPoint(x: 250, y: 200),
                primaryColor: .blue,
                secondaryColor: .white,
                guardianType: .flying,
                powerLevel: .legendary,
                isAwakened: false
            ),
            LegendaryGuardian(
                id: UUID(),
                name: "Rayquaza",
                emoji: "🐉",
                region: "Hoenn",
                position: CGPoint(x: 400, y: 100),
                primaryColor: .green,
                secondaryColor: .yellow,
                guardianType: .dragon,
                powerLevel: .legendary,
                isAwakened: false
            ),
            LegendaryGuardian(
                id: UUID(),
                name: "Dialga",
                emoji: "⏰",
                region: "Sinnoh",
                position: CGPoint(x: 150, y: 350),
                primaryColor: .blue,
                secondaryColor: .silver,
                guardianType: .time,
                powerLevel: .legendary,
                isAwakened: false
            ),
            LegendaryGuardian(
                id: UUID(),
                name: "Reshiram",
                emoji: "🔥",
                region: "Unova",
                position: CGPoint(x: 300, y: 400),
                primaryColor: .white,
                secondaryColor: .orange,
                guardianType: .fire,
                powerLevel: .legendary,
                isAwakened: false
            ),
            LegendaryGuardian(
                id: UUID(),
                name: "Xerneas",
                emoji: "🦌",
                region: "Kalos",
                position: CGPoint(x: 500, y: 250),
                primaryColor: .blue,
                secondaryColor: .purple,
                guardianType: .fairy,
                powerLevel: .legendary,
                isAwakened: false
            )
        ]
        
        setupMysteryMarkers()
    }
    
    private func setupMysteryMarkers() {
        mysteryMarkers = [
            MysteryMarker(
                id: UUID(),
                position: CGPoint(x: 200, y: 100),
                markerType: .hiddenPower,
                isRevealed: false
            ),
            MysteryMarker(
                id: UUID(),
                position: CGPoint(x: 350, y: 300),
                markerType: .ancientRuin,
                isRevealed: false
            ),
            MysteryMarker(
                id: UUID(),
                position: CGPoint(x: 450, y: 150),
                markerType: .temporalRift,
                isRevealed: false
            )
        ]
    }
    
    private func startGuardianAnimations() {
        guardianTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.updateGuardianAnimations()
        }
    }
    
    private func updateGuardianAnimations() {
        animationPhase += 0.02
        
        // Randomly awaken sleeping guardians
        if Int.random(in: 0...1000) == 1 {
            awakenRandomGuardian()
        }
        
        // Update guardian states
        for guardian in guardians {
            guardian.updateAnimationPhase(animationPhase)
        }
    }
    
    private func awakenRandomGuardian() {
        let sleepingGuardians = guardians.filter { !$0.isAwakened }
        guard let guardian = sleepingGuardians.randomElement() else { return }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
            guardian.awaken()
        }
        
        // Return to sleep after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            withAnimation(.easeOut(duration: 2.0)) {
                guardian.sleep()
            }
        }
    }
    
    func triggerLegendaryEvent(at region: String) {
        let regionGuardians = guardians.filter { $0.region == region }
        
        for guardian in regionGuardians {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                guardian.awaken()
                guardian.activatePower()
            }
        }
        
        // Create temporary mystery markers around the region
        createTemporaryMysteries(around: region)
    }
    
    private func createTemporaryMysteries(around region: String) {
        // Find region position and create mysteries around it
        let regionCenter = CGPoint(x: CGFloat.random(in: 100...500), y: CGFloat.random(in: 100...400))
        
        for i in 0..<3 {
            let angle = CGFloat(i) * .pi * 2 / 3
            let radius: CGFloat = 80
            let mysteryPosition = CGPoint(
                x: regionCenter.x + cos(angle) * radius,
                y: regionCenter.y + sin(angle) * radius
            )
            
            let mystery = MysteryMarker(
                id: UUID(),
                position: mysteryPosition,
                markerType: .legendaryEssence,
                isRevealed: true
            )
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                mysteryMarkers.append(mystery)
            }
            
            // Remove after 1 minute
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                withAnimation(.easeOut(duration: 1.0)) {
                    self.mysteryMarkers.removeAll { $0.id == mystery.id }
                }
            }
        }
    }
}

// MARK: - Legendary Guardian Model

class LegendaryGuardian: ObservableObject, Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let region: String
    let position: CGPoint
    let primaryColor: Color
    let secondaryColor: Color
    let guardianType: GuardianType
    let powerLevel: PowerLevel
    
    @Published var isAwakened: Bool = false
    @Published var isPowerActive: Bool = false
    @Published var animationPhase: CGFloat = 0
    @Published var glowIntensity: CGFloat = 0.3
    @Published var scale: CGFloat = 1.0
    @Published var rotation: CGFloat = 0
    
    init(id: UUID, name: String, emoji: String, region: String, position: CGPoint, primaryColor: Color, secondaryColor: Color, guardianType: GuardianType, powerLevel: PowerLevel, isAwakened: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.region = region
        self.position = position
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.guardianType = guardianType
        self.powerLevel = powerLevel
        self.isAwakened = isAwakened
    }
    
    func updateAnimationPhase(_ phase: CGFloat) {
        animationPhase = phase
        
        if isAwakened {
            glowIntensity = 0.6 + sin(phase * 2) * 0.3
            scale = 1.0 + sin(phase * 1.5) * 0.1
            
            if isPowerActive {
                rotation += 0.02
                glowIntensity = 0.9 + sin(phase * 4) * 0.1
            }
        } else {
            glowIntensity = 0.2 + sin(phase * 0.5) * 0.1
            scale = 0.8 + sin(phase * 0.3) * 0.05
        }
    }
    
    func awaken() {
        isAwakened = true
    }
    
    func sleep() {
        isAwakened = false
        isPowerActive = false
    }
    
    func activatePower() {
        isPowerActive = true
        
        // Deactivate after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.isPowerActive = false
        }
    }
}

// MARK: - Guardian Types

enum GuardianType {
    case psychic, flying, dragon, time, fire, fairy
    
    var particleEffect: String {
        switch self {
        case .psychic: return "✨"
        case .flying: return "💨"
        case .dragon: return "🔥"
        case .time: return "⏰"
        case .fire: return "🔥"
        case .fairy: return "🌟"
        }
    }
    
    var auraColor: Color {
        switch self {
        case .psychic: return .purple
        case .flying: return .cyan
        case .dragon: return .green
        case .time: return .blue
        case .fire: return .red
        case .fairy: return .pink
        }
    }
}

enum PowerLevel {
    case legendary, mythical, ultrabeast
    
    var intensity: CGFloat {
        switch self {
        case .legendary: return 1.0
        case .mythical: return 1.5
        case .ultrabeast: return 2.0
        }
    }
}

// MARK: - Mystery Marker System

struct MysteryMarker: Identifiable {
    let id: UUID
    let position: CGPoint
    let markerType: MysteryType
    var isRevealed: Bool
    
    var pulseSpeed: CGFloat {
        switch markerType {
        case .hiddenPower: return 1.0
        case .ancientRuin: return 0.5
        case .temporalRift: return 2.0
        case .legendaryEssence: return 1.5
        }
    }
}

enum MysteryType {
    case hiddenPower, ancientRuin, temporalRift, legendaryEssence
    
    var emoji: String {
        switch self {
        case .hiddenPower: return "💎"
        case .ancientRuin: return "🗿"
        case .temporalRift: return "🌀"
        case .legendaryEssence: return "✨"
        }
    }
    
    var color: Color {
        switch self {
        case .hiddenPower: return .purple
        case .ancientRuin: return .brown
        case .temporalRift: return .blue
        case .legendaryEssence: return .gold
        }
    }
}

// MARK: - Guardian View Component

struct LegendaryGuardianView: View {
    @ObservedObject var guardian: LegendaryGuardian
    let cameraOffset: CGSize
    let zoomScale: CGFloat
    
    private var auraGradient: RadialGradient {
        RadialGradient(
            colors: [
                guardian.guardianType.auraColor.opacity(0.6),
                guardian.guardianType.auraColor.opacity(0.3),
                Color.clear
            ],
            center: .center,
            startRadius: 10,
            endRadius: 60
        )
    }
    
    var body: some View {
        ZStack {
            // Guardian aura
            if guardian.isAwakened {
                Circle()
                    .fill(auraGradient)
                    .frame(width: 120 * zoomScale, height: 120 * zoomScale)
                    .scaleEffect(guardian.scale)
                    .blur(radius: 5)
            }
            
            // Power particles
            if guardian.isPowerActive {
                ForEach(0..<8, id: \.self) { i in
                    let angle = guardian.rotation + CGFloat(i) * .pi / 4
                    let radius = 40 * zoomScale
                    let xOffset = cos(angle) * radius
                    let yOffset = sin(angle) * radius
                    let opacity = 0.7 + sin(guardian.animationPhase * 3 + CGFloat(i)) * 0.3
                    
                    Text(guardian.guardianType.particleEffect)
                        .font(.system(size: 12 * zoomScale))
                        .offset(x: xOffset, y: yOffset)
                        .opacity(opacity)
                }
            }
            
            // Guardian sprite
            Text(guardian.emoji)
                .font(.system(size: 32 * zoomScale))
                .scaleEffect(guardian.scale)
                .rotationEffect(.radians(guardian.rotation * 0.1))
                .shadow(
                    color: guardian.primaryColor.opacity(guardian.glowIntensity),
                    radius: 10 * zoomScale
                )
            
            // Guardian name (when awakened)
            if guardian.isAwakened {
                Text(guardian.name)
                    .font(.caption)
                    .foregroundColor(guardian.primaryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.7))
                    )
                    .offset(y: 40 * zoomScale)
                    .scaleEffect(zoomScale * 0.8)
            }
        }
        .position(
            x: guardian.position.x * zoomScale + cameraOffset.width,
            y: guardian.position.y * zoomScale + cameraOffset.height
        )
    }
}

// MARK: - Mystery Marker View

struct MysteryMarkerView: View {
    let marker: MysteryMarker
    let animationPhase: CGFloat
    let cameraOffset: CGSize
    let zoomScale: CGFloat
    
    var body: some View {
        ZStack {
            // Mystery glow
            if marker.isRevealed {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                marker.markerType.color.opacity(0.6),
                                marker.markerType.color.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30 * zoomScale
                        )
                    )
                    .frame(width: 60 * zoomScale, height: 60 * zoomScale)
                    .scaleEffect(1.0 + sin(animationPhase * marker.pulseSpeed) * 0.3)
            }
            
            // Mystery marker
            Text(marker.markerType.emoji)
                .font(.system(size: 20 * zoomScale))
                .scaleEffect(1.0 + sin(animationPhase * marker.pulseSpeed) * 0.2)
                .opacity(marker.isRevealed ? 1.0 : 0.3)
        }
        .position(
            x: marker.position.x * zoomScale + cameraOffset.width,
            y: marker.position.y * zoomScale + cameraOffset.height
        )
    }
}

extension Color {
    static let silver = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let rainbow = LinearGradient(
        colors: [.red, .orange, .yellow, .green, .blue, .purple],
        startPoint: .leading,
        endPoint: .trailing
    )
}
//
//  EvolutionChainView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI
import Foundation

// MARK: - Supporting Data Models

struct EvolutionStage: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let stageNumber: Int
    let spriteURL: String
    let types: [PokemonType]
    let primaryColor: Color
    let requirements: [EvolutionRequirement]
    let stats: [Int] // Simplified stats array
    
    static func == (lhs: EvolutionStage, rhs: EvolutionStage) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct EvolutionRequirement: Identifiable, Hashable {
    let id = UUID()
    let type: RequirementType
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    static func == (lhs: EvolutionRequirement, rhs: EvolutionRequirement) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum RequirementType: CaseIterable {
    case level, item, trade, time, happiness, location, move, weather, special
}

// MARK: - Supporting Systems

class EvolutionParticleSystem: ObservableObject {
    @Published var particles: [QuantumParticle] = []
    @Published var isActive: Bool = false
    
    struct QuantumParticle {
        var position: CGPoint
        var velocity: CGPoint
        var size: CGFloat
        var opacity: Double
        var color: Color
        var age: Double = 0
        var lifespan: Double
    }
    
    func start() {
        isActive = true
        generateParticles()
    }
    
    func stop() {
        isActive = false
        particles.removeAll()
    }
    
    func burst() {
        generateBurstParticles()
    }
    
    func update() {
        particles = particles.compactMap { particle in
            var updated = particle
            updated.age += 0.016 // ~60fps
            updated.position.x += updated.velocity.x
            updated.position.y += updated.velocity.y
            updated.opacity = max(0, 1.0 - (updated.age / updated.lifespan))
            
            return updated.age < updated.lifespan ? updated : nil
        }
    }
    
    private func generateParticles() {
        for _ in 0..<50 {
            particles.append(QuantumParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                velocity: CGPoint(
                    x: CGFloat.random(in: -2...2),
                    y: CGFloat.random(in: -2...2)
                ),
                size: CGFloat.random(in: 2...6),
                opacity: CGFloat.random(in: 0.3...0.8),
                color: [ThemeManager.Colors.neural, ThemeManager.Colors.plasma, ThemeManager.Colors.aurora].randomElement() ?? ThemeManager.Colors.neural,
                lifespan: Double.random(in: 2...5)
            ))
        }
    }
    
    private func generateBurstParticles() {
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        
        for _ in 0..<100 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 50...150)
            
            particles.append(QuantumParticle(
                position: center,
                velocity: CGPoint(
                    x: CGFloat(cos(angle)) * speed,
                    y: CGFloat(sin(angle)) * speed
                ),
                size: CGFloat.random(in: 3...10),
                opacity: 1.0,
                color: [ThemeManager.Colors.neural, ThemeManager.Colors.plasma, ThemeManager.Colors.aurora].randomElement() ?? ThemeManager.Colors.neural,
                lifespan: 3.0
            ))
        }
    }
}

class SoundEngine: ObservableObject {
    func playInteraction() {
        // Placeholder for sound feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func playTransition() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func playEvolution() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
}

struct MeshPoint {
    let position: CGPoint
    let color: Color
    let radius: CGFloat
    let phase: CGFloat
}

enum GeometricShape: CaseIterable {
    case triangle, square, circle, diamond, hexagon
}

// MARK: - Custom Button Styles

struct QuantumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Evolution Engine

class EvolutionEngine: ObservableObject {
    @Published var evolutionChain: [EvolutionStage] = []
    
    func generateEvolutionChain(for pokemon: Pokemon) {
        // Generate sample evolution chain based on Pokemon
        evolutionChain = createSampleChain(for: pokemon)
    }
    
    private func createSampleChain(for pokemon: Pokemon) -> [EvolutionStage] {
        return [
            EvolutionStage(
                name: pokemon.displayName,
                stageNumber: 1,
                spriteURL: pokemon.sprites.officialArtwork,
                types: pokemon.types.map { $0.type },
                primaryColor: pokemon.primaryType.color,
                requirements: [],
                stats: pokemon.stats.map { $0.baseStat }
            ),
            EvolutionStage(
                name: "\(pokemon.displayName) Stage 2",
                stageNumber: 2,
                spriteURL: pokemon.sprites.officialArtwork,
                types: pokemon.types.map { $0.type },
                primaryColor: pokemon.primaryType.color.opacity(0.8),
                requirements: [
                    EvolutionRequirement(
                        type: .level,
                        title: "Level 16",
                        description: "Reach level 16 through battles",
                        icon: "arrow.up.circle",
                        color: ThemeManager.Colors.aurora
                    )
                ],
                stats: pokemon.stats.map { $0.baseStat + 20 }
            ),
            EvolutionStage(
                name: "\(pokemon.displayName) Final",
                stageNumber: 3,
                spriteURL: pokemon.sprites.officialArtwork,
                types: pokemon.types.map { $0.type },
                primaryColor: pokemon.primaryType.color.opacity(0.6),
                requirements: [
                    EvolutionRequirement(
                        type: .level,
                        title: "Level 36",
                        description: "Reach level 36 with high friendship",
                        icon: "star.circle",
                        color: .yellow
                    )
                ],
                stats: pokemon.stats.map { $0.baseStat + 50 }
            )
        ]
    }
}

// MARK: - Main Evolution Chain View

struct EvolutionChainView: View {
    let pokemon: Pokemon
    
    @State private var selectedStage: EvolutionStage? = nil
    @State private var animationPhase: CGFloat = 0
    @State private var morphingProgress: CGFloat = 0
    @State private var particlePhase: CGFloat = 0
    @State private var comparisonMode: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var isTransforming: Bool = false
    @State private var transformationIntensity: CGFloat = 0
    @State private var cardScale: CGFloat = 1.0
    @State private var glowIntensity: CGFloat = 0.3
    @State private var energyPulse: CGFloat = 0
    @State private var hologramOffset: CGSize = .zero
    @State private var magneticForce: CGFloat = 0
    
    @StateObject private var evolutionEngine = EvolutionEngine()
    @StateObject private var particleSystem = EvolutionParticleSystem() // Fixed: Added this line
    @State private var showParticles = true
    @StateObject private var soundEngine = SoundEngine()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ultra-modern cosmic background
                cosmicBackground(size: geometry.size)
                
                // Main content
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .frame(height: 70)
                        .zIndex(1000)
                    
                    // Evolution stages with proper scrolling
                    TabView(selection: $selectedStage) {
                        ForEach(evolutionEngine.evolutionChain, id: \.id) { stage in
                            evolutionStageView(stage: stage, screenSize: geometry.size)
                                .tag(stage)
                                .id(stage.id) // Ensure proper identification
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .onAppear {
                        // Auto-select first stage if none selected
                        if selectedStage == nil && !evolutionEngine.evolutionChain.isEmpty {
                            selectedStage = evolutionEngine.evolutionChain.first
                        }
                    }
                    
                    // Bottom interface
                    bottomInterface
                        .frame(height: 120)
                        .zIndex(1000)
                }
                
                // Particle effects
                if particleSystem.isActive {
                    particleLayer
                }
                
                // Comparison overlay
                if comparisonMode {
                    comparisonOverlay
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.2).combined(with: .opacity)
                        ))
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            initializeView()
        }
        .onChange(of: selectedStage) { _, newStage in
            handleStageChange(to: newStage)
        }
    }
    
    // MARK: - Background Components
    
    private func cosmicBackground(size: CGSize) -> some View {
        ZStack {
            // Base gradient
            ThemeManager.Colors.spaceGradient
                .ignoresSafeArea()
            
            // Dynamic star field
            StarFieldView(offset: .zero, zoom: 1.0)
                .opacity(0.6)
            
            // Floating geometric elements
            ForEach(0..<8, id: \.self) { index in
                geometricFloater(index: index, size: size)
            }
        }
    }
    
    private func geometricFloater(index: Int, size: CGSize) -> some View {
        let shapes = ["triangle", "square", "circle", "diamond"]
        let shape = shapes[index % shapes.count]
        let floatRadius: CGFloat = 100 + CGFloat(index) * 30
        let floatSpeed = 0.5 + Double(index) * 0.2
        
        return Image(systemName: shape == "triangle" ? "triangle" :
                    shape == "square" ? "square" :
                    shape == "circle" ? "circle" : "diamond")
            .font(.system(size: 20 + CGFloat(index) * 3))
            .foregroundColor(ThemeManager.Colors.neural.opacity(0.1))
            .offset(
                x: CGFloat(cos(animationPhase * floatSpeed + Double(index))) * floatRadius,
                y: CGFloat(sin(animationPhase * floatSpeed + Double(index))) * floatRadius
            )
            .position(x: size.width / 2, y: size.height / 2)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            // Back button
            Button(action: {
                soundEngine.playTransition()
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ThemeManager.Colors.lumina)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(QuantumButtonStyle())
            
            Spacer()
            
            // Title
            holographicTitle
            
            Spacer()
            
            // Comparison toggle
            Button(action: {
                soundEngine.playInteraction()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    comparisonMode.toggle()
                }
            }) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(comparisonMode ? ThemeManager.Colors.neural : ThemeManager.Colors.lumina)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(
                                        comparisonMode ? ThemeManager.Colors.neural : Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    )
            }
            .buttonStyle(QuantumButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ThemeManager.Colors.neural.opacity(0.5),
                                    ThemeManager.Colors.plasma.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: ThemeManager.Colors.neural.opacity(0.3), radius: 20, y: 10)
        )
    }
    
    private var holographicTitle: some View {
        ZStack {
            Text("EVOLUTION")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(ThemeManager.Colors.lumina)
                .tracking(4)
            
            Text("EVOLUTION")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(ThemeManager.Colors.neural)
                .tracking(4)
                .offset(x: CGFloat(sin(animationPhase * 2.0)) * 2.0, y: CGFloat(cos(animationPhase * 2.0)) * 1.0)
                .opacity(0.6)
                .blendMode(.screen)
        }
        .offset(hologramOffset)
    }
    
    // MARK: - Evolution Stage View
    
    private func evolutionStageView(stage: EvolutionStage, screenSize: CGSize) -> some View {
        GeometryReader { geometry in
            let offset = geometry.frame(in: .global).minX
            let progress = offset / screenSize.width
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 40)
                    
                    // Pokemon showcase
                    pokemonShowcase(stage: stage, parallaxOffset: progress)
                    
                    // Stage info
                    stageInfo(stage: stage)
                    
                    // Expanded details
                    if selectedStage?.id == stage.id {
                        expandedDetails(stage: stage)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                                removal: .scale(scale: 1.2).combined(with: .opacity).combined(with: .move(edge: .top))
                            ))
                    }
                    
                    Spacer(minLength: 100)
                }
                .frame(minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
            .scaleEffect(1.0 - abs(progress) * 0.05)
            .rotation3DEffect(
                .degrees(progress * 10),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.9
            )
            .opacity(1.0 - abs(progress) * 0.2)
        }
        .frame(width: screenSize.width)
        .clipped() // Ensure content doesn't overflow bounds
    }
    
    // MARK: - Pokemon Showcase
    
    private func pokemonShowcase(stage: EvolutionStage, parallaxOffset: CGFloat) -> some View {
        ZStack {
            // Platform
            platformView(stage: stage)
            
            // Pokemon display
            pokemonDisplay(stage: stage, parallaxOffset: parallaxOffset)
            
            // Orbital rings
            orbitalRings(stage: stage)
        }
        .frame(maxWidth: .infinity) // Ensure centered
        .onTapGesture {
            triggerStageSelection(stage: stage)
        }
    }
    
    private func platformView(stage: EvolutionStage) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            stage.primaryColor.opacity(0.2),
                            stage.primaryColor.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
            
            Circle()
                .stroke(
                    stage.primaryColor.opacity(0.4),
                    style: StrokeStyle(
                        lineWidth: 2,
                        dash: [10, 15],
                        dashPhase: animationPhase * 20
                    )
                )
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(animationPhase * 10))
        }
        .scaleEffect(1.0 + CGFloat(sin(animationPhase * 0.5)) * 0.05)
    }
    
    private func pokemonDisplay(stage: EvolutionStage, parallaxOffset: CGFloat) -> some View {
        AsyncImage(url: URL(string: stage.spriteURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .offset(
                    x: CGFloat(sin(animationPhase * 0.3)) * 8.0 + parallaxOffset * 20.0,
                    y: CGFloat(cos(animationPhase * 0.4)) * 6.0
                )
                .scaleEffect(cardScale)
                .shadow(
                    color: stage.primaryColor.opacity(glowIntensity),
                    radius: 20,
                    x: 0,
                    y: 10
                )
        } placeholder: {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                stage.primaryColor.opacity(0.3),
                                stage.primaryColor.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                
                Text(stage.name.prefix(1))
                    .font(.system(size: 80, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(stage.primaryColor.opacity(0.8))
                    .shadow(color: stage.primaryColor, radius: 10)
            }
        }
    }
    
    private func orbitalRings(stage: EvolutionStage) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { ring in
                let radius: CGFloat = 140 + CGFloat(ring) * 40
                let speed = 1.0 + Double(ring) * 0.3
                let opacity = 0.4 - Double(ring) * 0.1
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                stage.primaryColor.opacity(opacity),
                                Color.clear,
                                stage.primaryColor.opacity(opacity * 0.5),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [15, 25]
                        )
                    )
                    .frame(width: radius, height: radius)
                    .rotationEffect(.degrees(animationPhase * speed * (ring % 2 == 0 ? 1 : -1)))
            }
        }
        .opacity(selectedStage?.id == stage.id ? 1.0 : 0.3)
        .animation(.easeInOut(duration: 1.5), value: selectedStage?.id)
    }
    
    // MARK: - Stage Info
    
    private func stageInfo(stage: EvolutionStage) -> some View {
        VStack(spacing: 16) {
            quantumText(stage.name, size: 28, weight: .bold)
            
            quantumText("STAGE \(stage.stageNumber)", size: 12, weight: .medium, tracking: 3)
                .foregroundColor(stage.primaryColor)
                .opacity(0.8)
            
            HStack(spacing: 16) {
                ForEach(stage.types.prefix(2), id: \.self) { type in
                    typeBadge(type: type)
                }
            }
        }
        .frame(maxWidth: .infinity) // Ensure centered alignment
        .multilineTextAlignment(.center)
    }
    
    private func quantumText(_ text: String, size: CGFloat, weight: Font.Weight, tracking: CGFloat = 1) -> some View {
        ZStack {
            Text(text)
                .font(.system(size: size, weight: weight, design: .monospaced))
                .foregroundColor(ThemeManager.Colors.lumina)
                .tracking(tracking)
            
            Text(text)
                .font(.system(size: size, weight: weight, design: .monospaced))
                .foregroundColor(ThemeManager.Colors.neural)
                .tracking(tracking)
                .opacity(0.3)
                .blur(radius: 2)
                .offset(x: CGFloat(sin(animationPhase)) * 1.0, y: CGFloat(cos(animationPhase * 1.3)) * 0.5)
        }
    }
    
    private func typeBadge(type: PokemonType) -> some View {
        HStack(spacing: 8) {
            Image(systemName: type.icon)
                .font(.system(size: 14, weight: .medium))
            
            Text(type.displayName)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .tracking(1)
        }
        .foregroundColor(ThemeManager.Colors.lumina)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    type.color.opacity(0.8),
                                    type.color.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: type.color.opacity(0.3), radius: 8)
        )
        .scaleEffect(1.0 + CGFloat(sin(animationPhase + CGFloat(type.hashValue))) * 0.02)
    }
    
    // MARK: - Expanded Details
    
    private func expandedDetails(stage: EvolutionStage) -> some View {
        VStack(spacing: 24) {
            // Stats display
            statsDisplay(stage: stage)
            
            // Requirements
            if !stage.requirements.isEmpty {
                requirementsView(stage: stage)
            }
        }
    }
    
    private func statsDisplay(stage: EvolutionStage) -> some View {
        HStack(spacing: 20) {
            ForEach(["HP", "ATK", "DEF", "SPD"], id: \.self) { statName in
                let value = getStatValue(for: statName, stage: stage)
                
                VStack(spacing: 12) {
                    ZStack {
                        Text("\(value)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(ThemeManager.Colors.lumina)
                        
                        Text("\(value)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(stage.primaryColor)
                            .opacity(0.5)
                            .blur(radius: 1)
                            .offset(x: CGFloat(sin(animationPhase * 2.0)) * 1.0)
                    }
                    
                    Text(statName)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
                        .tracking(2)
                    
                    progressBar(value: value, maxValue: 255, color: stage.primaryColor)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    stage.primaryColor.opacity(0.5),
                                    Color.clear,
                                    stage.primaryColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: stage.primaryColor.opacity(0.2), radius: 20)
        )
    }
    
    private func progressBar(value: Int, maxValue: Int, color: Color) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color.opacity(0.1))
                .frame(width: 50, height: 6)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 50 * CGFloat(value) / CGFloat(maxValue), height: 6)
                .animation(.easeOut(duration: 1.5), value: value)
        }
    }
    
    private func requirementsView(stage: EvolutionStage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(stage.primaryColor)
                
                Text("EVOLUTION REQUIREMENTS")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(ThemeManager.Colors.lumina)
                    .tracking(1)
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                ForEach(stage.requirements, id: \.id) { requirement in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(requirement.color.opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: requirement.icon)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(requirement.color)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(requirement.title)
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(ThemeManager.Colors.lumina)
                            
                            Text(requirement.description)
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(stage.primaryColor.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: stage.primaryColor.opacity(0.2), radius: 8)
        )
    }
    
    // MARK: - Bottom Interface
    
    private var bottomInterface: some View {
        VStack(spacing: 20) {
            // Timeline
            timeline
            
            // Action buttons
            actionButtons
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    private var timeline: some View {
        HStack(spacing: 32) {
            ForEach(Array(evolutionEngine.evolutionChain.enumerated()), id: \.element.id) { index, stage in
                timelineNode(stage: stage, index: index)
            }
        }
        .frame(height: 50)
    }
    
    private func timelineNode(stage: EvolutionStage, index: Int) -> some View {
        HStack {
            Button(action: {
                triggerStageSelection(stage: stage)
            }) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    stage.primaryColor.opacity(selectedStage?.id == stage.id ? 0.6 : 0.2),
                                    stage.primaryColor.opacity(selectedStage?.id == stage.id ? 0.3 : 0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 15
                            )
                        )
                        .frame(width: 30, height: 30)
                    
                    Circle()
                        .fill(selectedStage?.id == stage.id ? stage.primaryColor : ThemeManager.Colors.lumina.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(stage.primaryColor.opacity(0.8), lineWidth: 1)
                        )
                }
            }
            .buttonStyle(QuantumButtonStyle())
            
            if index < evolutionEngine.evolutionChain.count - 1 {
                connection(from: stage, to: evolutionEngine.evolutionChain[index + 1])
            }
        }
    }
    
    private func connection(from: EvolutionStage, to: EvolutionStage) -> some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            from.primaryColor.opacity(0.4),
                            to.primaryColor.opacity(0.4)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(from.primaryColor)
                .frame(width: 20, height: 2)
                .offset(x: CGFloat(sin(animationPhase * 2.0)) * 30.0)
                .opacity(0.8)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            actionButton(
                icon: "sparkles",
                text: "EVOLVE",
                color: ThemeManager.Colors.aurora,
                action: triggerEvolution
            )
            
            actionButton(
                icon: "waveform.path.ecg",
                text: "ANALYZE",
                color: ThemeManager.Colors.plasma,
                action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        comparisonMode.toggle()
                    }
                }
            )
        }
    }
    
    private func actionButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(text)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .tracking(1)
            }
            .foregroundColor(ThemeManager.Colors.lumina)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.6),
                                        Color.clear,
                                        color.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: color.opacity(0.3), radius: 15)
            )
        }
        .buttonStyle(QuantumButtonStyle())
    }
    
    // MARK: - Helper Functions
    
    private var particleLayer: some View {
        Canvas { context, size in
            particleSystem.update()
            
            for particle in particleSystem.particles {
                let rect = CGRect(
                    x: particle.position.x - particle.size/2,
                    y: particle.position.y - particle.size/2,
                    width: particle.size,
                    height: particle.size
                )
                
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(particle.color.opacity(particle.opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Comparison Overlay
    
    private var comparisonOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("QUANTUM ANALYSIS")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(ThemeManager.Colors.lumina)
                    .tracking(3)
                
                if evolutionEngine.evolutionChain.count >= 2 {
                    comparisonChart()
                } else {
                    Text("Analyzing quantum signatures...")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
                        .tracking(1)
                }
                
                Button(action: {
                    soundEngine.playTransition()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        comparisonMode = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ThemeManager.Colors.lumina)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(QuantumButtonStyle())
            }
            .padding(32)
        }
    }
    
    private func comparisonChart() -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                ForEach(evolutionEngine.evolutionChain.prefix(2), id: \.id) { stage in
                    VStack(spacing: 12) {
                        Text(stage.name)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(stage.primaryColor)
                        
                        VStack(spacing: 8) {
                            ForEach(["HP", "ATK", "DEF", "SPD"], id: \.self) { statName in
                                let value = getStatValue(for: statName, stage: stage)
                                HStack {
                                    Text(statName)
                                        .font(.caption)
                                        .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
                                        .frame(width: 30, alignment: .leading)
                                    
                                    progressBar(value: value, maxValue: 255, color: stage.primaryColor)
                                        .frame(width: 80)
                                    
                                    Text("\(value)")
                                        .font(.caption)
                                        .foregroundColor(ThemeManager.Colors.lumina)
                                        .frame(width: 30, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.Colors.neural.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Functions
    
    private func initializeView() {
        evolutionEngine.generateEvolutionChain(for: pokemon)
        
        // Set initial selection to first stage
        DispatchQueue.main.async {
            if let firstStage = evolutionEngine.evolutionChain.first {
                selectedStage = firstStage
            }
        }
        
        withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
        
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            particlePhase = 2 * .pi
        }
        
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            hologramOffset = CGSize(width: 2, height: 1)
        }
        
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
        }
        
        particleSystem.start()
    }
    
    private func handleStageChange(to stage: EvolutionStage?) {
        guard let stage = stage else { return }
        soundEngine.playTransition()
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
            cardScale = 1.1
        }
        
        withAnimation(.easeOut(duration: 2.0)) {
            cardScale = 1.0
        }
    }
    
    private func triggerStageSelection(stage: EvolutionStage) {
        soundEngine.playInteraction()
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            selectedStage = selectedStage?.id == stage.id ? stage : stage // Always select, don't toggle off
            magneticForce = 1.0
        }
        
        withAnimation(.easeOut(duration: 2.0)) {
            magneticForce = 0.0
        }
    }
    
    private func triggerEvolution() {
        soundEngine.playEvolution()
        
        withAnimation(.spring(response: 1.2, dampingFraction: 0.5)) {
            isTransforming = true
            transformationIntensity = 1.0
            energyPulse = 1.0
        }
        
        if let currentStage = selectedStage,
           let currentIndex = evolutionEngine.evolutionChain.firstIndex(where: { $0.id == currentStage.id }),
           currentIndex < evolutionEngine.evolutionChain.count - 1 {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    selectedStage = evolutionEngine.evolutionChain[currentIndex + 1]
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeOut(duration: 2.0)) {
                isTransforming = false
                transformationIntensity = 0.0
                energyPulse = 0.0
            }
        }
        
        particleSystem.burst()
    }
    
    private func getStatValue(for statName: String, stage: EvolutionStage) -> Int {
        let index: Int
        switch statName {
        case "HP": index = 0
        case "ATK": index = 1
        case "DEF": index = 2
        case "SPD": index = 5
        default: index = 0
        }
        
        return index < stage.stats.count ? stage.stats[index] : 0
    }
}

#Preview {
    // Create a sample Pokemon for preview
    let samplePokemon = Pokemon(
        id: 25,
        name: "pikachu",
        height: 4,
        weight: 60,
        baseExperience: 112,
        order: 35,
        isDefault: true,
        sprites: PokemonSprites(
            frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
            frontShiny: nil,
            frontFemale: nil,
            frontShinyFemale: nil,
            backDefault: nil,
            backShiny: nil,
            backFemale: nil,
            backShinyFemale: nil,
            other: nil
        ),
        types: [
            PokemonTypeSlot(slot: 1, type: .electric)
        ],
        abilities: [],
        stats: [
            PokemonStat(baseStat: 35, effort: 0, stat: StatType(name: "hp", url: "")),
            PokemonStat(baseStat: 55, effort: 0, stat: StatType(name: "attack", url: "")),
            PokemonStat(baseStat: 40, effort: 0, stat: StatType(name: "defense", url: "")),
            PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-attack", url: "")),
            PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-defense", url: "")),
            PokemonStat(baseStat: 90, effort: 0, stat: StatType(name: "speed", url: ""))
        ],
        species: PokemonSpecies(name: "pikachu", url: ""),
        moves: [],
        gameIndices: []
    )
    
    EvolutionChainView(pokemon: samplePokemon)
        .preferredColorScheme(.dark)
}

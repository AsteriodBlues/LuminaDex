//
//  EnhancedDNAHelixViewer.swift
//  LuminaDex
//
//  Advanced 3D DNA Helix visualization using Metal
//

import SwiftUI
import MetalKit
import simd
import Combine

// MARK: - Enhanced DNA Helix Viewer

struct EnhancedDNAHelixViewer: View {
    let pokemon: Pokemon
    
    @StateObject private var viewModel = DNAViewModel()
    @State private var dragOffset: CGSize = .zero
    @State private var accumulatedRotation = simd_float2(0, 0)
    @State private var showDetailPanel = false
    @State private var selectedSegment: DNASegment?
    @State private var viewMode: DNAViewMode = .standard
    @State private var particleIntensity: Float = 0.5
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Advanced background with animated gradients
                advancedBackground
                
                VStack(spacing: 0) {
                    // Header with Pokemon info and controls
                    headerSection
                        .padding()
                    
                    // Main 3D DNA visualization
                    ZStack {
                        // Metal rendering view
                        Advanced3DDNAHelixView(
                            pokemon: pokemon,
                            viewModel: viewModel,
                            rotation: accumulatedRotation,
                            viewMode: viewMode,
                            particleIntensity: particleIntensity,
                            selectedSegment: selectedSegment
                        )
                        .frame(height: geometry.size.height * 0.6)
                        .gesture(rotationGesture)
                        .gesture(pinchGesture)
                        .onTapGesture(coordinateSpace: .local) { location in
                            handleTap(at: location, in: geometry.size)
                        }
                        
                        // Overlay UI elements
                        overlayElements
                    }
                    
                    // Control panel
                    controlPanel
                        .padding()
                }
                
                // Detail panel overlay
                if showDetailPanel, let segment = selectedSegment {
                    detailPanelOverlay(for: segment)
                }
            }
        }
        .onAppear {
            viewModel.analyzePokemon(pokemon)
        }
    }
    
    // MARK: - Background
    
    private var advancedBackground: some View {
        ZStack {
            // Dynamic gradient based on Pokemon type
            LinearGradient(
                colors: [
                    pokemon.primaryType.color.opacity(0.15),
                    Color.black.opacity(0.95),
                    pokemon.secondaryType?.color.opacity(0.1) ?? Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particle field
            ParticleFieldView(
                primaryColor: pokemon.primaryType.color,
                particleCount: 50,
                animationSpeed: 0.5
            )
            .opacity(0.3)
            .ignoresSafeArea()
            
            // Holographic grid overlay
            HolographicGridView()
                .opacity(0.1)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Text("\(pokemon.displayName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    pokemon.primaryType.color,
                                    pokemon.primaryType.color.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("DNA Analysis")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack(spacing: 16) {
                    // Status indicators
                    StatusIndicator(
                        title: "Stability",
                        value: viewModel.dnaStability,
                        color: .green
                    )
                    
                    StatusIndicator(
                        title: "Purity",
                        value: viewModel.dnaPurity,
                        color: .blue
                    )
                    
                    StatusIndicator(
                        title: "Evolution",
                        value: viewModel.evolutionPotential,
                        color: .purple
                    )
                }
            }
            
            Spacer()
            
            // View mode selector
            viewModeSelector
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    pokemon.primaryType.color.opacity(0.5),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private var viewModeSelector: some View {
        HStack(spacing: 8) {
            ForEach(DNAViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewMode = mode
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: mode.icon)
                            .font(.title2)
                        Text(mode.title)
                            .font(.caption2)
                    }
                    .foregroundColor(viewMode == mode ? .white : .white.opacity(0.5))
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewMode == mode ? 
                                  pokemon.primaryType.color.opacity(0.3) : 
                                  Color.clear)
                    )
                }
            }
        }
    }
    
    // MARK: - Overlay Elements
    
    private var overlayElements: some View {
        ZStack {
            // Info cards at corners
            VStack {
                HStack {
                    infoCard(
                        title: "Base Pairs",
                        value: "\(viewModel.basePairCount)",
                        icon: "link"
                    )
                    
                    Spacer()
                    
                    infoCard(
                        title: "Mutations",
                        value: "\(viewModel.mutationCount)",
                        icon: "waveform.path.ecg"
                    )
                }
                
                Spacer()
                
                HStack {
                    infoCard(
                        title: "Type Match",
                        value: "\(Int(viewModel.typeMatchPercentage))%",
                        icon: "percent"
                    )
                    
                    Spacer()
                    
                    infoCard(
                        title: "Power Level",
                        value: "\(viewModel.powerLevel)",
                        icon: "bolt.fill"
                    )
                }
            }
            .padding()
        }
    }
    
    private func infoCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(pokemon.primaryType.color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Control Panel
    
    private var controlPanel: some View {
        VStack(spacing: 16) {
            // Interactive controls
            HStack(spacing: 20) {
                // Particle intensity
                VStack(alignment: .leading, spacing: 8) {
                    Label("Particle Effects", systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Slider(value: $particleIntensity, in: 0...1)
                        .accentColor(pokemon.primaryType.color)
                        .frame(width: 150)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Action buttons
                HStack(spacing: 12) {
                    ActionButton(
                        title: "Analyze",
                        icon: "waveform.path.ecg.rectangle",
                        color: pokemon.primaryType.color
                    ) {
                        viewModel.performDeepAnalysis()
                    }
                    
                    ActionButton(
                        title: "Mutate",
                        icon: "atom",
                        color: .purple
                    ) {
                        viewModel.simulateMutation()
                    }
                    
                    ActionButton(
                        title: "Export",
                        icon: "square.and.arrow.up",
                        color: .green
                    ) {
                        viewModel.exportDNAData()
                    }
                }
                
                Spacer()
            }
            
            // Gene sequence visualization
            geneSequenceBar
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var geneSequenceBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gene Sequence Map")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(viewModel.geneSequence) { segment in
                        GeneSegmentView(
                            segment: segment,
                            isSelected: selectedSegment?.id == segment.id,
                            primaryColor: pokemon.primaryType.color
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedSegment = segment
                                showDetailPanel = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 40)
        }
    }
    
    // MARK: - Detail Panel
    
    private func detailPanelOverlay(for segment: DNASegment) -> some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(segment.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showDetailPanel = false
                            selectedSegment = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Text(segment.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 20) {
                    DetailMetric(
                        label: "Expression",
                        value: "\(Int(segment.expression * 100))%",
                        color: segment.typeAffinity.color
                    )
                    
                    DetailMetric(
                        label: "Stability",
                        value: segment.stability.description,
                        color: segment.stability.color
                    )
                    
                    DetailMetric(
                        label: "Type",
                        value: segment.typeAffinity.displayName,
                        color: segment.typeAffinity.color
                    )
                }
                
                // Mutation possibilities
                if !segment.mutationPossibilities.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mutation Possibilities")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(segment.mutationPossibilities, id: \.self) { mutation in
                                    MutationChip(mutation: mutation)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThickMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(segment.typeAffinity.color.opacity(0.5), lineWidth: 1)
                    )
            )
            .padding()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Gestures
    
    private var rotationGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation
                let newRotation = simd_float2(
                    Float(translation.width) * 0.01,
                    Float(translation.height) * 0.01
                )
                accumulatedRotation = newRotation
            }
    }
    
    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                viewModel.updateZoom(Float(value))
            }
    }
    
    private func handleTap(at location: CGPoint, in size: CGSize) {
        // Convert tap location to 3D space and select nearest DNA segment
        let normalizedLocation = CGPoint(
            x: (location.x / size.width) * 2 - 1,
            y: (location.y / size.height) * 2 - 1
        )
        viewModel.selectSegmentAt(normalizedLocation)
    }
}

// MARK: - Supporting Views

struct StatusIndicator: View {
    let title: String
    let value: Float
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(value))
                }
            }
            .frame(height: 4)
        }
        .frame(width: 80)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

struct GeneSegmentView: View {
    let segment: DNASegment
    let isSelected: Bool
    let primaryColor: Color
    
    var body: some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            segment.typeAffinity.color,
                            segment.typeAffinity.color.opacity(0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 30)
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .overlay(
                    isSelected ? 
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.white, lineWidth: 1) : nil
                )
            
            Text(segment.code)
                .font(.system(size: 6, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct DetailMetric: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct MutationChip: View {
    let mutation: String
    
    var body: some View {
        Text(mutation)
            .font(.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.purple.opacity(0.3))
            )
    }
}

// MARK: - View Mode Enum

enum DNAViewMode: String, CaseIterable {
    case standard = "Standard"
    case xray = "X-Ray"
    case energy = "Energy"
    case mutation = "Mutation"
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .standard: return "cube"
        case .xray: return "xray"
        case .energy: return "bolt.circle"
        case .mutation: return "atom"
        }
    }
}

// MARK: - Particle Field View

struct ParticleFieldView: View {
    let primaryColor: Color
    let particleCount: Int
    let animationSpeed: Double
    
    @State private var particles: [DNAParticleEffect] = []
    @State private var animationPhase: Double = 0
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let position = particle.position(
                    at: animationPhase,
                    in: size
                )
                
                let opacity = particle.opacity(at: animationPhase)
                
                context.fill(
                    Circle().path(in: CGRect(
                        x: position.x - particle.size / 2,
                        y: position.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )),
                    with: .color(primaryColor.opacity(opacity))
                )
            }
        }
        .onAppear {
            generateParticles()
            startAnimation()
        }
    }
    
    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            DNAParticleEffect(
                initialPosition: CGPoint(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1)
                ),
                velocity: CGVector(
                    dx: CGFloat.random(in: -0.02...0.02),
                    dy: CGFloat.random(in: -0.02...0.02)
                ),
                size: CGFloat.random(in: 2...6),
                lifespan: Double.random(in: 3...8)
            )
        }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            animationPhase = 1
        }
    }
}

struct DNAParticleEffect {
    let initialPosition: CGPoint
    let velocity: CGVector
    let size: CGFloat
    let lifespan: Double
    
    func position(at phase: Double, in size: CGSize) -> CGPoint {
        var x = (initialPosition.x + velocity.dx * phase).truncatingRemainder(dividingBy: 1)
        var y = (initialPosition.y + velocity.dy * phase).truncatingRemainder(dividingBy: 1)
        
        if x < 0 { x += 1 }
        if y < 0 { y += 1 }
        
        return CGPoint(x: x * size.width, y: y * size.height)
    }
    
    func opacity(at phase: Double) -> Double {
        let lifecyclePhase = (phase * 10).truncatingRemainder(dividingBy: lifespan) / lifespan
        return sin(lifecyclePhase * .pi) * 0.8
    }
}

// MARK: - Holographic Grid View

struct HolographicGridView: View {
    @State private var animationPhase: Double = 0
    
    var body: some View {
        Canvas { context, size in
            let gridSize: CGFloat = 30
            let lineWidth: CGFloat = 0.5
            
            // Vertical lines
            for x in stride(from: 0, through: size.width, by: gridSize) {
                let opacity = 0.1 + sin(animationPhase + x / 100) * 0.05
                
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(.cyan.opacity(opacity)),
                    lineWidth: lineWidth
                )
            }
            
            // Horizontal lines
            for y in stride(from: 0, through: size.height, by: gridSize) {
                let opacity = 0.1 + sin(animationPhase + y / 100) * 0.05
                
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(.cyan.opacity(opacity)),
                    lineWidth: lineWidth
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                animationPhase = 2 * .pi
            }
        }
    }
}
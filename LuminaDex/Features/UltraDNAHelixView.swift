//
//  UltraDNAHelixView.swift
//  LuminaDex
//
//  Ultra-modern DNA visualization with SceneKit for smooth 3D rendering
//

import SwiftUI
import SceneKit
import SpriteKit

struct UltraDNAHelixView: View {
    let pokemon: Pokemon
    
    @State private var rotation: Double = 0
    @State private var autoRotate = true
    @State private var selectedSegment: Int? = nil
    @State private var viewMode: DNAViewMode = .standard
    @State private var showParticles = true
    @State private var pulseAnimation = false
    @State private var glowIntensity: Double = 0.8
    @State private var isAnalyzing = false
    @State private var mutationPoints: [Int] = []
    @State private var analysisResult = ""
    @State private var showAnalysisAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gorgeous animated background
                AnimatedGradientBackground(pokemon: pokemon)
                
                VStack(spacing: 0) {
                    // Compact header
                    headerView
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    
                    // 3D DNA Scene with info overlays
                    ZStack {
                        // SceneKit 3D View
                        DNA3DSceneView(
                            pokemon: pokemon,
                            rotation: $rotation,
                            autoRotate: $autoRotate,
                            selectedSegment: $selectedSegment,
                            viewMode: $viewMode,
                            showParticles: $showParticles,
                            glowIntensity: $glowIntensity
                        )
                        .overlay(
                            // Holographic overlay effects
                            HolographicOverlay()
                                .allowsHitTesting(false)
                        )
                        
                        // Floating info cards - positioned at corners
                        floatingInfoCards
                            .padding(8)
                    }
                    .frame(maxHeight: .infinity)
                    
                    // Compact control panel
                    controlPanel
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                
                // Particle effects overlay
                if showParticles {
                    DNAParticleSystem(color: pokemon.primaryType.color)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startPulseAnimation()
            calculateMutations()
        }
        .alert("DNA Analysis Complete", isPresented: $showAnalysisAlert) {
            Button("OK") { }
        } message: {
            Text(analysisResult)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(pokemon.name.capitalized)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text("GENETIC ANALYSIS")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                }
                
                Spacer(minLength: 4)
                
                // DNA Stats
                HStack(spacing: 12) {
                    DNAStatBadge(
                        icon: "waveform.path.ecg",
                        value: "\(getDNAStability())%",
                        label: "STABILITY",
                        color: .green
                    )
                    
                    DNAStatBadge(
                        icon: "atom",
                        value: "\(pokemon.stats.reduce(0) { $0 + $1.baseStat })",
                        label: "POWER",
                        color: .orange
                    )
                }
            }
            
            // View mode selector
            viewModeSelector
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    pokemon.primaryType.color.opacity(0.5),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private var viewModeSelector: some View {
        HStack(spacing: 0) {
            ForEach(DNAViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewMode = mode
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 20))
                        Text(mode.title)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundColor(viewMode == mode ? .white : .white.opacity(0.4))
                    .background(
                        viewMode == mode ?
                        Capsule()
                            .fill(pokemon.primaryType.color.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(pokemon.primaryType.color, lineWidth: 1)
                            ) : nil
                    )
                }
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
    
    private var floatingInfoCards: some View {
        VStack {
            HStack {
                VStack {
                    DNAInfoCard(
                        title: "HELIX",
                        value: getHelixType(),
                        icon: "spiral",
                        color: pokemon.primaryType.color
                    )
                    .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    DNAInfoCard(
                        title: "MUTATIONS",
                        value: "\(mutationPoints.count)",
                        icon: "sparkles",
                        color: mutationPoints.isEmpty ? .purple : .yellow
                    )
                    .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                    Spacer()
                }
            }
            
            Spacer(minLength: 0)
            
            HStack {
                VStack {
                    Spacer()
                    DNAInfoCard(
                        title: "PAIRS",
                        value: "\(getBasePairs())",
                        icon: "link",
                        color: .cyan
                    )
                    .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    DNAInfoCard(
                        title: "EVOLVE",
                        value: getEvolutionPotential(),
                        icon: "arrow.triangle.branch",
                        color: isAnalyzing ? .yellow : .green
                    )
                    .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                }
            }
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: 10) {
            // Interactive controls
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Auto-rotate toggle
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 14))
                        Toggle("Rotate", isOn: $autoRotate)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 8)
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Particles toggle
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                        Toggle("Particles", isOn: $showParticles)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 8)
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Glow intensity
                    HStack(spacing: 6) {
                        Text("GLOW")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Slider(value: $glowIntensity, in: 0...1)
                            .frame(width: 80)
                            .accentColor(pokemon.primaryType.color)
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.vertical, 4)
            }
            
            // Action buttons
            HStack(spacing: 8) {
                CompactActionButton(
                    title: "ANALYZE",
                    icon: "waveform.path.ecg",
                    color: pokemon.primaryType.color
                ) {
                    analyzeGenes()
                }
                
                CompactActionButton(
                    title: "MUTATE",
                    icon: "atom",
                    color: .purple
                ) {
                    simulateMutation()
                }
                
                CompactActionButton(
                    title: "SHARE",
                    icon: "square.and.arrow.up",
                    color: .cyan
                ) {
                    shareData()
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    private func analyzeGenes() {
        withAnimation(.easeInOut(duration: 2)) {
            isAnalyzing = true
        }
        
        // Simulate analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let strengths = analyzeStrengths()
            let weaknesses = analyzeWeaknesses()
            let potential = calculatePotential()
            
            analysisResult = """
            Genetic Strengths: \(strengths)
            
            Weaknesses Detected: \(weaknesses)
            
            Evolution Potential: \(potential)%
            
            Unique Markers: \(pokemon.abilities.count) abilities detected
            
            Type DNA: \(pokemon.primaryType.rawValue.capitalized)\(pokemon.secondaryType != nil ? "/\(pokemon.secondaryType!.rawValue.capitalized)" : "")
            """
            
            withAnimation {
                isAnalyzing = false
                showAnalysisAlert = true
            }
        }
    }
    
    private func simulateMutation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            // Generate random mutation points based on Pokemon stats
            mutationPoints = (0..<5).map { _ in
                Int.random(in: 0...100)
            }
            
            // Change view mode to show mutations
            viewMode = .mutation
            
            // Trigger visual feedback
            glowIntensity = 1.0
        }
        
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                glowIntensity = 0.8
            }
        }
    }
    
    private func shareData() {
        let dnaReport = generateDNAReport()
        
        // In a real app, this would open share sheet
        analysisResult = dnaReport
        showAnalysisAlert = true
    }
    
    // MARK: - DNA Calculations
    
    private func getDNAStability() -> Int {
        // Calculate stability based on stats distribution
        let stats = pokemon.stats.map { $0.baseStat }
        let average = stats.reduce(0, +) / stats.count
        let variance = stats.map { abs($0 - average) }.reduce(0, +) / stats.count
        
        // Lower variance = higher stability
        let stability = 100 - min(variance, 30)
        return stability
    }
    
    private func getHelixType() -> String {
        // Different helix types based on Pokemon type
        switch pokemon.primaryType {
        case .psychic, .ghost, .dark:
            return "Z-DNA"  // Left-handed helix
        case .dragon, .steel, .rock:
            return "A-DNA"  // Compact helix
        case .electric, .fire, .poison:
            return "Triple"  // Triple helix
        default:
            return "B-DNA"  // Standard helix
        }
    }
    
    private func getBasePairs() -> String {
        // Calculate base pairs from Pokemon ID and stats
        let basePairs = (pokemon.id * 1000) + pokemon.stats.reduce(0) { $0 + $1.baseStat } * 10
        
        if basePairs > 100000 {
            return "\(basePairs / 1000)k"
        }
        return "\(basePairs)"
    }
    
    private func getEvolutionPotential() -> String {
        // Check evolution potential based on base experience
        let exp = pokemon.baseExperience ?? 100
        
        if isAnalyzing {
            return "Scanning..."
        } else if exp < 100 {
            return "High"
        } else if exp < 200 {
            return "Medium"
        } else {
            return "Stable"
        }
    }
    
    private func calculateMutations() {
        // Generate unique mutations based on Pokemon ID
        let seed = pokemon.id
        var mutations: [Int] = []
        
        for i in 0..<(seed % 10 + 3) {
            mutations.append((seed * (i + 1)) % 100)
        }
        
        mutationPoints = mutations
    }
    
    private func analyzeStrengths() -> String {
        // Find highest stats
        let topStats = pokemon.stats.sorted { $0.baseStat > $1.baseStat }.prefix(2)
        return topStats.map { $0.stat.displayName }.joined(separator: ", ")
    }
    
    private func analyzeWeaknesses() -> String {
        // Find lowest stats
        let weakStats = pokemon.stats.sorted { $0.baseStat < $1.baseStat }.prefix(2)
        return weakStats.map { $0.stat.displayName }.joined(separator: ", ")
    }
    
    private func calculatePotential() -> Int {
        let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
        // Max possible is ~720 for legendary Pokemon
        return min(Int(Double(totalStats) / 720.0 * 100), 100)
    }
    
    private func generateDNAReport() -> String {
        return """
        🧬 DNA ANALYSIS REPORT
        
        Pokemon: \(pokemon.name.capitalized) #\(pokemon.id)
        
        Genetic Profile:
        • Helix Type: \(getHelixType())
        • Base Pairs: \(getBasePairs())
        • Stability: \(getDNAStability())%
        • Mutations: \(mutationPoints.count) detected
        
        Stat Distribution:
        \(pokemon.stats.map { "• \($0.stat.displayName): \($0.baseStat)" }.joined(separator: "\n"))
        
        Total Power: \(pokemon.stats.reduce(0) { $0 + $1.baseStat })
        
        Type Genetics: \(pokemon.primaryType.rawValue.capitalized)\(pokemon.secondaryType != nil ? "/\(pokemon.secondaryType!.rawValue.capitalized)" : "")
        """
    }
}

// MARK: - 3D Scene View

struct DNA3DSceneView: UIViewRepresentable {
    let pokemon: Pokemon
    @Binding var rotation: Double
    @Binding var autoRotate: Bool
    @Binding var selectedSegment: Int?
    @Binding var viewMode: DNAViewMode
    @Binding var showParticles: Bool
    @Binding var glowIntensity: Double
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
        
        // Create scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Add DNA helix
        createDNAHelix(in: scene, for: pokemon)
        
        // Setup camera
        setupCamera(in: scene)
        
        // Setup lighting
        setupLighting(in: scene)
        
        // Add particle system
        if showParticles {
            addParticleSystem(to: scene, color: pokemon.primaryType.color)
        }
        
        context.coordinator.sceneView = sceneView
        
        return sceneView
    }
    
    func updateUIView(_ sceneView: SCNView, context: Context) {
        // Update rotation
        if autoRotate {
            sceneView.scene?.rootNode.childNode(withName: "dna", recursively: true)?.runAction(
                SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2 * CGFloat.pi, z: 0, duration: 10))
            )
        } else {
            sceneView.scene?.rootNode.childNode(withName: "dna", recursively: true)?.removeAllActions()
        }
        
        // Update glow
        updateGlow(in: sceneView.scene, intensity: glowIntensity)
        
        // Update view mode
        updateViewMode(in: sceneView.scene, mode: viewMode)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var sceneView: SCNView?
    }
    
    private func createDNAHelix(in scene: SCNScene, for pokemon: Pokemon) {
        let dnaNode = SCNNode()
        dnaNode.name = "dna"
        
        // Vary helix parameters based on Pokemon
        let helixHeight: CGFloat = 8
        let helixRadius: CGFloat = 1.0 + CGFloat(pokemon.height) / 50.0  // Vary by height
        let segments = 100 + (pokemon.id % 50)  // Unique segment count
        let basePairs = 20 + (pokemon.weight % 20)  // Vary base pairs by weight
        let twists = 2.0 + Double(pokemon.id % 3)  // 2-4 twists based on ID
        
        // Create double helix strands with Pokemon-specific pattern
        for i in 0..<segments {
            let t = CGFloat(i) / CGFloat(segments - 1)
            let angle = t * CGFloat.pi * CGFloat(twists * 2) // Variable twists
            let y = (t - 0.5) * helixHeight
            
            // Add unique wobble based on Pokemon stats
            let statModifier = CGFloat(pokemon.stats[i % pokemon.stats.count].baseStat) / 255.0
            let wobble = sin(t * CGFloat.pi * 4) * statModifier * 0.1
            
            // First strand with size variation
            let sphereSize = 0.08 + statModifier * 0.04
            let sphere1 = SCNSphere(radius: sphereSize)
            sphere1.firstMaterial?.diffuse.contents = pokemon.primaryType.color
            sphere1.firstMaterial?.emission.contents = pokemon.primaryType.color
            sphere1.firstMaterial?.emission.intensity = 0.2 + statModifier * 0.3
            
            let node1 = SCNNode(geometry: sphere1)
            node1.position = SCNVector3(
                cos(angle) * (helixRadius + wobble),
                y,
                sin(angle) * (helixRadius + wobble)
            )
            dnaNode.addChildNode(node1)
            
            // Second strand with complementary size
            let sphere2 = SCNSphere(radius: 0.08 + (1.0 - statModifier) * 0.04)
            sphere2.firstMaterial?.diffuse.contents = pokemon.secondaryType?.color ?? pokemon.primaryType.color.opacity(0.7)
            sphere2.firstMaterial?.emission.contents = pokemon.secondaryType?.color ?? pokemon.primaryType.color
            sphere2.firstMaterial?.emission.intensity = 0.2 + (1.0 - statModifier) * 0.3
            
            let node2 = SCNNode(geometry: sphere2)
            node2.position = SCNVector3(
                cos(angle + CGFloat.pi) * (helixRadius - wobble),
                y,
                sin(angle + CGFloat.pi) * (helixRadius - wobble)
            )
            dnaNode.addChildNode(node2)
            
            // Add base pairs
            if i % (segments / basePairs) == 0 {
                let cylinder = SCNCylinder(radius: 0.05, height: helixRadius * 2)
                cylinder.firstMaterial?.diffuse.contents = getBasePairColor(index: i / (segments / basePairs))
                cylinder.firstMaterial?.emission.contents = getBasePairColor(index: i / (segments / basePairs))
                cylinder.firstMaterial?.emission.intensity = 0.5
                
                let basePairNode = SCNNode(geometry: cylinder)
                basePairNode.position = SCNVector3(0, y, 0)
                basePairNode.eulerAngles = SCNVector3(0, 0, CGFloat.pi / 2)
                basePairNode.look(at: SCNVector3(cos(angle) * helixRadius, y, sin(angle) * helixRadius), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, 1))
                
                dnaNode.addChildNode(basePairNode)
            }
        }
        
        // Add connecting lines between spheres
        for i in 0..<(segments - 1) {
            let t1 = CGFloat(i) / CGFloat(segments - 1)
            let t2 = CGFloat(i + 1) / CGFloat(segments - 1)
            let angle1 = t1 * CGFloat.pi * 6
            let angle2 = t2 * CGFloat.pi * 6
            let y1 = (t1 - 0.5) * helixHeight
            let y2 = (t2 - 0.5) * helixHeight
            
            // Connect first strand
            let line1 = createLine(
                from: SCNVector3(cos(angle1) * helixRadius, y1, sin(angle1) * helixRadius),
                to: SCNVector3(cos(angle2) * helixRadius, y2, sin(angle2) * helixRadius),
                color: pokemon.primaryType.color
            )
            dnaNode.addChildNode(line1)
            
            // Connect second strand
            let line2 = createLine(
                from: SCNVector3(cos(angle1 + CGFloat.pi) * helixRadius, y1, sin(angle1 + CGFloat.pi) * helixRadius),
                to: SCNVector3(cos(angle2 + CGFloat.pi) * helixRadius, y2, sin(angle2 + CGFloat.pi) * helixRadius),
                color: pokemon.secondaryType?.color ?? pokemon.primaryType.color.opacity(0.7)
            )
            dnaNode.addChildNode(line2)
        }
        
        scene.rootNode.addChildNode(dnaNode)
    }
    
    private func createLine(from start: SCNVector3, to end: SCNVector3, color: Color) -> SCNNode {
        let distance = sqrt(
            pow(end.x - start.x, 2) +
            pow(end.y - start.y, 2) +
            pow(end.z - start.z, 2)
        )
        
        let cylinder = SCNCylinder(radius: 0.02, height: CGFloat(distance))
        cylinder.firstMaterial?.diffuse.contents = UIColor(color)
        cylinder.firstMaterial?.emission.contents = UIColor(color)
        cylinder.firstMaterial?.emission.intensity = 0.2
        
        let node = SCNNode(geometry: cylinder)
        node.position = SCNVector3(
            (start.x + end.x) / 2,
            (start.y + end.y) / 2,
            (start.z + end.z) / 2
        )
        node.look(at: end, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 1, 0))
        
        return node
    }
    
    private func setupCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 12)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting(in scene: SCNScene) {
        // Ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        ambientLight.intensity = 300
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        // Directional light
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.color = UIColor.white
        directionalLight.intensity = 500
        directionalLight.castsShadow = true
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.position = SCNVector3(x: 5, y: 5, z: 5)
        directionalNode.look(at: SCNVector3(0, 0, 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        scene.rootNode.addChildNode(directionalNode)
        
        // Spot light for dramatic effect
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.color = UIColor.cyan
        spotLight.intensity = 1000
        spotLight.spotInnerAngle = 30
        spotLight.spotOuterAngle = 60
        let spotNode = SCNNode()
        spotNode.light = spotLight
        spotNode.position = SCNVector3(x: 0, y: 10, z: 0)
        spotNode.look(at: SCNVector3(0, 0, 0), up: SCNVector3(0, 0, 1), localFront: SCNVector3(0, -1, 0))
        scene.rootNode.addChildNode(spotNode)
    }
    
    private func addParticleSystem(to scene: SCNScene, color: Color) {
        let particleSystem = SCNParticleSystem()
        particleSystem.loops = true
        particleSystem.birthRate = 20
        particleSystem.emissionDuration = 1
        particleSystem.spreadingAngle = 45
        particleSystem.particleLifeSpan = 5
        particleSystem.particleVelocity = 1
        particleSystem.particleSize = 0.05
        particleSystem.particleColor = UIColor(color)
        particleSystem.blendMode = .additive
        
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem)
        particleNode.position = SCNVector3(0, -5, 0)
        scene.rootNode.addChildNode(particleNode)
    }
    
    private func getBasePairColor(index: Int) -> UIColor {
        // Use Pokemon-specific colors for base pairs
        let pokemonSeed = pokemon.id + index
        
        let colors: [UIColor] = [
            UIColor(pokemon.primaryType.color),
            UIColor(pokemon.secondaryType?.color ?? pokemon.primaryType.color.opacity(0.8)),
            .systemCyan,
            .systemPurple,
            .systemYellow,
            .systemGreen
        ]
        
        return colors[pokemonSeed % colors.count].withAlphaComponent(0.8)
    }
    
    private func updateGlow(in scene: SCNScene?, intensity: Double) {
        scene?.rootNode.enumerateChildNodes { node, _ in
            node.geometry?.firstMaterial?.emission.intensity = CGFloat(intensity * 0.5)
        }
    }
    
    private func updateViewMode(in scene: SCNScene?, mode: DNAViewMode) {
        guard let dnaNode = scene?.rootNode.childNode(withName: "dna", recursively: true) else { return }
        
        switch mode {
        case .standard:
            dnaNode.opacity = 1.0
        case .xray:
            dnaNode.opacity = 0.3
        case .energy:
            dnaNode.opacity = 0.7
        case .mutation:
            dnaNode.opacity = 0.9
        }
    }
}

// MARK: - Supporting Views

struct AnimatedGradientBackground: View {
    let pokemon: Pokemon
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.black,
                pokemon.primaryType.color.opacity(0.2),
                Color.black,
                pokemon.secondaryType?.color.opacity(0.2) ?? pokemon.primaryType.color.opacity(0.1),
                Color.black
            ],
            startPoint: animateGradient ? .topLeading : .topTrailing,
            endPoint: animateGradient ? .bottomTrailing : .bottomLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct HolographicOverlay: View {
    @State private var animationPhase: Double = 0
    
    var body: some View {
        Canvas { context, size in
            for i in stride(from: 0, through: size.height, by: 20) {
                let opacity = 0.05 + sin(animationPhase + Double(i) / 50) * 0.02
                
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: i))
                        path.addLine(to: CGPoint(x: size.width, y: i))
                    },
                    with: .color(.cyan.opacity(opacity)),
                    lineWidth: 0.5
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                animationPhase = Double.pi * 2
            }
        }
    }
}

struct DNAParticleSystem: View {
    let color: Color
    @State private var particles: [FloatingParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color, color.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size
                        )
                    )
                    .frame(width: particle.size * 2, height: particle.size * 2)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .animation(
                        .linear(duration: particle.duration)
                            .repeatForever(autoreverses: false),
                        value: particle.position
                    )
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    private func generateParticles() {
        for _ in 0..<30 {
            particles.append(FloatingParticle())
        }
        
        // Animate particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for i in particles.indices {
                particles[i].position.y = -100
            }
        }
    }
}

struct FloatingParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    let duration: Double
    
    init() {
        position = CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
        )
        size = CGFloat.random(in: 2...6)
        opacity = Double.random(in: 0.3...0.7)
        duration = Double.random(in: 8...15)
    }
}

struct DNAInfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .tracking(0.5)
        }
        .frame(width: 60, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DNAStatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(value)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(label)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(0.3)
            }
        }
    }
}

// Add compact action button
struct CompactActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 9, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color, lineWidth: 1)
                    )
            )
        }
    }
}
//
//  TypeRelationshipNetwork.swift
//  LuminaDex
//
//  Network Graphs: Force-directed layout with interactive nodes and connection strength
//

import SwiftUI
import Combine

// MARK: - Network Data Models
struct TypeNode: Identifiable, Hashable {
    let id = UUID()
    let type: PokemonType
    var position: CGPoint
    var velocity: CGPoint = .zero
    var force: CGPoint = .zero
    let mass: CGFloat = 1.0
    var isSelected: Bool = false
    var isHighlighted: Bool = false
    
    // Visual properties
    var radius: CGFloat {
        isSelected ? 35 : (isHighlighted ? 30 : 25)
    }
    
    var color: Color {
        switch type {
        case .fire: return .red
        case .water: return .blue
        case .grass: return .green
        case .electric: return .yellow
        case .psychic: return .purple
        case .ice: return .cyan
        case .dragon: return .indigo
        case .dark: return Color(red: 0.2, green: 0.2, blue: 0.2)
        case .fairy: return .pink
        case .fighting: return .orange
        case .poison: return Color(red: 0.6, green: 0.2, blue: 0.8)
        case .ground: return Color(red: 0.8, green: 0.6, blue: 0.2)
        case .flying: return Color(red: 0.7, green: 0.7, blue: 1.0)
        case .bug: return Color(red: 0.6, green: 0.8, blue: 0.2)
        case .rock: return Color(red: 0.7, green: 0.6, blue: 0.3)
        case .ghost: return Color(red: 0.4, green: 0.3, blue: 0.6)
        case .steel: return Color(red: 0.7, green: 0.7, blue: 0.8)
        case .normal: return Color(red: 0.7, green: 0.7, blue: 0.7)
        @unknown default: return .gray
        }
    }
    
    static func == (lhs: TypeNode, rhs: TypeNode) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TypeConnection: Identifiable {
    let id = UUID()
    let fromType: PokemonType
    let toType: PokemonType
    let effectiveness: Double // 2.0 = super effective, 0.5 = not very effective, 0.0 = no effect
    
    var strength: CGFloat {
        CGFloat(effectiveness)
    }
    
    var color: Color {
        switch effectiveness {
        case 2.0: return .green
        case 0.5: return .orange
        case 0.0: return .red
        default: return .gray.opacity(0.3)
        }
    }
    
    var lineWidth: CGFloat {
        switch effectiveness {
        case 2.0: return 3.0
        case 0.5: return 2.0
        case 0.0: return 4.0
        default: return 1.0
        }
    }
}

struct ForceSimulation {
    var centerForce: CGFloat = 0.01
    var repulsionForce: CGFloat = 800
    var attractionForce: CGFloat = 0.001
    var damping: CGFloat = 0.9
    var minDistance: CGFloat = 60
}

// MARK: - Type Relationship Network View
struct TypeRelationshipNetwork: View {
    @State private var nodes: [TypeNode] = []
    @State private var connections: [TypeConnection] = []
    @State private var selectedNode: TypeNode? = nil
    @State private var isDragging: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var simulation = ForceSimulation()
    @State private var animationTimer: Timer? = nil
    @State private var showSprites: Bool = true
    @State private var networkCenter: CGPoint = CGPoint(x: 200, y: 200)
    @State private var showEffectiveness: Bool = false
    @State private var hoveredConnection: TypeConnection? = nil
    
    private let networkSize: CGSize = CGSize(width: 400, height: 400)
    
    var body: some View {
        ZStack {
            // Background with particle effects
            networkBackground
            
            // Network visualization
            VStack(spacing: 20) {
                // Controls
                networkControls
                
                // Main network graph
                ZStack {
                    // Connections (draw first, behind nodes)
                    ForEach(connections) { connection in
                        connectionLine(connection: connection)
                    }
                    
                    // Type nodes
                    ForEach(nodes.indices, id: \.self) { index in
                        typeNodeView(node: nodes[index], index: index)
                    }
                    
                    // Effectiveness tooltip
                    if let connection = hoveredConnection {
                        effectivenessTooltip(connection: connection)
                    }
                    
                    // Selected type info panel
                    if let selected = selectedNode {
                        selectedTypePanel(node: selected)
                    }
                }
                .frame(width: networkSize.width, height: networkSize.height)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.cyan.opacity(0.3), lineWidth: 2)
                        }
                }
                .clipped()
                
                // Network statistics
                networkStats
            }
            .padding()
        }
        .onAppear {
            setupNetwork()
            startPhysicsSimulation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    // MARK: - Network Background
    private var networkBackground: some View {
        ZStack {
            // Base gradient
            RadialGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.purple.opacity(0.2),
                    Color.cyan.opacity(0.1),
                    Color.black.opacity(0.05)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            // Animated particles
            ForEach(0..<20, id: \.self) { index in
                networkParticle(index: index)
            }
        }
    }
    
    private func networkParticle(index: Int) -> some View {
        let colors: [Color] = [.cyan, .purple, .pink, .blue, .green]
        let particleColor = colors[index % colors.count]
        
        return Circle()
            .fill(
                RadialGradient(
                    colors: [particleColor.opacity(0.6), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 3
                )
            )
            .frame(width: 6, height: 6)
            .position(
                x: CGFloat.random(in: 50...350),
                y: CGFloat.random(in: 100...500)
            )
            .opacity(0.7)
    }
    
    // MARK: - Network Controls
    private var networkControls: some View {
        HStack {
            // Show sprites toggle
            Button(action: {
                withAnimation(.spring()) {
                    showSprites.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: showSprites ? "person.3.fill" : "person.3")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Sprites")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(showSprites ? .white : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    if showSprites {
                        Capsule()
                            .fill(.blue)
                    } else {
                        Capsule()
                            .fill(.regularMaterial)
                    }
                }
            }
            
            // Show effectiveness toggle
            Button(action: {
                withAnimation(.spring()) {
                    showEffectiveness.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: showEffectiveness ? "chart.bar.fill" : "chart.bar")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Effectiveness")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(showEffectiveness ? .white : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    if showEffectiveness {
                        Capsule()
                            .fill(.green)
                    } else {
                        Capsule()
                            .fill(.regularMaterial)
                    }
                }
            }
            
            Spacer()
            
            // Reset network button
            Button(action: resetNetwork) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Reset")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(.orange)
                }
            }
        }
    }
    
    // MARK: - Type Node View
    private func typeNodeView(node: TypeNode, index: Int) -> some View {
        ZStack {
            // Node glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            node.color.opacity(0.6),
                            node.color.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: node.radius + 15
                    )
                )
                .frame(width: (node.radius + 15) * 2, height: (node.radius + 15) * 2)
                .opacity(node.isSelected || node.isHighlighted ? 1.0 : 0.4)
            
            // Main node
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            node.color,
                            node.color.opacity(0.8),
                            node.color.opacity(0.6)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: node.radius
                    )
                )
                .frame(width: node.radius * 2, height: node.radius * 2)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.8), lineWidth: node.isSelected ? 3 : 1)
                }
                .shadow(color: node.color.opacity(0.6), radius: node.isSelected ? 15 : 8)
            
            // Type icon
            Image(systemName: iconForType(node.type))
                .font(.system(size: node.radius * 0.6, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2)
            
            // Type name
            if node.isSelected || node.isHighlighted {
                Text(node.type.rawValue.capitalized)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2)
                    .offset(y: node.radius + 15)
            }
            
            // Sprite demonstrations (if enabled)
            if showSprites && (node.isSelected || node.isHighlighted) {
                spriteDemo(for: node)
            }
        }
        .position(nodes[index].position)
        .scaleEffect(node.isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: node.isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: node.isHighlighted)
        .onTapGesture {
            selectNode(at: index)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    nodes[index].position = CGPoint(
                        x: value.location.x,
                        y: value.location.y
                    )
                    // Temporarily stop physics on dragged node
                    nodes[index].velocity = .zero
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
    }
    
    // MARK: - Connection Line
    private func connectionLine(connection: TypeConnection) -> some View {
        let fromNode = nodes.first { $0.type == connection.fromType }
        let toNode = nodes.first { $0.type == connection.toType }
        
        guard let from = fromNode, let to = toNode else {
            return AnyView(EmptyView())
        }
        
        // Only show connections if effectiveness mode is on or nodes are selected
        let shouldShow = showEffectiveness || from.isSelected || to.isSelected || connection.effectiveness != 1.0
        
        return AnyView(
            Path { path in
                path.move(to: from.position)
                path.addLine(to: to.position)
            }
            .stroke(
                connection.color.opacity(shouldShow ? 0.8 : 0.2),
                style: StrokeStyle(
                    lineWidth: shouldShow ? connection.lineWidth : 1,
                    lineCap: .round,
                    dash: connection.effectiveness == 0.0 ? [5, 3] : []
                )
            )
            .opacity(shouldShow ? 1.0 : 0.3)
            .animation(.easeInOut(duration: 0.3), value: shouldShow)
            .onTapGesture {
                hoveredConnection = connection
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    hoveredConnection = nil
                }
            }
        )
    }
    
    // MARK: - Sprite Demo
    private func spriteDemo(for node: TypeNode) -> some View {
        let samplePokemon = samplePokemonForType(node.type)
        
        return VStack(spacing: 4) {
            // Simplified sprite representation
            Circle()
                .fill(node.color.opacity(0.3))
                .frame(width: 20, height: 20)
                .overlay {
                    Text(samplePokemon.prefix(1).uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(node.color)
                }
            
            Text(samplePokemon)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 1)
                .lineLimit(1)
        }
        .offset(x: node.radius + 25, y: -node.radius - 10)
        .opacity(0.9)
    }
    
    // MARK: - Selected Type Panel
    private func selectedTypePanel(node: TypeNode) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForType(node.type))
                    .font(.title2)
                    .foregroundColor(node.color)
                
                Text(node.type.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { selectedNode = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            Text("Effectiveness:")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // Show effectiveness relationships
            VStack(alignment: .leading, spacing: 4) {
                effectivenessRow(title: "Super Effective Against:", types: superEffectiveAgainst(node.type), color: .green)
                effectivenessRow(title: "Not Very Effective Against:", types: notVeryEffectiveAgainst(node.type), color: .orange)
                effectivenessRow(title: "No Effect Against:", types: noEffectAgainst(node.type), color: .red)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(node.color.opacity(0.5), lineWidth: 2)
                }
        }
        .frame(maxWidth: 250)
        .position(x: networkSize.width - 125, y: 100)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
    
    private func effectivenessRow(title: String, types: [PokemonType], color: Color) -> some View {
        if types.isEmpty {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(color)
                
                HStack {
                    ForEach(types, id: \.self) { type in
                        Text(type.rawValue.capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .fill(color.opacity(0.2))
                            }
                            .foregroundColor(color)
                    }
                }
            }
        )
    }
    
    // MARK: - Effectiveness Tooltip
    private func effectivenessTooltip(connection: TypeConnection) -> some View {
        let fromNode = nodes.first { $0.type == connection.fromType }
        let toNode = nodes.first { $0.type == connection.toType }
        
        guard let from = fromNode, let to = toNode else {
            return AnyView(EmptyView())
        }
        
        let midPoint = CGPoint(
            x: (from.position.x + to.position.x) / 2,
            y: (from.position.y + to.position.y) / 2
        )
        
        let effectivenessText: String
        switch connection.effectiveness {
        case 2.0: effectivenessText = "Super Effective (2×)"
        case 0.5: effectivenessText = "Not Very Effective (0.5×)"
        case 0.0: effectivenessText = "No Effect (0×)"
        default: effectivenessText = "Normal (1×)"
        }
        
        return AnyView(
            Text(effectivenessText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(connection.color)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                }
                .position(midPoint)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
        )
    }
    
    // MARK: - Network Stats
    private var networkStats: some View {
        HStack(spacing: 20) {
            statItem(title: "Types", value: "\(nodes.count)")
            statItem(title: "Connections", value: "\(connections.count)")
            statItem(title: "Super Effective", value: "\(connections.filter { $0.effectiveness == 2.0 }.count)")
            statItem(title: "No Effect", value: "\(connections.filter { $0.effectiveness == 0.0 }.count)")
        }
        .padding(.horizontal)
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Functions
    private func setupNetwork() {
        networkCenter = CGPoint(x: networkSize.width / 2, y: networkSize.height / 2)
        
        // Create nodes for each Pokemon type
        let types: [PokemonType] = [.fire, .water, .grass, .electric, .psychic, .ice, .dragon, .dark, .fairy, .fighting, .poison, .ground, .flying, .bug, .rock, .ghost, .steel, .normal]
        
        nodes = types.enumerated().map { index, type in
            let angle = Double(index) * 2 * Double.pi / Double(types.count)
            let radius: CGFloat = 120
            let x = networkCenter.x + cos(angle) * radius
            let y = networkCenter.y + sin(angle) * radius
            
            return TypeNode(type: type, position: CGPoint(x: x, y: y))
        }
        
        // Create connections based on type effectiveness
        createTypeConnections()
    }
    
    private func createTypeConnections() {
        connections.removeAll()
        
        for fromNode in nodes {
            for toNode in nodes {
                if fromNode.type != toNode.type {
                    let effectiveness = getTypeEffectiveness(attacking: fromNode.type, defending: toNode.type)
                    if effectiveness != 1.0 {
                        connections.append(TypeConnection(
                            fromType: fromNode.type,
                            toType: toNode.type,
                            effectiveness: effectiveness
                        ))
                    }
                }
            }
        }
    }
    
    private func startPhysicsSimulation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { _ in
            updatePhysics()
        }
    }
    
    private func updatePhysics() {
        guard !isDragging else { return }
        
        // Apply forces to each node
        for i in 0..<nodes.count {
            // Reset forces
            nodes[i].force = .zero
            
            // Center force (attraction to center)
            let centerDistance = distance(from: nodes[i].position, to: networkCenter)
            if centerDistance > 0 {
                let centerDirection = normalize(vector: CGPoint(
                    x: networkCenter.x - nodes[i].position.x,
                    y: networkCenter.y - nodes[i].position.y
                ))
                nodes[i].force.x += centerDirection.x * simulation.centerForce * centerDistance
                nodes[i].force.y += centerDirection.y * simulation.centerForce * centerDistance
            }
            
            // Repulsion force (push away from other nodes)
            for j in 0..<nodes.count {
                guard i != j else { continue }
                
                let nodeDistance = distance(from: nodes[i].position, to: nodes[j].position)
                if nodeDistance > 0 && nodeDistance < 150 {
                    let repulsionDirection = normalize(vector: CGPoint(
                        x: nodes[i].position.x - nodes[j].position.x,
                        y: nodes[i].position.y - nodes[j].position.y
                    ))
                    let repulsionMagnitude = simulation.repulsionForce / (nodeDistance * nodeDistance)
                    nodes[i].force.x += repulsionDirection.x * repulsionMagnitude
                    nodes[i].force.y += repulsionDirection.y * repulsionMagnitude
                }
            }
            
            // Connection force (attract connected nodes)
            for connection in connections {
                if connection.fromType == nodes[i].type {
                    if let toNode = nodes.first(where: { $0.type == connection.toType }) {
                        let connectionDistance = distance(from: nodes[i].position, to: toNode.position)
                        let idealDistance: CGFloat = 80 + CGFloat(connection.effectiveness) * 20
                        
                        if connectionDistance != idealDistance {
                            let attractionDirection = normalize(vector: CGPoint(
                                x: toNode.position.x - nodes[i].position.x,
                                y: toNode.position.y - nodes[i].position.y
                            ))
                            let attractionMagnitude = (connectionDistance - idealDistance) * simulation.attractionForce
                            nodes[i].force.x += attractionDirection.x * attractionMagnitude
                            nodes[i].force.y += attractionDirection.y * attractionMagnitude
                        }
                    }
                }
            }
            
            // Apply forces to velocity
            nodes[i].velocity.x += nodes[i].force.x
            nodes[i].velocity.y += nodes[i].force.y
            
            // Apply damping
            nodes[i].velocity.x *= simulation.damping
            nodes[i].velocity.y *= simulation.damping
            
            // Update position
            nodes[i].position.x += nodes[i].velocity.x
            nodes[i].position.y += nodes[i].velocity.y
            
            // Keep nodes within bounds
            let margin: CGFloat = 30
            nodes[i].position.x = max(margin, min(networkSize.width - margin, nodes[i].position.x))
            nodes[i].position.y = max(margin, min(networkSize.height - margin, nodes[i].position.y))
        }
    }
    
    private func selectNode(at index: Int) {
        // Deselect all nodes
        for i in 0..<nodes.count {
            nodes[i].isSelected = false
            nodes[i].isHighlighted = false
        }
        
        // Select clicked node
        nodes[index].isSelected = true
        selectedNode = nodes[index]
        
        // Highlight connected nodes
        for connection in connections {
            if connection.fromType == nodes[index].type {
                if let toIndex = nodes.firstIndex(where: { $0.type == connection.toType }) {
                    nodes[toIndex].isHighlighted = true
                }
            }
            if connection.toType == nodes[index].type {
                if let fromIndex = nodes.firstIndex(where: { $0.type == connection.fromType }) {
                    nodes[fromIndex].isHighlighted = true
                }
            }
        }
    }
    
    private func resetNetwork() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            setupNetwork()
            selectedNode = nil
        }
    }
    
    // MARK: - Utility Functions
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
    }
    
    private func normalize(vector: CGPoint) -> CGPoint {
        let magnitude = sqrt(vector.x * vector.x + vector.y * vector.y)
        guard magnitude > 0 else { return .zero }
        return CGPoint(x: vector.x / magnitude, y: vector.y / magnitude)
    }
    
    private func iconForType(_ type: PokemonType) -> String {
        switch type {
        case .fire: return "flame.fill"
        case .water: return "drop.fill"
        case .grass: return "leaf.fill"
        case .electric: return "bolt.fill"
        case .psychic: return "brain.head.profile"
        case .ice: return "snowflake"
        case .dragon: return "star.fill"
        case .dark: return "moon.fill"
        case .fairy: return "sparkles"
        case .fighting: return "figure.boxing"
        case .poison: return "bubbles.and.suds.fill"
        case .ground: return "mountain.2.fill"
        case .flying: return "wind"
        case .bug: return "ant.fill"
        case .rock: return "cube.fill"
        case .ghost: return "eye.fill"
        case .steel: return "shield.fill"
        case .normal: return "circle.fill"
        @unknown default: return "questionmark"
        }
    }
    
    private func samplePokemonForType(_ type: PokemonType) -> String {
        switch type {
        case .fire: return "Charmander"
        case .water: return "Squirtle"
        case .grass: return "Bulbasaur"
        case .electric: return "Pikachu"
        case .psychic: return "Abra"
        case .ice: return "Seel"
        case .dragon: return "Dratini"
        case .dark: return "Umbreon"
        case .fairy: return "Clefairy"
        case .fighting: return "Machop"
        case .poison: return "Weedle"
        case .ground: return "Diglett"
        case .flying: return "Pidgey"
        case .bug: return "Caterpie"
        case .rock: return "Geodude"
        case .ghost: return "Gastly"
        case .steel: return "Magnemite"
        case .normal: return "Rattata"
        @unknown default: return "Unknown"
        }
    }
    
    // Type effectiveness data (simplified)
    private func getTypeEffectiveness(attacking: PokemonType, defending: PokemonType) -> Double {
        let effectiveness: [PokemonType: [PokemonType: Double]] = [
            .fire: [.grass: 2.0, .ice: 2.0, .bug: 2.0, .steel: 2.0, .water: 0.5, .fire: 0.5, .rock: 0.5, .dragon: 0.5],
            .water: [.fire: 2.0, .ground: 2.0, .rock: 2.0, .water: 0.5, .grass: 0.5, .dragon: 0.5],
            .grass: [.water: 2.0, .ground: 2.0, .rock: 2.0, .fire: 0.5, .grass: 0.5, .poison: 0.5, .flying: 0.5, .bug: 0.5, .dragon: 0.5, .steel: 0.5],
            .electric: [.water: 2.0, .flying: 2.0, .electric: 0.5, .grass: 0.5, .dragon: 0.5, .ground: 0.0],
            .psychic: [.fighting: 2.0, .poison: 2.0, .psychic: 0.5, .steel: 0.5, .dark: 0.0],
            .ice: [.grass: 2.0, .ground: 2.0, .flying: 2.0, .dragon: 2.0, .fire: 0.5, .water: 0.5, .ice: 0.5, .steel: 0.5],
            .dragon: [.dragon: 2.0, .steel: 0.5, .fairy: 0.0],
            .dark: [.psychic: 2.0, .ghost: 2.0, .fighting: 0.5, .dark: 0.5, .fairy: 0.5],
            .fairy: [.fighting: 2.0, .dragon: 2.0, .dark: 2.0, .fire: 0.5, .poison: 0.5, .steel: 0.5],
            .fighting: [.normal: 2.0, .ice: 2.0, .rock: 2.0, .dark: 2.0, .steel: 2.0, .poison: 0.5, .flying: 0.5, .psychic: 0.5, .bug: 0.5, .fairy: 0.5, .ghost: 0.0],
            .poison: [.grass: 2.0, .fairy: 2.0, .poison: 0.5, .ground: 0.5, .rock: 0.5, .ghost: 0.5, .steel: 0.0],
            .ground: [.fire: 2.0, .electric: 2.0, .poison: 2.0, .rock: 2.0, .steel: 2.0, .grass: 0.5, .bug: 0.5, .flying: 0.0],
            .flying: [.electric: 0.5, .ice: 0.5, .rock: 0.5, .steel: 0.5, .grass: 2.0, .fighting: 2.0, .bug: 2.0],
            .bug: [.grass: 2.0, .psychic: 2.0, .dark: 2.0, .fire: 0.5, .fighting: 0.5, .poison: 0.5, .flying: 0.5, .ghost: 0.5, .steel: 0.5, .fairy: 0.5],
            .rock: [.fire: 2.0, .ice: 2.0, .flying: 2.0, .bug: 2.0, .fighting: 0.5, .ground: 0.5, .steel: 0.5],
            .ghost: [.psychic: 2.0, .ghost: 2.0, .dark: 0.5, .normal: 0.0],
            .steel: [.ice: 2.0, .rock: 2.0, .fairy: 2.0, .fire: 0.5, .water: 0.5, .electric: 0.5, .steel: 0.5],
            .normal: [.rock: 0.5, .ghost: 0.0, .steel: 0.5]
        ]
        
        return effectiveness[attacking]?[defending] ?? 1.0
    }
    
    private func superEffectiveAgainst(_ type: PokemonType) -> [PokemonType] {
        let allTypes: [PokemonType] = [.fire, .water, .grass, .electric, .psychic, .ice, .dragon, .dark, .fairy, .fighting, .poison, .ground, .flying, .bug, .rock, .ghost, .steel, .normal]
        return allTypes.filter { getTypeEffectiveness(attacking: type, defending: $0) == 2.0 }
    }
    
    private func notVeryEffectiveAgainst(_ type: PokemonType) -> [PokemonType] {
        let allTypes: [PokemonType] = [.fire, .water, .grass, .electric, .psychic, .ice, .dragon, .dark, .fairy, .fighting, .poison, .ground, .flying, .bug, .rock, .ghost, .steel, .normal]
        return allTypes.filter { getTypeEffectiveness(attacking: type, defending: $0) == 0.5 }
    }
    
    private func noEffectAgainst(_ type: PokemonType) -> [PokemonType] {
        let allTypes: [PokemonType] = [.fire, .water, .grass, .electric, .psychic, .ice, .dragon, .dark, .fairy, .fighting, .poison, .ground, .flying, .bug, .rock, .ghost, .steel, .normal]
        return allTypes.filter { getTypeEffectiveness(attacking: type, defending: $0) == 0.0 }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        TypeRelationshipNetwork()
            .navigationTitle("Type Network")
            .navigationBarTitleDisplayMode(.inline)
    }
}

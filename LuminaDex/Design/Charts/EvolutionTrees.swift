import SwiftUI
import Combine

// MARK: - Evolution Tree Models
struct EvolutionNode: Identifiable, Hashable {
    let id = UUID()
    let pokemonId: Int
    let name: String
    let sprite: String
    let position: CGPoint
    let level: Int // Evolution stage (0 = base, 1 = first evolution, etc.)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct EvolutionConnection: Identifiable {
    let id = UUID()
    let from: UUID
    let to: UUID
    let requirement: EvolutionRequirementType
    let controlPoint1: CGPoint
    let controlPoint2: CGPoint
}

enum EvolutionRequirementType {
    case level(Int)
    case stone(String)
    case friendship
    case trade
    case tradeWithItem(String)
    case timeOfDay(String)
    case location(String)
    case other(String)
    
    var displayText: String {
        switch self {
        case .level(let lvl): return "Level \(lvl)"
        case .stone(let stone): return stone
        case .friendship: return "Friendship"
        case .trade: return "Trade"
        case .tradeWithItem(let item): return "Trade + \(item)"
        case .timeOfDay(let time): return time
        case .location(let loc): return "@ \(loc)"
        case .other(let req): return req
        }
    }
    
    var color: Color {
        switch self {
        case .level: return .blue
        case .stone: return .purple
        case .friendship: return .pink
        case .trade: return .orange
        case .tradeWithItem: return .red
        case .timeOfDay: return .yellow
        case .location: return .green
        case .other: return .gray
        }
    }
}

// MARK: - Evolution Tree View
struct EvolutionTreeView: View {
    let pokemonFamily: String
    @State private var nodes: [EvolutionNode] = []
    @State private var connections: [EvolutionConnection] = []
    @State private var selectedNode: EvolutionNode?
    @State private var hoveredNode: EvolutionNode?
    @State private var previewNode: EvolutionNode?
    @State private var animationProgress: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    // Neural network animation states
    @State private var pulseAnimation: Bool = false
    @State private var connectionAnimation: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with neural network feel
                backgroundGradient
                
                // Evolution network
                evolutionNetwork(in: geometry)
                
                // Floating requirements
                ForEach(connections, id: \.id) { connection in
                    requirementLabel(for: connection, in: geometry)
                }
                
                // Preview popup
                if let preview = previewNode {
                    previewPopup(for: preview, in: geometry)
                }
                
                // Controls
                networkControls
            }
        }
        .onAppear {
            setupEvolutionTree()
            startAnimations()
        }
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .onChanged { scale = $0 }
                    .onEnded { _ in withAnimation(.spring()) { scale = 1.0 } },
                DragGesture()
                    .onChanged { offset = $0.translation }
                    .onEnded { _ in withAnimation(.spring()) { offset = .zero } }
            )
        )
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            // Animated particles
            ForEach(0..<50, id: \.self) { i in
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 2, height: 2)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 3...8))
                        .repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
            }
        }
    }
    
    // MARK: - Evolution Network
    private func evolutionNetwork(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Connection lines
            ForEach(connections) { connection in
                connectionPath(connection, in: geometry)
            }
            
            // Evolution nodes
            ForEach(nodes) { node in
                evolutionNodeView(node, in: geometry)
            }
        }
        .scaleEffect(scale)
        .offset(offset)
    }
    
    private func connectionPath(_ connection: EvolutionConnection, in geometry: GeometryProxy) -> some View {
        let fromNode = nodes.first { $0.id == connection.from }!
        let toNode = nodes.first { $0.id == connection.to }!
        
        return Path { path in
            path.move(to: fromNode.position)
            path.addCurve(
                to: toNode.position,
                control1: connection.controlPoint1,
                control2: connection.controlPoint2
            )
        }
        .stroke(
            LinearGradient(
                colors: [
                    connection.requirement.color.opacity(0.8),
                    connection.requirement.color.opacity(0.3),
                    connection.requirement.color.opacity(0.8)
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(
                lineWidth: 3,
                lineCap: .round,
                dash: connectionAnimation ? [0] : [5, 5]
            )
        )
        .overlay {
            // Neural pulse effect
            Path { path in
                path.move(to: fromNode.position)
                path.addCurve(
                    to: toNode.position,
                    control1: connection.controlPoint1,
                    control2: connection.controlPoint2
                )
            }
            .trim(from: 0, to: animationProgress)
            .stroke(
                connection.requirement.color,
                style: StrokeStyle(lineWidth: 6, lineCap: .round)
            )
            .opacity(connectionAnimation ? 0.8 : 0)
        }
    }
    
    private func evolutionNodeView(_ node: EvolutionNode, in geometry: GeometryProxy) -> some View {
        Button {
            withAnimation(.spring(response: 0.6)) {
                selectedNode = selectedNode?.id == node.id ? nil : node
            }
        } label: {
            ZStack {
                // Neural glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.4),
                                Color.blue.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                
                // Node background
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: selectedNode?.id == node.id ? 3 : 1
                            )
                    }
                
                // Pokemon sprite (placeholder)
                AsyncImage(url: URL(string: node.sprite)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Text(String(node.name.prefix(2)).uppercased())
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                
                // Level indicator
                if node.level > 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("L\(node.level)")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(4)
                                .background(.blue, in: Capsule())
                        }
                    }
                    .frame(width: 80, height: 80)
                }
            }
        }
        .position(node.position)
        .scaleEffect(selectedNode?.id == node.id ? 1.1 : 1.0)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.2)) {
                hoveredNode = isHovered ? node : nil
                if isHovered {
                    previewNode = node
                } else if previewNode?.id == node.id {
                    previewNode = nil
                }
            }
        }
    }
    
    // MARK: - Requirement Labels
    private func requirementLabel(for connection: EvolutionConnection, in geometry: GeometryProxy) -> some View {
        let midPoint = calculateMidPoint(connection)
        
        return Text(connection.requirement.displayText)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .stroke(connection.requirement.color, lineWidth: 1)
                    }
            }
            .position(midPoint)
            .scaleEffect(connectionAnimation ? 1.0 : 0.8)
            .opacity(connectionAnimation ? 1.0 : 0.7)
    }
    
    // MARK: - Preview Popup
    private func previewPopup(for node: EvolutionNode, in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: URL(string: node.sprite)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text(node.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Evolution Stage \(node.level)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Quick stats preview
            HStack {
                statPreview("HP", value: 45 + (node.level * 10))
                statPreview("ATK", value: 49 + (node.level * 15))
                statPreview("DEF", value: 49 + (node.level * 12))
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.5), lineWidth: 1)
                }
        }
        .position(
            x: node.position.x + 120,
            y: node.position.y - 60
        )
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .opacity
        ))
    }
    
    private func statPreview(_ name: String, value: Int) -> some View {
        VStack {
            Text(name)
                .font(.caption2)
                .foregroundColor(.gray)
            Text("\(value)")
                .font(.caption.bold())
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Controls
    private var networkControls: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        scale = 1.0
                        offset = .zero
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - Helper Functions
    private func setupEvolutionTree() {
        // Sample Charmander evolution line - adjusted for safe area
        nodes = [
            EvolutionNode(
                pokemonId: 4,
                name: "Charmander",
                sprite: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png",
                position: CGPoint(x: 120, y: 600),
                level: 0
            ),
            EvolutionNode(
                pokemonId: 5,
                name: "Charmeleon",
                sprite: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/5.png",
                position: CGPoint(x: 200, y: 450),
                level: 1
            ),
            EvolutionNode(
                pokemonId: 6,
                name: "Charizard",
                sprite: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png",
                position: CGPoint(x: 280, y: 300),
                level: 2
            )
        ]
        
        connections = [
            EvolutionConnection(
                from: nodes[0].id,
                to: nodes[1].id,
                requirement: EvolutionRequirementType.level(16),
                controlPoint1: CGPoint(x: 150, y: 550),
                controlPoint2: CGPoint(x: 170, y: 500)
            ),
            EvolutionConnection(
                from: nodes[1].id,
                to: nodes[2].id,
                requirement: EvolutionRequirementType.level(36),
                controlPoint1: CGPoint(x: 230, y: 400),
                controlPoint2: CGPoint(x: 250, y: 350)
            )
        ]
    }
    
    private func calculateMidPoint(_ connection: EvolutionConnection) -> CGPoint {
        let fromNode = nodes.first { $0.id == connection.from }!
        let toNode = nodes.first { $0.id == connection.to }!
        
        return CGPoint(
            x: (fromNode.position.x + toNode.position.x) / 2,
            y: (fromNode.position.y + toNode.position.y) / 2 - 20
        )
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever()) {
            pulseAnimation.toggle()
        }
        
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            animationProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                connectionAnimation.toggle()
            }
        }
    }
}

// MARK: - Preview
struct EvolutionTreeView_Previews: PreviewProvider {
    static var previews: some View {
        EvolutionTreeView(pokemonFamily: "Charmander")
            .preferredColorScheme(.dark)
    }
}

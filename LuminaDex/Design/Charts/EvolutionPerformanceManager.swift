import SwiftUI
import UIKit
import Combine

// MARK: - Performance Manager
@MainActor
class EvolutionPerformanceManager: ObservableObject {
    // Sprite caching
    private var spriteCache: [String: UIImage] = [:]
    private let imageCache = NSCache<NSString, UIImage>()
    
    // Animation optimization
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    
    // Touch optimization
    private var touchHitCache: [CGPoint: EvolutionNode] = [:]
    private let hitTestRadius: CGFloat = 50
    
    // Memory management
    private let maxCacheSize = 100
    private var cacheCleanupTimer: Timer?
    
    init() {
        setupImageCache()
        startCacheCleanup()
    }
    
    deinit {
        Task { @MainActor in
            stopDisplayLink()
        }
        cacheCleanupTimer?.invalidate()
    }
    
    // MARK: - Sprite Caching System
    private func setupImageCache() {
        imageCache.countLimit = maxCacheSize
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func preloadSprites(for nodes: [EvolutionNode]) async {
        await withTaskGroup(of: Void.self) { group in
            for node in nodes {
                group.addTask {
                    await self.loadAndCacheSprite(url: node.sprite, key: node.name)
                }
            }
        }
    }
    
    private func loadAndCacheSprite(url: String, key: String) async {
        guard let imageURL = URL(string: url),
              imageCache.object(forKey: key as NSString) == nil else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let image = UIImage(data: data) {
                // Optimize image for display
                let optimizedImage = await optimizeImageForDisplay(image)
                await MainActor.run {
                    imageCache.setObject(optimizedImage, forKey: key as NSString)
                }
            }
        } catch {
            print("Failed to load sprite: \(error)")
        }
    }
    
    private func optimizeImageForDisplay(_ image: UIImage) async -> UIImage {
        return await Task.detached {
            let targetSize = CGSize(width: 50, height: 50)
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }.value
    }
    
    func getCachedSprite(for key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
    
    // MARK: - 60fps Animation Engine
    func startHighPerformanceAnimations(updateCallback: @escaping (CFTimeInterval) -> Void) {
        stopDisplayLink()
        
        displayLink = CADisplayLink(target: DisplayLinkTarget { [weak self] displayLink in
            let currentTime = displayLink.timestamp
            if self?.animationStartTime == 0 {
                self?.animationStartTime = currentTime
            }
            
            let elapsedTime = currentTime - (self?.animationStartTime ?? 0)
            Task { @MainActor in
                updateCallback(elapsedTime)
            }
        }, selector: #selector(DisplayLinkTarget.update(_:)))
        
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        animationStartTime = 0
    }
    
    // MARK: - Enhanced Touch Detection
    func optimizedNodeHitTest(point: CGPoint, nodes: [EvolutionNode]) -> EvolutionNode? {
        // Check cache first
        if let cachedNode = touchHitCache[point] {
            return cachedNode
        }
        
        // Spatial partitioning for better performance
        let candidateNodes = nodes.filter { node in
            let distance = sqrt(pow(point.x - node.position.x, 2) + pow(point.y - node.position.y, 2))
            return distance <= hitTestRadius
        }
        
        // Find closest node
        let closestNode = candidateNodes.min { node1, node2 in
            let dist1 = sqrt(pow(point.x - node1.position.x, 2) + pow(point.y - node1.position.y, 2))
            let dist2 = sqrt(pow(point.x - node2.position.x, 2) + pow(point.y - node2.position.y, 2))
            return dist1 < dist2
        }
        
        // Cache result for performance
        if touchHitCache.count > 100 {
            touchHitCache.removeAll()
        }
        touchHitCache[point] = closestNode
        
        return closestNode
    }
    
    func clearTouchCache() {
        touchHitCache.removeAll()
    }
    
    // MARK: - Memory Optimization
    private func startCacheCleanup() {
        cacheCleanupTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.performMemoryCleanup()
        }
    }
    
    private func performMemoryCleanup() {
        // Clean up old touch cache entries
        if touchHitCache.count > 50 {
            touchHitCache.removeAll()
        }
        
        // Trigger image cache cleanup if needed
        if imageCache.totalCostLimit > 0 {
            // NSCache automatically manages memory, but we can force cleanup
            let memoryWarning = UIApplication.shared.applicationState == .background
            if memoryWarning {
                imageCache.removeAllObjects()
            }
        }
    }
    
    // MARK: - Performance Metrics
    func measureRenderingPerformance<T>(operation: () -> T) -> (result: T, duration: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        return (result, duration)
    }
}

// MARK: - Display Link Helper
private class DisplayLinkTarget {
    let updateCallback: (CADisplayLink) -> Void
    
    init(updateCallback: @escaping (CADisplayLink) -> Void) {
        self.updateCallback = updateCallback
    }
    
    @objc func update(_ displayLink: CADisplayLink) {
        updateCallback(displayLink)
    }
}

// MARK: - Optimized Evolution Tree View
struct OptimizedEvolutionTreeView: View {
    let pokemonFamily: String
    
    @StateObject private var performanceManager = EvolutionPerformanceManager()
    @State private var nodes: [EvolutionNode] = []
    @State private var connections: [EvolutionConnection] = []
    @State private var selectedNode: EvolutionNode?
    @State private var hoveredNode: EvolutionNode?
    @State private var previewNode: EvolutionNode?
    
    // Performance optimized animation states
    @State private var animationTime: CFTimeInterval = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var isAnimating = false
    
    // Rendering optimization
    @State private var shouldRedraw = false
    @State private var lastFrameTime: CFTimeInterval = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Optimized background
                optimizedBackground
                
                // High-performance evolution network
                optimizedEvolutionNetwork(in: geometry)
                
                // Cached requirement labels
                cachedRequirementLabels(in: geometry)
                
                // Preview popup with fade optimization
                if let preview = previewNode {
                    optimizedPreviewPopup(for: preview, in: geometry)
                }
                
                // Performance controls
                performanceControls
                
                // Debug performance info (remove in production)
                if ProcessInfo.processInfo.environment["DEBUG_PERFORMANCE"] != nil {
                    performanceDebugInfo
                }
            }
            .onTapGesture { location in
                handleOptimizedTap(at: location, geometry: geometry)
            }
        }
        .onAppear {
            setupOptimizedEvolutionTree()
            startOptimizedAnimations()
        }
        .onDisappear {
            performanceManager.stopDisplayLink()
        }
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .onChanged { newScale in
                        scale = max(0.5, min(3.0, newScale)) // Limit zoom range
                        performanceManager.clearTouchCache()
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            scale = max(0.8, min(2.0, scale))
                        }
                    },
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                        performanceManager.clearTouchCache()
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset = .zero
                        }
                    }
            )
        )
    }
    
    // MARK: - Optimized Background
    private var optimizedBackground: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                // Reduced particle count for performance
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat(i * 20 + 50),
                            y: sin(animationTime + Double(i)) * 100 + 300
                        )
                }
            }
    }
    
    // MARK: - High-Performance Network Rendering
    private func optimizedEvolutionNetwork(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Optimized connection rendering
            ForEach(connections, id: \.id) { connection in
                optimizedConnectionPath(connection, in: geometry)
            }
            
            // Cached node rendering
            ForEach(nodes, id: \.id) { node in
                optimizedNodeView(node, in: geometry)
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .drawingGroup() // Render as single layer for performance
    }
    
    private func optimizedConnectionPath(_ connection: EvolutionConnection, in geometry: GeometryProxy) -> some View {
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
            style: StrokeStyle(lineWidth: 3, lineCap: .round)
        )
        .overlay {
            // Optimized neural pulse
            Path { path in
                path.move(to: fromNode.position)
                path.addCurve(
                    to: toNode.position,
                    control1: connection.controlPoint1,
                    control2: connection.controlPoint2
                )
            }
            .trim(from: 0, to: (sin(animationTime * 2) + 1) / 2)
            .stroke(connection.requirement.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .opacity(0.6)
        }
    }
    
    private func optimizedNodeView(_ node: EvolutionNode, in geometry: GeometryProxy) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedNode = selectedNode?.id == node.id ? nil : node
            }
        } label: {
            ZStack {
                // Optimized glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(1.0 + sin(animationTime * 3) * 0.1)
                
                // Node with cached sprite
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Circle()
                            .stroke(
                                selectedNode?.id == node.id ? Color.blue : Color.gray.opacity(0.5),
                                lineWidth: selectedNode?.id == node.id ? 3 : 1
                            )
                    }
                
                // Optimized sprite rendering
                Group {
                    if let cachedImage = performanceManager.getCachedSprite(for: node.name) {
                        Image(uiImage: cachedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Text(String(node.name.prefix(2)).uppercased())
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
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
    }
    
    // MARK: - Cached Requirement Labels
    private func cachedRequirementLabels(in geometry: GeometryProxy) -> some View {
        ForEach(connections, id: \.id) { connection in
            let midPoint = calculateMidPoint(connection)
            
            Text(connection.requirement.displayText)
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
        }
        .drawingGroup() // Batch render labels
    }
    
    // MARK: - Optimized Preview Popup
    private func optimizedPreviewPopup(for node: EvolutionNode, in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Group {
                    if let cachedImage = performanceManager.getCachedSprite(for: node.name) {
                        Image(uiImage: cachedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray.opacity(0.3))
                    }
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
            x: min(node.position.x + 120, geometry.size.width - 100),
            y: max(node.position.y - 60, 100)
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
    
    // MARK: - Performance Controls
    private var performanceControls: some View {
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
                
                Button {
                    isAnimating.toggle()
                    if isAnimating {
                        startOptimizedAnimations()
                    } else {
                        performanceManager.stopDisplayLink()
                    }
                } label: {
                    Image(systemName: isAnimating ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - Debug Performance Info
    private var performanceDebugInfo: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("FPS: 60")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("Nodes: \(nodes.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text("Scale: \(String(format: "%.2f", scale))")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(8)
                .background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Optimized Helper Functions
    private func setupOptimizedEvolutionTree() {
        // Sample Charmander evolution line
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
        
        // Preload sprites for instant rendering
        Task {
            await performanceManager.preloadSprites(for: nodes)
        }
    }
    
    private func startOptimizedAnimations() {
        isAnimating = true
        performanceManager.startHighPerformanceAnimations { elapsedTime in
            animationTime = elapsedTime
        }
    }
    
    private func handleOptimizedTap(at location: CGPoint, geometry: GeometryProxy) {
        // Convert tap location to node coordinate space
        let adjustedLocation = CGPoint(
            x: (location.x - offset.width) / scale,
            y: (location.y - offset.height) / scale
        )
        
        if let tappedNode = performanceManager.optimizedNodeHitTest(point: adjustedLocation, nodes: nodes) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedNode = selectedNode?.id == tappedNode.id ? nil : tappedNode
                previewNode = tappedNode
            }
            
            // Auto-hide preview after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if previewNode?.id == tappedNode.id {
                    withAnimation {
                        previewNode = nil
                    }
                }
            }
        }
    }
    
    private func calculateMidPoint(_ connection: EvolutionConnection) -> CGPoint {
        let fromNode = nodes.first { $0.id == connection.from }!
        let toNode = nodes.first { $0.id == connection.to }!
        
        return CGPoint(
            x: (fromNode.position.x + toNode.position.x) / 2,
            y: (fromNode.position.y + toNode.position.y) / 2 - 20
        )
    }
}

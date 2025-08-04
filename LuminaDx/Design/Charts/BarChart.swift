import SwiftUI
import Foundation

// MARK: - Bar Chart with Liquid Animations
struct BarChart: View {
    @State private var animationProgress: Double = 0.0
    @State private var selectedBar: Int? = nil
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    @State private var liquidAnimation: Double = 0.0
    @State private var particleEmitters: [ParticleEmitter] = []
    
    let chartData: [BarChartData]
    let chartType: BarChartType
    let orientation: ChartOrientation
    let size: CGSize
    let enableInteraction: Bool
    let showLabels: Bool
    
    // Animation configuration
    private let animationDuration: Double = 2.5
    private let staggerDelay: Double = 0.15
    private let liquidWaveSpeed: Double = 3.0
    
    init(
        chartData: [BarChartData],
        chartType: BarChartType = .standard,
        orientation: ChartOrientation = .vertical,
        size: CGSize = CGSize(width: 350, height: 200),
        enableInteraction: Bool = true,
        showLabels: Bool = true
    ) {
        self.chartData = chartData
        self.chartType = chartType
        self.orientation = orientation
        self.size = size
        self.enableInteraction = enableInteraction
        self.showLabels = showLabels
    }
    
    var body: some View {
        ZStack {
            // Holographic background
            HolographicBackground()
                .opacity(0.4)
                .blur(radius: 15)
            
            // Main chart content
            chartContent
                .frame(width: size.width, height: size.height)
        }
        .onAppear {
            startAnimations()
            initializeParticleEmitters()
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: selectedBar)
    }
    
    private var chartContent: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid with depth
                BackgroundGrid(size: geometry.size, orientation: orientation)
                    .opacity(0.3 * animationProgress)
                
                // Bar containers
                if orientation == .vertical {
                    verticalBars(in: geometry)
                } else {
                    horizontalBars(in: geometry)
                }
                
                // Interactive overlays
                if enableInteraction && selectedBar != nil {
                    DetailOverlay(
                        data: chartData[selectedBar!],
                        position: barPosition(for: selectedBar!, in: geometry),
                        orientation: orientation
                    )
                }
                
                // Particle effects for selected bars
                ForEach(particleEmitters) { emitter in
                    ParticleEffect(emitter: emitter)
                }
                
                // Labels and legends
                if showLabels {
                    LabelsOverlay(
                        chartData: chartData,
                        size: geometry.size,
                        orientation: orientation,
                        animationProgress: animationProgress
                    )
                }
            }
        }
    }
    
    // MARK: - Vertical Bars
    private func verticalBars(in geometry: GeometryProxy) -> some View {
        let barWidth = geometry.size.width / CGFloat(chartData.count) * 0.7
        let spacing = geometry.size.width / CGFloat(chartData.count) * 0.3
        
        return HStack(spacing: spacing / CGFloat(chartData.count - 1)) {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                LiquidBar(
                    data: data,
                    maxValue: chartData.map(\.value).max() ?? 1,
                    barWidth: barWidth,
                    maxHeight: geometry.size.height * 0.8,
                    animationProgress: animationProgress,
                    liquidAnimation: liquidAnimation,
                    orientation: .vertical,
                    isSelected: selectedBar == index,
                    chartType: chartType
                )
                .onTapGesture {
                    handleBarTap(index: index)
                }
                .animation(
                    .spring(response: 1.8, dampingFraction: 0.6, blendDuration: 0.3)
                    .delay(Double(index) * staggerDelay),
                    value: animationProgress
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
    
    // MARK: - Horizontal Bars
    private func horizontalBars(in geometry: GeometryProxy) -> some View {
        let barHeight = geometry.size.height / CGFloat(chartData.count) * 0.7
        let spacing = geometry.size.height / CGFloat(chartData.count) * 0.3
        
        return VStack(spacing: spacing / CGFloat(chartData.count - 1)) {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                LiquidBar(
                    data: data,
                    maxValue: chartData.map(\.value).max() ?? 1,
                    barWidth: barHeight,
                    maxHeight: geometry.size.width * 0.8,
                    animationProgress: animationProgress,
                    liquidAnimation: liquidAnimation,
                    orientation: .horizontal,
                    isSelected: selectedBar == index,
                    chartType: chartType
                )
                .onTapGesture {
                    handleBarTap(index: index)
                }
                .animation(
                    .spring(response: 1.8, dampingFraction: 0.6, blendDuration: 0.3)
                    .delay(Double(index) * staggerDelay),
                    value: animationProgress
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    // MARK: - Animation Control
    private func startAnimations() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            animationProgress = 1.0
        }
        
        withAnimation(
            .linear(duration: liquidWaveSpeed)
            .repeatForever(autoreverses: false)
        ) {
            liquidAnimation = 1.0
        }
    }
    
    private func handleBarTap(index: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedBar = selectedBar == index ? nil : index
        }
        hapticGenerator.impactOccurred()
        
        if selectedBar == index {
            activateParticleEmitter(at: index)
        }
    }
    
    private func barPosition(for index: Int, in geometry: GeometryProxy) -> CGPoint {
        if orientation == .vertical {
            let barWidth = geometry.size.width / CGFloat(chartData.count)
            return CGPoint(
                x: CGFloat(index) * barWidth + barWidth / 2,
                y: geometry.size.height * 0.1
            )
        } else {
            let barHeight = geometry.size.height / CGFloat(chartData.count)
            return CGPoint(
                x: geometry.size.width * 0.9,
                y: CGFloat(index) * barHeight + barHeight / 2
            )
        }
    }
    
    private func initializeParticleEmitters() {
        particleEmitters = chartData.enumerated().map { index, data in
            ParticleEmitter(
                id: index,
                position: .zero,
                color: data.color,
                isActive: false
            )
        }
    }
    
    private func activateParticleEmitter(at index: Int) {
        if index < particleEmitters.count {
            particleEmitters[index].isActive = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                particleEmitters[index].isActive = false
            }
        }
    }
}

// MARK: - Liquid Bar Component
struct LiquidBar: View {
    let data: BarChartData
    let maxValue: Double
    let barWidth: CGFloat
    let maxHeight: CGFloat
    let animationProgress: Double
    let liquidAnimation: Double
    let orientation: ChartOrientation
    let isSelected: Bool
    let chartType: BarChartType
    
    private var barHeight: CGFloat {
        CGFloat(data.value / maxValue) * maxHeight * animationProgress
    }
    
    private var barLength: CGFloat {
        orientation == .vertical ? barHeight : barWidth
    }
    
    var body: some View {
        ZStack {
            // 3D Bar Base with depth perception
            RoundedRectangle(cornerRadius: barWidth * 0.1)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.1)
                        ],
                        startPoint: orientation == .vertical ? .bottom : .leading,
                        endPoint: orientation == .vertical ? .top : .trailing
                    )
                )
                .frame(
                    width: orientation == .vertical ? barWidth : maxHeight,
                    height: orientation == .vertical ? maxHeight : barWidth
                )
                .offset(x: 2, y: 2)
            
            // Main liquid bar with fluid dynamics
            LiquidShape(
                progress: animationProgress,
                liquidAnimation: liquidAnimation,
                orientation: orientation
            )
            .fill(createBarGradient())
            .frame(
                width: orientation == .vertical ? barWidth : barLength,
                height: orientation == .vertical ? barHeight : barWidth
            )
            .overlay(
                // Liquid surface effect
                LiquidSurface(
                    liquidAnimation: liquidAnimation,
                    color: data.color,
                    orientation: orientation
                )
                .opacity(0.8)
            )
            .overlay(
                // Iridescent overlay for selection
                RoundedRectangle(cornerRadius: barWidth * 0.1)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.clear,
                                data.color.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(isSelected ? 1.0 : 0.3)
                    .blendMode(.overlay)
            )
            .clipShape(RoundedRectangle(cornerRadius: barWidth * 0.1))
            .shadow(
                color: data.color.opacity(0.5),
                radius: isSelected ? 15 : 5,
                x: 0,
                y: 0
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            
            // Magnetic interaction indicator
            if isSelected {
                MagneticIndicator(color: data.color, size: barWidth * 0.3)
                    .offset(
                        x: orientation == .vertical ? 0 : barLength / 2 + 20,
                        y: orientation == .vertical ? -barHeight / 2 - 20 : 0
                    )
            }
        }
        .frame(
            maxWidth: orientation == .vertical ? barWidth : .infinity,
            maxHeight: orientation == .vertical ? .infinity : barWidth,
            alignment: orientation == .vertical ? .bottom : .leading
        )
    }
    
    private func createBarGradient() -> some ShapeStyle {
        switch chartType {
        case .standard:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        data.color,
                        data.color.opacity(0.7),
                        data.color.opacity(0.9)
                    ],
                    startPoint: orientation == .vertical ? .bottom : .leading,
                    endPoint: orientation == .vertical ? .top : .trailing
                )
            )
        case .neon:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        data.color.opacity(0.8),
                        Color.white.opacity(0.6),
                        data.color
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .glassmorphism:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        data.color.opacity(0.4),
                        Color.white.opacity(0.2),
                        data.color.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

// MARK: - Liquid Shape
struct LiquidShape: Shape {
    let progress: Double
    let liquidAnimation: Double
    let orientation: ChartOrientation
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let animatedProgress = progress
        let waveOffset = liquidAnimation * 2 * .pi
        
        if orientation == .vertical {
            // Vertical liquid animation
            let liquidHeight = rect.height * animatedProgress
            let startY = rect.maxY - liquidHeight
            
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            
            for x in stride(from: rect.minX, to: rect.maxX, by: 2) {
                let normalizedX = (x - rect.minX) / rect.width
                let wave = sin(normalizedX * 4 * .pi + waveOffset) * 3
                let y = startY + wave
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.maxX, y: startY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        } else {
            // Horizontal liquid animation
            let liquidWidth = rect.width * animatedProgress
            
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            
            for y in stride(from: rect.minY, to: rect.maxY, by: 2) {
                let normalizedY = (y - rect.minY) / rect.height
                let wave = sin(normalizedY * 4 * .pi + waveOffset) * 3
                let x = liquidWidth + wave
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: liquidWidth, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Liquid Surface Effect
struct LiquidSurface: View {
    let liquidAnimation: Double
    let color: Color
    let orientation: ChartOrientation
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.6),
                        color.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: orientation == .vertical ? .top : .leading,
                    endPoint: orientation == .vertical ? .bottom : .trailing
                )
            )
            .mask(
                Wave(animationProgress: liquidAnimation, orientation: orientation)
            )
    }
}

// MARK: - Wave Shape
struct Wave: Shape {
    let animationProgress: Double
    let orientation: ChartOrientation
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveOffset = animationProgress * 2 * .pi
        
        if orientation == .vertical {
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            
            for x in stride(from: rect.minX, to: rect.maxX, by: 1) {
                let normalizedX = (x - rect.minX) / rect.width
                let wave = sin(normalizedX * 6 * .pi + waveOffset) * 8
                let y = rect.midY + wave
                path.addLine(to: CGPoint(x: x, y: y))
            }
        } else {
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            
            for y in stride(from: rect.minY, to: rect.maxY, by: 1) {
                let normalizedY = (y - rect.minY) / rect.height
                let wave = sin(normalizedY * 6 * .pi + waveOffset) * 8
                let x = rect.midX + wave
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// MARK: - Magnetic Interaction Indicator
struct MagneticIndicator: View {
    let color: Color
    let size: CGFloat
    @State private var pulseScale: Double = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 2)
                .frame(width: size * 1.5, height: size * 1.5)
                .scaleEffect(pulseScale)
            
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: size, height: size)
                .shadow(color: color, radius: 10, x: 0, y: 0)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.3
            }
        }
    }
}

// MARK: - Holographic Background
struct HolographicBackground: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        ZStack {
            // Base holographic layer
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.15),
                    Color.pink.opacity(0.1),
                    Color.cyan.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Shimmer effect
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: shimmerOffset)
                .onAppear {
                    withAnimation(
                        .linear(duration: 3)
                        .repeatForever(autoreverses: false)
                    ) {
                        shimmerOffset = 200
                    }
                }
        }
    }
}

// MARK: - Background Grid
struct BackgroundGrid: View {
    let size: CGSize
    let orientation: ChartOrientation
    
    var body: some View {
        ZStack {
            // Horizontal grid lines
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: size.width, height: 0.5)
                    .offset(y: CGFloat(i) * size.height / 4 - size.height / 2)
            }
            
            // Vertical grid lines
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 0.5, height: size.height)
                    .offset(x: CGFloat(i) * size.width / 4 - size.width / 2)
            }
        }
    }
}

// MARK: - Detail Overlay
struct DetailOverlay: View {
    let data: BarChartData
    let position: CGPoint
    let orientation: ChartOrientation
    
    var body: some View {
        VStack(spacing: 8) {
            Text(data.label)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
            
            Text("\(data.value, specifier: "%.1f")")
                .font(.title2.weight(.bold))
                .foregroundColor(data.color)
            
            if let description = data.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(data.color.opacity(0.5), lineWidth: 1)
                )
        )
        .position(position)
    }
}

// MARK: - Labels Overlay
struct LabelsOverlay: View {
    let chartData: [BarChartData]
    let size: CGSize
    let orientation: ChartOrientation
    let animationProgress: Double
    
    var body: some View {
        ZStack {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                Text(data.label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(data.color)
                    .position(labelPosition(for: index))
                    .opacity(animationProgress)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .delay(Double(index) * 0.1 + 1.0),
                        value: animationProgress
                    )
            }
        }
    }
    
    private func labelPosition(for index: Int) -> CGPoint {
        if orientation == .vertical {
            let barWidth = size.width / CGFloat(chartData.count)
            return CGPoint(
                x: CGFloat(index) * barWidth + barWidth / 2,
                y: size.height - 10
            )
        } else {
            let barHeight = size.height / CGFloat(chartData.count)
            return CGPoint(
                x: 10,
                y: CGFloat(index) * barHeight + barHeight / 2
            )
        }
    }
}

// MARK: - Particle Effect
struct ParticleEffect: View {
    let emitter: ParticleEmitter
    @State private var particles: [AnimatedParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(emitter.color.opacity(0.7))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            if emitter.isActive {
                generateParticles()
            }
        }
        .onChange(of: emitter.isActive) { isActive in
            if isActive {
                generateParticles()
            } else {
                particles.removeAll()
            }
        }
    }
    
    private func generateParticles() {
        particles = (0..<15).map { _ in
            AnimatedParticle(
                position: emitter.position,
                size: CGFloat.random(in: 3...8),
                opacity: Double.random(in: 0.5...1.0)
            )
        }
        
        withAnimation(.easeOut(duration: 2.0)) {
            particles = particles.map { particle in
                var newParticle = particle
                newParticle.position = CGPoint(
                    x: particle.position.x + CGFloat.random(in: -50...50),
                    y: particle.position.y + CGFloat.random(in: -50...50)
                )
                newParticle.opacity = 0.0
                return newParticle
            }
        }
    }
}

// MARK: - Supporting Types
struct BarChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
    let description: String?
    
    init(label: String, value: Double, color: Color, description: String? = nil) {
        self.label = label
        self.value = value
        self.color = color
        self.description = description
    }
}

enum BarChartType {
    case standard
    case neon
    case glassmorphism
}

enum ChartOrientation {
    case vertical
    case horizontal
}

struct ParticleEmitter: Identifiable {
    let id: Int
    var position: CGPoint
    let color: Color
    var isActive: Bool
}

struct AnimatedParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
}

// MARK: - Extensions for Pokemon Data
extension PokemonStats {
    var typeDistributionData: [BarChartData] {
        chartData.map { stat in
            BarChartData(
                label: stat.name,
                value: Double(stat.value),
                color: stat.color,
                description: "Base stat: \(stat.value)/255"
            )
        }
    }
    
    var generationData: [BarChartData] {
        // This would be populated with actual generation statistics
        // For now, returning sample data
        [
            BarChartData(label: "Gen I", value: Double.random(in: 20...100), color: .red),
            BarChartData(label: "Gen II", value: Double.random(in: 20...100), color: .orange),
            BarChartData(label: "Gen III", value: Double.random(in: 20...100), color: .yellow),
            BarChartData(label: "Gen IV", value: Double.random(in: 20...100), color: .green),
            BarChartData(label: "Gen V", value: Double.random(in: 20...100), color: .blue),
            BarChartData(label: "Gen VI+", value: Double.random(in: 20...100), color: .purple)
        ]
    }
}

#Preview {
    let sampleData = [
        BarChartData(label: "HP", value: 78, color: .red),
        BarChartData(label: "Attack", value: 84, color: .orange),
        BarChartData(label: "Defense", value: 78, color: .blue),
        BarChartData(label: "Sp.Atk", value: 109, color: .purple),
        BarChartData(label: "Sp.Def", value: 85, color: .green),
        BarChartData(label: "Speed", value: 100, color: .yellow)
    ]
    
    BarChart(
        chartData: sampleData,
        chartType: .neon,
        orientation: .vertical
    )
    .preferredColorScheme(.dark)
    .background(Color.black)
}
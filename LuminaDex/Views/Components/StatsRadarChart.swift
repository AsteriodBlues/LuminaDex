//
//  StatsRadarChart.swift
//  LuminaDex
//
//  Interactive radar chart for Pokemon stats visualization
//

import SwiftUI

struct StatsRadarChart: View {
    let pokemon: Pokemon
    let animate: Bool
    
    @State private var animationProgress: CGFloat = 0
    @State private var selectedStat: String? = nil
    
    private let statLabels = ["HP", "ATK", "DEF", "SP.ATK", "SP.DEF", "SPD"]
    private let maxStatValue: CGFloat = 255 // Max possible stat value
    
    var body: some View {
        chartContent
            .frame(height: 250)
            .background(chartBackground)
            .onAppear(perform: startAnimation)
    }
    
    private var chartContent: some View {
        GeometryReader { geometry in
            RadarChartContent(
                geometry: geometry,
                pokemon: pokemon,
                statLabels: statLabels,
                normalizedStats: normalizedStats,
                animationProgress: animationProgress,
                selectedStat: $selectedStat,
                maxStatValue: maxStatValue,
                angleForIndex: angleForIndex
            )
        }
    }
    
    private var chartBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.black.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(pokemon.primaryType.color.opacity(0.2), lineWidth: 1)
            )
    }
    
    private func startAnimation() {
        if animate {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animationProgress = 1.0
            }
        } else {
            animationProgress = 1.0
        }
    }
    
    private var normalizedStats: [CGFloat] {
        // Ensure we have exactly 6 stats in the correct order
        let statOrder = ["hp", "attack", "defense", "special-attack", "special-defense", "speed"]
        
        return statOrder.map { statName in
            if let stat = pokemon.stats.first(where: { $0.stat.name == statName }) {
                return CGFloat(stat.baseStat) / maxStatValue
            }
            return 0
        }
    }
    
    private func angleForIndex(_ index: Int) -> CGFloat {
        let angleStep = (2 * CGFloat.pi) / 6
        return -(CGFloat.pi / 2) + angleStep * CGFloat(index) // Start from top
    }
}

// MARK: - Radar Chart Content
struct RadarChartContent: View {
    let geometry: GeometryProxy
    let pokemon: Pokemon
    let statLabels: [String]
    let normalizedStats: [CGFloat]
    let animationProgress: CGFloat
    @Binding var selectedStat: String?
    let maxStatValue: CGFloat
    let angleForIndex: (Int) -> CGFloat
    
    var body: some View {
        let size = geometry.size
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 - 30
        
        ZStack {
            // Background grid
            RadarChartGrid(
                center: center,
                radius: radius,
                sides: 6
            )
            
            // Stat polygon
            RadarChartPolygon(
                stats: normalizedStats,
                center: center,
                radius: radius,
                animationProgress: animationProgress,
                primaryColor: pokemon.primaryType.color
            )
            
            // Stat points and labels
            ForEach(0..<6, id: \.self) { index in
                StatPointView(
                    index: index,
                    center: center,
                    radius: radius,
                    pokemon: pokemon,
                    statLabels: statLabels,
                    normalizedStats: normalizedStats,
                    animationProgress: animationProgress,
                    selectedStat: $selectedStat,
                    angleForIndex: angleForIndex
                )
            }
            
            // Selected stat detail
            selectedStatDetail(center: center)
        }
    }
    
    @ViewBuilder
    private func selectedStatDetail(center: CGPoint) -> some View {
        if let selected = selectedStat,
           let index = statLabels.firstIndex(of: selected),
           let stat = pokemon.stats[safe: index] {
            VStack(spacing: 4) {
                Text(selected)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(stat.baseStat) / 255")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(pokemon.primaryType.color)
                
                let percentage = Int((CGFloat(stat.baseStat) / maxStatValue) * 100)
                Text("\(percentage)%")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(pokemon.primaryType.color.opacity(0.5), lineWidth: 1)
                    )
            )
            .position(center)
        }
    }
}

// MARK: - Stat Point View
struct StatPointView: View {
    let index: Int
    let center: CGPoint
    let radius: CGFloat
    let pokemon: Pokemon
    let statLabels: [String]
    let normalizedStats: [CGFloat]
    let animationProgress: CGFloat
    @Binding var selectedStat: String?
    let angleForIndex: (Int) -> CGFloat
    
    var body: some View {
        let angle = angleForIndex(index)
        let statValue = normalizedStats[index]
        let pointRadius = radius * statValue * animationProgress
        let labelRadius = radius + 20
        
        // Calculate positions
        let labelX = center.x + cos(angle) * labelRadius
        let labelY = center.y + sin(angle) * labelRadius
        let pointX = center.x + cos(angle) * pointRadius
        let pointY = center.y + sin(angle) * pointRadius
        
        ZStack {
            // Label with value
            VStack(spacing: 2) {
                Text(statLabels[index])
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                
                if let stat = pokemon.stats[safe: index] {
                    Text("\(stat.baseStat)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(pokemon.primaryType.color)
                }
            }
            .position(x: labelX, y: labelY)
            .opacity(animationProgress)
            
            // Interactive stat point
            Circle()
                .fill(pokemon.primaryType.color)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .position(x: pointX, y: pointY)
                .scaleEffect(selectedStat == statLabels[index] ? 1.5 : 1.0)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        if selectedStat == statLabels[index] {
                            selectedStat = nil
                        } else {
                            selectedStat = statLabels[index]
                        }
                    }
                }
        }
    }
}

// MARK: - Radar Chart Grid
struct RadarChartGrid: View {
    let center: CGPoint
    let radius: CGFloat
    let sides: Int
    
    var body: some View {
        ZStack {
            // Concentric hexagons
            ForEach(1...5, id: \.self) { level in
                Path { path in
                    let levelRadius = radius * CGFloat(level) / 5
                    
                    for i in 0..<sides {
                        let angle = angleForIndex(i)
                        let x = center.x + cos(angle) * levelRadius
                        let y = center.y + sin(angle) * levelRadius
                        
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            }
            
            // Radial lines
            ForEach(0..<sides, id: \.self) { index in
                Path { path in
                    let angle = angleForIndex(index)
                    path.move(to: center)
                    path.addLine(to: CGPoint(
                        x: center.x + cos(angle) * radius,
                        y: center.y + sin(angle) * radius
                    ))
                }
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
            }
        }
    }
    
    private func angleForIndex(_ index: Int) -> CGFloat {
        let angleStep = (2 * CGFloat.pi) / CGFloat(sides)
        return -(CGFloat.pi / 2) + angleStep * CGFloat(index)
    }
}

// MARK: - Radar Chart Polygon
struct RadarChartPolygon: View {
    let stats: [CGFloat]
    let center: CGPoint
    let radius: CGFloat
    let animationProgress: CGFloat
    let primaryColor: Color
    
    var body: some View {
        ZStack {
            // Filled area
            Path { path in
                for i in 0..<stats.count {
                    let angle = angleForIndex(i)
                    let statRadius = radius * stats[i] * animationProgress
                    let x = center.x + cos(angle) * statRadius
                    let y = center.y + sin(angle) * statRadius
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        primaryColor.opacity(0.3),
                        primaryColor.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Outline
            Path { path in
                for i in 0..<stats.count {
                    let angle = angleForIndex(i)
                    let statRadius = radius * stats[i] * animationProgress
                    let x = center.x + cos(angle) * statRadius
                    let y = center.y + sin(angle) * statRadius
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.closeSubpath()
            }
            .stroke(primaryColor, lineWidth: 2)
        }
    }
    
    private func angleForIndex(_ index: Int) -> CGFloat {
        let angleStep = (2 * CGFloat.pi) / CGFloat(stats.count)
        return -(CGFloat.pi / 2) + angleStep * CGFloat(index)
    }
}

// MARK: - Safe Array Access
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
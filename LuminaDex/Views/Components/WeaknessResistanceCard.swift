//
//  WeaknessResistanceCard.swift
//  LuminaDex
//
//  Day 25: Type Effectiveness Summary Cards with Charts
//

import SwiftUI
import Charts

struct WeaknessResistanceCard: View {
    let pokemon: Pokemon
    @State private var selectedCategory: EffectivenessCategory = .weaknesses
    @State private var animateChart = false
    
    enum EffectivenessCategory: String, CaseIterable {
        case weaknesses = "Weak To"
        case resistances = "Resists"
        case immunities = "Immune To"
        
        var color: Color {
            switch self {
            case .weaknesses: return .red
            case .resistances: return .green
            case .immunities: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .weaknesses: return "exclamationmark.triangle.fill"
            case .resistances: return "shield.fill"
            case .immunities: return "xmark.shield.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            header
            
            // Category Selector
            categorySelector
            
            // Effectiveness Display
            effectivenessDisplay
            
            // Chart
            effectivenessChart
            
            // Critical Warnings
            if selectedCategory == .weaknesses {
                criticalWeaknessWarning
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedCategory.color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                animateChart = true
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Image(systemName: "bolt.batteryblock.fill")
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [pokemon.primaryType.color, pokemon.primaryType.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Type Effectiveness")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Type badges
            HStack(spacing: 4) {
                ForEach(pokemon.types, id: \.slot) { typeSlot in
                    Image(systemName: typeSlot.pokemonType.icon)
                        .font(.system(size: 14))
                        .foregroundColor(typeSlot.pokemonType.color)
                        .padding(4)
                        .background(
                            Circle()
                                .fill(typeSlot.pokemonType.color.opacity(0.2))
                        )
                }
            }
        }
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        HStack(spacing: 8) {
            ForEach(EffectivenessCategory.allCases, id: \.self) { category in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedCategory = category
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.system(size: 12))
                        
                        Text(category.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(selectedCategory == category ? .white : category.color.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(selectedCategory == category ? category.color : category.color.opacity(0.2))
                    )
                }
            }
        }
    }
    
    // MARK: - Effectiveness Display
    private var effectivenessDisplay: some View {
        let effectiveness = getTypeEffectiveness()
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(effectiveness, id: \.type) { item in
                    EffectivenessChip(
                        type: item.type,
                        multiplier: item.multiplier,
                        animate: animateChart
                    )
                }
            }
        }
    }
    
    // MARK: - Effectiveness Chart
    private var effectivenessChart: some View {
        let data = getChartData()
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Damage Multipliers")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            Chart(data, id: \.type) { item in
                BarMark(
                    x: .value("Type", item.type.displayName),
                    y: .value("Multiplier", animateChart ? item.multiplier : 0)
                )
                .foregroundStyle(
                    item.multiplier > 1 ? Color.red :
                    item.multiplier < 1 ? Color.green :
                    Color.gray
                )
                .annotation(position: .top) {
                    Text(formatMultiplier(item.multiplier))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(
                            item.multiplier > 1 ? .red :
                            item.multiplier < 1 ? .green :
                            .gray
                        )
                }
            }
            .frame(height: 150)
            .chartYScale(domain: 0...4)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(.gray)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(doubleValue, specifier: "%.1f")×")
                                .font(.system(size: 10))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .animation(.spring(response: 0.5), value: animateChart)
        }
    }
    
    // MARK: - Critical Weakness Warning
    private var criticalWeaknessWarning: some View {
        let criticalWeaknesses = getCriticalWeaknesses()
        
        return Group {
            if !criticalWeaknesses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("Critical Weaknesses")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    ForEach(criticalWeaknesses, id: \.type) { weakness in
                        HStack {
                            Image(systemName: weakness.type.icon)
                                .font(.system(size: 12))
                                .foregroundColor(weakness.type.color)
                            
                            Text(weakness.type.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("×\(formatMultiplier(weakness.multiplier))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.red.opacity(0.2))
                                )
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getTypeEffectiveness() -> [(type: PokemonType, multiplier: Double)] {
        // This would normally calculate based on the Pokemon's types
        // For demo, returning sample data
        switch selectedCategory {
        case .weaknesses:
            return [
                (type: .fire, multiplier: 2.0),
                (type: .ground, multiplier: 2.0),
                (type: .rock, multiplier: 4.0), // 4x weakness
                (type: .flying, multiplier: 2.0)
            ]
        case .resistances:
            return [
                (type: .grass, multiplier: 0.5),
                (type: .water, multiplier: 0.5),
                (type: .electric, multiplier: 0.5),
                (type: .steel, multiplier: 0.25) // 4x resistance
            ]
        case .immunities:
            return [
                (type: .ground, multiplier: 0.0)
            ]
        }
    }
    
    private func getChartData() -> [(type: PokemonType, multiplier: Double)] {
        getTypeEffectiveness()
    }
    
    private func getCriticalWeaknesses() -> [(type: PokemonType, multiplier: Double)] {
        getTypeEffectiveness().filter { $0.multiplier >= 4.0 }
    }
    
    private func formatMultiplier(_ multiplier: Double) -> String {
        if multiplier == 0 {
            return "0"
        } else if multiplier == 0.25 {
            return "¼"
        } else if multiplier == 0.5 {
            return "½"
        } else if multiplier == 1.0 {
            return "1"
        } else if multiplier == 2.0 {
            return "2"
        } else if multiplier == 4.0 {
            return "4"
        } else {
            return String(format: "%.1f", multiplier)
        }
    }
}

// MARK: - Effectiveness Chip
struct EffectivenessChip: View {
    let type: PokemonType
    let multiplier: Double
    let animate: Bool
    @State private var scale: CGFloat = 0
    
    private var effectiveness: (text: String, color: Color, icon: String) {
        switch multiplier {
        case 0:
            return ("Immune", .gray, "xmark.shield.fill")
        case 0.25:
            return ("¼×", .green, "shield.lefthalf.filled")
        case 0.5:
            return ("½×", .green, "shield.fill")
        case 1.0:
            return ("1×", .gray, "minus.circle")
        case 2.0:
            return ("2×", .red, "exclamationmark.triangle")
        case 4.0:
            return ("4×", .red, "exclamationmark.2")
        default:
            return ("\(multiplier)×", .gray, "questionmark.circle")
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Type icon with effectiveness indicator
            ZStack {
                Circle()
                    .fill(type.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(type.color)
                
                // Effectiveness badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(effectiveness.color)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: effectiveness.icon)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 60, height: 60)
            }
            .scaleEffect(scale)
            
            // Type name
            Text(type.displayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
            
            // Multiplier
            Text(effectiveness.text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(effectiveness.color)
        }
        .onAppear {
            if animate {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double.random(in: 0...0.3))) {
                    scale = 1.0
                }
            } else {
                scale = 1.0
            }
        }
    }
}

// MARK: - Type Coverage Radar
struct TypeCoverageRadar: View {
    let pokemon: Pokemon
    @State private var animationProgress: CGFloat = 0
    
    private var allTypes: [PokemonType] {
        PokemonType.allCases.filter { $0 != .unknown }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type Coverage")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            radarChart
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var radarChart: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundCircles(geometry: geometry)
                radarLines(geometry: geometry)
                coveragePolygon(geometry: geometry)
                typeLabels(geometry: geometry)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func backgroundCircles(geometry: GeometryProxy) -> some View {
        ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                .frame(
                    width: geometry.size.width * scale,
                    height: geometry.size.width * scale
                )
        }
    }
    
    private func radarLines(geometry: GeometryProxy) -> some View {
        ForEach(Array(allTypes.enumerated()), id: \.offset) { index, _ in
            radarLine(index: index, geometry: geometry)
        }
    }
    
    private func radarLine(index: Int, geometry: GeometryProxy) -> some View {
        let indexDouble = Double(index)
        let typeCount = Double(allTypes.count)
        let angleBase = (indexDouble / typeCount) * 2.0 * Double.pi
        let angle = angleBase - (Double.pi / 2.0)
        
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.width / 2
        let maxRadius = centerX
        
        let endX = centerX + cos(angle) * maxRadius
        let endY = centerY + sin(angle) * maxRadius
        
        return Path { path in
            path.move(to: CGPoint(x: centerX, y: centerY))
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
    }
    
    private func coveragePolygon(geometry: GeometryProxy) -> some View {
        ZStack {
            coverageShape(geometry: geometry)
                .fill(pokemon.primaryType.color.opacity(0.3))
            
            coverageShape(geometry: geometry)
                .stroke(pokemon.primaryType.color, lineWidth: 2)
        }
    }
    
    private func coverageShape(geometry: GeometryProxy) -> Path {
        let points = calculatePolygonPoints(geometry: geometry)
        
        return Path { path in
            guard !points.isEmpty else { return }
            
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
    }
    
    private func calculatePolygonPoints(geometry: GeometryProxy) -> [CGPoint] {
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.width / 2
        let typeCount = Double(allTypes.count)
        
        var points: [CGPoint] = []
        
        for (index, type) in allTypes.enumerated() {
            let point = calculatePoint(
                index: index,
                type: type,
                centerX: centerX,
                centerY: centerY,
                typeCount: typeCount
            )
            points.append(point)
        }
        
        return points
    }
    
    private func calculatePoint(index: Int, type: PokemonType, centerX: CGFloat, centerY: CGFloat, typeCount: Double) -> CGPoint {
        let indexDouble = Double(index)
        let angleBase = (indexDouble / typeCount) * 2.0 * Double.pi
        let angle = angleBase - (Double.pi / 2.0)
        
        let effectiveness = getEffectivenessAgainst(type)
        let radius = centerX * effectiveness * animationProgress
        
        let xOffset = cos(angle) * radius
        let yOffset = sin(angle) * radius
        
        return CGPoint(
            x: centerX + xOffset,
            y: centerY + yOffset
        )
    }
    
    private func typeLabels(geometry: GeometryProxy) -> some View {
        ForEach(Array(allTypes.enumerated()), id: \.offset) { index, type in
            typeLabel(type: type, index: index, geometry: geometry)
        }
    }
    
    private func typeLabel(type: PokemonType, index: Int, geometry: GeometryProxy) -> some View {
        let indexDouble = Double(index)
        let typeCount = Double(allTypes.count)
        let angleBase = (indexDouble / typeCount) * 2.0 * Double.pi
        let angle = angleBase - (Double.pi / 2.0)
        
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.width / 2
        let labelRadius = centerX + 20
        
        let posX = centerX + cos(angle) * labelRadius
        let posY = centerY + sin(angle) * labelRadius
        
        return Image(systemName: type.icon)
            .font(.system(size: 14))
            .foregroundColor(type.color)
            .position(x: posX, y: posY)
    }
    
    private func getEffectivenessAgainst(_ type: PokemonType) -> Double {
        // This would calculate actual effectiveness
        // For demo, returning random values
        Double.random(in: 0.2...1.0)
    }
}
//
//  CompleteInfoDisplay.swift
//  LuminaDex
//
//  Day 25: Complete Pokemon Information Display
//

import SwiftUI
import Charts

struct CompleteInfoDisplay: View {
    let pokemon: Pokemon
    @State private var selectedSection: InfoSection = .basic
    @State private var animateStats = false
    
    enum InfoSection: String, CaseIterable {
        case basic = "Basic Info"
        case training = "Training"
        case breeding = "Breeding"
        case stats = "Base Stats"
        
        var icon: String {
            switch self {
            case .basic: return "info.circle"
            case .training: return "figure.run"
            case .breeding: return "heart.circle"
            case .stats: return "chart.bar.xaxis"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Section Tabs
            sectionTabs
            
            // Content
            Group {
                switch selectedSection {
                case .basic:
                    basicInfoSection
                case .training:
                    trainingSection
                case .breeding:
                    breedingSection
                case .stats:
                    statsSection
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .padding()
    }
    
    // MARK: - Section Tabs
    private var sectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(InfoSection.allCases, id: \.self) { section in
                    Button(action: { 
                        withAnimation(.spring()) {
                            selectedSection = section
                            if section == .stats {
                                animateStats = true
                            }
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: section.icon)
                                .font(.system(size: 20))
                            Text(section.rawValue)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(selectedSection == section ? .white : .gray)
                        .frame(width: 80, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedSection == section ? pokemon.primaryType.color : Color.gray.opacity(0.2))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(spacing: 16) {
            // Physical Characteristics with Visual Comparison
            VStack(alignment: .leading, spacing: 12) {
                Text("Physical Characteristics")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    // Height Card with Comparison
                    PhysicalStatCard(
                        title: "Height",
                        value: pokemon.formattedHeight,
                        comparison: heightComparison,
                        icon: "ruler.fill",
                        color: .blue
                    )
                    
                    // Weight Card with Comparison
                    PhysicalStatCard(
                        title: "Weight",
                        value: pokemon.formattedWeight,
                        comparison: weightComparison,
                        icon: "scalemass.fill",
                        color: .green
                    )
                }
                
                // BMI Calculator
                BMICard(pokemon: pokemon)
            }
            
            // Base Stats Total with Tier
            BaseTotalCard(pokemon: pokemon)
            
            // Catch Rate with Difficulty
            CatchRateCard(pokemon: pokemon)
        }
    }
    
    // MARK: - Training Section
    private var trainingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Information")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // EV Yield
            EVYieldCard(pokemon: pokemon)
            
            // Growth Rate
            GrowthRateCard(pokemon: pokemon)
            
            // Base Friendship
            FriendshipCard(pokemon: pokemon)
        }
    }
    
    // MARK: - Breeding Section
    private var breedingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Breeding Information")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // Egg Groups
            EggGroupsCard(pokemon: pokemon)
            
            // Gender Ratio
            GenderRatioCard(pokemon: pokemon)
            
            // Egg Cycles
            EggCyclesCard(pokemon: pokemon)
        }
    }
    
    // MARK: - Stats Section with Charts
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base Stats Analysis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // Radar Chart
            StatsRadarChart(pokemon: pokemon, animate: animateStats)
            
            // Bar Chart
            StatsBarChart(pokemon: pokemon, animate: animateStats)
            
            // Stats Distribution
            StatsDistribution(pokemon: pokemon)
        }
    }
    
    // MARK: - Helper Computed Properties
    private var heightComparison: String {
        let heightM = Double(pokemon.height) / 10.0
        switch heightM {
        case 0..<0.5: return "Tiny (smaller than Pikachu)"
        case 0.5..<1.0: return "Small (child-sized)"
        case 1.0..<1.8: return "Medium (human-sized)"
        case 1.8..<3.0: return "Large (taller than human)"
        case 3.0..<6.0: return "Huge (building-sized)"
        default: return "Colossal (skyscraper-sized)"
        }
    }
    
    private var weightComparison: String {
        let weightKg = Double(pokemon.weight) / 10.0
        switch weightKg {
        case 0..<10: return "Featherweight"
        case 10..<50: return "Lightweight"
        case 50..<100: return "Middleweight"
        case 100..<200: return "Heavyweight"
        case 200..<500: return "Super Heavyweight"
        default: return "Titan Weight"
        }
    }
}

// MARK: - Physical Stat Card
struct PhysicalStatCard: View {
    let title: String
    let value: String
    let comparison: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(comparison)
                .font(.system(size: 11))
                .foregroundColor(color.opacity(0.8))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - BMI Card
struct BMICard: View {
    let pokemon: Pokemon
    
    private var bmi: Double {
        let heightM = Double(pokemon.height) / 10.0
        let weightKg = Double(pokemon.weight) / 10.0
        guard heightM > 0 else { return 0 }
        return weightKg / (heightM * heightM)
    }
    
    private var bmiCategory: (String, Color) {
        switch bmi {
        case 0..<18.5: return ("Underweight", .blue)
        case 18.5..<25: return ("Normal", .green)
        case 25..<30: return ("Overweight", .orange)
        default: return ("Obese", .red)
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Body Mass Index")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(alignment: .bottom, spacing: 8) {
                    Text(String(format: "%.1f", bmi))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(bmiCategory.0)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(bmiCategory.1)
                        .padding(.bottom, 4)
                }
            }
            
            Spacer()
            
            // BMI Gauge
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: min(bmi / 40, 1.0))
                    .stroke(bmiCategory.1, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text(bmiCategory.0.prefix(1))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(bmiCategory.1)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

// MARK: - Base Total Card
struct BaseTotalCard: View {
    let pokemon: Pokemon
    
    private var total: Int {
        pokemon.stats.reduce(0) { $0 + $1.baseStat }
    }
    
    private var tier: (String, Color, String) {
        switch total {
        case 0..<200: return ("F", .gray, "Tiny")
        case 200..<300: return ("E", .brown, "Weak")
        case 300..<380: return ("D", .red, "Basic")
        case 380..<450: return ("C", .orange, "Decent")
        case 450..<500: return ("B", .yellow, "Strong")
        case 500..<540: return ("A", .green, "Elite")
        case 540..<580: return ("A+", .mint, "Champion")
        case 580..<600: return ("S", .blue, "Legendary")
        case 600..<680: return ("S+", .purple, "Mythical")
        case 680..<720: return ("SS", .pink, "Divine")
        default: return ("SSS", .indigo, "Godlike")
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Base Stats Total")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(alignment: .bottom, spacing: 12) {
                    Text("\(total)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tier \(tier.0)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(tier.1)
                        Text(tier.2)
                            .font(.system(size: 10))
                            .foregroundColor(tier.1.opacity(0.8))
                    }
                }
            }
            
            Spacer()
            
            // Tier Badge
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [tier.1, tier.1.opacity(0.3)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(tier.0)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [tier.1.opacity(0.2), tier.1.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(tier.1.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Catch Rate Card
struct CatchRateCard: View {
    let pokemon: Pokemon
    private let catchRate = 45 // Default catch rate, would come from API
    
    private var difficulty: (String, Color, String) {
        let percentage = Double(catchRate) / 255.0 * 100
        switch percentage {
        case 0..<10: return ("Nearly Impossible", .red, "Master Ball recommended")
        case 10..<25: return ("Very Hard", .orange, "Ultra Ball recommended")
        case 25..<50: return ("Hard", .yellow, "Great Ball recommended")
        case 50..<75: return ("Medium", .blue, "Poké Ball works")
        default: return ("Easy", .green, "Any ball works")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "circle.circle")
                    .foregroundColor(difficulty.1)
                Text("Catch Rate")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("\(catchRate)/255")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("(\(Int(Double(catchRate) / 255.0 * 100))%)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(difficulty.0)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(difficulty.1)
                    Text(difficulty.2)
                        .font(.system(size: 10))
                        .foregroundColor(difficulty.1.opacity(0.8))
                }
            }
            
            // Difficulty Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.green, .yellow, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (1.0 - Double(catchRate) / 255.0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

// MARK: - Additional Cards (Simplified versions)
struct EVYieldCard: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EV Yield")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(pokemon.stats, id: \.stat.name) { stat in
                    if stat.effort > 0 {
                        HStack(spacing: 4) {
                            Text(stat.stat.displayName)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Text("+\(stat.effort)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.2))
                        )
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct GrowthRateCard: View {
    let pokemon: Pokemon
    private let growthRate = "Medium Fast" // Would come from API
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Growth Rate")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Text(growthRate)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Experience curve mini chart
            ExpCurveChart()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct ExpCurveChart: View {
    var body: some View {
        Chart {
            ForEach([10, 30, 50, 70, 90, 100], id: \.self) { level in
                LineMark(
                    x: .value("Level", level),
                    y: .value("EXP", level * level * 10)
                )
                .foregroundStyle(.blue)
            }
        }
        .frame(width: 100, height: 50)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

struct FriendshipCard: View {
    let pokemon: Pokemon
    private let baseFriendship = 70 // Would come from API
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Base Friendship")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Text("\(baseFriendship)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/ 255")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Hearts indicator
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < (baseFriendship / 51) ? "heart.fill" : "heart")
                        .foregroundColor(.pink)
                        .font(.system(size: 14))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct EggGroupsCard: View {
    let pokemon: Pokemon
    private let eggGroups = ["Monster", "Dragon"] // Would come from API
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Egg Groups")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                ForEach(eggGroups, id: \.self) { group in
                    Text(group)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.3))
                        )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct GenderRatioCard: View {
    let pokemon: Pokemon
    private let maleRatio: Double = 50.0 // Would come from API
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender Ratio")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack(spacing: 0) {
                // Male portion
                HStack {
                    Image(systemName: "mustache.fill")
                        .foregroundColor(.blue)
                    Text("\(Int(maleRatio))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.3))
                
                // Female portion
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                    Text("\(Int(100 - maleRatio))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.pink.opacity(0.3))
            }
            .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct EggCyclesCard: View {
    let pokemon: Pokemon
    private let eggCycles = 20 // Would come from API
    
    private var steps: Int {
        eggCycles * 256
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Egg Cycles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Text("\(eggCycles)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("(\(steps) steps)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "figure.walk")
                .font(.system(size: 24))
                .foregroundColor(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

// MARK: - Stats Charts
struct StatsRadarChart: View {
    let pokemon: Pokemon
    let animate: Bool
    
    var body: some View {
        Text("Radar Chart Placeholder")
            .foregroundColor(.gray)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
            )
    }
}

struct StatsBarChart: View {
    let pokemon: Pokemon
    let animate: Bool
    
    var body: some View {
        Chart(pokemon.stats, id: \.stat.name) { stat in
            BarMark(
                x: .value("Stat", stat.stat.displayName),
                y: .value("Value", animate ? stat.baseStat : 0)
            )
            .foregroundStyle(statColor(for: stat.stat.name))
        }
        .frame(height: 200)
        .animation(.spring(response: 0.5), value: animate)
    }
    
    private func statColor(for name: String) -> Color {
        switch name {
        case "hp": return .red
        case "attack": return .orange
        case "defense": return .blue
        case "special-attack": return .purple
        case "special-defense": return .green
        case "speed": return .yellow
        default: return .gray
        }
    }
}

struct StatsDistribution: View {
    let pokemon: Pokemon
    
    private var distribution: (physical: Int, special: Int) {
        let physical = pokemon.stats.filter { ["attack", "defense"].contains($0.stat.name) }
            .reduce(0) { $0 + $1.baseStat }
        let special = pokemon.stats.filter { ["special-attack", "special-defense"].contains($0.stat.name) }
            .reduce(0) { $0 + $1.baseStat }
        return (physical, special)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            StatDistCard(
                title: "Physical",
                value: distribution.physical,
                color: .orange,
                icon: "bolt.fill"
            )
            
            StatDistCard(
                title: "Special",
                value: distribution.special,
                color: .purple,
                icon: "sparkles"
            )
        }
    }
}

struct StatDistCard: View {
    let title: String
    let value: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.2))
        )
    }
}
//
//  AdvancedAnalysisView.swift
//  LuminaDex
//
//  Advanced AI-powered team analysis view
//

import SwiftUI

struct AdvancedAnalysisView: View {
    let team: PokemonTeam
    @ObservedObject var analyzer: AdvancedTeamAnalyzer
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.02, green: 0.02, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab Selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AnalysisTab.allCases, id: \.self) { tab in
                                AnalysisTabButton(
                                    title: tab.title,
                                    icon: tab.icon,
                                    isSelected: selectedTab == tab.rawValue,
                                    color: tab.color
                                ) {
                                    withAnimation(.spring()) {
                                        selectedTab = tab.rawValue
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 20) {
                            if let analysis = analyzer.detailedAnalysis {
                                switch AnalysisTab(rawValue: selectedTab) {
                                case .overview:
                                    OverviewSection(analysis: analysis, synergy: analyzer.synergyScore)
                                case .offensive:
                                    OffensiveSection(rating: analysis.offensiveRating)
                                case .defensive:
                                    DefensiveSection(rating: analysis.defensiveRating)
                                case .speed:
                                    SpeedSection(control: analysis.speedControl)
                                case .threats:
                                    ThreatsSection(threats: analyzer.threatList, coverage: analysis.threatCoverage)
                                case .optimization:
                                    OptimizationSection(suggestions: analyzer.optimizationSuggestions)
                                case .none:
                                    EmptyView()
                                }
                            } else {
                                ProgressView("Analyzing team...")
                                    .padding(40)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Advanced Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Analysis Tabs
enum AnalysisTab: Int, CaseIterable {
    case overview = 0
    case offensive
    case defensive
    case speed
    case threats
    case optimization
    
    var title: String {
        switch self {
        case .overview: return "Overview"
        case .offensive: return "Offense"
        case .defensive: return "Defense"
        case .speed: return "Speed"
        case .threats: return "Threats"
        case .optimization: return "Optimize"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "chart.pie.fill"
        case .offensive: return "bolt.fill"
        case .defensive: return "shield.fill"
        case .speed: return "hare.fill"
        case .threats: return "exclamationmark.triangle.fill"
        case .optimization: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .overview: return .blue
        case .offensive: return .red
        case .defensive: return .green
        case .speed: return .orange
        case .threats: return .yellow
        case .optimization: return .purple
        }
    }
}

// MARK: - Tab Button
struct AnalysisTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : color.opacity(0.2))
            )
        }
    }
}

// MARK: - Overview Section
struct OverviewSection: View {
    let analysis: DetailedTeamAnalysis
    let synergy: Double
    
    var body: some View {
        VStack(spacing: 20) {
            // Synergy Score
            VStack(spacing: 8) {
                Text("Team Synergy Score")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 10)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: synergy / 100)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 150, height: 150)
                    
                    VStack {
                        Text("\(Int(synergy))%")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(synergyRating(synergy))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Key Metrics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Offensive Power",
                    value: "\(Int(analysis.offensiveRating.physicalDamage + analysis.offensiveRating.specialDamage))",
                    icon: "bolt.fill",
                    color: .red
                )
                
                MetricCard(
                    title: "Defensive Bulk",
                    value: "\(Int(analysis.defensiveRating.physicalBulk + analysis.defensiveRating.specialBulk))",
                    icon: "shield.fill",
                    color: .green
                )
                
                MetricCard(
                    title: "Speed Control",
                    value: "\(analysis.speedControl.averageSpeed)",
                    icon: "hare.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Momentum",
                    value: "\(Int(analysis.momentum * 100))%",
                    icon: "arrow.triangle.2.circlepath",
                    color: .blue
                )
            }
            
            // Win Conditions
            if !analysis.winConditions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Win Conditions")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(analysis.winConditions, id: \.type) { condition in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text(winConditionTitle(condition.type))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Text(condition.pokemon.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("\(Int(condition.reliability * 100))%")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.3))
                                )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
    
    func synergyRating(_ score: Double) -> String {
        switch score {
        case 0..<40: return "Needs Work"
        case 40..<60: return "Average"
        case 60..<80: return "Good"
        case 80...: return "Excellent"
        default: return "Unknown"
        }
    }
    
    func winConditionTitle(_ type: WinCondition.WinConditionType) -> String {
        switch type {
        case .setupSweep: return "Setup Sweep"
        case .stall: return "Stall Strategy"
        case .weatherSweep: return "Weather Sweep"
        case .trickRoom: return "Trick Room"
        case .hazardStack: return "Hazard Stack"
        }
    }
}

// MARK: - Offensive Section
struct OffensiveSection: View {
    let rating: OffensiveRating
    
    var body: some View {
        VStack(spacing: 20) {
            // Power Distribution
            VStack(alignment: .leading, spacing: 12) {
                Text("Damage Output")
                    .font(.headline)
                    .foregroundColor(.white)
                
                PowerBar(
                    title: "Physical",
                    value: rating.physicalDamage,
                    maxValue: 6,
                    color: .red
                )
                
                PowerBar(
                    title: "Special",
                    value: rating.specialDamage,
                    maxValue: 6,
                    color: .purple
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
            
            // Attack Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                AdvancedStatCard(title: "Mixed Attackers", value: "\(rating.mixedAttackers)", icon: "arrow.left.arrow.right")
                AdvancedStatCard(title: "Setup Sweepers", value: "\(rating.setupPotential)", icon: "arrow.up.circle")
                AdvancedStatCard(title: "Wallbreakers", value: "\(rating.wallbreaking)", icon: "hammer.fill")
                AdvancedStatCard(title: "Priority Moves", value: "\(rating.priority)", icon: "bolt.circle")
            }
        }
    }
}

// MARK: - Defensive Section
struct DefensiveSection: View {
    let rating: DefensiveRating
    
    var body: some View {
        VStack(spacing: 20) {
            // Bulk Distribution
            VStack(alignment: .leading, spacing: 12) {
                Text("Defensive Bulk")
                    .font(.headline)
                    .foregroundColor(.white)
                
                PowerBar(
                    title: "Physical",
                    value: rating.physicalBulk,
                    maxValue: 6,
                    color: .green
                )
                
                PowerBar(
                    title: "Special",
                    value: rating.specialBulk,
                    maxValue: 6,
                    color: .blue
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
            
            // Defense Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                AdvancedStatCard(title: "Walls", value: "\(rating.walls)", icon: "shield.fill")
                AdvancedStatCard(title: "Pivots", value: "\(rating.pivoting)", icon: "arrow.triangle.swap")
                AdvancedStatCard(title: "Recovery", value: "\(rating.recovery)", icon: "heart.fill")
                AdvancedStatCard(title: "Hazard Removal", value: "\(rating.hazardRemoval)", icon: "wind")
            }
        }
    }
}

// MARK: - Speed Section
struct SpeedSection: View {
    let control: SpeedControl
    
    var body: some View {
        VStack(spacing: 20) {
            // Speed Control Options
            HStack(spacing: 16) {
                SpeedOption(title: "Trick Room", isActive: control.hasTrickRoom, icon: "clock.arrow.circlepath")
                SpeedOption(title: "Tailwind", isActive: control.hasTailwind, icon: "wind")
                SpeedOption(title: "Paralysis", isActive: control.hasParalysis, icon: "bolt.slash")
            }
            
            // Speed Tiers
            VStack(alignment: .leading, spacing: 12) {
                Text("Speed Tiers")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(control.speedTiers, id: \.pokemon) { tier in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tier.pokemon.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text(tier.speedTier)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "hare.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("\(tier.effectiveSpeed)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(speedTierColor(tier.effectiveSpeed))
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                }
            }
        }
    }
    
    func speedTierColor(_ speed: Int) -> Color {
        switch speed {
        case 0..<50: return .red.opacity(0.3)
        case 50..<80: return .orange.opacity(0.3)
        case 80..<100: return .yellow.opacity(0.3)
        case 100..<130: return .green.opacity(0.3)
        case 130...: return .blue.opacity(0.3)
        default: return .gray.opacity(0.3)
        }
    }
}

// MARK: - Threats Section
struct ThreatsSection: View {
    let threats: [ThreatAnalysis]
    let coverage: ThreatCoverage
    
    var body: some View {
        VStack(spacing: 20) {
            // Coverage Overview
            VStack(spacing: 8) {
                Text("Threat Coverage")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("\(Int(coverage.coveragePercentage))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("of common threats covered")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                ProgressView(value: coverage.coveragePercentage / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: coverageColor(coverage.coveragePercentage)))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
            
            // Threat List
            VStack(alignment: .leading, spacing: 12) {
                Text("Threat Analysis")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(threats, id: \.threatName) { threat in
                    ThreatRow(threat: threat)
                }
            }
        }
    }
    
    func coverageColor(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        case 80...: return .green
        default: return .gray
        }
    }
}

// MARK: - Optimization Section
struct OptimizationSection: View {
    let suggestions: [OptimizationSuggestion]
    
    var body: some View {
        VStack(spacing: 20) {
            if suggestions.isEmpty {
                Text("Your team is well-optimized!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(40)
            } else {
                ForEach(suggestions) { suggestion in
                    OptimizationCard(suggestion: suggestion)
                }
            }
        }
    }
}

struct OptimizationCard: View {
    let suggestion: OptimizationSuggestion
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(suggestion.priority.color)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(categoryTitle(suggestion.category))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
            
            Text(suggestion.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommended Pokemon:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestion.recommendedPokemon, id: \.self) { pokemon in
                                Text(pokemon.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.3))
                                    )
                            }
                        }
                    }
                    
                    HStack {
                        Text("Impact:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(impactTitle(suggestion.impact))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(impactColor(suggestion.impact))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(suggestion.priority.color.opacity(0.3), lineWidth: 1)
                )
        )
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
    
    func categoryTitle(_ category: OptimizationSuggestion.Category) -> String {
        switch category {
        case .offensive: return "Offensive"
        case .defensive: return "Defensive"
        case .speed: return "Speed Control"
        case .utility: return "Utility"
        case .synergy: return "Team Synergy"
        }
    }
    
    func impactTitle(_ impact: OptimizationSuggestion.Impact) -> String {
        switch impact {
        case .minor: return "Minor"
        case .moderate: return "Moderate"
        case .major: return "Major"
        case .gameChanging: return "Game Changing"
        }
    }
    
    func impactColor(_ impact: OptimizationSuggestion.Impact) -> Color {
        switch impact {
        case .minor: return .blue
        case .moderate: return .yellow
        case .major: return .orange
        case .gameChanging: return .red
        }
    }
}

// MARK: - Helper Components
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct AdvancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct PowerBar: View {
    let title: String
    let value: Double
    let maxValue: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(String(format: "%.1f", value))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(value / maxValue, 1.0), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct SpeedOption: View {
    let title: String
    let isActive: Bool
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isActive ? .green : .gray)
            
            Text(title)
                .font(.caption)
                .foregroundColor(isActive ? .white : .gray)
            
            Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle")
                .font(.caption)
                .foregroundColor(isActive ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

struct ThreatRow: View {
    let threat: ThreatAnalysis
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(threat.threatName)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    if !threat.counters.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark.shield")
                                .font(.caption)
                            Text("\(threat.counters.count)")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                    
                    if !threat.checks.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "shield")
                                .font(.caption)
                            Text("\(threat.checks.count)")
                                .font(.caption)
                        }
                        .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
            
            ThreatLevelBadge(level: threat.threatLevel)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct ThreatLevelBadge: View {
    let level: ThreatAnalysis.ThreatLevel
    
    var levelText: String {
        switch level {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    var body: some View {
        Text(levelText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(level.color.opacity(0.3))
            )
    }
}
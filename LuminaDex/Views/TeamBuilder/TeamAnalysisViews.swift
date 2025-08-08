//
//  TeamAnalysisViews.swift
//  LuminaDex
//
//  Beautiful visualization components for team analysis
//

import SwiftUI
import Charts

// MARK: - Type Coverage Matrix
struct TypeCoverageMatrix: View {
    let offensive: [PokemonType: CoverageLevel]
    let defensive: [PokemonType: CoverageLevel]
    @State private var selectedMode = 0
    @State private var animateIn = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with Mode Switcher
            HStack {
                Text("Type Coverage")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Picker("Mode", selection: $selectedMode) {
                    Text("Offensive").tag(0)
                    Text("Defensive").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
            }
            
            // Coverage Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(PokemonType.allCases, id: \.self) { type in
                    let coverage = selectedMode == 0 ? offensive[type] : defensive[type]
                    
                    TypeCoverageCell(
                        type: type,
                        coverage: coverage ?? .neutral,
                        delay: Double(type.hashValue % 18) * 0.02
                    )
                    .opacity(animateIn ? 1 : 0)
                    .scaleEffect(animateIn ? 1 : 0.5)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateIn = true
            }
        }
    }
}

struct TypeCoverageCell: View {
    let type: PokemonType
    let coverage: CoverageLevel
    let delay: Double
    @State private var isHovered = false
    @State private var showDetail = false
    
    var body: some View {
        VStack(spacing: 4) {
            // Type Icon
            Image(systemName: type.symbolName)
                .font(.system(size: 20))
                .foregroundColor(type.color)
                .scaleEffect(isHovered ? 1.2 : 1.0)
            
            // Type Name
            Text(type.rawValue)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            
            // Coverage Indicator
            Circle()
                .fill(coverage.color)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(coverage.color.opacity(0.5), lineWidth: isHovered ? 8 : 0)
                        .scaleEffect(isHovered ? 2 : 1)
                        .blur(radius: 2)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    coverage.color.opacity(isHovered ? 0.2 : 0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(coverage.color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay), value: isHovered)
    }
}

// MARK: - Speed Tiers Chart
struct SpeedTiersChart: View {
    let speedAnalysis: SpeedAnalysis
    @State private var selectedTier: SpeedTier?
    @State private var animateChart = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Speed Tiers")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            // Speed Stats
            HStack(spacing: 20) {
                SpeedStatBadge(
                    label: "Fastest",
                    value: "\(speedAnalysis.fastestSpeed)",
                    color: .green
                )
                
                SpeedStatBadge(
                    label: "Average",
                    value: "\(speedAnalysis.averageSpeed)",
                    color: .yellow
                )
                
                SpeedStatBadge(
                    label: "Slowest",
                    value: "\(speedAnalysis.slowestSpeed)",
                    color: .red
                )
            }
            
            // Speed Tier Bars
            if #available(iOS 16.0, *) {
                Chart(speedAnalysis.speedTiers) { tier in
                    BarMark(
                        x: .value("Speed", animateChart ? tier.effectiveSpeed : 0),
                        y: .value("Pokemon", tier.pokemon.name)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                    .annotation(position: .trailing) {
                        Text("\(tier.effectiveSpeed)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(height: CGFloat(speedAnalysis.speedTiers.count * 50))
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .yellow.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateChart = true
            }
        }
    }
}

struct SpeedStatBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Role Distribution Chart
struct RoleDistributionChart: View {
    let distribution: RoleDistribution
    @State private var animateSlices = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Role Distribution")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Balance Badge
                Text(distribution.balance.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(distribution.balance.color)
                    )
            }
            
            // Role Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Array(distribution.roles.keys), id: \.self) { role in
                    RoleCard(
                        role: role,
                        count: distribution.roles[role] ?? 0,
                        isAnimating: animateSlices
                    )
                }
            }
            
            // Missing Roles
            if !distribution.missingRoles.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Missing Roles")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    HStack(spacing: 8) {
                        ForEach(distribution.missingRoles, id: \.self) { role in
                            Text(role.rawValue)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.opacity(0.2))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.green.opacity(0.3), .mint.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                animateSlices = true
            }
        }
    }
}

struct RoleCard: View {
    let role: TeamRole
    let count: Int
    let isAnimating: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: role.icon)
                .font(.title3)
                .foregroundColor(role.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(role.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("\(count) Pokemon")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Count Badge
            Text("\(count)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(role.color)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(role.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(role.color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isAnimating ? 1 : 0.8)
        .opacity(isAnimating ? 1 : 0)
    }
}

// MARK: - Overall Score Card
struct OverallScoreCard: View {
    let score: Float
    @State private var animatedScore: Float = 0
    @State private var showParticles = false
    
    var scoreColor: Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .yellow
        } else if score >= 40 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Team Score")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                // Score Arc
                Circle()
                    .trim(from: 0, to: CGFloat(animatedScore / 100))
                    .stroke(
                        AngularGradient(
                            colors: [scoreColor, scoreColor.opacity(0.5)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                // Score Text
                VStack(spacing: 4) {
                    Text("\(Int(animatedScore))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                    
                    Text("Overall")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Particle Effects for High Scores
                if showParticles && score >= 80 {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(scoreColor)
                            .frame(width: 4, height: 4)
                            .offset(x: 0, y: showParticles ? -80 : 0)
                            .rotationEffect(.degrees(Double(index) * 45))
                            .scaleEffect(showParticles ? 0 : 1)
                            .opacity(showParticles ? 0 : 1)
                            .animation(
                                .spring(response: 0.8, dampingFraction: 0.5)
                                .delay(Double(index) * 0.05),
                                value: showParticles
                            )
                    }
                }
            }
            
            // Score Description
            Text(getScoreDescription())
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(scoreColor.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                animatedScore = score
            }
            
            if score >= 80 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showParticles = true
                }
            }
        }
    }
    
    private func getScoreDescription() -> String {
        if score >= 90 {
            return "Exceptional team composition!"
        } else if score >= 80 {
            return "Excellent balance and synergy"
        } else if score >= 70 {
            return "Good team with minor improvements needed"
        } else if score >= 60 {
            return "Decent foundation, consider adjustments"
        } else if score >= 50 {
            return "Average team, several areas need work"
        } else {
            return "Team needs significant improvements"
        }
    }
}

// MARK: - Strengths & Weaknesses Card
struct StrengthsWeaknessesCard: View {
    let strengths: [String]
    let weaknesses: [String]
    @State private var selectedTab = 0
    @State private var animateItems = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tab Selector
            HStack(spacing: 0) {
                TabButton(
                    title: "Strengths",
                    icon: "checkmark.shield.fill",
                    isSelected: selectedTab == 0,
                    color: .green
                ) {
                    withAnimation { selectedTab = 0 }
                }
                
                TabButton(
                    title: "Weaknesses",
                    icon: "exclamationmark.triangle.fill",
                    isSelected: selectedTab == 1,
                    color: .orange
                ) {
                    withAnimation { selectedTab = 1 }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                let items = selectedTab == 0 ? strengths : weaknesses
                let color = selectedTab == 0 ? Color.green : Color.orange
                
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 12) {
                        Image(systemName: selectedTab == 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(color)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                    }
                    .opacity(animateItems ? 1 : 0)
                    .offset(x: animateItems ? 0 : -20)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8)
                        .delay(Double(index) * 0.05),
                        value: animateItems
                    )
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            selectedTab == 0 ?
                                Color.green.opacity(0.3) :
                                Color.orange.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            animateItems = true
        }
        .onChange(of: selectedTab) { _ in
            animateItems = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateItems = true
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.8))
                    : nil
            )
        }
    }
}

// MARK: - Empty States
struct EmptyAnalysisView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Analysis Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Build your team and tap Analyze to see detailed insights")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct EmptySuggestionsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Suggestions Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Analyze your team first to get optimization suggestions")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Suggestion Card
struct SuggestionCard: View {
    let suggestion: TeamSuggestion
    let onApply: () -> Void
    @State private var isExpanded = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Priority Indicator
                Circle()
                    .fill(suggestion.priority.color)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(suggestion.priority.color.opacity(0.5), lineWidth: isHovered ? 8 : 0)
                            .scaleEffect(isHovered ? 2 : 1)
                            .blur(radius: 2)
                    )
                
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(suggestion.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if isExpanded && !suggestion.pokemonSuggestions.isEmpty {
                // Pokemon Suggestions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(suggestion.pokemonSuggestions.prefix(5), id: \.id) { pokemon in
                            MiniPokemonCard(pokemon: pokemon)
                        }
                    }
                }
                
                // Apply Button
                Button(action: {
                    HapticManager.notification(type: .success)
                    onApply()
                }) {
                    Text("Apply Suggestion")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [suggestion.priority.color, suggestion.priority.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(suggestion.priority.color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
    }
}

struct MiniPokemonCard: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: URL(string: pokemon.sprites.frontDefault ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            
            Text(pokemon.name.capitalized)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Team Type Badge Helper
struct TeamTypeBadge: View {
    let type: PokemonType
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .medium: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }
    
    var body: some View {
        Text(type.rawValue)
            .font(size.fontSize)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(size.padding)
            .background(
                Capsule()
                    .fill(type.color)
            )
    }
}
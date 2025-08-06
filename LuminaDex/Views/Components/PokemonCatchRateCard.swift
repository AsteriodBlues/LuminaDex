//
//  PokemonCatchRateCard.swift
//  LuminaDex
//
//  Real Pokeball Catch Rate Calculator for Pokemon
//

import SwiftUI

struct PokemonCatchRateCard: View {
    let pokemon: Pokemon
    @State private var selectedBall: Pokeball?
    @State private var showAllBalls = false
    @State private var currentHP: Double = 100
    @State private var statusCondition: StatusCondition = .none
    @State private var isExpanded = false
    
    private let database = PokeballDatabase.shared
    
    // Base catch rate for Pokemon (would come from API, using defaults for now)
    private var baseCatchRate: Int {
        // Legendary Pokemon have lower catch rates
        switch pokemon.id {
        case 144, 145, 146: return 3 // Legendary birds
        case 150: return 3 // Mewtwo
        case 151: return 45 // Mew
        case 243, 244, 245: return 3 // Legendary beasts
        case 249, 250: return 3 // Lugia, Ho-Oh
        case 377...384: return 3 // Regis, Legendaries
        case 480...488: return 3 // Lake trio, Creation trio
        case 1...9: return 45 // Starters
        case 10...20: return 255 // Early route Pokemon
        default:
            // Calculate based on total stats
            let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
            switch totalStats {
            case 0..<300: return 255
            case 300..<400: return 190
            case 400..<500: return 120
            case 500..<600: return 45
            default: return 3
            }
        }
    }
    
    enum StatusCondition: String, CaseIterable {
        case none = "None"
        case sleep = "Sleep"
        case freeze = "Freeze"
        case paralysis = "Paralysis"
        case poison = "Poison"
        case burn = "Burn"
        
        var multiplier: Double {
            switch self {
            case .sleep, .freeze: return 2.5
            case .paralysis, .poison, .burn: return 1.5
            case .none: return 1.0
            }
        }
        
        var color: Color {
            switch self {
            case .none: return .gray
            case .sleep: return .purple
            case .freeze: return .cyan
            case .paralysis: return .yellow
            case .poison: return .purple
            case .burn: return .orange
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            headerView
            
            // HP and Status Controls
            if isExpanded {
                controlsView
                
                // Top Pokeballs Grid
                topPokeballsGrid
                
                // All Pokeballs Button
                if !showAllBalls {
                    showAllBallsButton
                }
                
                // All Pokeballs Grid
                if showAllBalls {
                    allPokeballsGrid
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            selectedBall = database.getPokeball(by: "poke-ball")
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Image(systemName: "circle.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.red)
            
            Text("Catch Rate Calculator")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Base Catch Rate Badge
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(baseCatchRate)/255")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(catchRateDifficultyColor)
                Text("Base Rate")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Controls
    private var controlsView: some View {
        VStack(spacing: 12) {
            // HP Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("HP", systemImage: "heart.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("\(Int(currentHP))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Slider(value: $currentHP, in: 1...100, step: 1)
                    .accentColor(.red)
            }
            
            // Status Condition Picker
            VStack(alignment: .leading, spacing: 8) {
                Label("Status", systemImage: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(StatusCondition.allCases, id: \.self) { status in
                            StatusChip(
                                status: status,
                                isSelected: statusCondition == status
                            ) {
                                statusCondition = status
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Top Pokeballs
    private var topPokeballsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Pokéballs")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Best balls for this Pokemon
                ForEach(getRecommendedBalls(), id: \.id) { ball in
                    PokeballCatchCard(
                        pokeball: ball,
                        catchPercentage: calculateCatchRate(for: ball),
                        isRecommended: true,
                        isSelected: selectedBall?.id == ball.id
                    ) {
                        selectedBall = ball
                    }
                }
            }
        }
    }
    
    // MARK: - All Pokeballs
    private var allPokeballsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Pokéballs")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(database.allPokeballs, id: \.id) { ball in
                    PokeballCatchCard(
                        pokeball: ball,
                        catchPercentage: calculateCatchRate(for: ball),
                        isRecommended: false,
                        isSelected: selectedBall?.id == ball.id
                    ) {
                        selectedBall = ball
                    }
                }
            }
        }
    }
    
    private var showAllBallsButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                showAllBalls = true
            }
        }) {
            HStack {
                Text("Show All Pokéballs")
                    .font(.system(size: 14, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
            )
        }
    }
    
    // MARK: - Calculations
    private func calculateCatchRate(for pokeball: Pokeball) -> Double {
        // Pokemon catch rate formula (simplified)
        // ((3 * MaxHP - 2 * CurrentHP) * CatchRate * BallRate * Status) / (3 * MaxHP)
        
        let maxHP = 100.0
        let hpFactor = (3 * maxHP - 2 * currentHP) / (3 * maxHP)
        let ballMultiplier = getEffectiveBallMultiplier(for: pokeball)
        let statusMultiplier = statusCondition.multiplier
        
        let catchValue = (Double(baseCatchRate) / 255.0) * ballMultiplier * statusMultiplier * hpFactor
        
        // Convert to percentage (simplified, actual formula is more complex)
        let percentage = min(100, catchValue * 100)
        
        return percentage
    }
    
    private func getEffectiveBallMultiplier(for pokeball: Pokeball) -> Double {
        // Check special conditions
        switch pokeball.name {
        case "net-ball":
            // 3.5x for Water/Bug types
            if pokemon.types.contains(where: { $0.pokemonType == .water || $0.pokemonType == .bug }) {
                return 3.5
            }
            return 1.0
            
        case "dusk-ball":
            // Would check time/location, using default for now
            return 3.0
            
        case "nest-ball":
            // Better for low-level Pokemon
            return pokemon.id < 50 ? 4.0 : 1.0
            
        case "quick-ball":
            // 5x on first turn
            return 5.0
            
        case "timer-ball":
            // Increases over time, using average
            return 2.5
            
        case "heavy-ball":
            // Based on weight
            let weightKg = Double(pokemon.weight) / 10.0
            if weightKg > 300 { return 1.3 }
            if weightKg < 100 { return 0.5 }
            return 1.0
            
        case "fast-ball":
            // Check speed stat
            if let speedStat = pokemon.stats.first(where: { $0.stat.name == "speed" }),
               speedStat.baseStat >= 100 {
                return 4.0
            }
            return 1.0
            
        case "level-ball":
            // Would check level difference
            return 2.0
            
        case "love-ball":
            // Would check gender/species
            return 1.0
            
        case "moon-ball":
            // Check if evolves with Moon Stone
            let moonStoneEvolutions = [35, 36, 39, 40, 300, 301] // Clefairy, Jigglypuff, etc.
            return moonStoneEvolutions.contains(pokemon.id) ? 4.0 : 1.0
            
        case "beast-ball":
            // 0.1x for regular Pokemon
            return 0.1
            
        default:
            return pokeball.catchRateMultiplier
        }
    }
    
    private func getRecommendedBalls() -> [Pokeball] {
        var recommended: [Pokeball] = []
        
        // Always include Master Ball
        if let masterBall = database.getPokeball(by: "master-ball") {
            recommended.append(masterBall)
        }
        
        // Add type-specific balls
        if pokemon.types.contains(where: { $0.pokemonType == .water || $0.pokemonType == .bug }) {
            if let netBall = database.getPokeball(by: "net-ball") {
                recommended.append(netBall)
            }
        }
        
        // Add Quick Ball (always good)
        if let quickBall = database.getPokeball(by: "quick-ball") {
            recommended.append(quickBall)
        }
        
        // Add Ultra Ball as standard option
        if let ultraBall = database.getPokeball(by: "ultra-ball") {
            recommended.append(ultraBall)
        }
        
        // Add weight-based ball
        let weightKg = Double(pokemon.weight) / 10.0
        if weightKg > 200, let heavyBall = database.getPokeball(by: "heavy-ball") {
            recommended.append(heavyBall)
        }
        
        // Add speed-based ball
        if let speedStat = pokemon.stats.first(where: { $0.stat.name == "speed" }),
           speedStat.baseStat >= 100,
           let fastBall = database.getPokeball(by: "fast-ball") {
            recommended.append(fastBall)
        }
        
        return Array(recommended.prefix(6))
    }
    
    private var catchRateDifficultyColor: Color {
        switch baseCatchRate {
        case 0..<45: return .red
        case 45..<100: return .orange
        case 100..<200: return .yellow
        default: return .green
        }
    }
}

// MARK: - Pokeball Catch Card
struct PokeballCatchCard: View {
    let pokeball: Pokeball
    let catchPercentage: Double
    let isRecommended: Bool
    let isSelected: Bool
    let action: () -> Void
    
    private var effectivenessColor: Color {
        switch catchPercentage {
        case 0..<25: return .red
        case 25..<50: return .orange
        case 50..<75: return .yellow
        default: return .green
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Pokeball Image
                ZStack {
                    if isRecommended {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [pokeball.color.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 50, height: 50)
                    }
                    
                    AsyncImage(url: URL(string: pokeball.spriteURL)) { image in
                        image
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                    } placeholder: {
                        Circle()
                            .fill(pokeball.color.opacity(0.2))
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: 30, height: 30)
                }
                
                // Name
                Text(pokeball.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Catch Rate
                Text("\(Int(catchPercentage))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(effectivenessColor)
                
                // Effectiveness Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(effectivenessColor)
                            .frame(
                                width: geometry.size.width * (min(catchPercentage, 100) / 100),
                                height: 4
                            )
                    }
                }
                .frame(height: 4)
                
                // Recommended Badge
                if isRecommended {
                    Text("BEST")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.yellow.opacity(0.2))
                        )
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? pokeball.color.opacity(0.2) : Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? pokeball.color : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Status Chip
struct StatusChip: View {
    let status: PokemonCatchRateCard.StatusCondition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: statusIcon)
                    .font(.system(size: 10))
                Text(status.rawValue)
                    .font(.system(size: 12, weight: .medium))
                if status != .none {
                    Text("×\(status.multiplier, specifier: "%.1f")")
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .foregroundColor(isSelected ? .white : status.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? status.color : status.color.opacity(0.2))
            )
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .none: return "minus.circle"
        case .sleep: return "moon.zzz"
        case .freeze: return "snowflake"
        case .paralysis: return "bolt"
        case .poison: return "drop.triangle"
        case .burn: return "flame"
        }
    }
}
//
//  AdvancedTeamAnalyzer.swift
//  LuminaDex
//
//  Advanced AI-powered team analysis and optimization
//

import Foundation
import SwiftUI

@MainActor
class AdvancedTeamAnalyzer: ObservableObject {
    static let shared = AdvancedTeamAnalyzer()
    
    @Published var detailedAnalysis: DetailedTeamAnalysis?
    @Published var optimizationSuggestions: [OptimizationSuggestion] = []
    @Published var synergyScore: Double = 0
    @Published var threatList: [ThreatAnalysis] = []
    
    // MARK: - Advanced Analysis
    func performDeepAnalysis(_ team: PokemonTeam) async {
        let analysis = DetailedTeamAnalysis(
            team: team,
            offensiveRating: calculateOffensiveRating(team),
            defensiveRating: calculateDefensiveRating(team),
            speedControl: analyzeSpeedControl(team),
            hazardControl: analyzeHazardControl(team),
            weatherSynergy: analyzeWeatherSynergy(team),
            statusSpread: analyzeStatusSpread(team),
            pivotOptions: analyzePivotOptions(team),
            winConditions: identifyWinConditions(team),
            coreWeaknesses: identifyCoreWeaknesses(team),
            threatCoverage: calculateThreatCoverage(team),
            momentum: analyzeMomentum(team),
            stallbreaking: analyzeStallbreaking(team)
        )
        
        self.detailedAnalysis = analysis
        self.synergyScore = calculateSynergyScore(team)
        self.threatList = analyzeThreatList(team)
        self.optimizationSuggestions = generateOptimizationSuggestions(analysis)
    }
    
    // MARK: - Offensive Analysis
    private func calculateOffensiveRating(_ team: PokemonTeam) -> OffensiveRating {
        var physicalPower = 0.0
        var specialPower = 0.0
        var mixedAttackers = 0
        var setupSweepers = 0
        var wallbreakers = 0
        var speedTiers: [Int] = []
        
        for member in team.members {
            guard let pokemon = member.pokemon else { continue }
            
            let attack = pokemon.stats.first(where: { $0.stat.name == "attack" })?.baseStat ?? 0
            let spAttack = pokemon.stats.first(where: { $0.stat.name == "special-attack" })?.baseStat ?? 0
            let speed = pokemon.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
            
            speedTiers.append(speed)
            
            if attack > 110 {
                physicalPower += Double(attack) / 100.0
                if member.role == .physicalSweeper {
                    setupSweepers += 1
                }
            }
            
            if spAttack > 110 {
                specialPower += Double(spAttack) / 100.0
                if member.role == .specialSweeper {
                    setupSweepers += 1
                }
            }
            
            if attack > 100 && spAttack > 100 {
                mixedAttackers += 1
            }
            
            if (attack > 130 || spAttack > 130) && member.role != .support {
                wallbreakers += 1
            }
        }
        
        return OffensiveRating(
            physicalDamage: physicalPower,
            specialDamage: specialPower,
            mixedAttackers: mixedAttackers,
            setupPotential: setupSweepers,
            wallbreaking: wallbreakers,
            speedControl: speedTiers.filter { $0 > 100 }.count,
            priority: analyzePriorityMoves(team)
        )
    }
    
    // MARK: - Defensive Analysis
    private func calculateDefensiveRating(_ team: PokemonTeam) -> DefensiveRating {
        var physicalBulk = 0.0
        var specialBulk = 0.0
        var pivots = 0
        var walls = 0
        var clerics = 0
        
        for member in team.members {
            guard let pokemon = member.pokemon else { continue }
            
            let hp = pokemon.stats.first(where: { $0.stat.name == "hp" })?.baseStat ?? 0
            let defense = pokemon.stats.first(where: { $0.stat.name == "defense" })?.baseStat ?? 0
            let spDefense = pokemon.stats.first(where: { $0.stat.name == "special-defense" })?.baseStat ?? 0
            
            physicalBulk += Double(hp + defense) / 200.0
            specialBulk += Double(hp + spDefense) / 200.0
            
            if member.role == .tank || member.role == .wall {
                walls += 1
            }
            
            if member.role == .pivot {
                pivots += 1
            }
            
            if member.role == .support {
                clerics += 1
            }
        }
        
        return DefensiveRating(
            physicalBulk: physicalBulk,
            specialBulk: specialBulk,
            recovery: analyzeRecoveryOptions(team),
            hazardRemoval: analyzeHazardRemoval(team),
            statusAbsorbers: clerics,
            pivoting: pivots,
            walls: walls
        )
    }
    
    // MARK: - Speed Control Analysis
    private func analyzeSpeedControl(_ team: PokemonTeam) -> SpeedControl {
        var speedTiers: [SpeedTierAnalysis] = []
        var trickRoom = false
        var tailwind = false
        var speedBoosts = 0
        var paralysisSupport = false
        
        for member in team.members {
            guard let pokemon = member.pokemon else { continue }
            
            let speed = pokemon.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
            let effectiveSpeed = calculateEffectiveSpeed(member, baseSpeed: speed)
            
            speedTiers.append(SpeedTierAnalysis(
                pokemon: pokemon.name,
                baseSpeed: speed,
                effectiveSpeed: effectiveSpeed,
                speedTier: categorizeSpeedTier(effectiveSpeed),
                outspeeds: calculateOutspeeds(effectiveSpeed)
            ))
            
            // Check for speed control moves
            if member.moves.contains(where: { $0.lowercased().contains("trick room") }) {
                trickRoom = true
            }
            if member.moves.contains(where: { $0.lowercased().contains("tailwind") }) {
                tailwind = true
            }
            if member.moves.contains(where: { $0.lowercased().contains("thunder wave") || $0.lowercased().contains("glare") }) {
                paralysisSupport = true
            }
        }
        
        return SpeedControl(
            speedTiers: speedTiers.sorted { $0.effectiveSpeed > $1.effectiveSpeed },
            hasTrickRoom: trickRoom,
            hasTailwind: tailwind,
            hasSpeedBoost: speedBoosts > 0,
            hasParalysis: paralysisSupport,
            averageSpeed: speedTiers.map { $0.baseSpeed }.reduce(0, +) / max(speedTiers.count, 1)
        )
    }
    
    // MARK: - Weather Synergy
    private func analyzeWeatherSynergy(_ team: PokemonTeam) -> WeatherSynergy {
        var sunBeneficiaries = 0
        var rainBeneficiaries = 0
        var sandBeneficiaries = 0
        var hailBeneficiaries = 0
        
        for member in team.members {
            guard let pokemon = member.pokemon else { continue }
            
            // Check type synergies with weather
            if pokemon.types.contains { $0.pokemonType == .fire || $0.pokemonType == .grass } {
                sunBeneficiaries += 1
            }
            if pokemon.types.contains { $0.pokemonType == .water || $0.pokemonType == .electric } {
                rainBeneficiaries += 1
            }
            if pokemon.types.contains { $0.pokemonType == .rock || $0.pokemonType == .ground || $0.pokemonType == .steel } {
                sandBeneficiaries += 1
            }
            if pokemon.types.contains { $0.pokemonType == .ice } {
                hailBeneficiaries += 1
            }
        }
        
        return WeatherSynergy(
            sunTeam: sunBeneficiaries >= 3,
            rainTeam: rainBeneficiaries >= 3,
            sandTeam: sandBeneficiaries >= 3,
            hailTeam: hailBeneficiaries >= 3,
            weatherSetters: identifyWeatherSetters(team),
            weatherAbusers: max(sunBeneficiaries, rainBeneficiaries, sandBeneficiaries, hailBeneficiaries)
        )
    }
    
    // MARK: - Win Conditions
    private func identifyWinConditions(_ team: PokemonTeam) -> [WinCondition] {
        var conditions: [WinCondition] = []
        
        // Check for setup sweepers
        let sweepers = team.members.filter { 
            $0.role == .physicalSweeper || $0.role == .specialSweeper 
        }
        if sweepers.count > 0 {
            conditions.append(WinCondition(
                type: .setupSweep,
                pokemon: sweepers.compactMap { $0.pokemon?.name },
                reliability: Double(sweepers.count) / 6.0
            ))
        }
        
        // Check for stall win condition
        let walls = team.members.filter { $0.role == .wall || $0.role == .tank }
        if walls.count >= 3 {
            conditions.append(WinCondition(
                type: .stall,
                pokemon: walls.compactMap { $0.pokemon?.name },
                reliability: 0.7
            ))
        }
        
        // Check for weather sweep
        let weather = analyzeWeatherSynergy(team)
        if weather.sunTeam || weather.rainTeam {
            conditions.append(WinCondition(
                type: .weatherSweep,
                pokemon: team.members.compactMap { $0.pokemon?.name },
                reliability: 0.6
            ))
        }
        
        return conditions
    }
    
    // MARK: - Threat Coverage
    private func calculateThreatCoverage(_ team: PokemonTeam) -> ThreatCoverage {
        let commonThreats = getCommonThreats()
        var coveredThreats: [String] = []
        var uncoveredThreats: [String] = []
        
        for threat in commonThreats {
            var covered = false
            
            for member in team.members {
                if canHandleThreat(member, threat: threat) {
                    covered = true
                    break
                }
            }
            
            if covered {
                coveredThreats.append(threat)
            } else {
                uncoveredThreats.append(threat)
            }
        }
        
        return ThreatCoverage(
            coveredThreats: coveredThreats,
            uncoveredThreats: uncoveredThreats,
            coveragePercentage: Double(coveredThreats.count) / Double(commonThreats.count) * 100
        )
    }
    
    // MARK: - Optimization Suggestions
    private func generateOptimizationSuggestions(_ analysis: DetailedTeamAnalysis) -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []
        
        // Check offensive balance
        if analysis.offensiveRating.physicalDamage < 2 {
            suggestions.append(OptimizationSuggestion(
                priority: .high,
                category: .offensive,
                title: "Add Physical Attacker",
                description: "Your team lacks physical offensive pressure. Consider adding a strong physical attacker.",
                recommendedPokemon: ["garchomp", "dragapult", "kartana", "urshifu"],
                impact: .major
            ))
        }
        
        if analysis.offensiveRating.specialDamage < 2 {
            suggestions.append(OptimizationSuggestion(
                priority: .high,
                category: .offensive,
                title: "Add Special Attacker",
                description: "Your team lacks special offensive pressure. Consider adding a strong special attacker.",
                recommendedPokemon: ["dragapult", "tapu-lele", "heatran", "kyurem"],
                impact: .major
            ))
        }
        
        // Check defensive balance
        if analysis.defensiveRating.physicalBulk < 2 {
            suggestions.append(OptimizationSuggestion(
                priority: .medium,
                category: .defensive,
                title: "Improve Physical Defense",
                description: "Your team is vulnerable to physical attacks. Add a physical wall or tank.",
                recommendedPokemon: ["corviknight", "toxapex", "ferrothorn", "hippowdon"],
                impact: .moderate
            ))
        }
        
        // Check speed control
        if analysis.speedControl.averageSpeed < 70 && !analysis.speedControl.hasTrickRoom {
            suggestions.append(OptimizationSuggestion(
                priority: .high,
                category: .speed,
                title: "Speed Control Needed",
                description: "Your team is too slow. Consider adding faster Pokemon or Trick Room support.",
                recommendedPokemon: ["dragapult", "zeraora", "regieleki", "porygon2"],
                impact: .major
            ))
        }
        
        // Check for hazard control
        if !analysis.hazardControl.hasRapidSpin && !analysis.hazardControl.hasDefog {
            suggestions.append(OptimizationSuggestion(
                priority: .medium,
                category: .utility,
                title: "Add Hazard Removal",
                description: "Your team lacks hazard removal. This makes switching difficult.",
                recommendedPokemon: ["corviknight", "mandibuzz", "excadrill", "tornadus-t"],
                impact: .moderate
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Helper Functions
    private func calculateEffectiveSpeed(_ member: TeamMember, baseSpeed: Int) -> Int {
        var speed = baseSpeed
        
        // Apply nature modifier
        if member.nature.boostedStat == "Speed" {
            speed = Int(Double(speed) * 1.1)
        } else if member.nature.loweredStat == "Speed" {
            speed = Int(Double(speed) * 0.9)
        }
        
        // Apply EV investment
        speed += (member.evs["speed"] ?? 0) / 4
        
        // Apply Choice Scarf if equipped
        if member.item?.lowercased().contains("choice scarf") == true {
            speed = Int(Double(speed) * 1.5)
        }
        
        return speed
    }
    
    private func categorizeSpeedTier(_ speed: Int) -> String {
        switch speed {
        case 0..<50: return "Very Slow"
        case 50..<80: return "Slow"
        case 80..<100: return "Medium"
        case 100..<130: return "Fast"
        case 130...: return "Very Fast"
        default: return "Unknown"
        }
    }
    
    private func calculateOutspeeds(_ speed: Int) -> [String] {
        // Return list of common Pokemon this speed outspeeds
        var outspeeds: [String] = []
        
        let commonSpeeds: [(String, Int)] = [
            ("Regieleki", 200),
            ("Dragapult", 142),
            ("Zeraora", 143),
            ("Garchomp", 102),
            ("Gengar", 110),
            ("Latios", 110),
            ("Tapu Koko", 130),
            ("Greninja", 122),
            ("Weavile", 125)
        ]
        
        for (pokemon, threatSpeed) in commonSpeeds {
            if speed > threatSpeed {
                outspeeds.append(pokemon)
            }
        }
        
        return outspeeds
    }
    
    private func getCommonThreats() -> [String] {
        return ["dragapult", "garchomp", "landorus-t", "heatran", "tapu-koko", 
                "ferrothorn", "toxapex", "corviknight", "urshifu", "kyurem"]
    }
    
    private func canHandleThreat(_ member: TeamMember, threat: String) -> Bool {
        // Simplified threat checking logic
        guard let pokemon = member.pokemon else { return false }
        
        // Check type advantage
        // This would be more complex in a real implementation
        return true
    }
    
    private func analyzeHazardControl(_ team: PokemonTeam) -> HazardControl {
        var hasStealthRock = false
        var hasSpikes = false
        var hasToxicSpikes = false
        var hasRapidSpin = false
        var hasDefog = false
        
        for member in team.members {
            for move in member.moves {
                let moveLower = move.lowercased()
                if moveLower.contains("stealth rock") { hasStealthRock = true }
                if moveLower.contains("spikes") && !moveLower.contains("toxic") { hasSpikes = true }
                if moveLower.contains("toxic spikes") { hasToxicSpikes = true }
                if moveLower.contains("rapid spin") { hasRapidSpin = true }
                if moveLower.contains("defog") { hasDefog = true }
            }
        }
        
        return HazardControl(
            hasStealthRock: hasStealthRock,
            hasSpikes: hasSpikes,
            hasToxicSpikes: hasToxicSpikes,
            hasRapidSpin: hasRapidSpin,
            hasDefog: hasDefog
        )
    }
    
    private func analyzeStatusSpread(_ team: PokemonTeam) -> StatusSpread {
        var paralysis = 0
        var burn = 0
        var sleep = 0
        var poison = 0
        
        for member in team.members {
            for move in member.moves {
                let moveLower = move.lowercased()
                if moveLower.contains("thunder wave") || moveLower.contains("glare") { paralysis += 1 }
                if moveLower.contains("will-o-wisp") || moveLower.contains("scald") { burn += 1 }
                if moveLower.contains("sleep powder") || moveLower.contains("spore") { sleep += 1 }
                if moveLower.contains("toxic") { poison += 1 }
            }
        }
        
        return StatusSpread(
            paralysisUsers: paralysis,
            burnUsers: burn,
            sleepUsers: sleep,
            poisonUsers: poison
        )
    }
    
    private func analyzePivotOptions(_ team: PokemonTeam) -> Int {
        var pivots = 0
        
        for member in team.members {
            for move in member.moves {
                let moveLower = move.lowercased()
                if moveLower.contains("u-turn") || moveLower.contains("volt switch") || 
                   moveLower.contains("flip turn") || moveLower.contains("teleport") {
                    pivots += 1
                    break
                }
            }
        }
        
        return pivots
    }
    
    private func identifyCoreWeaknesses(_ team: PokemonTeam) -> [String] {
        var weaknesses: [String] = []
        
        let coverage = team.typeEffectiveness.defensiveCoverage
        let poorDefense = coverage.filter { $0.value == .poor }
        
        if poorDefense.count >= 3 {
            weaknesses.append("Weak to \(poorDefense.count) types defensively")
        }
        
        return weaknesses
    }
    
    private func analyzeMomentum(_ team: PokemonTeam) -> Double {
        let pivots = Double(analyzePivotOptions(team))
        let speed = Double(team.speedTiers.filter { $0.effectiveSpeed > 100 }.count)
        let priority = Double(analyzePriorityMoves(team))
        
        return (pivots + speed + priority) / 9.0 // Max 3 each, total 9
    }
    
    private func analyzeStallbreaking(_ team: PokemonTeam) -> Double {
        var stallbreakers = 0.0
        
        for member in team.members {
            // Check for Taunt users
            if member.moves.contains(where: { $0.lowercased().contains("taunt") }) {
                stallbreakers += 0.5
            }
            
            // Check for strong wallbreakers
            if let pokemon = member.pokemon {
                let attack = pokemon.stats.first(where: { $0.stat.name == "attack" })?.baseStat ?? 0
                let spAttack = pokemon.stats.first(where: { $0.stat.name == "special-attack" })?.baseStat ?? 0
                
                if attack > 130 || spAttack > 130 {
                    stallbreakers += 0.5
                }
            }
        }
        
        return min(stallbreakers / 3.0, 1.0) // Normalize to 0-1
    }
    
    private func analyzePriorityMoves(_ team: PokemonTeam) -> Int {
        var priority = 0
        
        let priorityMoves = ["extreme speed", "aqua jet", "bullet punch", "ice shard", 
                            "shadow sneak", "sucker punch", "mach punch", "fake out"]
        
        for member in team.members {
            for move in member.moves {
                if priorityMoves.contains(where: { move.lowercased().contains($0) }) {
                    priority += 1
                    break
                }
            }
        }
        
        return priority
    }
    
    private func analyzeRecoveryOptions(_ team: PokemonTeam) -> Int {
        var recovery = 0
        
        let recoveryMoves = ["roost", "recover", "slack off", "soft-boiled", "synthesis", 
                            "moonlight", "morning sun", "wish", "leech seed"]
        
        for member in team.members {
            for move in member.moves {
                if recoveryMoves.contains(where: { move.lowercased().contains($0) }) {
                    recovery += 1
                    break
                }
            }
        }
        
        return recovery
    }
    
    private func analyzeHazardRemoval(_ team: PokemonTeam) -> Int {
        var removal = 0
        
        for member in team.members {
            for move in member.moves {
                let moveLower = move.lowercased()
                if moveLower.contains("rapid spin") || moveLower.contains("defog") {
                    removal += 1
                    break
                }
            }
        }
        
        return removal
    }
    
    private func identifyWeatherSetters(_ team: PokemonTeam) -> [String] {
        var setters: [String] = []
        
        for member in team.members {
            guard let pokemon = member.pokemon else { continue }
            
            // Check for weather abilities (simplified)
            if let ability = member.ability?.lowercased() {
                if ability.contains("drought") { setters.append("\(pokemon.name) (Sun)") }
                if ability.contains("drizzle") { setters.append("\(pokemon.name) (Rain)") }
                if ability.contains("sand stream") { setters.append("\(pokemon.name) (Sand)") }
                if ability.contains("snow warning") { setters.append("\(pokemon.name) (Hail)") }
            }
        }
        
        return setters
    }
    
    private func calculateSynergyScore(_ team: PokemonTeam) -> Double {
        var score = 0.0
        
        // Type synergy
        score += Double(team.typeEffectiveness.synergyScore) / 100.0 * 30
        
        // Role synergy
        let roles = Set(team.members.map { $0.role })
        score += Double(roles.count) / Double(TeamRole.allCases.count) * 20
        
        // Speed tier distribution
        let speedVariance = calculateSpeedVariance(team.speedTiers.map { $0.effectiveSpeed })
        score += speedVariance * 20
        
        // Defensive/Offensive balance
        let balance = abs(50 - team.typeEffectiveness.offensiveCoverage.filter { $0.value == .excellent }.count * 10)
        score += Double(50 - balance) / 50.0 * 30
        
        return min(score, 100)
    }
    
    private func calculateSpeedVariance(_ speeds: [Int]) -> Double {
        guard speeds.count > 1 else { return 0.5 }
        
        let mean = Double(speeds.reduce(0, +)) / Double(speeds.count)
        let variance = speeds.map { pow(Double($0) - mean, 2) }.reduce(0, +) / Double(speeds.count)
        let standardDeviation = sqrt(variance)
        
        return min(standardDeviation / mean, 1.0)
    }
    
    private func analyzeThreatList(_ team: PokemonTeam) -> [ThreatAnalysis] {
        var threats: [ThreatAnalysis] = []
        
        let commonThreats = [
            ("Dragapult", ["dragon", "ghost"], 142),
            ("Garchomp", ["dragon", "ground"], 102),
            ("Landorus-T", ["ground", "flying"], 91),
            ("Heatran", ["fire", "steel"], 77),
            ("Tapu Koko", ["electric", "fairy"], 130)
        ]
        
        for (name, types, speed) in commonThreats {
            var counters: [String] = []
            var checks: [String] = []
            
            for member in team.members {
                guard let pokemon = member.pokemon else { continue }
                
                // Simplified counter/check logic
                let memberSpeed = pokemon.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
                
                if memberSpeed > speed {
                    checks.append(pokemon.name)
                }
                
                // Check type advantage
                for type in types {
                    if hasTypeAdvantage(pokemon.types.map { $0.pokemonType }, against: type) {
                        counters.append(pokemon.name)
                        break
                    }
                }
            }
            
            threats.append(ThreatAnalysis(
                threatName: name,
                threatLevel: counters.isEmpty ? .high : checks.isEmpty ? .medium : .low,
                counters: counters,
                checks: checks
            ))
        }
        
        return threats
    }
    
    private func hasTypeAdvantage(_ types: [PokemonType], against targetType: String) -> Bool {
        // Simplified type advantage check
        for type in types {
            if type.strongAgainst.contains(where: { $0.rawValue == targetType }) {
                return true
            }
        }
        return false
    }
}

// MARK: - Analysis Models
struct DetailedTeamAnalysis {
    let team: PokemonTeam
    let offensiveRating: OffensiveRating
    let defensiveRating: DefensiveRating
    let speedControl: SpeedControl
    let hazardControl: HazardControl
    let weatherSynergy: WeatherSynergy
    let statusSpread: StatusSpread
    let pivotOptions: Int
    let winConditions: [WinCondition]
    let coreWeaknesses: [String]
    let threatCoverage: ThreatCoverage
    let momentum: Double
    let stallbreaking: Double
}

struct OffensiveRating {
    let physicalDamage: Double
    let specialDamage: Double
    let mixedAttackers: Int
    let setupPotential: Int
    let wallbreaking: Int
    let speedControl: Int
    let priority: Int
}

struct DefensiveRating {
    let physicalBulk: Double
    let specialBulk: Double
    let recovery: Int
    let hazardRemoval: Int
    let statusAbsorbers: Int
    let pivoting: Int
    let walls: Int
}

struct SpeedControl {
    let speedTiers: [SpeedTierAnalysis]
    let hasTrickRoom: Bool
    let hasTailwind: Bool
    let hasSpeedBoost: Bool
    let hasParalysis: Bool
    let averageSpeed: Int
}

struct SpeedTierAnalysis {
    let pokemon: String
    let baseSpeed: Int
    let effectiveSpeed: Int
    let speedTier: String
    let outspeeds: [String]
}

struct HazardControl {
    let hasStealthRock: Bool
    let hasSpikes: Bool
    let hasToxicSpikes: Bool
    let hasRapidSpin: Bool
    let hasDefog: Bool
}

struct WeatherSynergy {
    let sunTeam: Bool
    let rainTeam: Bool
    let sandTeam: Bool
    let hailTeam: Bool
    let weatherSetters: [String]
    let weatherAbusers: Int
}

struct StatusSpread {
    let paralysisUsers: Int
    let burnUsers: Int
    let sleepUsers: Int
    let poisonUsers: Int
}

struct WinCondition {
    let type: WinConditionType
    let pokemon: [String]
    let reliability: Double
    
    enum WinConditionType {
        case setupSweep
        case stall
        case weatherSweep
        case trickRoom
        case hazardStack
    }
}

struct ThreatCoverage {
    let coveredThreats: [String]
    let uncoveredThreats: [String]
    let coveragePercentage: Double
}

struct ThreatAnalysis {
    let threatName: String
    let threatLevel: ThreatLevel
    let counters: [String]
    let checks: [String]
    
    enum ThreatLevel {
        case low, medium, high, critical
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
}

struct OptimizationSuggestion: Identifiable {
    let id = UUID()
    let priority: Priority
    let category: Category
    let title: String
    let description: String
    let recommendedPokemon: [String]
    let impact: Impact
    
    enum Priority {
        case low, medium, high, critical
        
        var color: Color {
            switch self {
            case .low: return .blue
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
    
    enum Category {
        case offensive, defensive, speed, utility, synergy
    }
    
    enum Impact {
        case minor, moderate, major, gameChanging
    }
}
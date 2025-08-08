//
//  TeamAnalysisEngine.swift
//  LuminaDex
//
//  Intelligent team analysis and optimization engine
//

import Foundation
import SwiftUI
import GRDB

class TeamAnalysisEngine: ObservableObject {
    static let shared = TeamAnalysisEngine()
    
    @Published var currentAnalysis: TeamAnalysis?
    @Published var suggestions: [TeamSuggestion] = []
    @Published var isAnalyzing = false
    
    private let database = DatabaseManager.shared
    
    // MARK: - Analysis
    func analyzeTeam(_ team: PokemonTeam) async {
        await MainActor.run {
            isAnalyzing = true
        }
        
        let analysis = TeamAnalysis(
            team: team,
            overallScore: calculateOverallScore(team),
            typeEffectiveness: analyzeTypeEffectiveness(team),
            speedAnalysis: analyzeSpeedTiers(team),
            roleDistribution: analyzeRoles(team),
            weaknesses: findWeaknesses(team),
            strengths: findStrengths(team),
            suggestions: await generateSuggestions(team)
        )
        
        await MainActor.run {
            self.currentAnalysis = analysis
            self.suggestions = analysis.suggestions
            self.isAnalyzing = false
        }
    }
    
    private func calculateOverallScore(_ team: PokemonTeam) -> Float {
        var score: Float = 0
        let weights = ScoreWeights()
        
        // Type coverage score
        let coverage = team.typeEffectiveness
        let offensiveScore = Float(coverage.offensiveCoverage.values.filter { 
            $0 == .good || $0 == .excellent 
        }.count) / Float(PokemonType.allCases.count) * 100
        score += offensiveScore * weights.typeCoverage
        
        // Defensive coverage score
        let defensiveScore = Float(coverage.defensiveCoverage.values.filter { 
            $0 == .good || $0 == .excellent 
        }.count) / Float(PokemonType.allCases.count) * 100
        score += defensiveScore * weights.defensiveCoverage
        
        // Role distribution score
        let roles = Set(team.members.map { $0.role })
        let roleScore = Float(roles.count) / Float(TeamRole.allCases.count) * 100
        score += roleScore * weights.roleDistribution
        
        // Speed tier distribution
        let speedTiers = team.speedTiers
        let speedVariance = calculateSpeedVariance(speedTiers)
        score += speedVariance * weights.speedDistribution
        
        // Synergy score
        score += coverage.synergyScore * weights.synergy
        
        return min(score, 100)
    }
    
    private func calculateSpeedVariance(_ tiers: [SpeedTier]) -> Float {
        guard tiers.count > 1 else { return 50 }
        
        let speeds = tiers.map { Float($0.effectiveSpeed) }
        let mean = speeds.reduce(0, +) / Float(speeds.count)
        let variance = speeds.map { pow($0 - mean, 2) }.reduce(0, +) / Float(speeds.count)
        let standardDeviation = sqrt(variance)
        
        // Higher variance is better for speed tiers
        return min(standardDeviation / mean * 100, 100)
    }
    
    private func analyzeTypeEffectiveness(_ team: PokemonTeam) -> TypeEffectivenessAnalysis {
        let coverage = team.typeEffectiveness
        
        var superEffectiveAgainst: [PokemonType] = []
        var notVeryEffectiveAgainst: [PokemonType] = []
        var immunities: [PokemonType] = []
        
        for (type, level) in coverage.offensiveCoverage {
            switch level {
            case .excellent:
                superEffectiveAgainst.append(type)
            case .poor:
                notVeryEffectiveAgainst.append(type)
            default:
                break
            }
        }
        
        return TypeEffectivenessAnalysis(
            offensiveCoverage: coverage.offensiveCoverage,
            defensiveCoverage: coverage.defensiveCoverage,
            superEffectiveAgainst: superEffectiveAgainst,
            notVeryEffectiveAgainst: notVeryEffectiveAgainst,
            immunities: immunities
        )
    }
    
    private func analyzeSpeedTiers(_ team: PokemonTeam) -> SpeedAnalysis {
        let tiers = team.speedTiers
        
        let fastest = tiers.first?.effectiveSpeed ?? 0
        let slowest = tiers.last?.effectiveSpeed ?? 0
        let average = tiers.isEmpty ? 0 : tiers.map { $0.effectiveSpeed }.reduce(0, +) / tiers.count
        
        var speedCategories: [SpeedCategory: [TeamMember]] = [:]
        
        for member in team.members {
            guard let pokemon = member.pokemon else { continue }
            let speedStat = pokemon.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
            let speed = speedStat + (member.evs["speed"] ?? 0) / 4
            
            let category: SpeedCategory
            if speed >= 130 {
                category = .veryFast
            } else if speed >= 100 {
                category = .fast
            } else if speed >= 70 {
                category = .medium
            } else if speed >= 40 {
                category = .slow
            } else {
                category = .verySlow
            }
            
            speedCategories[category, default: []].append(member)
        }
        
        return SpeedAnalysis(
            fastestSpeed: fastest,
            slowestSpeed: slowest,
            averageSpeed: average,
            speedTiers: tiers,
            speedCategories: speedCategories
        )
    }
    
    private func analyzeRoles(_ team: PokemonTeam) -> RoleDistribution {
        var distribution: [TeamRole: Int] = [:]
        
        for member in team.members {
            let role = member.role
            distribution[role, default: 0] += 1
        }
        
        let balance = calculateRoleBalance(distribution)
        
        return RoleDistribution(
            roles: distribution,
            balance: balance,
            missingRoles: findMissingRoles(distribution)
        )
    }
    
    private func calculateRoleBalance(_ distribution: [TeamRole: Int]) -> RoleBalance {
        let sweepers = (distribution[.physicalSweeper] ?? 0) + (distribution[.specialSweeper] ?? 0)
        let defensive = (distribution[.wall] ?? 0) + (distribution[.tank] ?? 0)
        let support = distribution[.support] ?? 0
        
        if sweepers >= 4 {
            return .hyperOffensive
        } else if defensive >= 4 {
            return .stall
        } else if sweepers == defensive {
            return .balanced
        } else if sweepers > defensive {
            return .offensive
        } else {
            return .defensive
        }
    }
    
    private func findMissingRoles(_ distribution: [TeamRole: Int]) -> [TeamRole] {
        var missing: [TeamRole] = []
        
        // Essential roles every team should consider
        let essentials: [TeamRole] = [.physicalSweeper, .specialSweeper, .tank, .support]
        
        for role in essentials {
            if distribution[role] == nil || distribution[role] == 0 {
                missing.append(role)
            }
        }
        
        return missing
    }
    
    private func findWeaknesses(_ team: PokemonTeam) -> [String] {
        var weaknesses: [String] = []
        
        let coverage = team.typeEffectiveness
        let poorOffensive = coverage.offensiveCoverage.filter { $0.value == .poor }
        let poorDefensive = coverage.defensiveCoverage.filter { $0.value == .poor }
        
        if poorOffensive.count >= 3 {
            weaknesses.append("Poor offensive coverage against \(poorOffensive.count) types")
        }
        
        if poorDefensive.count >= 3 {
            weaknesses.append("Vulnerable to \(poorDefensive.count) types defensively")
        }
        
        let roles = Set(team.members.map { $0.role })
        if roles.count <= 2 {
            weaknesses.append("Limited role diversity")
        }
        
        let speedTiers = team.speedTiers
        if speedTiers.allSatisfy({ $0.effectiveSpeed < 80 }) {
            weaknesses.append("Team is too slow overall")
        }
        
        if speedTiers.allSatisfy({ $0.effectiveSpeed > 110 }) {
            weaknesses.append("Vulnerable to Trick Room")
        }
        
        return weaknesses
    }
    
    private func findStrengths(_ team: PokemonTeam) -> [String] {
        var strengths: [String] = []
        
        let coverage = team.typeEffectiveness
        let excellentOffensive = coverage.offensiveCoverage.filter { $0.value == .excellent }
        let excellentDefensive = coverage.defensiveCoverage.filter { $0.value == .excellent }
        
        if excellentOffensive.count >= 6 {
            strengths.append("Excellent offensive coverage")
        }
        
        if excellentDefensive.count >= 6 {
            strengths.append("Strong defensive core")
        }
        
        if coverage.synergyScore >= 80 {
            strengths.append("Great team synergy")
        }
        
        let speedVariance = calculateSpeedVariance(team.speedTiers)
        if speedVariance >= 70 {
            strengths.append("Good speed tier distribution")
        }
        
        return strengths
    }
    
    // MARK: - Suggestions
    private func generateSuggestions(_ team: PokemonTeam) async -> [TeamSuggestion] {
        var suggestions: [TeamSuggestion] = []
        
        // Check for type coverage gaps
        let coverage = team.typeEffectiveness
        let poorCoverage = coverage.offensiveCoverage.filter { $0.value == .poor }
        
        if !poorCoverage.isEmpty {
            let types = poorCoverage.keys.map { $0.rawValue }.joined(separator: ", ")
            suggestions.append(TeamSuggestion(
                type: .coverage,
                priority: .high,
                title: "Improve Type Coverage",
                description: "Consider adding Pokemon with moves effective against: \(types)",
                pokemonSuggestions: await findPokemonForCoverage(poorCoverage.keys)
            ))
        }
        
        // Check for missing roles
        let roleDistribution = analyzeRoles(team)
        if !roleDistribution.missingRoles.isEmpty {
            for role in roleDistribution.missingRoles {
                suggestions.append(TeamSuggestion(
                    type: .role,
                    priority: .medium,
                    title: "Add \(role.rawValue)",
                    description: "Your team lacks a \(role.rawValue). Consider adding one for better balance.",
                    pokemonSuggestions: await findPokemonForRole(role)
                ))
            }
        }
        
        // Check speed tiers
        let speedAnalysis = analyzeSpeedTiers(team)
        if speedAnalysis.averageSpeed < 70 {
            suggestions.append(TeamSuggestion(
                type: .speed,
                priority: .medium,
                title: "Add Faster Pokemon",
                description: "Your team's average speed is low. Consider adding faster threats.",
                pokemonSuggestions: await findFastPokemon()
            ))
        }
        
        return suggestions
    }
    
    private func findPokemonForCoverage(_ types: Dictionary<PokemonType, CoverageLevel>.Keys) async -> [Pokemon] {
        // Query database for Pokemon strong against these types
        []  // Placeholder
    }
    
    private func findPokemonForRole(_ role: TeamRole) async -> [Pokemon] {
        // Query database for Pokemon fitting this role
        []  // Placeholder
    }
    
    private func findFastPokemon() async -> [Pokemon] {
        // Query database for fast Pokemon
        []  // Placeholder
    }
}

// MARK: - Analysis Models
struct TeamAnalysis {
    let team: PokemonTeam
    let overallScore: Float
    let typeEffectiveness: TypeEffectivenessAnalysis
    let speedAnalysis: SpeedAnalysis
    let roleDistribution: RoleDistribution
    let weaknesses: [String]
    let strengths: [String]
    let suggestions: [TeamSuggestion]
}

struct TypeEffectivenessAnalysis {
    let offensiveCoverage: [PokemonType: CoverageLevel]
    let defensiveCoverage: [PokemonType: CoverageLevel]
    let superEffectiveAgainst: [PokemonType]
    let notVeryEffectiveAgainst: [PokemonType]
    let immunities: [PokemonType]
}

struct SpeedAnalysis {
    let fastestSpeed: Int
    let slowestSpeed: Int
    let averageSpeed: Int
    let speedTiers: [SpeedTier]
    let speedCategories: [SpeedCategory: [TeamMember]]
}

struct RoleDistribution {
    let roles: [TeamRole: Int]
    let balance: RoleBalance
    let missingRoles: [TeamRole]
}

struct TeamSuggestion: Identifiable {
    let id = UUID()
    let type: SuggestionType
    let priority: SuggestionPriority
    let title: String
    let description: String
    let pokemonSuggestions: [Pokemon]
}

// MARK: - Enums
enum SpeedCategory: String {
    case veryFast = "Very Fast (130+)"
    case fast = "Fast (100-129)"
    case medium = "Medium (70-99)"
    case slow = "Slow (40-69)"
    case verySlow = "Very Slow (<40)"
}

enum RoleBalance: String {
    case hyperOffensive = "Hyper Offensive"
    case offensive = "Offensive"
    case balanced = "Balanced"
    case defensive = "Defensive"
    case stall = "Stall"
    
    var color: Color {
        switch self {
        case .hyperOffensive: return .red
        case .offensive: return .orange
        case .balanced: return .green
        case .defensive: return .blue
        case .stall: return .purple
        }
    }
}

enum SuggestionType {
    case coverage
    case role
    case speed
    case synergy
    case counter
}

enum SuggestionPriority {
    case high
    case medium
    case low
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }
}

// MARK: - Score Weights
struct ScoreWeights {
    let typeCoverage: Float = 0.25
    let defensiveCoverage: Float = 0.20
    let roleDistribution: Float = 0.20
    let speedDistribution: Float = 0.15
    let synergy: Float = 0.20
}
//
//  DNAViewModel.swift
//  LuminaDex
//
//  View model for DNA helix visualization
//

import SwiftUI
import Combine

// MARK: - DNA View Model

class DNAViewModel: ObservableObject {
    @Published var geneSequence: [DNASegment] = []
    @Published var dnaStability: Float = 0.85
    @Published var dnaPurity: Float = 0.92
    @Published var evolutionPotential: Float = 0.78
    @Published var basePairCount: Int = 3000
    @Published var mutationCount: Int = 12
    @Published var typeMatchPercentage: Float = 94.5
    @Published var powerLevel: Int = 850
    @Published var zoomLevel: Float = 1.0
    @Published var isAnalyzing: Bool = false
    @Published var analysisProgress: Float = 0.0
    
    private var pokemon: Pokemon?
    private var cancellables = Set<AnyCancellable>()
    
    func analyzePokemon(_ pokemon: Pokemon) {
        self.pokemon = pokemon
        generateGeneSequence(for: pokemon)
        calculateDNAMetrics(for: pokemon)
    }
    
    private func generateGeneSequence(for pokemon: Pokemon) {
        geneSequence.removeAll()
        
        // Generate segments based on Pokemon stats and types
        let statNames = ["HP", "Attack", "Defense", "Sp. Atk", "Sp. Def", "Speed"]
        let stats = pokemon.stats
        
        // Type-based genes
        geneSequence.append(DNASegment(
            name: "Primary Type Gene",
            code: "PTG",
            description: "Controls \(pokemon.primaryType.displayName) type expression and abilities",
            typeAffinity: pokemon.primaryType,
            expression: 0.95,
            stability: .high,
            position: 0,
            mutationPossibilities: ["Enhanced \(pokemon.primaryType.displayName)", "Pure Type"]
        ))
        
        if let secondaryType = pokemon.secondaryType {
            geneSequence.append(DNASegment(
                name: "Secondary Type Gene",
                code: "STG",
                description: "Regulates \(secondaryType.displayName) type traits",
                typeAffinity: secondaryType,
                expression: 0.75,
                stability: .medium,
                position: 1,
                mutationPossibilities: ["Type Synergy", "Dual Type Master"]
            ))
        }
        
        // Stat-based genes
        for (index, stat) in stats.enumerated() {
            let statName = index < statNames.count ? statNames[index] : "Unknown"
            let statValue = Float(stat.baseStat) / 255.0
            
            let segment = DNASegment(
                name: "\(statName) Gene",
                code: String(statName.prefix(3)).uppercased(),
                description: "Determines \(statName) potential and growth",
                typeAffinity: getTypeAffinityForStat(statName),
                expression: statValue,
                stability: getStabilityForValue(statValue),
                position: index + 2,
                mutationPossibilities: getMutationsForStat(statName, value: statValue)
            )
            geneSequence.append(segment)
        }
        
        // Special ability genes
        for (index, ability) in pokemon.abilities.prefix(3).enumerated() {
            let abilitySegment = DNASegment(
                name: "Ability Gene \(index + 1)",
                code: "ABL\(index + 1)",
                description: "Encodes special ability: \(ability.ability.name)",
                typeAffinity: .normal,
                expression: ability.isHidden ? 0.3 : 0.8,
                stability: ability.isHidden ? .low : .high,
                position: stats.count + 2 + index,
                mutationPossibilities: ability.isHidden ? ["Hidden Power", "Ability Awakening"] : []
            )
            geneSequence.append(abilitySegment)
        }
        
        // Evolution genes
        geneSequence.append(DNASegment(
            name: "Evolution Potential",
            code: "EVO",
            description: "Determines evolution capacity and mega evolution potential",
            typeAffinity: .dragon,
            expression: 0.6,
            stability: .medium,
            position: geneSequence.count,
            mutationPossibilities: ["Mega Evolution", "Gigantamax", "Regional Form"]
        ))
        
        // Generate random filler sequences for visual completeness
        let targetCount = 50
        while geneSequence.count < targetCount {
            let randomSegment = generateRandomSegment(at: geneSequence.count)
            geneSequence.append(randomSegment)
        }
    }
    
    private func calculateDNAMetrics(for pokemon: Pokemon) {
        // Calculate stability based on stats distribution
        let stats = pokemon.stats.map { Float($0.baseStat) }
        let avgStat = stats.reduce(0, +) / Float(stats.count)
        let variance = stats.map { pow($0 - avgStat, 2) }.reduce(0, +) / Float(stats.count)
        dnaStability = max(0.3, min(1.0, 1.0 - (variance / 10000.0)))
        
        // Calculate purity based on type count
        dnaPurity = pokemon.types.count == 1 ? 0.95 : 0.75
        
        // Calculate evolution potential
        evolutionPotential = Float.random(in: 0.6...0.95)
        
        // Calculate base pair count based on total stats
        let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
        basePairCount = 2000 + totalStats * 5
        
        // Random mutation count
        mutationCount = Int.random(in: 5...20)
        
        // Type match percentage
        typeMatchPercentage = 85 + Float.random(in: 0...15)
        
        // Power level
        powerLevel = totalStats + Int.random(in: -50...200)
    }
    
    private func getTypeAffinityForStat(_ stat: String) -> PokemonType {
        switch stat {
        case "Attack": return .fighting
        case "Defense": return .steel
        case "Sp. Atk": return .psychic
        case "Sp. Def": return .fairy
        case "Speed": return .flying
        case "HP": return .normal
        default: return .normal
        }
    }
    
    private func getStabilityForValue(_ value: Float) -> GeneStability {
        if value > 0.8 { return .high }
        if value > 0.5 { return .medium }
        return .low
    }
    
    private func getMutationsForStat(_ stat: String, value: Float) -> [String] {
        var mutations: [String] = []
        
        if value > 0.7 {
            mutations.append("Super \(stat)")
            mutations.append("\(stat) Boost")
        }
        
        if value < 0.4 {
            mutations.append("\(stat) Training")
            mutations.append("Potential Unlock")
        }
        
        return mutations
    }
    
    private func generateRandomSegment(at position: Int) -> DNASegment {
        let codes = ["NCG", "JNK", "REG", "TRN", "INT", "EXN", "PRO", "END"]
        let types: [PokemonType] = [.normal, .psychic, .dark, .fairy, .dragon, .steel]
        
        return DNASegment(
            name: "Regulatory Sequence \(position)",
            code: codes.randomElement()!,
            description: "Non-coding regulatory sequence",
            typeAffinity: types.randomElement()!,
            expression: Float.random(in: 0.1...0.5),
            stability: .medium,
            position: position,
            mutationPossibilities: []
        )
    }
    
    // MARK: - Public Methods
    
    func updateZoom(_ zoom: Float) {
        zoomLevel = max(0.5, min(3.0, zoom))
    }
    
    func selectSegmentAt(_ location: CGPoint) {
        // Implementation for selecting DNA segment based on tap location
        // This would involve ray casting in 3D space
    }
    
    func performDeepAnalysis() {
        isAnalyzing = true
        analysisProgress = 0.0
        
        // Simulate analysis progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.analysisProgress += 0.05
            
            if self.analysisProgress >= 1.0 {
                self.analysisProgress = 1.0
                self.isAnalyzing = false
                timer.invalidate()
                
                // Update metrics after analysis
                self.recalculateMetrics()
            }
        }
    }
    
    func simulateMutation() {
        guard !geneSequence.isEmpty else { return }
        
        // Randomly mutate some segments
        for _ in 0..<3 {
            let randomIndex = Int.random(in: 0..<geneSequence.count)
            geneSequence[randomIndex].expression = Float.random(in: 0.3...1.0)
            geneSequence[randomIndex].stability = [.low, .medium, .high].randomElement()!
        }
        
        // Update mutation count
        mutationCount += 1
        
        // Recalculate metrics
        recalculateMetrics()
    }
    
    func exportDNAData() {
        // Implementation for exporting DNA data
        print("Exporting DNA data for \(pokemon?.name ?? "Unknown")")
        
        // Create export format
        let exportData = DNAExportData(
            pokemonName: pokemon?.name ?? "Unknown",
            geneSequence: geneSequence,
            metrics: DNAMetrics(
                stability: dnaStability,
                purity: dnaPurity,
                evolutionPotential: evolutionPotential,
                basePairCount: basePairCount,
                mutationCount: mutationCount
            ),
            timestamp: Date()
        )
        
        // In a real app, this would save to file or share
        print("Export data created: \(exportData)")
    }
    
    private func recalculateMetrics() {
        guard let pokemon = pokemon else { return }
        
        // Recalculate with slight variations
        dnaStability = max(0.3, min(1.0, dnaStability + Float.random(in: -0.1...0.1)))
        dnaPurity = max(0.3, min(1.0, dnaPurity + Float.random(in: -0.05...0.05)))
        evolutionPotential = max(0.3, min(1.0, evolutionPotential + Float.random(in: -0.1...0.1)))
        typeMatchPercentage = max(50, min(100, typeMatchPercentage + Float.random(in: -5...5)))
    }
}

// MARK: - DNA Segment Model

struct DNASegment: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let code: String
    let description: String
    let typeAffinity: PokemonType
    var expression: Float // 0.0 to 1.0
    var stability: GeneStability
    let position: Int
    let mutationPossibilities: [String]
}

enum GeneStability: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .red
        case .medium: return .yellow
        case .high: return .green
        }
    }
    
    var description: String {
        rawValue
    }
}

// MARK: - Export Models

struct DNAExportData {
    let pokemonName: String
    let geneSequence: [DNASegment]
    let metrics: DNAMetrics
    let timestamp: Date
}

struct DNAMetrics {
    let stability: Float
    let purity: Float
    let evolutionPotential: Float
    let basePairCount: Int
    let mutationCount: Int
}


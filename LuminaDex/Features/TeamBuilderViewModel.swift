//
//  TeamBuilderViewModel.swift
//  LuminaDex
//
//  Team Builder view model and logic
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TeamBuilderViewModel: ObservableObject {
    @Published var team = PokemonTeam()
    @Published var savedTeams: [PokemonTeam] = []
    @Published var isLoading = false
    @Published var showingShareSheet = false
    @Published var shareURL: URL?
    
    private let database = DatabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSavedTeams()
    }
    
    // MARK: - Team Management
    func addPokemon(_ pokemon: Pokemon, at slot: Int?) {
        var member = TeamMember()
        member.pokemonId = pokemon.id
        member.pokemon = pokemon
        
        if let slot = slot, slot < team.members.count {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                team.members[slot] = member
            }
        } else if team.members.count < 6 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                team.members.append(member)
            }
        }
        
        team.lastModified = Date()
        HapticManager.notification(type: .success)
    }
    
    func removePokemon(at index: Int) {
        guard index < team.members.count else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            team.members.remove(at: index)
        }
        
        team.lastModified = Date()
        HapticManager.impact(style: .light)
    }
    
    func swapPokemon(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex < team.members.count else { return }
        
        if destinationIndex >= team.members.count {
            // Moving to empty slot
            let member = team.members.remove(at: sourceIndex)
            team.members.append(member)
        } else {
            // Swapping positions
            team.members.swapAt(sourceIndex, destinationIndex)
        }
        
        team.lastModified = Date()
        HapticManager.impact(style: .light)
    }
    
    func updateMember(_ member: TeamMember, at index: Int) {
        guard index < team.members.count else { return }
        
        withAnimation {
            team.members[index] = member
        }
        
        team.lastModified = Date()
    }
    
    // MARK: - Team Operations
    func saveTeam() {
        savedTeams.append(team)
        saveToDisk()
        HapticManager.notification(type: .success)
    }
    
    func loadTeam(_ savedTeam: PokemonTeam) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            team = savedTeam
        }
    }
    
    func clearTeam() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            team = PokemonTeam()
        }
        HapticManager.impact(style: .medium)
    }
    
    func loadTemplate() {
        let templates = TeamTemplate.templates
        if let randomTemplate = templates.randomElement() {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                team = randomTemplate
            }
        }
    }
    
    // MARK: - Sharing
    func shareTeam() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(team) {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(team.name).json")
            
            try? data.write(to: tempURL)
            shareURL = tempURL
            showingShareSheet = true
        }
    }
    
    func exportTeam() {
        // Create multiple export formats
        let showdownExport = exportToShowdown()
        let jsonExport = exportToJSON()
        
        // For now, copy Showdown format to clipboard
        UIPasteboard.general.string = showdownExport
        HapticManager.notification(type: .success)
    }
    
    private func exportToShowdown() -> String {
        var export = "=== \(team.name) ===\n\n"
        
        for member in team.members {
            guard let pokemon = member.pokemon else { continue }
            
            export += "\(member.nickname ?? pokemon.name.capitalized)"
            if let item = member.item {
                export += " @ \(item)"
            }
            export += "\n"
            
            export += "Ability: \(member.ability ?? pokemon.abilities.first?.ability.name ?? "Unknown")\n"
            export += "Level: \(member.level)\n"
            
            // EVs
            let evString = member.evs.compactMap { key, value in
                value > 0 ? "\(value) \(key.capitalized)" : nil
            }.joined(separator: " / ")
            if !evString.isEmpty {
                export += "EVs: \(evString)\n"
            }
            
            export += "\(member.nature.rawValue) Nature\n"
            
            // IVs if not perfect
            let ivString = member.ivs.compactMap { key, value in
                value < 31 ? "\(value) \(key.capitalized)" : nil
            }.joined(separator: " / ")
            if !ivString.isEmpty {
                export += "IVs: \(ivString)\n"
            }
            
            // Moves
            for move in member.moves {
                export += "- \(move)\n"
            }
            
            export += "\n"
        }
        
        return export
    }
    
    private func exportToJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(team),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
    
    func importFromShowdown(_ text: String) {
        // Parse showdown format
        // Implementation would parse the text format
    }
    
    // MARK: - Analysis Helpers
    func getBalanceText() -> String {
        let roles = Set(team.members.map { $0.role })
        if roles.count >= 4 {
            return "Great"
        } else if roles.count >= 3 {
            return "Good"
        } else if roles.count >= 2 {
            return "Fair"
        } else {
            return "Poor"
        }
    }
    
    func getAverageSpeed() -> Int {
        guard !team.members.isEmpty else { return 0 }
        
        let totalSpeed = team.members.compactMap { member in
            member.pokemon?.stats.first(where: { $0.stat.name == "speed" })?.baseStat
        }.reduce(0, +)
        
        return totalSpeed / max(team.members.count, 1)
    }
    
    // MARK: - Suggestions
    func applySuggestion(_ suggestion: TeamSuggestion) {
        // Apply the suggestion based on type
        switch suggestion.type {
        case .coverage:
            if let pokemon = suggestion.pokemonSuggestions.first {
                addPokemon(pokemon, at: nil)
            }
        case .role:
            if let pokemon = suggestion.pokemonSuggestions.first {
                addPokemon(pokemon, at: nil)
            }
        default:
            break
        }
        
        HapticManager.notification(type: .success)
    }
    
    // MARK: - Persistence
    private func loadSavedTeams() {
        if let data = UserDefaults.standard.data(forKey: "savedTeams"),
           let teams = try? JSONDecoder().decode([PokemonTeam].self, from: data) {
            savedTeams = teams
        }
    }
    
    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(savedTeams) {
            UserDefaults.standard.set(data, forKey: "savedTeams")
        }
    }
}
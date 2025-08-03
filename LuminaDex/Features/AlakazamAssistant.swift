//
//  AlakazamAssistant.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//

import SwiftUI
import Combine

@MainActor
class AlakazamAssistant: ObservableObject {
    @Published var isVisible = false
    @Published var currentMessage = ""
    
    private let messages = [
        "✨ Try searching for types like 'fire' or 'electric'",
        "🔮 Search by generation: 'gen 1' or 'kanto'",
        "⚡ Voice commands work too! Just say what you're looking for",
        "🌟 Try 'legendary' to find rare Pokémon",
        "🎯 Search for specific names: 'pikachu' or 'charizard'",
        "🌊 Explore regions: 'hoenn', 'sinnoh', 'galar'",
        "🔥 Filter by starter Pokémon with 'starter'",
        "💫 Feeling lucky? Try 'surprise me'",
        "🧬 Search by abilities or moves coming soon...",
        "🎪 Combine searches: 'fire legendary' or 'water starter'"
    ]
    
    private var messageTimer: Timer?
    private var visibilityTimer: Timer?
    
    func appear() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            isVisible = true
        }
        
        // Start showing helpful messages
        startMessageCycle()
    }
    
    func disappear() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isVisible = false
            currentMessage = ""
        }
        
        stopMessageCycle()
    }
    
    func showHint(for query: String) {
        let hints: [String: String] = [
            "fire": "🔥 Found fire types! Try 'fire starter' for fire starter Pokémon",
            "water": "🌊 Splash! Try 'water legendary' for powerful water types",
            "electric": "⚡ Shocking results! Search 'electric gen 1' for classic electric types",
            "grass": "🌿 Nature's power! Try 'grass evolution' for evolving grass types",
            "legendary": "👑 Legendary creatures await! Try adding a type: 'legendary dragon'",
            "starter": "🎯 Starter squad! Try 'starter fire' or 'starter gen 3'",
            "dragon": "🐉 Mighty dragons! Search 'dragon legendary' for ultimate power",
            "psychic": "🔮 Mind-bending! Try 'psychic legendary' for mystical creatures",
            "gen": "🎮 Generation selected! Try combining: 'gen 1 fire' or 'gen 4 legendary'",
            "kanto": "🗾 Classic region! Try 'kanto legendary' or 'kanto starter'"
        ]
        
        let lowercasedQuery = query.lowercased()
        for (keyword, hint) in hints {
            if lowercasedQuery.contains(keyword) {
                showMessage(hint)
                return
            }
        }
        
        // Default encouraging message
        showMessage("🎯 Great search! Try adding types or regions for more specific results")
    }
    
    func showMessage(_ message: String) {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentMessage = message
        }
        
        // Auto-hide message after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.4)) {
                self.currentMessage = ""
            }
        }
    }
    
    private func startMessageCycle() {
        // Show first helpful message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showRandomTip()
        }
        
        // Continue showing tips every 10 seconds
        messageTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            if self.currentMessage.isEmpty {
                self.showRandomTip()
            }
        }
    }
    
    private func stopMessageCycle() {
        messageTimer?.invalidate()
        messageTimer = nil
        visibilityTimer?.invalidate()
        visibilityTimer = nil
    }
    
    private func showRandomTip() {
        guard let randomMessage = messages.randomElement() else { return }
        showMessage(randomMessage)
    }
    
    func celebrateSuccess() {
        let celebrations = [
            "🎉 Excellent search! You're becoming a Pokémon master!",
            "✨ Amazing results! Your search skills are legendary!",
            "🔥 Spectacular! You've unlocked the secrets of the Pokédex!",
            "⚡ Incredible! The Pokémon world reveals its mysteries to you!",
            "🌟 Outstanding! Your search prowess knows no bounds!"
        ]
        
        if let celebration = celebrations.randomElement() {
            showMessage(celebration)
        }
    }
    
    func offerHelp() {
        let helpMessages = [
            "🤔 Having trouble? Try simpler terms like 'fire' or 'legendary'",
            "💡 Tip: Search by type, generation, or region for better results",
            "🔍 Try voice search for hands-free exploration!",
            "🎯 Combine terms: 'water gen 3' or 'electric legendary'",
            "✨ Use descriptive words: 'starter', 'evolution', 'dragon'"
        ]
        
        if let helpMessage = helpMessages.randomElement() {
            showMessage(helpMessage)
        }
    }
}

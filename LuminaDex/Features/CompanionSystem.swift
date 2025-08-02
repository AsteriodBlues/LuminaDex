//
//  CompanionSystem.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI
import Combine

// MARK: - Companion Manager

@MainActor
class CompanionManager: ObservableObject {
    @Published var currentCompanion: CompanionData?
    @Published var isCompanionVisible: Bool = true
    @Published var companionPosition: CGPoint = .zero
    @Published var companionEmotionState: EmotionState = .neutral
    
    private var cancellables = Set<AnyCancellable>()
    private let persistenceKey = "selectedCompanion"
    
    init() {
        loadCompanion()
        setupEmotionUpdates()
    }
    
    // MARK: - Companion Selection
    
    func selectCompanion(_ companion: CompanionData) {
        currentCompanion = companion
        saveCompanion()
        
        // Initialize companion with happy emotion
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            companionEmotionState = .happy
        }
        
        // Reset to neutral after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.companionEmotionState = .neutral
            }
        }
    }
    
    // MARK: - Companion Behaviors
    
    func updateCompanionPosition(to position: CGPoint) {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
            companionPosition = position
        }
    }
    
    func celebrateDiscovery() {
        guard currentCompanion != nil else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            companionEmotionState = .excited
        }
        
        // Increase happiness and experience
        increaseHappiness(by: 5)
        increaseExperience(by: 10)
        
        // Return to neutral after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.companionEmotionState = .neutral
            }
        }
    }
    
    func reactToWeather(_ weather: WeatherType) {
        guard currentCompanion != nil else { return }
        
        let newEmotion: EmotionState = switch weather {
        case .sunny: .happy
        case .rainy: .sad
        case .stormy: .scared
        case .snowy: .curious
        }
        
        withAnimation(.easeInOut(duration: 0.6)) {
            companionEmotionState = newEmotion
        }
    }
    
    func feedCompanion() {
        guard var companion = currentCompanion else { return }
        
        companion.happiness = min(companion.happiness + 20, 100)
        currentCompanion = companion
        saveCompanion()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            companionEmotionState = .happy
        }
    }
    
    func toggleCompanionVisibility() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isCompanionVisible.toggle()
        }
    }
    
    // MARK: - Private Methods
    
    private func increaseHappiness(by amount: Int) {
        guard var companion = currentCompanion else { return }
        companion.happiness = min(companion.happiness + amount, 100)
        currentCompanion = companion
        saveCompanion()
    }
    
    private func increaseExperience(by amount: Int) {
        guard var companion = currentCompanion else { return }
        companion.experience += amount
        currentCompanion = companion
        saveCompanion()
    }
    
    private func setupEmotionUpdates() {
        // Auto-decay happiness over time (realistic pet simulation)
        Timer.publish(every: 300, on: .main, in: .common) // Every 5 minutes
            .autoconnect()
            .sink { _ in
                self.decreaseHappiness(by: 1)
            }
            .store(in: &cancellables)
        
        // Update emotion based on happiness level
        $currentCompanion
            .compactMap { $0 }
            .map { companion in
                switch companion.happiness {
                case 80...100: return EmotionState.happy
                case 60..<80: return EmotionState.neutral
                case 40..<60: return EmotionState.bored
                case 20..<40: return EmotionState.sad
                default: return EmotionState.sleeping
                }
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { newEmotion in
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.companionEmotionState = newEmotion
                }
            }
            .store(in: &cancellables)
    }
    
    private func decreaseHappiness(by amount: Int) {
        guard var companion = currentCompanion else { return }
        companion.happiness = max(companion.happiness - amount, 0)
        currentCompanion = companion
        saveCompanion()
    }
    
    // MARK: - Persistence
    
    private func saveCompanion() {
        guard let companion = currentCompanion else { return }
        
        do {
            let data = try JSONEncoder().encode(companion)
            UserDefaults.standard.set(data, forKey: persistenceKey)
        } catch {
            print("Failed to save companion: \(error)")
        }
    }
    
    private func loadCompanion() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey) else { return }
        
        do {
            let companion = try JSONDecoder().decode(CompanionData.self, from: data)
            currentCompanion = companion
        } catch {
            print("Failed to load companion: \(error)")
        }
    }
}

// MARK: - Emotion System

enum EmotionState: String, CaseIterable {
    case happy, excited, neutral, bored, sad, scared, curious, sleeping
    
    var animationScale: CGFloat {
        switch self {
        case .excited: return 1.2
        case .happy: return 1.1
        case .curious: return 1.05
        case .neutral, .bored: return 1.0
        case .sad, .scared: return 0.9
        case .sleeping: return 0.8
        }
    }
    
    var animationOffset: CGPoint {
        switch self {
        case .excited: return CGPoint(x: 0, y: -5)
        case .happy: return CGPoint(x: 0, y: -2)
        case .curious: return CGPoint(x: 2, y: 0)
        case .scared: return CGPoint(x: -2, y: 2)
        case .sleeping: return CGPoint(x: 0, y: 5)
        default: return .zero
        }
    }
    
    var particleEffect: ParticleEffect? {
        switch self {
        case .excited: return .sparkles
        case .happy: return .hearts
        case .sad: return .teardrops
        case .sleeping: return .zzz
        default: return nil
        }
    }
}

enum ParticleEffect {
    case sparkles, hearts, teardrops, zzz
    
    var systemImage: String {
        switch self {
        case .sparkles: return "sparkles"
        case .hearts: return "heart.fill"
        case .teardrops: return "drop.fill"
        case .zzz: return "zzz"
        }
    }
    
    var color: Color {
        switch self {
        case .sparkles: return .yellow
        case .hearts: return .pink
        case .teardrops: return .blue
        case .zzz: return .gray
        }
    }
}

enum WeatherType {
    case sunny, rainy, stormy, snowy
}

// MARK: - CompanionData Codable Implementation
// Moved to Data/CompanionData.swift for better organization
//
//  CompanionData.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

// MARK: - Companion Data Model

struct CompanionData {
    let type: CompanionType
    let name: String
    var happiness: Int
    var experience: Int
    let dateSelected: Date
    
    init(type: CompanionType, name: String, happiness: Int, experience: Int) {
        self.type = type
        self.name = name
        self.happiness = happiness
        self.experience = experience
        self.dateSelected = Date()
    }
    
    // Computed properties for companion state
    var level: Int {
        return min(experience / 100 + 1, 100)
    }
    
    var moodEmoji: String {
        switch happiness {
        case 80...100: return "😄"
        case 60..<80: return "😊"
        case 40..<60: return "😐"
        case 20..<40: return "😔"
        default: return "😢"
        }
    }
}

// MARK: - Companion Types

enum CompanionType: String, CaseIterable {
    case pikachu, eevee, mew
    
    var name: String {
        switch self {
        case .pikachu: return "Pikachu"
        case .eevee: return "Eevee"
        case .mew: return "Mew"
        }
    }
    
    var sprite: String {
        // Unicode representations for preview
        switch self {
        case .pikachu: return "⚡"
        case .eevee: return "🦊"
        case .mew: return "✨"
        }
    }
    
    var personality: String {
        switch self {
        case .pikachu: return "Energetic and loyal, loves to explore new regions and celebrate discoveries"
        case .eevee: return "Adaptive and curious, evolves emotions based on your journey together"
        case .mew: return "Playful and mysterious, provides psychic insights and hidden knowledge"
        }
    }
    
    var traits: [String] {
        switch self {
        case .pikachu: return ["Energetic", "Loyal", "Explorer"]
        case .eevee: return ["Adaptive", "Curious", "Evolving"]
        case .mew: return ["Playful", "Mysterious", "Psychic"]
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .pikachu: return Color.yellow
        case .eevee: return Color.brown
        case .mew: return Color.pink
        }
    }
}

// MARK: - Make CompanionData Codable

extension CompanionData: Codable {
    enum CodingKeys: String, CodingKey {
        case type, name, happiness, experience, dateSelected
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let typeString = try container.decode(String.self, forKey: .type)
        guard let companionType = CompanionType(rawValue: typeString) else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid companion type")
        }
        
        self.type = companionType
        self.name = try container.decode(String.self, forKey: .name)
        self.happiness = try container.decode(Int.self, forKey: .happiness)
        self.experience = try container.decode(Int.self, forKey: .experience)
        self.dateSelected = try container.decode(Date.self, forKey: .dateSelected)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(happiness, forKey: .happiness)
        try container.encode(experience, forKey: .experience)
        try container.encode(dateSelected, forKey: .dateSelected)
    }
}
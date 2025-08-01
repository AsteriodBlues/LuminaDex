//
//  Region.swift
//  LuminaDex
//
//  Created by Ritwik on 8/1/25.
//
import Foundation
import SwiftUI

// MARK: - Pokemon Region
struct Region: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let locations: [RegionLocation]
    let mainGeneration: RegionGeneration
    let pokedexes: [RegionPokedex]
    let versionGroups: [RegionVersionGroup]
    
    var displayName: String {
        name.capitalized
    }
    
    // 3D Map coordinates (for our world map)
    var mapCoordinates: MapCoordinates {
        switch name.lowercased() {
        case "kanto":
            return MapCoordinates(latitude: 35.6762, longitude: 139.6503, zoom: 1.0)
        case "johto":
            return MapCoordinates(latitude: 34.6937, longitude: 135.5023, zoom: 1.0)
        case "hoenn":
            return MapCoordinates(latitude: 33.5904, longitude: 130.4017, zoom: 1.0)
        case "sinnoh":
            return MapCoordinates(latitude: 43.0642, longitude: 141.3469, zoom: 1.0)
        case "unova":
            return MapCoordinates(latitude: 40.7128, longitude: -74.0060, zoom: 1.0)
        case "kalos":
            return MapCoordinates(latitude: 48.8566, longitude: 2.3522, zoom: 1.0)
        case "alola":
            return MapCoordinates(latitude: 21.3099, longitude: -157.8581, zoom: 1.0)
        case "galar":
            return MapCoordinates(latitude: 55.3781, longitude: -3.4360, zoom: 1.0)
        case "paldea":
            return MapCoordinates(latitude: 40.4637, longitude: -3.7492, zoom: 1.0)
        default:
            return MapCoordinates(latitude: 0, longitude: 0, zoom: 1.0)
        }
    }
    
    // Color theme for region
    var primaryColor: Color {
        switch name.lowercased() {
        case "kanto":
            return Color(hex: "FF6B6B")  // Red
        case "johto":
            return Color(hex: "4ECDC4")  // Teal
        case "hoenn":
            return Color(hex: "45B7D1")  // Blue
        case "sinnoh":
            return Color(hex: "96CEB4")  // Green
        case "unova":
            return Color(hex: "FFEAA7")  // Yellow
        case "kalos":
            return Color(hex: "DDA0DD")  // Plum
        case "alola":
            return Color(hex: "FFD93D")  // Gold
        case "galar":
            return Color(hex: "6C5CE7")  // Purple
        case "paldea":
            return Color(hex: "FD79A8")  // Pink
        default:
            return ThemeManager.Colors.neural
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, primaryColor.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Generation info
    var generation: String {
        switch name.lowercased() {
        case "kanto":
            return "Generation I"
        case "johto":
            return "Generation II"
        case "hoenn":
            return "Generation III"
        case "sinnoh":
            return "Generation IV"
        case "unova":
            return "Generation V"
        case "kalos":
            return "Generation VI"
        case "alola":
            return "Generation VII"
        case "galar":
            return "Generation VIII"
        case "paldea":
            return "Generation IX"
        default:
            return "Unknown Generation"
        }
    }
    
    // Estimated Pokemon count for UI
    var estimatedPokemonCount: Int {
        switch name.lowercased() {
        case "kanto":
            return 151
        case "johto":
            return 100
        case "hoenn":
            return 135
        case "sinnoh":
            return 107
        case "unova":
            return 156
        case "kalos":
            return 72
        case "alola":
            return 81
        case "galar":
            return 89
        case "paldea":
            return 103
        default:
            return 0
        }
    }
}

// MARK: - Map Coordinates
struct MapCoordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let zoom: Double
}

// MARK: - Region Location
struct RegionLocation: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let url: String
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, url
    }
}

// MARK: - Region Generation
struct RegionGeneration: Codable, Hashable {
    let name: String
    let url: String
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    var romanNumeral: String {
        switch name {
        case "generation-i":
            return "I"
        case "generation-ii":
            return "II"
        case "generation-iii":
            return "III"
        case "generation-iv":
            return "IV"
        case "generation-v":
            return "V"
        case "generation-vi":
            return "VI"
        case "generation-vii":
            return "VII"
        case "generation-viii":
            return "VIII"
        case "generation-ix":
            return "IX"
        default:
            return "?"
        }
    }
}

// MARK: - Region Pokedex
struct RegionPokedex: Codable, Hashable {
    let name: String
    let url: String
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Region Version Group
struct RegionVersionGroup: Codable, Hashable {
    let name: String
    let url: String
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Region Weather (for environmental effects)
enum RegionWeather: String, CaseIterable {
    case sunny = "sunny"
    case rainy = "rainy"
    case snowy = "snowy"
    case cloudy = "cloudy"
    case sandstorm = "sandstorm"
    case foggy = "foggy"
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .snowy:
            return "cloud.snow.fill"
        case .cloudy:
            return "cloud.fill"
        case .sandstorm:
            return "wind"
        case .foggy:
            return "cloud.fog.fill"
        }
    }
    
    var particleColor: Color {
        switch self {
        case .sunny:
            return .yellow
        case .rainy:
            return .blue
        case .snowy:
            return .white
        case .cloudy:
            return .gray
        case .sandstorm:
            return .orange
        case .foggy:
            return .gray.opacity(0.5)
        }
    }
}

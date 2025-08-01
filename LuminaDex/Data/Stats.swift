import Foundation
import SwiftUI

// MARK: - Pokemon Stats Container
struct PokemonStats: Identifiable, Codable, Hashable {
    let id: UUID
    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int
    
    init(hp: Int, attack: Int, defense: Int, specialAttack: Int, specialDefense: Int, speed: Int) {
        self.id = UUID()
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
    }
    
    // Computed properties
    var total: Int {
        hp + attack + defense + specialAttack + specialDefense + speed
    }
    
    var average: Double {
        Double(total) / 6.0
    }
    
    // For radar chart visualization
    var chartData: [StatChartData] {
        [
            StatChartData(name: "HP", value: hp, color: .red, maxValue: 255),
            StatChartData(name: "Attack", value: attack, color: .orange, maxValue: 255),
            StatChartData(name: "Defense", value: defense, color: .blue, maxValue: 255),
            StatChartData(name: "Sp. Atk", value: specialAttack, color: .purple, maxValue: 255),
            StatChartData(name: "Sp. Def", value: specialDefense, color: .green, maxValue: 255),
            StatChartData(name: "Speed", value: speed, color: .yellow, maxValue: 255)
        ]
    }
    
    // Normalized values for animations (0.0 - 1.0)
    var normalizedStats: [Double] {
        [
            Double(hp) / 255.0,
            Double(attack) / 255.0,
            Double(defense) / 255.0,
            Double(specialAttack) / 255.0,
            Double(specialDefense) / 255.0,
            Double(speed) / 255.0
        ]
    }
    
    // Battle rating calculation
    var battleRating: BattleRating {
        let totalStat = total
        switch totalStat {
        case 0..<300:
            return .poor
        case 300..<400:
            return .below
        case 400..<500:
            return .average
        case 500..<600:
            return .good
        case 600..<700:
            return .excellent
        default:
            return .legendary
        }
    }
    
    // Primary stat category
    var primaryCategory: StatCategory {
        let stats = [
            ("Physical", attack + defense),
            ("Special", specialAttack + specialDefense),
            ("Speed", speed * 2),
            ("Tank", hp + defense + specialDefense)
        ]
        
        let highest = stats.max { $0.1 < $1.1 }
        
        switch highest?.0 {
        case "Physical":
            return .physical
        case "Special":
            return .special
        case "Speed":
            return .speed
        case "Tank":
            return .tank
        default:
            return .balanced
        }
    }
}

// MARK: - Stat Chart Data
struct StatChartData: Identifiable, Hashable {
    let id: UUID
    let name: String
    let value: Int
    let color: Color
    let maxValue: Int
    
    init(name: String, value: Int, color: Color, maxValue: Int) {
        self.id = UUID()
        self.name = name
        self.value = value
        self.color = color
        self.maxValue = maxValue
    }
    
    var percentage: Double {
        Double(value) / Double(maxValue)
    }
    
    var normalizedValue: Double {
        min(percentage, 1.0)
    }
    
    var displayValue: String {
        "\(value)"
    }
    
    var grade: StatGrade {
        let percent = percentage
        switch percent {
        case 0.0..<0.2:
            return .f
        case 0.2..<0.4:
            return .d
        case 0.4..<0.6:
            return .c
        case 0.6..<0.8:
            return .b
        case 0.8..<0.95:
            return .a
        default:
            return .s
        }
    }
}

// MARK: - Battle Rating
enum BattleRating: String, CaseIterable {
    case poor = "Poor"
    case below = "Below Average"
    case average = "Average"
    case good = "Good"
    case excellent = "Excellent"
    case legendary = "Legendary"
    
    var color: Color {
        switch self {
        case .poor:
            return .red
        case .below:
            return .orange
        case .average:
            return .yellow
        case .good:
            return .green
        case .excellent:
            return .blue
        case .legendary:
            return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .poor:
            return "arrow.down.circle.fill"
        case .below:
            return "minus.circle.fill"
        case .average:
            return "equal.circle.fill"
        case .good:
            return "plus.circle.fill"
        case .excellent:
            return "arrow.up.circle.fill"
        case .legendary:
            return "crown.fill"
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Stat Category
enum StatCategory: String, CaseIterable {
    case physical = "Physical Attacker"
    case special = "Special Attacker"
    case speed = "Speed Demon"
    case tank = "Tank"
    case balanced = "Balanced"
    
    var description: String {
        switch self {
        case .physical:
            return "Excels in physical combat"
        case .special:
            return "Masters special attacks"
        case .speed:
            return "Lightning fast movement"
        case .tank:
            return "High durability and defense"
        case .balanced:
            return "Well-rounded capabilities"
        }
    }
    
    var color: Color {
        switch self {
        case .physical:
            return .red
        case .special:
            return .purple
        case .speed:
            return .yellow
        case .tank:
            return .blue
        case .balanced:
            return .green
        }
    }
    
    var icon: String {
        switch self {
        case .physical:
            return "fist.raised.fill"
        case .special:
            return "sparkles"
        case .speed:
            return "bolt.fill"
        case .tank:
            return "shield.fill"
        case .balanced:
            return "scale.3d"
        }
    }
}

// MARK: - Stat Grade
enum StatGrade: String, CaseIterable {
    case f = "F"
    case d = "D"
    case c = "C"
    case b = "B"
    case a = "A"
    case s = "S"
    
    var color: Color {
        switch self {
        case .f:
            return .red
        case .d:
            return .orange
        case .c:
            return .yellow
        case .b:
            return .green
        case .a:
            return .blue
        case .s:
            return .purple
        }
    }
    
    var description: String {
        switch self {
        case .f:
            return "Very Poor"
        case .d:
            return "Poor"
        case .c:
            return "Average"
        case .b:
            return "Good"
        case .a:
            return "Excellent"
        case .s:
            return "Outstanding"
        }
    }
}

// MARK: - Stat Comparison
struct StatComparison {
    let pokemon1: PokemonStats
    let pokemon2: PokemonStats
    
    var winner: ComparisonResult {
        if pokemon1.total > pokemon2.total {
            return .first
        } else if pokemon2.total > pokemon1.total {
            return .second
        } else {
            return .tie
        }
    }
    
    var difference: Int {
        abs(pokemon1.total - pokemon2.total)
    }
    
    var percentageDifference: Double {
        let higher = max(pokemon1.total, pokemon2.total)
        let lower = min(pokemon1.total, pokemon2.total)
        return Double(higher - lower) / Double(higher) * 100
    }
}

// MARK: - Comparison Result
enum ComparisonResult {
    case first
    case second
    case tie
    
    var description: String {
        switch self {
        case .first:
            return "First Pokemon wins"
        case .second:
            return "Second Pokemon wins"
        case .tie:
            return "It's a tie!"
        }
    }
}

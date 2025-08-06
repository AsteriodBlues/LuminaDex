//
//  MoveTypeBadge.swift
//  LuminaDex
//
//  Cute badge component for move types
//

import SwiftUI

struct MoveTypeBadge: View {
    let type: PokemonType
    var size: BadgeSize = .medium
    var style: BadgeStyle = .filled
    
    enum BadgeSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
    }
    
    enum BadgeStyle {
        case filled, outlined, gradient
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: type.icon)
                .font(.system(size: size.iconSize))
                .foregroundColor(iconColor)
            
            Text(type.rawValue.capitalized)
                .font(size.fontSize)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, size.padding * 1.5)
        .padding(.vertical, size.padding)
        .background(backgroundView)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: style == .outlined ? 1.5 : 0)
        )
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            type.color.opacity(0.9)
        case .outlined:
            Color.clear
        case .gradient:
            LinearGradient(
                colors: [type.color, type.color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var iconColor: Color {
        switch style {
        case .filled, .gradient:
            return .white
        case .outlined:
            return type.color
        }
    }
    
    private var textColor: Color {
        switch style {
        case .filled, .gradient:
            return .white
        case .outlined:
            return type.color
        }
    }
    
    private var borderColor: Color {
        type.color
    }
}

// MARK: - Move Category Badge
struct MoveCategoryBadge: View {
    let category: MoveCategory
    var size: MoveTypeBadge.BadgeSize = .medium
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: size.iconSize))
                .foregroundColor(category.color)
            
            Text(category.rawValue)
                .font(size.fontSize)
                .fontWeight(.medium)
                .foregroundColor(category.color)
        }
        .padding(.horizontal, size.padding * 1.5)
        .padding(.vertical, size.padding)
        .background(category.color.opacity(0.15))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(category.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Move Power Badge
struct MovePowerBadge: View {
    let power: Int
    
    var powerColor: Color {
        switch power {
        case 0..<40:
            return .green
        case 40..<70:
            return .yellow
        case 70..<100:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.system(size: 10))
                .foregroundColor(powerColor)
            
            Text("\(power)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(powerColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(powerColor.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Move Accuracy Badge
struct MoveAccuracyBadge: View {
    let accuracy: Int
    
    var accuracyColor: Color {
        switch accuracy {
        case 0..<70:
            return .red
        case 70..<90:
            return .orange
        case 90..<100:
            return .yellow
        default:
            return .green
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "target")
                .font(.system(size: 10))
                .foregroundColor(accuracyColor)
            
            Text("\(accuracy)%")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(accuracyColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(accuracyColor.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Move PP Badge
struct MovePPBadge: View {
    let pp: Int
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "battery.100")
                .font(.system(size: 10))
                .foregroundColor(.blue)
            
            Text("\(pp)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.blue.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Priority Badge
struct MovePriorityBadge: View {
    let priority: Int
    
    var priorityColor: Color {
        switch priority {
        case ..<0:
            return .red
        case 0:
            return .gray
        default:
            return .green
        }
    }
    
    var priorityIcon: String {
        switch priority {
        case ..<0:
            return "tortoise.fill"
        case 0:
            return "equal.circle.fill"
        default:
            return "hare.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: priorityIcon)
                .font(.system(size: 10))
                .foregroundColor(priorityColor)
            
            Text(priority > 0 ? "+\(priority)" : "\(priority)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(priorityColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(priorityColor.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Previews
struct MoveTypeBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Type badges
            HStack(spacing: 8) {
                MoveTypeBadge(type: .fire, size: .small)
                MoveTypeBadge(type: .water, size: .medium)
                MoveTypeBadge(type: .electric, size: .large, style: .gradient)
                MoveTypeBadge(type: .grass, style: .outlined)
            }
            
            // Category badges
            HStack(spacing: 8) {
                MoveCategoryBadge(category: .physical)
                MoveCategoryBadge(category: .special)
                MoveCategoryBadge(category: .status)
            }
            
            // Stat badges
            HStack(spacing: 8) {
                MovePowerBadge(power: 90)
                MoveAccuracyBadge(accuracy: 100)
                MovePPBadge(pp: 15)
                MovePriorityBadge(priority: 1)
            }
        }
        .padding()
        .background(Color.black)
    }
}
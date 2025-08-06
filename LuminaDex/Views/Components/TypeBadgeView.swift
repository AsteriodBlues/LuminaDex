//
//  TypeBadgeView.swift
//  LuminaDex
//
//  Day 24: Enhanced type badges with animations
//

import SwiftUI

struct TypeBadgeView: View {
    let type: PokemonType
    let size: BadgeSize
    @State private var isAnimating = false
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 14
            case .large: return 16
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: size.iconSize))
                .foregroundColor(.white)
            
            Text(type.displayName)
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, size.padding + 2)
        .padding(.vertical, size.padding)
        .background(
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [type.color, type.color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Shimmer effect
                if isAnimating {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: isAnimating ? 100 : -100)
                    .animation(
                        .linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                }
            }
        )
        .clipShape(Capsule())
        .shadow(color: type.color.opacity(0.3), radius: 4, x: 0, y: 2)
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Type Effectiveness Badge
struct TypeEffectivenessBadge: View {
    let effectiveness: Double
    
    var effectivenessText: String {
        switch effectiveness {
        case 0: return "No Effect"
        case 0.25: return "1/4×"
        case 0.5: return "1/2×"
        case 1: return "1×"
        case 2: return "2×"
        case 4: return "4×"
        default: return "\(effectiveness)×"
        }
    }
    
    var effectivenessColor: Color {
        switch effectiveness {
        case 0: return .gray
        case let x where x < 1: return .red
        case 1: return .secondary
        case let x where x > 1: return .green
        default: return .secondary
        }
    }
    
    var effectivenessIcon: String {
        switch effectiveness {
        case 0: return "xmark.circle"
        case let x where x < 1: return "arrow.down.circle"
        case 1: return "minus.circle"
        case let x where x > 1: return "arrow.up.circle"
        default: return "questionmark.circle"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: effectivenessIcon)
                .font(.system(size: 12, weight: .semibold))
            
            Text(effectivenessText)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(effectivenessColor)
        .cornerRadius(6)
    }
}

// MARK: - Dual Type Badge
struct DualTypeBadge: View {
    let primaryType: PokemonType
    let secondaryType: PokemonType?
    let size: TypeBadgeView.BadgeSize
    
    var body: some View {
        HStack(spacing: 4) {
            TypeBadgeView(type: primaryType, size: size)
            
            if let secondaryType = secondaryType {
                Text("/")
                    .font(.system(size: size.fontSize, weight: .medium))
                    .foregroundColor(.secondary)
                
                TypeBadgeView(type: secondaryType, size: size)
            }
        }
    }
}

// MARK: - Type Icon Grid
struct TypeIconGrid: View {
    let types: [PokemonType]
    let columns: Int
    @State private var animatedTypes: Set<PokemonType> = []
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: columns)
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(types, id: \.rawValue) { type in
                TypeIconButton(
                    type: type,
                    isAnimated: animatedTypes.contains(type),
                    action: { }
                )
                .onAppear {
                    let delay = Double(types.firstIndex(of: type) ?? 0) * 0.05
                    withAnimation(.spring().delay(delay)) {
                        animatedTypes.insert(type)
                    }
                }
            }
        }
    }
}

// MARK: - Type Icon Button
struct TypeIconButton: View {
    let type: PokemonType
    let isAnimated: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [type.color, type.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: type.color.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: type.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.9 : (isAnimated ? 1.0 : 0.8))
            .opacity(isAnimated ? 1.0 : 0)
            .rotationEffect(.degrees(isPressed ? 10 : 0))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
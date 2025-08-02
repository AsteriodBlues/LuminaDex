//
//  RegionBubbleCard.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

struct RegionBubbleCard: View {
    let region: RegionNode
    let isSelected: Bool
    let activeSpriteCount: Int
    let spriteTypeDistribution: [PokemonType: Int]
    
    @State private var isHovered = false
    @State private var shimmerPhase: CGFloat = 0
    @State private var spriteAnimationPhase: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 8) {
            // Region name with glow
            Text(region.name)
                .font(ThemeManager.Typography.headlineBold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [region.primaryColor, region.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: region.primaryColor.opacity(0.5), radius: 8)
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .animation(ThemeManager.Animation.springBouncy, value: isSelected)
            
            // Generation badge
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.caption)
                Text("Gen \(region.generation)")
                    .font(ThemeManager.Typography.captionMedium)
            }
            .foregroundColor(ThemeManager.Colors.lumina.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(ThemeManager.Colors.glassMaterial)
                    .stroke(region.primaryColor.opacity(0.3), lineWidth: 1)
            )
            
            if isSelected {
                // Mini sprite preview animation
                HStack(spacing: 4) {
                    ForEach(Array(region.dominantTypes.prefix(3)), id: \.self) { type in
                        MiniSpritePreview(
                            type: type,
                            animationOffset: spriteAnimationPhase + CGFloat.random(in: 0...1),
                            isActive: isSelected
                        )
                    }
                }
                .padding(.vertical, 4)
                
                // Expanded details
                VStack(spacing: 6) {
                    // Pokemon count with live sprite counter
                    HStack {
                        Image(systemName: "circle.grid.cross")
                            .foregroundColor(region.secondaryColor)
                        Text("\(region.pokemonCount) Pokémon")
                            .font(ThemeManager.Typography.bodySmall)
                            .foregroundColor(ThemeManager.Colors.lumina.opacity(0.9))
                        Spacer()
                    }
                    
                    // Live sprite population display
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(region.primaryColor)
                            .font(.caption)
                        
                        Text("\(activeSpriteCount) Active Sprites")
                            .font(ThemeManager.Typography.captionMedium)
                            .foregroundColor(ThemeManager.Colors.lumina.opacity(0.9))
                        
                        Spacer()
                        
                        // Live indicator with pulse
                        HStack(spacing: 2) {
                            Circle()
                                .fill(region.primaryColor)
                                .frame(width: 4, height: 4)
                                .scaleEffect(1.0 + sin(spriteAnimationPhase * 2) * 0.3)
                            Text("Live")
                                .font(.caption2)
                                .foregroundColor(region.primaryColor)
                        }
                    }
                    
                    // Sprite activity meter
                    HStack {
                        Text("Activity")
                            .font(.caption2)
                            .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
                        
                        Spacer()
                        
                        // Activity bar
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ThemeManager.Colors.lumina.opacity(0.2))
                                .frame(height: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(
                                            LinearGradient(
                                                colors: [region.primaryColor, region.secondaryColor],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * activityLevel)
                                        .animation(.easeInOut(duration: 0.5), value: activityLevel)
                                , alignment: .leading
                                )
                        }
                        .frame(height: 4)
                    }
                    
                    // Live sprite type distribution
                    if !spriteTypeDistribution.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(region.primaryColor)
                                    .font(.caption)
                                Text("Live Distribution")
                                    .font(ThemeManager.Typography.captionBold)
                                    .foregroundColor(ThemeManager.Colors.lumina)
                                Spacer()
                            }
                            
                            // Type distribution bars
                            VStack(spacing: 2) {
                                ForEach(sortedTypeDistribution, id: \.type) { distribution in
                                    HStack(spacing: 6) {
                                        // Type indicator
                                        Circle()
                                            .fill(distribution.type.color)
                                            .frame(width: 8, height: 8)
                                            .overlay(
                                                Circle()
                                                    .fill(Color.white.opacity(0.3))
                                                    .frame(width: 4, height: 4)
                                            )
                                        
                                        // Type name
                                        Text(distribution.type.displayName)
                                            .font(.caption2)
                                            .foregroundColor(ThemeManager.Colors.lumina.opacity(0.8))
                                            .frame(width: 50, alignment: .leading)
                                        
                                        // Distribution bar
                                        GeometryReader { geometry in
                                            RoundedRectangle(cornerRadius: 1)
                                                .fill(distribution.type.color.opacity(0.3))
                                                .frame(height: 3)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 1)
                                                        .fill(distribution.type.color)
                                                        .frame(width: geometry.size.width * distribution.percentage)
                                                        .animation(.easeInOut(duration: 0.5), value: distribution.percentage)
                                                    , alignment: .leading
                                                )
                                        }
                                        .frame(height: 3)
                                        
                                        // Count
                                        Text("\(distribution.count)")
                                            .font(.caption2)
                                            .foregroundColor(distribution.type.color)
                                            .frame(width: 15, alignment: .trailing)
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // Dominant types
                    HStack {
                        Image(systemName: "atom")
                            .foregroundColor(region.primaryColor)
                        
                        HStack(spacing: 4) {
                            ForEach(Array(region.dominantTypes.prefix(3)), id: \.self) { type in
                                TypeChip(type: type, size: .small)
                            }
                        }
                        Spacer()
                    }
                    
                    // Climate info
                    HStack {
                        Image(systemName: climateIcon)
                            .foregroundColor(region.secondaryColor)
                        Text(climateDescription)
                            .font(ThemeManager.Typography.captionMedium)
                            .foregroundColor(ThemeManager.Colors.lumina.opacity(0.8))
                        Spacer()
                    }
                    
                    // Legendary Pokemon preview
                    if !region.legendaryPokemon.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(Color(hex: "FFD700"))
                                Text("Legendaries")
                                    .font(ThemeManager.Typography.captionBold)
                                    .foregroundColor(ThemeManager.Colors.lumina)
                                Spacer()
                            }
                            
                            Text(region.legendaryPokemon.prefix(2).joined(separator: ", "))
                                .font(ThemeManager.Typography.captionMedium)
                                .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(16)
        .frame(width: isSelected ? 260 : 140)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(glassMaterial)
                .stroke(glassStroke, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: region.primaryColor.opacity(0.3), radius: isSelected ? 15 : 8)
        )
        .overlay(
            // Shimmer effect
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: shimmerPhase - 0.1),
                            .init(color: region.primaryColor.opacity(0.6), location: shimmerPhase),
                            .init(color: .clear, location: shimmerPhase + 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .opacity(isHovered ? 1.0 : 0.0)
        )
        .scaleEffect(isSelected ? 1.05 : (isHovered ? 1.02 : 1.0))
        .animation(ThemeManager.Animation.springSmooth, value: isSelected)
        .animation(ThemeManager.Animation.easeInOut, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                startShimmer()
            }
        }
        .onAppear {
            if isSelected {
                startShimmer()
            }
            startSpriteAnimations()
        }
    }
    
    private var glassMaterial: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        region.primaryColor.opacity(0.2),
                        region.secondaryColor.opacity(0.15),
                        region.primaryColor.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            return AnyShapeStyle(ThemeManager.Colors.glassMaterial)
        }
    }
    
    private var glassStroke: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        region.primaryColor.opacity(0.6),
                        region.secondaryColor.opacity(0.4),
                        region.primaryColor.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            return AnyShapeStyle(ThemeManager.Colors.glassStroke)
        }
    }
    
    private var climateIcon: String {
        switch region.climate {
        case .temperate: return "leaf.fill"
        case .tropical: return "sun.max.fill"
        case .arctic: return "snowflake"
        case .desert: return "sun.dust.fill"
        case .volcanic: return "flame.fill"
        case .mystical: return "sparkles"
        }
    }
    
    private var climateDescription: String {
        switch region.climate {
        case .temperate: return "Temperate"
        case .tropical: return "Tropical"
        case .arctic: return "Arctic"
        case .desert: return "Desert"
        case .volcanic: return "Volcanic"
        case .mystical: return "Mystical"
        }
    }
    
    private func startShimmer() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerPhase = 1.0
        }
    }
    
    private func startSpriteAnimations() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            spriteAnimationPhase = 2 * .pi
        }
    }
    
    /// Calculate activity level based on sprite population
    private var activityLevel: CGFloat {
        let maxSprites = 8 // Based on max sprites per region
        return min(CGFloat(activeSpriteCount) / CGFloat(maxSprites), 1.0)
    }
    
    /// Sorted type distribution for display
    private var sortedTypeDistribution: [TypeDistribution] {
        let distributions = spriteTypeDistribution.map { (type, count) in
            TypeDistribution(
                type: type,
                count: count,
                percentage: activeSpriteCount > 0 ? CGFloat(count) / CGFloat(activeSpriteCount) : 0
            )
        }
        return distributions.sorted { $0.count > $1.count }
    }
}

struct TypeChip: View {
    let type: PokemonType
    let size: ChipSize
    
    enum ChipSize {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .footnote
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .medium: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }
    
    var body: some View {
        Text(type.displayName)
            .font(size.font.weight(.medium))
            .foregroundColor(.white)
            .padding(size.padding)
            .background(
                Capsule()
                    .fill(type.color)
                    .shadow(color: type.color.opacity(0.5), radius: 2)
            )
    }
}

/// Type distribution data structure
struct TypeDistribution {
    let type: PokemonType
    let count: Int
    let percentage: CGFloat
}

/// Mini sprite preview for region cards
struct MiniSpritePreview: View {
    let type: PokemonType
    let animationOffset: CGFloat
    let isActive: Bool
    
    var body: some View {
        ZStack {
            // Sprite glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            type.color.opacity(0.6),
                            type.color.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 16)
                .scaleEffect(isActive ? 1.0 + sin(animationOffset * 2) * 0.2 : 0.8)
            
            // Main sprite dot
            Circle()
                .fill(type.color)
                .frame(width: 6, height: 6)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 3, height: 3)
                )
                .scaleEffect(isActive ? 1.0 + sin(animationOffset * 3) * 0.15 : 0.9)
            
            // Floating animation
            Circle()
                .fill(type.color.opacity(0.4))
                .frame(width: 2, height: 2)
                .offset(
                    x: sin(animationOffset) * 6,
                    y: cos(animationOffset * 1.3) * 4
                )
                .opacity(isActive ? 1.0 : 0.0)
        }
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 20) {
            RegionBubbleCard(
                region: RegionNode.createNetworkLayout()[0],
                isSelected: false,
                activeSpriteCount: 3,
                spriteTypeDistribution: [.fire: 2, .water: 1]
            )
            
            RegionBubbleCard(
                region: RegionNode.createNetworkLayout()[1],
                isSelected: true,
                activeSpriteCount: 6,
                spriteTypeDistribution: [.grass: 3, .electric: 2, .normal: 1]
            )
        }
    }
    .preferredColorScheme(.dark)
}
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
    
    @State private var isHovered = false
    @State private var shimmerPhase: CGFloat = 0
    
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
                .scaleEffect(isSelected ? 1.1 : 1.0)
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
                // Expanded details
                VStack(spacing: 6) {
                    // Pokemon count
                    HStack {
                        Image(systemName: "circle.grid.cross")
                            .foregroundColor(region.secondaryColor)
                        Text("\(region.pokemonCount) Pokémon")
                            .font(ThemeManager.Typography.bodySmall)
                            .foregroundColor(ThemeManager.Colors.lumina.opacity(0.9))
                        Spacer()
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
        .frame(width: isSelected ? 220 : 140)
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


#Preview {
    ZStack {
        Color.black
        VStack(spacing: 20) {
            RegionBubbleCard(
                region: RegionNode.createNetworkLayout()[0],
                isSelected: false
            )
            
            RegionBubbleCard(
                region: RegionNode.createNetworkLayout()[1],
                isSelected: true
            )
        }
    }
    .preferredColorScheme(.dark)
}
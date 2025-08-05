//
//  TypeShimmer.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import SwiftUI
import Shimmer

struct TypeShimmer: View {
    let type: PokemonType
    let variant: ShimmerVariant
    
    enum ShimmerVariant {
        case badge
        case chip
        case card
        case banner
        case icon
    }
    
    var body: some View {
        Group {
            switch variant {
            case .badge:
                typeBadgeShimmer
            case .chip:
                typeChipShimmer
            case .card:
                typeCardShimmer
            case .banner:
                typeBannerShimmer
            case .icon:
                typeIconShimmer
            }
        }
    }
    
    private var typeBadgeShimmer: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(type.shimmerBaseColor)
            .frame(width: 60, height: 24)
            .shimmering(
                animation: .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                gradient: type.shimmerGradient
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(type.color.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var typeChipShimmer: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(type.shimmerBaseColor)
                .frame(width: 16, height: 16)
                .shimmering(
                    animation: .easeInOut(duration: 1.2).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            RoundedRectangle(cornerRadius: 4)
                .fill(type.shimmerBaseColor)
                .frame(width: 50, height: 12)
                .shimmering(
                    animation: .easeInOut(duration: 1.2).delay(0.2).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(type.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var typeCardShimmer: some View {
        VStack(spacing: 12) {
            // Type icon placeholder
            Circle()
                .fill(type.shimmerBaseColor)
                .frame(width: 60, height: 60)
                .shimmering(
                    animation: .easeInOut(duration: 1.8).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            // Type name placeholder
            RoundedRectangle(cornerRadius: 6)
                .fill(type.shimmerBaseColor)
                .frame(width: 80, height: 20)
                .shimmering(
                    animation: .easeInOut(duration: 1.8).delay(0.3).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            // Description placeholder
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(type.shimmerBaseColor)
                        .frame(width: CGFloat.random(in: 60...100), height: 10)
                        .shimmering(
                            animation: .easeInOut(duration: 1.8).delay(0.5 + Double(index) * 0.1).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                }
            }
        }
        .padding()
        .frame(width: 140, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(type.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(type.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var typeBannerShimmer: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(type.shimmerBaseColor)
                .frame(width: 40, height: 40)
                .shimmering(
                    animation: .easeInOut(duration: 2.0).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            VStack(alignment: .leading, spacing: 8) {
                // Title
                RoundedRectangle(cornerRadius: 6)
                    .fill(type.shimmerBaseColor)
                    .frame(width: 120, height: 18)
                    .shimmering(
                        animation: .easeInOut(duration: 2.0).delay(0.2).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
                
                // Subtitle
                RoundedRectangle(cornerRadius: 4)
                    .fill(type.shimmerBaseColor)
                    .frame(width: 80, height: 14)
                    .shimmering(
                        animation: .easeInOut(duration: 2.0).delay(0.4).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
            }
            
            Spacer()
            
            // Action button
            RoundedRectangle(cornerRadius: 8)
                .fill(type.shimmerBaseColor)
                .frame(width: 60, height: 32)
                .shimmering(
                    animation: .easeInOut(duration: 2.0).delay(0.6).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(type.color.opacity(0.05))
        )
    }
    
    private var typeIconShimmer: some View {
        Circle()
            .fill(type.shimmerBaseColor)
            .frame(width: 32, height: 32)
            .shimmering(
                animation: .easeInOut(duration: 1.0).repeatForever(autoreverses: false),
                gradient: type.shimmerGradient
            )
            .overlay(
                Circle()
                    .stroke(type.color.opacity(0.3), lineWidth: 2)
            )
    }
}

// MARK: - Type Grid Shimmer
struct TypeGridShimmer: View {
    @State private var animationOffsets: [CGFloat] = Array(repeating: 0, count: 18)
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(Array(PokemonType.allCases.enumerated()), id: \.offset) { index, type in
                TypeShimmer(type: type, variant: .card)
                    .offset(y: animationOffsets[index])
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.0)
                            .delay(Double(index) * 0.1)
                            .repeatForever(autoreverses: true)
                        ) {
                            animationOffsets[index] = CGFloat.random(in: -5...5)
                        }
                    }
            }
        }
        .padding()
    }
}

// MARK: - Type Effectiveness Shimmer
struct TypeEffectivenessShimmer: View {
    let type: PokemonType
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                TypeShimmer(type: type, variant: .icon)
                
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(type.shimmerBaseColor)
                        .frame(width: 120, height: 20)
                        .shimmering(
                            animation: .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(type.shimmerBaseColor)
                        .frame(width: 80, height: 12)
                        .shimmering(
                            animation: .easeInOut(duration: 1.5).delay(0.2).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                }
                
                Spacer()
            }
            
            // Effectiveness sections
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { sectionIndex in
                    VStack(alignment: .leading, spacing: 8) {
                        // Section title
                        RoundedRectangle(cornerRadius: 4)
                            .fill(type.shimmerBaseColor)
                            .frame(width: 100, height: 14)
                            .shimmering(
                                animation: .easeInOut(duration: 1.5).delay(Double(sectionIndex) * 0.3).repeatForever(autoreverses: false),
                                gradient: type.shimmerGradient
                            )
                        
                        // Type badges
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(0..<6, id: \.self) { badgeIndex in
                                    TypeShimmer(type: getRandomType(for: badgeIndex), variant: .badge)
                                        .opacity(0.7)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(type.color.opacity(0.05))
        )
    }
    
    private func getRandomType(for index: Int) -> PokemonType {
        let types: [PokemonType] = [.fire, .water, .grass, .electric, .psychic, .dragon]
        return types[index % types.count]
    }
}

// MARK: - Type Filter Shimmer
struct TypeFilterShimmer: View {
    @State private var selectedTypes: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Filter header
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 18)
                    .shimmering(
                        animation: .easeInOut(duration: 1.8).repeatForever(autoreverses: false),
                        gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1), .gray.opacity(0.3)])
                    )
                
                Spacer()
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .shimmering(
                        animation: .easeInOut(duration: 1.8).delay(0.3).repeatForever(autoreverses: false),
                        gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1), .gray.opacity(0.3)])
                    )
            }
            
            // Type filter chips
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(Array(PokemonType.allCases.enumerated()), id: \.offset) { index, type in
                    Button(action: {
                        if selectedTypes.contains(index) {
                            selectedTypes.remove(index)
                        } else {
                            selectedTypes.insert(index)
                        }
                    }) {
                        TypeShimmer(type: type, variant: .chip)
                            .opacity(selectedTypes.contains(index) ? 1.0 : 0.6)
                            .scaleEffect(selectedTypes.contains(index) ? 1.05 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .animation(.spring(response: 0.3), value: selectedTypes.contains(index))
                }
            }
        }
        .padding()
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            TypeShimmer(type: .electric, variant: .badge)
            TypeShimmer(type: .fire, variant: .chip)
            TypeShimmer(type: .water, variant: .card)
            TypeEffectivenessShimmer(type: .grass)
        }
        .padding()
    }
}
//
//  PokemonCardShimmer.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import SwiftUI
import Shimmer

struct PokemonCardShimmer: View {
    let type: PokemonType
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Image placeholder
            Circle()
                .fill(type.shimmerBaseColor)
                .frame(width: 80, height: 80)
                .shimmering(
                    animation: .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            // Name placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(type.shimmerBaseColor)
                .frame(width: 120, height: 16)
                .shimmering(
                    animation: .easeInOut(duration: 1.5).delay(0.2).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            // Type badges placeholder
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(type.shimmerBaseColor)
                        .frame(width: 60, height: 24)
                        .shimmering(
                            animation: .easeInOut(duration: 1.5).delay(0.4).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                }
            }
            
            // Stats placeholder
            VStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(type.shimmerBaseColor)
                            .frame(width: 40, height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(type.shimmerBaseColor)
                            .frame(width: CGFloat.random(in: 60...100), height: 8)
                        
                        Spacer()
                    }
                    .shimmering(
                        animation: .easeInOut(duration: 1.5).delay(Double(index) * 0.1 + 0.6).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(type.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(type.color.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Grid Card Shimmer
struct PokemonGridCardShimmer: View {
    let type: PokemonType
    
    var body: some View {
        VStack(spacing: 8) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(type.shimmerBaseColor)
                .aspectRatio(1, contentMode: .fit)
                .shimmering(
                    animation: .easeInOut(duration: 1.2).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            // Name placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(type.shimmerBaseColor)
                .frame(height: 14)
                .shimmering(
                    animation: .easeInOut(duration: 1.2).delay(0.3).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            // ID placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(type.shimmerBaseColor)
                .frame(width: 40, height: 10)
                .shimmering(
                    animation: .easeInOut(duration: 1.2).delay(0.5).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(type.color.opacity(0.05))
        )
    }
}

// MARK: - List Card Shimmer
struct PokemonListCardShimmer: View {
    let type: PokemonType
    
    var body: some View {
        HStack(spacing: 16) {
            // Image placeholder
            Circle()
                .fill(type.shimmerBaseColor)
                .frame(width: 60, height: 60)
                .shimmering(
                    animation: .easeInOut(duration: 1.0).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            
            VStack(alignment: .leading, spacing: 8) {
                // Name placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(type.shimmerBaseColor)
                    .frame(width: 140, height: 18)
                    .shimmering(
                        animation: .easeInOut(duration: 1.0).delay(0.2).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
                
                // Type badges
                HStack(spacing: 6) {
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(type.shimmerBaseColor)
                            .frame(width: 50, height: 16)
                    }
                    Spacer()
                }
                .shimmering(
                    animation: .easeInOut(duration: 1.0).delay(0.4).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
                
                // Stats preview
                HStack(spacing: 4) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(type.shimmerBaseColor)
                            .frame(width: 8, height: 20)
                    }
                    Spacer()
                }
                .shimmering(
                    animation: .easeInOut(duration: 1.0).delay(0.6).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
            }
            
            Spacer()
            
            // Favorite icon placeholder
            Circle()
                .fill(type.shimmerBaseColor)
                .frame(width: 24, height: 24)
                .shimmering(
                    animation: .easeInOut(duration: 1.0).delay(0.8).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(type.color.opacity(0.05))
        )
    }
}

// MARK: - Detail View Shimmer
struct PokemonDetailShimmer: View {
    let type: PokemonType
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero section
                VStack(spacing: 16) {
                    Circle()
                        .fill(type.shimmerBaseColor)
                        .frame(width: 200, height: 200)
                        .shimmering(
                            animation: .easeInOut(duration: 2.0).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(type.shimmerBaseColor)
                        .frame(width: 180, height: 32)
                        .shimmering(
                            animation: .easeInOut(duration: 2.0).delay(0.3).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                }
                
                // Stats section
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(type.shimmerBaseColor)
                        .frame(width: 100, height: 20)
                        .shimmering(
                            animation: .easeInOut(duration: 2.0).delay(0.5).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                    
                    ForEach(0..<6, id: \.self) { index in
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(type.shimmerBaseColor)
                                .frame(width: 80, height: 16)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(type.shimmerBaseColor)
                                .frame(height: 16)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(type.shimmerBaseColor)
                                .frame(width: 40, height: 16)
                        }
                        .shimmering(
                            animation: .easeInOut(duration: 2.0).delay(0.7 + Double(index) * 0.1).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Additional sections
                ForEach(0..<3, id: \.self) { sectionIndex in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(type.shimmerBaseColor)
                            .frame(width: 120, height: 18)
                        
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(type.shimmerBaseColor)
                                .frame(height: 12)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shimmering(
                        animation: .easeInOut(duration: 2.0).delay(1.3 + Double(sectionIndex) * 0.2).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PokemonCardShimmer(type: .electric)
        PokemonGridCardShimmer(type: .fire)
        PokemonListCardShimmer(type: .water)
    }
    .padding()
}
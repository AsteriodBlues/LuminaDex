//
//  CollectionShimmer.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import SwiftUI
import Shimmer

struct CollectionShimmer: View {
    let layout: CollectionLayout
    let type: PokemonType
    @State private var itemCount: Int = 12
    
    enum CollectionLayout {
        case grid
        case list
        case masonry
    }
    
    var body: some View {
        Group {
            switch layout {
            case .grid:
                gridLayout
            case .list:
                listLayout
            case .masonry:
                masonryLayout
            }
        }
    }
    
    private var gridLayout: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(0..<itemCount, id: \.self) { index in
                PokemonGridCardShimmer(type: getShimmerType(for: index))
                    .onAppear {
                        if index == itemCount - 1 {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                itemCount += 6
                            }
                        }
                    }
            }
        }
        .padding()
    }
    
    private var listLayout: some View {
        LazyVStack(spacing: 12) {
            ForEach(0..<itemCount, id: \.self) { index in
                PokemonListCardShimmer(type: getShimmerType(for: index))
                    .onAppear {
                        if index == itemCount - 1 {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                itemCount += 6
                            }
                        }
                    }
            }
        }
        .padding()
    }
    
    private var masonryLayout: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(0..<itemCount, id: \.self) { index in
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(getShimmerType(for: index).shimmerBaseColor)
                        .aspectRatio(CGFloat.random(in: 0.7...1.3), contentMode: .fit)
                        .shimmering(
                            animation: .easeInOut(duration: 1.5).delay(Double(index) * 0.1).repeatForever(autoreverses: false),
                            gradient: getShimmerType(for: index).shimmerGradient
                        )
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(getShimmerType(for: index).shimmerBaseColor)
                        .frame(height: 14)
                        .shimmering(
                            animation: .easeInOut(duration: 1.5).delay(Double(index) * 0.1 + 0.3).repeatForever(autoreverses: false),
                            gradient: getShimmerType(for: index).shimmerGradient
                        )
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(getShimmerType(for: index).color.opacity(0.05))
                )
                .onAppear {
                    if index == itemCount - 1 {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            itemCount += 6
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func getShimmerType(for index: Int) -> PokemonType {
        let types: [PokemonType] = [.fire, .water, .electric, .grass, .psychic, .dragon, .fairy, .dark]
        return types[index % types.count]
    }
}

// MARK: - Search Collection Shimmer
struct SearchCollectionShimmer: View {
    let type: PokemonType
    @State private var searchBarWidth: CGFloat = 200
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Search bar shimmer
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(type.shimmerBaseColor)
                    .frame(width: searchBarWidth, height: 40)
                    .shimmering(
                        animation: .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            searchBarWidth = CGFloat.random(in: 150...250)
                        }
                    }
                
                Spacer()
                
                Circle()
                    .fill(type.shimmerBaseColor)
                    .frame(width: 40, height: 40)
                    .shimmering(
                        animation: .easeInOut(duration: 1.5).delay(0.3).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
            }
            .padding(.horizontal)
            
            // Filter chips shimmer
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<8, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(type.shimmerBaseColor)
                            .frame(width: CGFloat.random(in: 60...100), height: 32)
                            .shimmering(
                                animation: .easeInOut(duration: 1.5).delay(Double(index) * 0.1).repeatForever(autoreverses: false),
                                gradient: type.shimmerGradient
                            )
                    }
                }
                .padding(.horizontal)
            }
            
            // Results count shimmer
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(type.shimmerBaseColor)
                    .frame(width: 120, height: 16)
                    .shimmering(
                        animation: .easeInOut(duration: 1.5).delay(0.8).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(type.shimmerBaseColor)
                    .frame(width: 80, height: 16)
                    .shimmering(
                        animation: .easeInOut(duration: 1.5).delay(1.0).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
            }
            .padding(.horizontal)
            
            // Collection shimmer
            CollectionShimmer(layout: .grid, type: type)
        }
    }
}

// MARK: - Favorite Collection Shimmer
struct FavoriteCollectionShimmer: View {
    let type: PokemonType
    @State private var favoriteCount = 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(type.shimmerBaseColor)
                        .frame(width: 120, height: 24)
                        .shimmering(
                            animation: .easeInOut(duration: 1.8).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(type.shimmerBaseColor)
                        .frame(width: 80, height: 14)
                        .shimmering(
                            animation: .easeInOut(duration: 1.8).delay(0.2).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                }
                
                Spacer()
                
                Circle()
                    .fill(type.shimmerBaseColor)
                    .frame(width: 32, height: 32)
                    .shimmering(
                        animation: .easeInOut(duration: 1.8).delay(0.4).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
            }
            .padding(.horizontal)
            
            // Favorite cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<favoriteCount, id: \.self) { index in
                        VStack(spacing: 8) {
                            Circle()
                                .fill(getShimmerType(for: index).shimmerBaseColor)
                                .frame(width: 80, height: 80)
                                .shimmering(
                                    animation: .easeInOut(duration: 1.5).delay(Double(index) * 0.1).repeatForever(autoreverses: false),
                                    gradient: getShimmerType(for: index).shimmerGradient
                                )
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(getShimmerType(for: index).shimmerBaseColor)
                                .frame(width: 70, height: 12)
                                .shimmering(
                                    animation: .easeInOut(duration: 1.5).delay(Double(index) * 0.1 + 0.3).repeatForever(autoreverses: false),
                                    gradient: getShimmerType(for: index).shimmerGradient
                                )
                        }
                        .frame(width: 100)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getShimmerType(for index: Int) -> PokemonType {
        let types: [PokemonType] = [.fire, .water, .electric, .grass, .psychic, .dragon]
        return types[index % types.count]
    }
}

// MARK: - Empty State Shimmer
struct EmptyCollectionShimmer: View {
    let type: PokemonType
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(type.shimmerBaseColor)
                .frame(width: 120, height: 120)
                .scaleEffect(pulseScale)
                .shimmering(
                    animation: .easeInOut(duration: 2.0).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        pulseScale = 1.1
                    }
                }
            
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(type.shimmerBaseColor)
                    .frame(width: 200, height: 20)
                    .shimmering(
                        animation: .easeInOut(duration: 2.0).delay(0.5).repeatForever(autoreverses: false),
                        gradient: type.shimmerGradient
                    )
                
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(type.shimmerBaseColor)
                        .frame(width: CGFloat.random(in: 150...250), height: 14)
                        .shimmering(
                            animation: .easeInOut(duration: 2.0).delay(0.7 + Double(index) * 0.2).repeatForever(autoreverses: false),
                            gradient: type.shimmerGradient
                        )
                }
            }
            
            RoundedRectangle(cornerRadius: 20)
                .fill(type.shimmerBaseColor)
                .frame(width: 160, height: 40)
                .shimmering(
                    animation: .easeInOut(duration: 2.0).delay(1.5).repeatForever(autoreverses: false),
                    gradient: type.shimmerGradient
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchCollectionShimmer(type: .electric)
        FavoriteCollectionShimmer(type: .fire)
    }
}
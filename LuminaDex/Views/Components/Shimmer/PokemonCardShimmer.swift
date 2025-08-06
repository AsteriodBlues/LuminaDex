//
//  PokemonCardShimmer.swift
//  LuminaDex
//
//  Day 24: Skeleton loading state for Pokemon cards
//

import SwiftUI

struct PokemonCardShimmer: View {
    let type: PokemonType?
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header placeholder
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .shimmer()
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 16)
                    .shimmer()
            }
            
            // Pokemon sprite placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .overlay(
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .shimmer()
                )
            
            // Name placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 18)
                .shimmer()
            
            // Type badges placeholder
            HStack(spacing: 4) {
                ForEach(0..<2, id: \.self) { _ in
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 20)
                        .shimmer()
                }
            }
            
            // Progress bar placeholder
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 10)
                        .shimmer()
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 30, height: 10)
                        .shimmer()
                }
                
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.size.width * 0.6)
                                .shimmer(),
                            alignment: .leading
                        )
                }
                .frame(height: 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .if(type != nil) { view in
            view.typeShimmer(type!, active: true)
        }
    }
}

// MARK: - Grid Card Shimmer
struct PokemonGridCardShimmer: View {
    var body: some View {
        VStack(spacing: 8) {
            // Sprite placeholder
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .shimmer()
            
            // Name placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 14)
                .padding(.horizontal, 8)
                .shimmer()
            
            // Number placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 12)
                .shimmer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Helper Extension
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
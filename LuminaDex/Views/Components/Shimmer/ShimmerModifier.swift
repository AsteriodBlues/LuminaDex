//
//  ShimmerModifier.swift
//  LuminaDex
//
//  Day 24: Reusable shimmer modifier for loading states
//

import SwiftUI

// MARK: - Shimmer View Modifier
struct ShimmerModifier: ViewModifier {
    let active: Bool
    let gradient: Gradient
    let duration: Double
    
    @State private var phase: CGFloat = 0
    
    init(active: Bool = true,
         gradient: Gradient? = nil,
         duration: Double = 1.5) {
        self.active = active
        self.gradient = gradient ?? Gradient(colors: [
            Color.white.opacity(0.1),
            Color.white.opacity(0.3),
            Color.white.opacity(0.1)
        ])
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        if active {
            content
                .overlay(
                    LinearGradient(
                        gradient: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.clear,
                                        Color.white,
                                        Color.clear
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: phase * 400 - 200)
                    )
                    .allowsHitTesting(false)
                )
                .onAppear {
                    withAnimation(
                        .linear(duration: duration)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Type-Specific Shimmer
struct TypeShimmerModifier: ViewModifier {
    let type: PokemonType
    let active: Bool
    
    func body(content: Content) -> some View {
        content
            .modifier(
                ShimmerModifier(
                    active: active,
                    gradient: type.shimmerGradient,
                    duration: 1.5
                )
            )
    }
}

// MARK: - Extensions
extension View {
    func shimmer(_ active: Bool = true, duration: Double = 1.5) -> some View {
        modifier(ShimmerModifier(active: active, duration: duration))
    }
    
    func typeShimmer(_ type: PokemonType, active: Bool = true) -> some View {
        modifier(TypeShimmerModifier(type: type, active: active))
    }
}
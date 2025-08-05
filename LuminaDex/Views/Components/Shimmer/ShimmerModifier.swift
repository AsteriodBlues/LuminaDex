//
//  ShimmerModifier.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import SwiftUI
import Shimmer

// MARK: - Custom Shimmer Modifier
struct PokemonShimmerModifier: ViewModifier {
    let type: PokemonType
    let duration: Double
    let delay: Double
    let intensity: Double
    
    init(type: PokemonType = .normal, duration: Double = 1.5, delay: Double = 0.0, intensity: Double = 1.0) {
        self.type = type
        self.duration = duration
        self.delay = delay
        self.intensity = intensity
    }
    
    func body(content: Content) -> some View {
        content
            .shimmering(
                animation: .easeInOut(duration: duration).delay(delay).repeatForever(autoreverses: false),
                gradient: type.shimmerGradient,
                bandSize: 0.3 * intensity
            )
    }
}

// MARK: - Pulsing Shimmer Modifier
struct PulsingShimmerModifier: ViewModifier {
    let type: PokemonType
    let pulseScale: CGFloat
    @State private var isAnimating = false
    
    init(type: PokemonType = .normal, pulseScale: CGFloat = 1.1) {
        self.type = type
        self.pulseScale = pulseScale
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? pulseScale : 1.0)
            .shimmering(
                animation: .easeInOut(duration: 2.0).repeatForever(autoreverses: false),
                gradient: type.shimmerGradient
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Wave Shimmer Modifier
struct WaveShimmerModifier: ViewModifier {
    let type: PokemonType
    let waveCount: Int
    @State private var waveOffset: CGFloat = 0
    
    init(type: PokemonType = .normal, waveCount: Int = 3) {
        self.type = type
        self.waveCount = waveCount
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                waveOverlay
                    .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    waveOffset = 1.0
                }
            }
    }
    
    private var waveOverlay: some View {
        GeometryReader { geometry in
            ForEach(0..<waveCount, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: type.shimmerGradient.stops.map(\.color),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width / CGFloat(waveCount))
                    .offset(x: (geometry.size.width + geometry.size.width / CGFloat(waveCount)) * waveOffset - geometry.size.width + CGFloat(index) * (geometry.size.width / CGFloat(waveCount)))
                    .opacity(0.6)
            }
        }
    }
}

// MARK: - Breathing Shimmer Modifier
struct BreathingShimmerModifier: ViewModifier {
    let type: PokemonType
    @State private var opacity: Double = 0.3
    @State private var scale: CGFloat = 0.95
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .shimmering(
                animation: .easeInOut(duration: 3.0).repeatForever(autoreverses: false),
                gradient: type.shimmerGradient
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    opacity = 1.0
                    scale = 1.05
                }
            }
    }
}

// MARK: - Rotating Shimmer Modifier
struct RotatingShimmerModifier: ViewModifier {
    let type: PokemonType
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .shimmering(
                animation: .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                gradient: type.shimmerGradient
            )
            .onAppear {
                withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Glowing Shimmer Modifier
struct GlowingShimmerModifier: ViewModifier {
    let type: PokemonType
    let glowRadius: CGFloat
    @State private var glowOpacity: Double = 0.3
    
    init(type: PokemonType = .normal, glowRadius: CGFloat = 10) {
        self.type = type
        self.glowRadius = glowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(color: type.color.opacity(glowOpacity), radius: glowRadius)
            .shimmering(
                animation: .easeInOut(duration: 2.5).repeatForever(autoreverses: false),
                gradient: type.shimmerGradient
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    glowOpacity = 0.8
                }
            }
    }
}

// MARK: - View Extensions
extension View {
    func pokemonShimmer(
        type: PokemonType = .normal,
        duration: Double = 1.5,
        delay: Double = 0.0,
        intensity: Double = 1.0
    ) -> some View {
        modifier(PokemonShimmerModifier(type: type, duration: duration, delay: delay, intensity: intensity))
    }
    
    func pulsingShimmer(
        type: PokemonType = .normal,
        pulseScale: CGFloat = 1.1
    ) -> some View {
        modifier(PulsingShimmerModifier(type: type, pulseScale: pulseScale))
    }
    
    func waveShimmer(
        type: PokemonType = .normal,
        waveCount: Int = 3
    ) -> some View {
        modifier(WaveShimmerModifier(type: type, waveCount: waveCount))
    }
    
    func breathingShimmer(type: PokemonType = .normal) -> some View {
        modifier(BreathingShimmerModifier(type: type))
    }
    
    func rotatingShimmer(type: PokemonType = .normal) -> some View {
        modifier(RotatingShimmerModifier(type: type))
    }
    
    func glowingShimmer(
        type: PokemonType = .normal,
        glowRadius: CGFloat = 10
    ) -> some View {
        modifier(GlowingShimmerModifier(type: type, glowRadius: glowRadius))
    }
}

// MARK: - Shimmer Preset Styles
struct ShimmerPresets {
    static func pokemonCard(type: PokemonType) -> some ViewModifier {
        PokemonShimmerModifier(type: type, duration: 1.5, delay: 0.0, intensity: 1.0)
    }
    
    static func pokemonList(type: PokemonType, index: Int) -> some ViewModifier {
        PokemonShimmerModifier(type: type, duration: 1.2, delay: Double(index) * 0.1, intensity: 0.8)
    }
    
    static func pokemonDetail(type: PokemonType) -> some ViewModifier {
        PulsingShimmerModifier(type: type, pulseScale: 1.05)
    }
    
    static func pokemonGrid(type: PokemonType, index: Int) -> some ViewModifier {
        WaveShimmerModifier(type: type, waveCount: 2)
    }
}

// MARK: - Demo View
struct ShimmerDemo: View {
    let demoTypes: [PokemonType] = [.electric, .fire, .water, .grass, .psychic, .dragon]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Shimmer Effects Demo")
                    .font(.title)
                    .fontWeight(.bold)
                
                ForEach(Array(demoTypes.enumerated()), id: \.offset) { index, type in
                    VStack(spacing: 12) {
                        Text("\(type.displayName) Type Effects")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            // Standard shimmer
                            RoundedRectangle(cornerRadius: 12)
                                .fill(type.color.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .pokemonShimmer(type: type)
                            
                            // Pulsing shimmer
                            Circle()
                                .fill(type.color.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .pulsingShimmer(type: type)
                            
                            // Glowing shimmer
                            RoundedRectangle(cornerRadius: 12)
                                .fill(type.color.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .glowingShimmer(type: type, glowRadius: 8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ShimmerDemo()
}
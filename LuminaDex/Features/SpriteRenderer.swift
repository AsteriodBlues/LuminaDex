//
//  SpriteRenderer.swift
//  LuminaDex
//

import SwiftUI

/// Renders individual sprites with optimized drawing and animations
struct SpriteRenderer: View {
    let sprite: MapSprite
    let screenScale: CGFloat
    
    @State private var shimmerPhase: CGFloat = 0
    @State private var pulsePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Sprite glow based on type
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            sprite.type.color.opacity(0.4),
                            sprite.type.color.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .frame(width: 30, height: 30)
                .scaleEffect(1.0 + pulsePhase * 0.3)
                .opacity(sprite.opacity * 0.7)
            
            // Main sprite representation with actual Pokemon image
            ImageManager.shared.loadThumbnail(url: sprite.spriteURL)
            .frame(width: 24, height: 24)
            .scaleEffect(sprite.scale)
            .opacity(sprite.opacity)
            .rotationEffect(sprite.rotation)
            
            // Movement trail particles
            if sprite.velocity != .zero {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(sprite.type.color.opacity(0.3))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: -sprite.velocity.x * CGFloat(index + 1) * 0.1,
                            y: -sprite.velocity.y * CGFloat(index + 1) * 0.1
                        )
                        .opacity(sprite.opacity * (1.0 - CGFloat(index) * 0.3))
                        .scaleEffect(sprite.scale * (1.0 - CGFloat(index) * 0.2))
                }
            }
            
            // Special effects for different movement patterns
            if sprite.movementPattern == .flowing {
                // Energy connection indicator
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                sprite.type.color.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 20, height: 1)
                    .offset(x: sin(shimmerPhase) * 10)
                    .rotationEffect(sprite.rotation)
                    .opacity(sprite.opacity * 0.8)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Staggered animation start to avoid synchronization
        let delay = Double.random(in: 0...1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // Shimmer effect for flowing sprites
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                shimmerPhase = 2 * .pi
            }
            
            // Gentle pulsing for all sprites
            withAnimation(.easeInOut(duration: 1.5 + Double.random(in: -0.3...0.3)).repeatForever(autoreverses: true)) {
                pulsePhase = 1.0
            }
        }
    }
}

/// Container view for rendering all sprites with performance optimizations
struct SpriteLayer: View {
    let sprites: [MapSprite]
    let cameraOffset: CGSize
    let zoomScale: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(sprites, id: \.id) { sprite in
                SpriteRenderer(sprite: sprite, screenScale: zoomScale)
                    .position(
                        x: sprite.position.x + cameraOffset.width,
                        y: sprite.position.y + cameraOffset.height
                    )
                    .scaleEffect(zoomScale)
            }
        }
    }
    
}

#Preview {
    ZStack {
        Color.black
        SpriteLayer(
            sprites: [
                MapSprite(
                    pokemonId: 25,
                    spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
                    type: .electric,
                    position: CGPoint(x: 100, y: 100),
                    movementPattern: .orbiting,
                    regionAffinity: "Kanto"
                ),
                MapSprite(
                    pokemonId: 144,
                    spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/144.png",
                    type: .ice,
                    position: CGPoint(x: 200, y: 150),
                    movementPattern: .flowing,
                    regionAffinity: "Kanto"
                )
            ],
            cameraOffset: .zero,
            zoomScale: 1.0
        )
    }
    .preferredColorScheme(.dark)
}
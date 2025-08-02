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
            
            // Main sprite representation
            // TODO: Replace with actual Pokemon sprite image when API is integrated
            Circle()
                .fill(sprite.type.color)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 8, height: 8)
                )
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
        Canvas { context, size in
            // Apply camera transformation
            context.translateBy(x: cameraOffset.width, y: cameraOffset.height)
            context.scaleBy(x: zoomScale, y: zoomScale)
            
            // Batch render sprites for better performance
            for sprite in sprites {
                drawSprite(context: context, sprite: sprite)
            }
        }
    }
    
    private func drawSprite(context: GraphicsContext, sprite: MapSprite) {
        // Performance optimizations: early exit conditions
        let effectiveScale = sprite.scale * zoomScale
        
        // Skip drawing if sprite is too small to see or inactive
        if effectiveScale < 0.1 || !sprite.isActive || sprite.opacity < 0.01 { return }
        
        // Sprite glow
        let glowSize: CGFloat = 30 * effectiveScale
        let glowRect = CGRect(
            x: sprite.position.x - glowSize/2,
            y: sprite.position.y - glowSize/2,
            width: glowSize,
            height: glowSize
        )
        
        context.fill(
            Path(ellipseIn: glowRect),
            with: .radialGradient(
                Gradient(colors: [
                    sprite.type.color.opacity(0.4 * sprite.opacity),
                    sprite.type.color.opacity(0.1 * sprite.opacity),
                    Color.clear
                ]),
                center: sprite.position,
                startRadius: 0,
                endRadius: glowSize/2
            )
        )
        
        // Main sprite circle
        let spriteSize: CGFloat = 12 * sprite.scale * zoomScale
        let spriteRect = CGRect(
            x: sprite.position.x - spriteSize/2,
            y: sprite.position.y - spriteSize/2,
            width: spriteSize,
            height: spriteSize
        )
        
        context.fill(
            Path(ellipseIn: spriteRect),
            with: .color(sprite.type.color.opacity(sprite.opacity))
        )
        
        // Inner highlight
        let highlightSize = spriteSize * 0.6
        let highlightRect = CGRect(
            x: sprite.position.x - highlightSize/2,
            y: sprite.position.y - highlightSize/2,
            width: highlightSize,
            height: highlightSize
        )
        
        context.fill(
            Path(ellipseIn: highlightRect),
            with: .color(Color.white.opacity(0.6 * sprite.opacity))
        )
        
        // Movement trail for fast-moving sprites
        let speed = sqrt(sprite.velocity.x * sprite.velocity.x + sprite.velocity.y * sprite.velocity.y)
        if speed > 10.0 && zoomScale > 0.5 {
            drawMovementTrail(context: context, sprite: sprite, speed: speed)
        }
    }
    
    private func drawMovementTrail(context: GraphicsContext, sprite: MapSprite, speed: CGFloat) {
        let trailLength = min(speed * 0.5, 20.0)
        let trailCount = min(Int(speed / 5), 5)
        
        for i in 0..<trailCount {
            let progress = CGFloat(i) / CGFloat(trailCount)
            let trailPosition = CGPoint(
                x: sprite.position.x - sprite.velocity.x * progress * 0.1,
                y: sprite.position.y - sprite.velocity.y * progress * 0.1
            )
            
            let trailSize = (4.0 - progress * 2.0) * sprite.scale * zoomScale
            let trailRect = CGRect(
                x: trailPosition.x - trailSize/2,
                y: trailPosition.y - trailSize/2,
                width: trailSize,
                height: trailSize
            )
            
            context.fill(
                Path(ellipseIn: trailRect),
                with: .color(sprite.type.color.opacity((1.0 - progress) * sprite.opacity * 0.6))
            )
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
                    spriteURL: "placeholder",
                    type: .electric,
                    position: CGPoint(x: 100, y: 100),
                    movementPattern: .orbiting,
                    regionAffinity: "Kanto"
                ),
                MapSprite(
                    pokemonId: 144,
                    spriteURL: "placeholder",
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
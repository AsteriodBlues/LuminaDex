//
//  StarFieldView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

struct StarFieldView: View {
    let offset: CGSize
    let zoom: CGFloat
    
    @State private var stars: [Star] = []
    @State private var animationPhase: CGFloat = 0
    
    private let starCount = 200
    
    var body: some View {
        Canvas { context, size in
            // Draw background layers with parallax
            drawStarLayers(context: context, size: size)
            
            // Draw nebula clouds
            drawNebulaClouds(context: context, size: size)
            
            // Draw twinkling stars
            drawTwinklingStars(context: context, size: size)
        }
        .onAppear {
            generateStars()
            startAnimation()
        }
    }
    
    private func generateStars() {
        stars = (0..<starCount).map { _ in
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: -500...UIScreen.main.bounds.width + 500),
                    y: CGFloat.random(in: -500...UIScreen.main.bounds.height + 500)
                ),
                size: CGFloat.random(in: 0.5...3.0),
                brightness: CGFloat.random(in: 0.3...1.0),
                twinkleSpeed: CGFloat.random(in: 0.5...2.0),
                color: Star.randomStarColor(),
                layer: Int.random(in: 0...2)
            )
        }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
    }
    
    private func drawStarLayers(context: GraphicsContext, size: CGSize) {
        for star in stars {
            let layerParallax = 1.0 - CGFloat(star.layer) * 0.3
            let adjustedOffset = CGSize(
                width: offset.width * layerParallax,
                height: offset.height * layerParallax
            )
            
            let starPosition = CGPoint(
                x: star.position.x + adjustedOffset.width,
                y: star.position.y + adjustedOffset.height
            )
            
            // Skip stars outside visible area (with margin)
            let margin: CGFloat = 100
            if starPosition.x < -margin || starPosition.x > size.width + margin ||
               starPosition.y < -margin || starPosition.y > size.height + margin {
                continue
            }
            
            let twinkle = sin(animationPhase * star.twinkleSpeed + star.position.x) * 0.3 + 0.7
            let currentBrightness = star.brightness * twinkle
            let currentSize = star.size * zoom * layerParallax
            
            // Draw star glow
            if currentSize > 1.0 {
                let glowRect = CGRect(
                    x: starPosition.x - currentSize * 2,
                    y: starPosition.y - currentSize * 2,
                    width: currentSize * 4,
                    height: currentSize * 4
                )
                
                context.fill(
                    Path(ellipseIn: glowRect),
                    with: .radialGradient(
                        Gradient(colors: [
                            star.color.opacity(currentBrightness * 0.3),
                            star.color.opacity(0)
                        ]),
                        center: starPosition,
                        startRadius: 0,
                        endRadius: currentSize * 2
                    )
                )
            }
            
            // Draw star core
            let starRect = CGRect(
                x: starPosition.x - currentSize/2,
                y: starPosition.y - currentSize/2,
                width: currentSize,
                height: currentSize
            )
            
            context.fill(
                Path(ellipseIn: starRect),
                with: .color(star.color.opacity(currentBrightness))
            )
        }
    }
    
    private func drawNebulaClouds(context: GraphicsContext, size: CGSize) {
        let cloudCount = 3
        
        for i in 0..<cloudCount {
            let cloudOffset = CGFloat(i) * .pi * 2 / CGFloat(cloudCount)
            let cloudX = size.width * 0.5 + cos(animationPhase * 0.1 + cloudOffset) * 300 + offset.width * 0.1
            let cloudY = size.height * 0.5 + sin(animationPhase * 0.1 + cloudOffset) * 200 + offset.height * 0.1
            
            let cloudSize = 200 + sin(animationPhase * 0.2 + cloudOffset) * 50
            let cloudRect = CGRect(
                x: cloudX - cloudSize/2,
                y: cloudY - cloudSize/2,
                width: cloudSize,
                height: cloudSize
            )
            
            let nebulaColors = [
                Color(hex: "6B5FFF").opacity(0.1),
                Color(hex: "00D4FF").opacity(0.08),
                Color(hex: "00FF88").opacity(0.06),
                Color.clear
            ]
            
            context.fill(
                Path(ellipseIn: cloudRect),
                with: .radialGradient(
                    Gradient(colors: nebulaColors),
                    center: CGPoint(x: cloudX, y: cloudY),
                    startRadius: 0,
                    endRadius: cloudSize/2
                )
            )
        }
    }
    
    private func drawTwinklingStars(context: GraphicsContext, size: CGSize) {
        let brightStars = stars.filter { $0.size > 2.0 }
        
        for star in brightStars {
            let starPosition = CGPoint(
                x: star.position.x + offset.width * 0.8,
                y: star.position.y + offset.height * 0.8
            )
            
            let twinkle = sin(animationPhase * star.twinkleSpeed * 2 + star.position.y) * 0.5 + 0.5
            let spikeLength = star.size * zoom * twinkle * 8
            
            if spikeLength > 2 {
                // Draw cross-shaped spikes for bright stars
                let horizontalPath = Path { path in
                    path.move(to: CGPoint(x: starPosition.x - spikeLength, y: starPosition.y))
                    path.addLine(to: CGPoint(x: starPosition.x + spikeLength, y: starPosition.y))
                }
                
                let verticalPath = Path { path in
                    path.move(to: CGPoint(x: starPosition.x, y: starPosition.y - spikeLength))
                    path.addLine(to: CGPoint(x: starPosition.x, y: starPosition.y + spikeLength))
                }
                
                context.stroke(
                    horizontalPath,
                    with: .color(star.color.opacity(twinkle * 0.6)),
                    style: StrokeStyle(lineWidth: 0.5, lineCap: .round)
                )
                
                context.stroke(
                    verticalPath,
                    with: .color(star.color.opacity(twinkle * 0.6)),
                    style: StrokeStyle(lineWidth: 0.5, lineCap: .round)
                )
            }
        }
    }
}

struct Star {
    let position: CGPoint
    let size: CGFloat
    let brightness: CGFloat
    let twinkleSpeed: CGFloat
    let color: Color
    let layer: Int
    
    static func randomStarColor() -> Color {
        let colors = [
            Color.white,
            Color(hex: "FAFBFC"),
            Color(hex: "E8F4FD"),
            Color(hex: "FFF8E1"),
            Color(hex: "F3E5F5"),
            Color(hex: "E1F5FE")
        ]
        return colors.randomElement() ?? Color.white
    }
}

#Preview {
    StarFieldView(offset: .zero, zoom: 1.0)
        .background(Color.black)
}
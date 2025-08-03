//
//  NeuralNetworkBackground.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//

import SwiftUI

struct NeuralNetworkBackground: View {
    @State private var animationOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Deep space gradient
            LinearGradient(
                colors: [
                    .black,
                    .purple.opacity(0.3),
                    .blue.opacity(0.2),
                    .black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Neural network nodes
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { index in
                    NeuralNode(
                        size: CGFloat.random(in: 2...6),
                        position: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        ),
                        animationOffset: animationOffset,
                        index: index
                    )
                }
                
                // Connection lines
                ForEach(0..<15, id: \.self) { index in
                    NeuralConnection(
                        startPoint: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        ),
                        endPoint: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        ),
                        animationOffset: animationOffset
                    )
                }
            }
            
            // Simple floating particles
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 2, height: 2)
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: CGFloat.random(in: 0...800)
                    )
                    .animation(.easeInOut(duration: Double.random(in: 2...4)).repeatForever(autoreverses: true), value: animationOffset)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            animationOffset = 360
        }
        
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
}

// MARK: - Neural Node
struct NeuralNode: View {
    let size: CGFloat
    let position: CGPoint
    let animationOffset: CGFloat
    let index: Int
    
    private var animatedPosition: CGPoint {
        CGPoint(
            x: position.x + sin(animationOffset * .pi / 180 + Double(index)) * 10,
            y: position.y + cos(animationOffset * .pi / 180 + Double(index)) * 10
        )
    }
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.cyan.opacity(0.8), .blue.opacity(0.4), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size
                )
            )
            .frame(width: size, height: size)
            .position(animatedPosition)
            .shadow(color: .cyan.opacity(0.5), radius: size / 2)
    }
}

// MARK: - Neural Connection
struct NeuralConnection: View {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let animationOffset: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        .stroke(
            LinearGradient(
                colors: [
                    .cyan.opacity(0.1),
                    .blue.opacity(0.3),
                    .purple.opacity(0.2),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 0.5, dash: [2, 4])
        )
        .opacity(sin(animationOffset * Double.pi / 180.0) * 0.3 + 0.4)
    }
}

// MARK: - Particle System
struct ParticleSystem: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .blur(radius: particle.blur)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<50).map { index in
            Particle(
                id: index,
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 1...3),
                color: [Color.cyan, Color.blue, Color.purple, Color.pink].randomElement() ?? Color.blue,
                opacity: Double.random(in: 0.2...0.8),
                blur: CGFloat.random(in: 0...2)
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                for index in particles.indices {
                    particles[index].position.x += CGFloat.random(in: -1...1)
                    particles[index].position.y += CGFloat.random(in: -1...1)
                    particles[index].opacity = Double.random(in: 0.2...0.8)
                    
                    // Wrap around screen
                    if particles[index].position.x > UIScreen.main.bounds.width {
                        particles[index].position.x = 0
                    }
                    if particles[index].position.x < 0 {
                        particles[index].position.x = UIScreen.main.bounds.width
                    }
                    if particles[index].position.y > UIScreen.main.bounds.height {
                        particles[index].position.y = 0
                    }
                    if particles[index].position.y < 0 {
                        particles[index].position.y = UIScreen.main.bounds.height
                    }
                }
            }
        }
    }
}

// MARK: - Particle Model
struct Particle: Identifiable {
    let id: Int
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
    let blur: CGFloat
}

// MARK: - Preview
struct NeuralNetworkBackground_Previews: PreviewProvider {
    static var previews: some View {
        NeuralNetworkBackground()
    }
}
//
//  SplashScreenView.swift
//  LuminaDex
//
//  Modern animated splash screen with Pokémon-themed animations
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showLogo = false
    @State private var showPokeball = false
    @State private var pokeballRotation = 0.0
    @State private var particlesVisible = false
    @State private var textGlow = false
    @State private var neuralNodesVisible = false
    @State private var dnaHelixRotation = 0.0
    @Binding var isActive: Bool
    
    // Neural network nodes positions
    let nodePositions: [(x: CGFloat, y: CGFloat)] = [
        (0.2, 0.3), (0.8, 0.2), (0.5, 0.4),
        (0.3, 0.6), (0.7, 0.7), (0.9, 0.5),
        (0.1, 0.8), (0.6, 0.9), (0.4, 0.1)
    ]
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.1, green: 0.05, blue: 0.2), location: 0),
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.15), location: 0.3),
                    .init(color: Color(red: 0.02, green: 0.02, blue: 0.1), location: 0.7),
                    .init(color: Color.black, location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Neural Network Background
            GeometryReader { geometry in
                ForEach(0..<nodePositions.count, id: \.self) { index in
                    SplashNeuralNode(
                        position: CGPoint(
                            x: geometry.size.width * nodePositions[index].x,
                            y: geometry.size.height * nodePositions[index].y
                        ),
                        delay: Double(index) * 0.1,
                        isVisible: neuralNodesVisible
                    )
                }
                
                // Neural connections
                if neuralNodesVisible {
                    ForEach(0..<nodePositions.count - 1, id: \.self) { index in
                        SplashNeuralConnection(
                            start: CGPoint(
                                x: geometry.size.width * nodePositions[index].x,
                                y: geometry.size.height * nodePositions[index].y
                            ),
                            end: CGPoint(
                                x: geometry.size.width * nodePositions[index + 1].x,
                                y: geometry.size.height * nodePositions[index + 1].y
                            ),
                            delay: Double(index) * 0.15
                        )
                    }
                }
            }
            .opacity(0.3)
            
            // Particle Effects
            if particlesVisible {
                ParticleEmitterView()
                    .opacity(0.6)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Animated Pokéball Logo
                ZStack {
                    // DNA Helix Background
                    DNAHelixIcon()
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(dnaHelixRotation))
                        .opacity(showPokeball ? 0.3 : 0)
                        .blur(radius: 2)
                    
                    // Main Pokéball
                    if showPokeball {
                        PokeballLogo()
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(pokeballRotation))
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .shadow(
                                color: Color.red.opacity(textGlow ? 0.8 : 0.3),
                                radius: textGlow ? 30 : 10
                            )
                    }
                }
                
                // App Name with Glow Effect
                if showLogo {
                    VStack(spacing: 8) {
                        Text("LuminaDex")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1, green: 0.8, blue: 0.2),
                                        Color(red: 1, green: 0.5, blue: 0.2),
                                        Color(red: 1, green: 0.3, blue: 0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .yellow.opacity(textGlow ? 1 : 0.5), radius: textGlow ? 20 : 5)
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                        
                        Text("The Future of Pokémon Discovery")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(isAnimating ? 1 : 0)
                    }
                }
                
                Spacer()
                
                // Loading Indicator
                if isAnimating {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 12, height: 12)
                                .scaleEffect(isAnimating ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Show neural nodes first
        withAnimation(.easeOut(duration: 0.8)) {
            neuralNodesVisible = true
        }
        
        // Show Pokéball with rotation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            showPokeball = true
        }
        
        // Start continuous rotation
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false).delay(0.5)) {
            pokeballRotation = 360
        }
        
        // DNA Helix rotation
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false).delay(0.5)) {
            dnaHelixRotation = 360
        }
        
        // Show logo text
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            showLogo = true
        }
        
        // Activate main animations
        withAnimation(.easeInOut(duration: 0.8).delay(1.0)) {
            isAnimating = true
        }
        
        // Show particles
        withAnimation(.easeIn(duration: 1.0).delay(1.2)) {
            particlesVisible = true
        }
        
        // Text glow effect
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.5)) {
            textGlow = true
        }
        
        // Transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = false
            }
        }
    }
}

// MARK: - Pokéball Logo Component
struct PokeballLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.red, Color.red.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Circle()
                .fill(Color.white)
                .scaleEffect(0.5)
                .offset(y: 30)
            
            Rectangle()
                .fill(Color.black)
                .frame(height: 8)
            
            Circle()
                .stroke(Color.black, lineWidth: 8)
            
            Circle()
                .fill(Color.black)
                .frame(width: 30, height: 30)
            
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, .white.opacity(0.3)],
                        center: .center,
                        startRadius: 5,
                        endRadius: 15
                    )
                )
                .frame(width: 12, height: 12)
        }
    }
}

// MARK: - DNA Helix Icon
struct DNAHelixIcon: View {
    var body: some View {
        ZStack {
            ForEach(0..<12) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.6),
                                Color.blue.opacity(0.6),
                                Color.cyan.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 4, height: 80)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .offset(x: cos(Double(index) * .pi / 6) * 40,
                           y: sin(Double(index) * .pi / 6) * 40)
            }
        }
    }
}

// MARK: - Splash Neural Node Component
struct SplashNeuralNode: View {
    let position: CGPoint
    let delay: Double
    let isVisible: Bool
    @State private var isGlowing = false
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.cyan.opacity(isGlowing ? 0.8 : 0.4),
                        Color.blue.opacity(isGlowing ? 0.6 : 0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 2,
                    endRadius: isGlowing ? 25 : 15
                )
            )
            .frame(width: 50, height: 50)
            .position(position)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.5)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    isGlowing = true
                }
            }
    }
}

// MARK: - Splash Neural Connection Component
struct SplashNeuralConnection: View {
    let start: CGPoint
    let end: CGPoint
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.3),
                    Color.blue.opacity(0.5),
                    Color.cyan.opacity(0.3)
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            lineWidth: 1
        )
        .opacity(isAnimating ? 0.6 : 0)
        .animation(.easeInOut(duration: 1.5).delay(delay), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Particle Emitter
struct ParticleEmitterView: View {
    @State private var particles: [SplashParticle] = []
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Image(systemName: "sparkle")
                    .foregroundColor(particle.color)
                    .font(.system(size: particle.size))
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onReceive(timer) { _ in
            createParticle()
            updateParticles()
        }
    }
    
    private func createParticle() {
        let particle = SplashParticle()
        particles.append(particle)
    }
    
    private func updateParticles() {
        for index in particles.indices.reversed() {
            particles[index].update()
            if particles[index].opacity <= 0 {
                particles.remove(at: index)
            }
        }
    }
}

// MARK: - Splash Particle Model
struct SplashParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    
    init() {
        position = CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: UIScreen.main.bounds.height + 20
        )
        velocity = CGPoint(
            x: CGFloat.random(in: -2...2),
            y: CGFloat.random(in: -8...(-4))
        )
        size = CGFloat.random(in: 4...12)
        color = [Color.yellow, .orange, .cyan, .purple].randomElement()!
        opacity = 1.0
    }
    
    mutating func update() {
        position.x += velocity.x
        position.y += velocity.y
        opacity -= 0.02
    }
}

// MARK: - Preview
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(isActive: .constant(true))
    }
}
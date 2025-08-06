//
//  CelebrationAnimations.swift  
//  LuminaDex
//
//  Day 25: Celebration and Success Animations
//

import SwiftUI
import ConfettiSwiftUI

// MARK: - Confetti Celebration View
struct ConfettiCelebration: View {
    @Binding var trigger: Int
    let type: CelebrationType
    
    enum CelebrationType {
        case pokemonCaught
        case shinyFound
        case milestoneReached
        case favoriteAdded
        
        // Removed confettiType as it seems the API is different
        var confettiConfig: Int {
            switch self {
            case .pokemonCaught: return 0
            case .shinyFound: return 1
            case .milestoneReached: return 2
            case .favoriteAdded: return 3
            }
        }
        
        var colors: [Color] {
            switch self {
            case .pokemonCaught: return [.red, .blue, .yellow, .green, .purple]
            case .shinyFound: return [.yellow, .orange, .white, Color(red: 1, green: 0.84, blue: 0)]
            case .milestoneReached: return [.purple, .pink, .blue, .cyan]
            case .favoriteAdded: return [.pink, .red, Color(red: 1, green: 0.41, blue: 0.71)]
            }
        }
        
        var message: String {
            switch self {
            case .pokemonCaught: return "Pokémon Caught!"
            case .shinyFound: return "✨ Shiny Found! ✨"
            case .milestoneReached: return "Milestone Achieved!"
            case .favoriteAdded: return "Added to Favorites!"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Confetti effect - using correct API signature
            ConfettiCannon(
                trigger: $trigger,
                num: type == .shinyFound ? 100 : 50,
                confettis: [.text("🎉"), .text("✨"), .text("🌟"), .text("💫")],
                colors: type.colors,
                rainHeight: 600,
                radius: 400
            )
            
            // Success message
            if trigger > 0 {
                VStack(spacing: 20) {
                    // Icon animation
                    celebrationIcon
                        .transition(.scale.combined(with: .opacity))
                    
                    // Message
                    Text(type.message)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: type.colors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .transition(.push(from: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: trigger)
            }
        }
    }
    
    private var celebrationIcon: some View {
        Group {
            switch type {
            case .pokemonCaught:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .scaleEffect(1.2)
                            .opacity(0.5)
                    )
                
            case .shinyFound:
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .rotationEffect(.degrees(Double(index) * 120))
                            .offset(x: cos(Double(index) * 2.09) * 30, y: sin(Double(index) * 2.09) * 30)
                            .scaleEffect(1.0 + sin(Double(Date().timeIntervalSince1970) + Double(index)) * 0.2)
                    }
                }
                
            case .milestoneReached:
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                
            case .favoriteAdded:
                HeartAnimation()
            }
        }
    }
}

// MARK: - Heart Animation for Favorites
struct HeartAnimation: View {
    @State private var scale: CGFloat = 0.0
    @State private var rotation: Double = 0
    @State private var particles = false
    
    var body: some View {
        ZStack {
            // Main heart
            Image(systemName: "heart.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .shadow(color: .pink.opacity(0.5), radius: 20)
            
            // Particle hearts
            if particles {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.pink)
                        .offset(
                            x: particles ? cos(Double(index) * .pi / 4) * 60 : 0,
                            y: particles ? sin(Double(index) * .pi / 4) * 60 : 0
                        )
                        .scaleEffect(particles ? 0.0 : 1.0)
                        .opacity(particles ? 0.0 : 1.0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.6)
                            .delay(Double(index) * 0.05),
                            value: particles
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                rotation = 360
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                particles = true
            }
        }
    }
}

// MARK: - Lottie-style Success Animation
struct SuccessCheckmark: View {
    @State private var drawProgress: CGFloat = 0
    @State private var circleScale: CGFloat = 0
    @State private var checkmarkTrim: CGFloat = 0
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 100, color: Color = .green) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 4)
                .frame(width: size, height: size)
                .scaleEffect(circleScale)
            
            // Animated circle
            Circle()
                .trim(from: 0, to: drawProgress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            // Checkmark
            CheckmarkShape()
                .trim(from: 0, to: checkmarkTrim)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
                .frame(width: size * 0.5, height: size * 0.5)
        }
        .onAppear {
            animateSuccess()
        }
    }
    
    private func animateSuccess() {
        withAnimation(.easeOut(duration: 0.3)) {
            circleScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
            drawProgress = 1.0
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.5)) {
            checkmarkTrim = 1.0
        }
    }
}

// MARK: - Checkmark Shape
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.3))
        
        return path
    }
}

// MARK: - Milestone Progress Animation
struct MilestoneAnimation: View {
    let milestone: Int
    let current: Int
    @State private var progress: CGFloat = 0
    @State private var showCelebration = false
    
    private var percentage: Double {
        min(Double(current) / Double(milestone), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [.purple, .pink, .purple],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)
                
                VStack(spacing: 4) {
                    Text("\(current)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/ \(milestone)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    if percentage >= 1.0 {
                        Text("COMPLETE!")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            
            // Milestone Info
            VStack(spacing: 8) {
                Text("Pokédex Progress")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(Int(percentage * 100))% Complete")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                progress = percentage
            }
            
            if percentage >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCelebration = true
                }
            }
        }
    }
}

// MARK: - Favorite Button with Animation
struct AnimatedFavoriteButton: View {
    @Binding var isFavorite: Bool
    let color: Color
    @State private var animationTrigger = 0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var offset: CGSize = .zero
        var opacity: Double = 1.0
        var scale: CGFloat = 1.0
    }
    
    var body: some View {
        Button(action: toggleFavorite) {
            ZStack {
                // Particles
                ForEach(particles) { particle in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 8))
                        .foregroundColor(color)
                        .offset(particle.offset)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                }
                
                // Main heart
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(
                        isFavorite ? 
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        ) : 
                        LinearGradient(
                            colors: [.gray, .gray.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onChange(of: isFavorite) { _, newValue in
            if newValue {
                animateFavorite()
            }
        }
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func animateFavorite() {
        // Scale and rotate animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            scale = 1.3
            rotation = 15
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
            scale = 1.0
            rotation = -15
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.3)) {
            rotation = 0
        }
        
        // Create particles
        createParticles()
        
        // Animate particles
        withAnimation(.easeOut(duration: 0.8)) {
            for index in particles.indices {
                let angle = Double(index) * (2 * .pi / Double(particles.count))
                particles[index].offset = CGSize(
                    width: cos(angle) * 40,
                    height: sin(angle) * 40
                )
                particles[index].opacity = 0
                particles[index].scale = 0.5
            }
        }
        
        // Clear particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            particles.removeAll()
        }
    }
    
    private func createParticles() {
        particles = (0..<8).map { _ in Particle() }
    }
}

// MARK: - Wave Animation Modifier
struct WaveAnimationModifier: ViewModifier {
    let amplitude: CGFloat
    let frequency: CGFloat
    let phase: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: amplitude * sin(frequency * phase))
    }
}

extension View {
    func waveAnimation(amplitude: CGFloat = 10, frequency: CGFloat = 1, phase: CGFloat) -> some View {
        modifier(WaveAnimationModifier(amplitude: amplitude, frequency: frequency, phase: phase))
    }
}

// MARK: - Liquid Blob Effect
struct LiquidBlobView: View {
    let color: Color
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for i in 0..<5 {
                    let offset = CGFloat(i) * 0.5
                    let x = size.width / 2 + cos(time + offset) * 20
                    let y = size.height / 2 + sin(time * 1.5 + offset) * 20
                    let radius = 30 + sin(time * 2 + offset) * 10
                    
                    let circle = Path(ellipseIn: CGRect(
                        x: x - radius,
                        y: y - radius,
                        width: radius * 2,
                        height: radius * 2
                    ))
                    
                    context.fill(
                        circle,
                        with: .color(color.opacity(0.3))
                    )
                }
            }
            .blur(radius: 20)
        }
    }
}
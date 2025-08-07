//
//  AchievementNotification.swift
//  LuminaDex
//
//  Achievement unlock notifications with celebrations
//

import SwiftUI

struct AchievementNotificationView: View {
    let achievement: LuminaAchievement
    @Binding var isShowing: Bool
    @State private var animateIn = false
    @State private var showParticles = false
    @State private var showShine = false
    
    var body: some View {
        if isShowing {
            ZStack {
                // Background blur
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissNotification()
                    }
                
                // Notification card
                VStack(spacing: 0) {
                    // Header with gradient
                    ZStack {
                        LinearGradient(
                            colors: [
                                achievement.tier.color,
                                achievement.tier.color.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        HStack {
                            Text("ACHIEVEMENT UNLOCKED!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .tracking(2)
                            
                            Spacer()
                            
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .onTapGesture {
                                    dismissNotification()
                                }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .frame(height: 40)
                    
                    // Content
                    HStack(spacing: 20) {
                        // Animated Badge
                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(achievement.tier.color.opacity(0.3))
                                .frame(width: 90, height: 90)
                                .blur(radius: showShine ? 20 : 10)
                                .scaleEffect(showShine ? 1.3 : 1.0)
                            
                            // Badge
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            achievement.tier.color,
                                            achievement.tier.color.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .stroke(achievement.tier.color, lineWidth: 3)
                                .frame(width: 80, height: 80)
                            
                            // Shine overlay
                            if showShine {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.6),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(showShine ? 360 : 0))
                            }
                            
                            Image(systemName: achievement.icon)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(animateIn ? 1.0 : 0.5)
                                .rotationEffect(.degrees(animateIn ? 360 : 0))
                        }
                        
                        // Achievement Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(achievement.title)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(achievement.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            // Tier and Points
                            HStack(spacing: 8) {
                                TierBadge(tier: achievement.tier)
                                
                                Text("+\(achievement.tier.rawValue * 100) XP")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(achievement.tier.color)
                            }
                            
                            // Rewards
                            if let firstReward = achievement.rewards.first {
                                HStack(spacing: 4) {
                                    Image(systemName: "gift.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    
                                    Text(firstReward)
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
                .frame(maxWidth: 400)
                .cornerRadius(16)
                .shadow(radius: 20)
                .scaleEffect(animateIn ? 1.0 : 0.8)
                .opacity(animateIn ? 1.0 : 0.0)
                .padding()
                
                // Particle effects
                if showParticles {
                    ForEach(0..<20, id: \.self) { index in
                        ParticleView(
                            color: achievement.tier.color,
                            delay: Double(index) * 0.05
                        )
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    animateIn = true
                }
                
                withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                    showShine = true
                }
                
                withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                    showParticles = true
                }
                
                // Auto dismiss after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    dismissNotification()
                }
            }
        }
    }
    
    private func dismissNotification() {
        withAnimation(.easeInOut(duration: 0.3)) {
            animateIn = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

// MARK: - Particle View
struct ParticleView: View {
    let color: Color
    let delay: Double
    
    @State private var offset = CGSize.zero
    @State private var opacity = 1.0
    @State private var scale = 1.0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(offset)
            .onAppear {
                let randomX = CGFloat.random(in: -200...200)
                let randomY = CGFloat.random(in: -300...(-100))
                
                withAnimation(.easeOut(duration: 2.0).delay(delay)) {
                    offset = CGSize(width: randomX, height: randomY)
                    opacity = 0
                    scale = 0.3
                }
            }
    }
}

// MARK: - Achievement Toast (Smaller notification)
struct AchievementToast: View {
    let achievement: LuminaAchievement
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0
    
    var body: some View {
        if isShowing {
            VStack {
                HStack(spacing: 12) {
                    // Mini badge
                    ZStack {
                        Circle()
                            .fill(achievement.tier.color)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Achievement Unlocked!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(achievement.title)
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    // Points
                    Text("+\(achievement.tier.rawValue * 100)")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(achievement.tier.color)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 10)
                )
                .padding(.horizontal)
                .offset(y: offset)
                .opacity(opacity)
                
                Spacer()
            }
            .onAppear {
                withAnimation(.spring()) {
                    offset = 10
                    opacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut) {
                        offset = -100
                        opacity = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isShowing = false
                    }
                }
            }
        }
    }
}

// MARK: - Achievement Celebration Overlay
struct AchievementCelebrationOverlay: View {
    let achievement: LuminaAchievement
    @Binding var isShowing: Bool
    @State private var showConfetti = false
    @State private var showStars = false
    
    var body: some View {
        if isShowing {
            ZStack {
                // Confetti background
                if showConfetti {
                    ConfettiView(
                        colors: [
                            achievement.tier.color,
                            .yellow,
                            .orange,
                            .purple,
                            .blue
                        ]
                    )
                }
                
                // Stars animation
                if showStars {
                    ForEach(0..<30, id: \.self) { index in
                        StarBurst(
                            color: achievement.tier.color,
                            delay: Double(index) * 0.1,
                            size: CGFloat.random(in: 10...30)
                        )
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear {
                showConfetti = true
                showStars = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }
}

struct StarBurst: View {
    let color: Color
    let delay: Double
    let size: CGFloat
    
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundColor(color)
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .position(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 100)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(delay)) {
                    scale = 2.0
                    opacity = 0
                    rotation = 360
                }
            }
    }
}

struct ConfettiView: View {
    let colors: [Color]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(
                    color: colors.randomElement() ?? .blue,
                    size: CGFloat.random(in: 8...16),
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    delay: Double(index) * 0.02
                )
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let delay: Double
    
    @State private var offsetY: CGFloat = -100
    @State private var rotation = 0.0
    @State private var opacity = 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: size, height: size * 1.5)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(x: startX, y: offsetY)
            .onAppear {
                withAnimation(.easeIn(duration: 2.0).delay(delay)) {
                    offsetY = UIScreen.main.bounds.height + 100
                    rotation = Double.random(in: 180...540)
                    opacity = 0.8
                }
            }
    }
}
//
//  CompanionSprite.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

struct CompanionSprite: View {
    let companion: CompanionData
    let emotionState: EmotionState
    let position: CGPoint
    let isVisible: Bool
    
    @State private var isAnimating = false
    @State private var particleOffset: CGFloat = 0
    @State private var breathingScale: CGFloat = 1.0
    
    private let breathingTimer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    private let particleTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if isVisible {
                // Main sprite body
                spriteBody
                
                // Particle effects
                if let particleEffect = emotionState.particleEffect {
                    particleLayer(effect: particleEffect)
                }
                
                // Emotion bubble (appears occasionally)
                if emotionState != .neutral && isAnimating {
                    emotionBubble
                }
            }
        }
        .position(position)
        .onAppear {
            startAnimations()
        }
        .onReceive(breathingTimer) { _ in
            animateBreathing()
        }
        .onReceive(particleTimer) { _ in
            animateParticles()
        }
    }
    
    private var spriteBody: some View {
        ZStack {
            // Shadow
            Circle()
                .fill(Color.black.opacity(0.2))
                .frame(width: 30, height: 15)
                .offset(y: 15)
                .blur(radius: 2)
            
            // Main sprite container
            ZStack {
                // Glow effect for certain emotions
                if emotionState == .excited || emotionState == .happy {
                    Circle()
                        .fill(companion.type.primaryColor.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .blur(radius: 10)
                        .scaleEffect(breathingScale)
                }
                
                // Sprite background
                Circle()
                    .fill(companion.type.primaryColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(companion.type.primaryColor.opacity(0.3), lineWidth: 1)
                    )
                
                // Companion sprite
                Text(getSpriteForEmotion())
                    .font(.system(size: 28))
                    .scaleEffect(emotionState.animationScale * breathingScale)
                    .offset(x: emotionState.animationOffset.x, y: emotionState.animationOffset.y)
                    .animation(.easeInOut(duration: 0.3), value: emotionState)
            }
        }
        .scaleEffect(isVisible ? 1.0 : 0.0)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
    }
    
    private func particleLayer(effect: ParticleEffect) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: effect.systemImage)
                    .font(.system(size: 12))
                    .foregroundColor(effect.color)
                    .offset(
                        x: cos(Double(index) * 2.0 * .pi / 3.0 + particleOffset) * 25,
                        y: sin(Double(index) * 2.0 * .pi / 3.0 + particleOffset) * 25 - 20
                    )
                    .opacity(0.8)
                    .scaleEffect(0.8 + 0.2 * sin(particleOffset + Double(index)))
            }
        }
        .animation(.linear(duration: 2.0), value: particleOffset)
    }
    
    private var emotionBubble: some View {
        VStack(spacing: 2) {
            Text(getEmotionText())
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(companion.type.primaryColor.opacity(0.9))
                )
            
            // Bubble pointer
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundColor(companion.type.primaryColor.opacity(0.9))
        }
        .offset(y: -45)
        .opacity(isAnimating ? 1.0 : 0.0)
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAnimating)
    }
    
    // MARK: - Helper Methods
    
    private func getSpriteForEmotion() -> String {
        switch emotionState {
        case .excited:
            return companion.type.sprite + "✨"
        case .happy:
            return companion.type.sprite + "😊"
        case .sad:
            return companion.type.sprite + "😢"
        case .scared:
            return companion.type.sprite + "😰"
        case .sleeping:
            return companion.type.sprite + "💤"
        case .curious:
            return companion.type.sprite + "🤔"
        case .bored:
            return companion.type.sprite + "😴"
        default:
            return companion.type.sprite
        }
    }
    
    private func getEmotionText() -> String {
        switch emotionState {
        case .excited: return "Wow!"
        case .happy: return "Yay!"
        case .sad: return "Aww..."
        case .scared: return "Eek!"
        case .sleeping: return "Zzz..."
        case .curious: return "Hmm?"
        case .bored: return "..."
        default: return ""
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
        }
        
        // Hide emotion bubble after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnimating = false
            }
        }
    }
    
    private func animateBreathing() {
        withAnimation(.easeInOut(duration: 1.0)) {
            breathingScale = breathingScale == 1.0 ? 1.05 : 1.0
        }
    }
    
    private func animateParticles() {
        withAnimation(.linear(duration: 0.5)) {
            particleOffset += 0.5
        }
    }
}

// MARK: - Companion Overlay View

struct CompanionOverlay: View {
    @ObservedObject var companionManager: CompanionManager
    
    var body: some View {
        ZStack {
            if let companion = companionManager.currentCompanion {
                CompanionSprite(
                    companion: companion,
                    emotionState: companionManager.companionEmotionState,
                    position: companionManager.companionPosition,
                    isVisible: companionManager.isCompanionVisible
                )
            }
        }
        .allowsHitTesting(false) // Allow touches to pass through
    }
}

// MARK: - Companion Control Panel

struct CompanionControlPanel: View {
    @ObservedObject var companionManager: CompanionManager
    @State private var showPanel = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 12) {
                    // Toggle visibility button
                    Button(action: {
                        companionManager.toggleCompanionVisibility()
                    }) {
                        Image(systemName: companionManager.isCompanionVisible ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(ThemeManager.Colors.glassMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(ThemeManager.Colors.glassStroke, lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Feed companion button
                    if let companion = companionManager.currentCompanion {
                        Button(action: {
                            companionManager.feedCompanion()
                        }) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(companion.type.primaryColor.opacity(0.8))
                                        .overlay(
                                            Circle()
                                                .stroke(companion.type.primaryColor, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Happiness indicator
                        Text("\(companion.happiness)%")
                            .font(.caption2)
                            .foregroundColor(ThemeManager.Colors.lumina)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(ThemeManager.Colors.glassMaterial)
                            )
                    }
                }
                .padding(.trailing, 20)
                .opacity(showPanel ? 1.0 : 0.0)
                .scaleEffect(showPanel ? 1.0 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showPanel)
            }
        }
        .onAppear {
            // Show panel after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showPanel = true
            }
        }
    }
}

#Preview {
    ZStack {
        ThemeManager.Colors.spaceGradient
            .ignoresSafeArea()
        
        CompanionSprite(
            companion: CompanionData(
                type: .pikachu,
                name: "Sparky",
                happiness: 85,
                experience: 150
            ),
            emotionState: .excited,
            position: CGPoint(x: 200, y: 300),
            isVisible: true
        )
    }
    .preferredColorScheme(.dark)
}
//
//  CompanionFloatingView.swift
//  LuminaDex
//
//  Floating companion view with real Pokemon sprites
//

import SwiftUI

struct CompanionFloatingView: View {
    @ObservedObject var companionManager: CompanionManager
    @State private var imageData: Data?
    @State private var isLoadingImage = true
    @State private var floatOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var showEmotionParticles = false
    
    private let size: CGFloat = 60
    
    var body: some View {
        if let companion = companionManager.currentCompanion {
            ZStack {
                // Emotion particles
                if showEmotionParticles,
                   let particleEffect = companionManager.companionEmotionState.particleEffect {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: particleEffect.systemImage)
                            .font(.caption)
                            .foregroundColor(particleEffect.color)
                            .scaleEffect(showEmotionParticles ? 1 : 0)
                            .opacity(showEmotionParticles ? 0 : 1)
                            .offset(
                                x: CGFloat.random(in: -30...30),
                                y: CGFloat.random(in: -30...(-10))
                            )
                            .animation(
                                .easeOut(duration: 1.5)
                                .delay(Double(index) * 0.1),
                                value: showEmotionParticles
                            )
                    }
                }
                
                // Companion sprite container
                VStack(spacing: 4) {
                    // Pokemon sprite
                    ZStack {
                        // Background glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        companion.type.primaryColor.opacity(0.3),
                                        companion.type.primaryColor.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: size * 0.8
                                )
                            )
                            .frame(width: size * 1.5, height: size * 1.5)
                            .blur(radius: 8)
                        
                        // Sprite container
                        if isLoadingImage {
                            // Loading state with emoji fallback
                            Text(companion.type.sprite)
                                .font(.system(size: size * 0.6))
                                .frame(width: size, height: size)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(radius: 4)
                                )
                        } else if let imageData = imageData,
                                  let uiImage = UIImage(data: imageData) {
                            // Actual Pokemon sprite
                            Image(uiImage: uiImage)
                                .resizable()
                                .interpolation(.none) // Pixel-perfect rendering
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size, height: size)
                        } else {
                            // Fallback emoji if image fails
                            Text(companion.type.sprite)
                                .font(.system(size: size * 0.6))
                                .frame(width: size, height: size)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(radius: 4)
                                )
                        }
                    }
                    .scaleEffect(companionManager.companionEmotionState.animationScale)
                    .offset(y: floatOffset)
                    .rotationEffect(.degrees(rotationAngle))
                    
                    // Name and mood
                    VStack(spacing: 2) {
                        Text(companion.name)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 2) {
                            Text(companion.moodEmoji)
                                .font(.caption2)
                            
                            // Level indicator
                            Text("Lv.\(companion.level)")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                            .overlay(
                                Capsule()
                                    .stroke(companion.type.primaryColor.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
                .offset(x: companionManager.companionEmotionState.animationOffset.x,
                        y: companionManager.companionEmotionState.animationOffset.y)
            }
            .onTapGesture {
                // Interact with companion - feed them to increase happiness
                companionManager.feedCompanion()
                triggerEmotionParticles(for: .happy)
            }
            .onAppear {
                loadCompanionSprite()
                startFloatingAnimation()
            }
            .onChange(of: companion.type) { _ in
                loadCompanionSprite()
            }
            .onChange(of: companionManager.companionEmotionState) { newState in
                triggerEmotionParticles(for: newState)
            }
        }
    }
    
    private func loadCompanionSprite() {
        guard let companion = companionManager.currentCompanion else { return }
        
        isLoadingImage = true
        
        // Load sprite from URL
        guard let url = URL(string: companion.type.spriteURL) else {
            isLoadingImage = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    self.imageData = data
                }
                self.isLoadingImage = false
            }
        }.resume()
    }
    
    private func startFloatingAnimation() {
        // Gentle floating animation
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            floatOffset = -8
        }
        
        // Subtle rotation
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            rotationAngle = 5
        }
    }
    
    private func triggerEmotionParticles(for state: EmotionState) {
        if state.particleEffect != nil {
            showEmotionParticles = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showEmotionParticles = false
            }
        }
    }
}


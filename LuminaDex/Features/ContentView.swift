//
//  ContentView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient
            ThemeManager.Colors.spaceGradient
                .ignoresSafeArea()
            
            VStack(spacing: ThemeManager.Spacing.xl) {
                // Hero title
                VStack(spacing: ThemeManager.Spacing.md) {
                    Text("LuminaDex")
                        .font(ThemeManager.Typography.displayHeavy)
                        .foregroundStyle(ThemeManager.Colors.neuralGradient)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(ThemeManager.Animation.springBouncy.delay(0.2), value: isAnimating)
                    
                    Text("The Future of Pokémon Discovery")
                        .font(ThemeManager.Typography.bodyLarge)
                        .foregroundColor(ThemeManager.Colors.lumina.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(ThemeManager.Animation.easeInOut.delay(0.6), value: isAnimating)
                }
                
                // Glassmorphic card
                VStack(spacing: ThemeManager.Spacing.lg) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(ThemeManager.Colors.auroraGradient)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(ThemeManager.Animation.springSmooth.delay(1.0), value: isAnimating)
                    
                    Text("Welcome to the most beautiful\nPokémon experience ever created")
                        .font(ThemeManager.Typography.bodyMedium)
                        .foregroundColor(ThemeManager.Colors.lumina)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(ThemeManager.Animation.easeInOut.delay(1.2), value: isAnimating)
                }
                .padding(ThemeManager.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ThemeManager.Colors.glassMaterial)
                        .stroke(ThemeManager.Colors.glassStroke, lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                )
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .animation(ThemeManager.Animation.springBouncy.delay(0.8), value: isAnimating)
            }
            .padding(ThemeManager.Spacing.xl)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ContentView()
}   

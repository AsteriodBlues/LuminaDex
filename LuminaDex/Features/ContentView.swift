//
//  ContentView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showWorldMap = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            if showWorldMap {
                NeuralFlowMapView()
                    .transition(.asymmetric(
                        insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                        removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                welcomeScreen
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showWorldMap)
    }
    
    private var welcomeScreen: some View {
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
                    Image(systemName: "drop.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(ThemeManager.Colors.auroraGradient)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(ThemeManager.Animation.springSmooth.delay(1.0), value: isAnimating)
                    
                    Text("Experience liquid animations,\nmorphing shapes, and flowing particles")
                        .font(ThemeManager.Typography.bodyMedium)
                        .foregroundColor(ThemeManager.Colors.lumina)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(ThemeManager.Animation.easeInOut.delay(1.2), value: isAnimating)
                    
                    // Launch button
                    Button(action: {
                        showWorldMap = true
                    }) {
                        HStack {
                            Text("Enter the Flow")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ThemeManager.Colors.neuralGradient)
                        )
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(ThemeManager.Animation.easeInOut.delay(1.6), value: isAnimating)
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
        .preferredColorScheme(.dark)
}

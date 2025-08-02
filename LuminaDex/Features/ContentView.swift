//
//  ContentView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var companionManager = CompanionManager()
    @State private var showWorldMap = false
    @State private var showCompanionSelection = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            if showWorldMap {
                ZStack {
                    NeuralFlowMapView()
                        .transition(.asymmetric(
                            insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                            removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                        ))
                    
                    // Companion overlay on map
                    CompanionOverlay(companionManager: companionManager)
                    
                    // Companion control panel
                    CompanionControlPanel(companionManager: companionManager)
                }
            } else if showCompanionSelection {
                CompanionSelectionView { selectedCompanion in
                    companionManager.selectCompanion(selectedCompanion)
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                        showCompanionSelection = false
                        showWorldMap = true
                    }
                    
                    // Position companion in center of screen initially
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        companionManager.updateCompanionPosition(to: CGPoint(x: 200, y: 400))
                    }
                }
                .transition(.asymmetric(
                    insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                    removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                welcomeScreen
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showWorldMap)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCompanionSelection)
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
                        if companionManager.currentCompanion != nil {
                            showWorldMap = true
                        } else {
                            showCompanionSelection = true
                        }
                    }) {
                        HStack {
                            Text(companionManager.currentCompanion != nil ? "Enter the Flow" : "Choose Companion")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Image(systemName: companionManager.currentCompanion != nil ? "arrow.right.circle.fill" : "heart.circle.fill")
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

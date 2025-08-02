//
//  CompanionSelectionView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

struct CompanionSelectionView: View {
    @State private var selectedCompanion: CompanionType? = nil
    @State private var companionName: String = ""
    @State private var isAnimating = false
    @State private var showNameInput = false
    @State private var currentPreviewIndex = 0
    
    let onCompanionSelected: (CompanionData) -> Void
    
    private let companions: [CompanionType] = [.pikachu, .eevee, .mew]
    private let previewTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Neural gradient background
            ThemeManager.Colors.spaceGradient
                .ignoresSafeArea()
            
            VStack(spacing: ThemeManager.Spacing.xl) {
                headerSection
                
                if showNameInput {
                    nameInputSection
                } else {
                    companionGridSection
                }
                
                actionButton
            }
            .padding(ThemeManager.Spacing.xl)
        }
        .onAppear {
            withAnimation(ThemeManager.Animation.springBouncy.delay(0.3)) {
                isAnimating = true
            }
        }
        .onReceive(previewTimer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPreviewIndex = (currentPreviewIndex + 1) % 3
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: ThemeManager.Spacing.md) {
            Text("Choose Your Companion")
                .font(ThemeManager.Typography.displaySemibold)
                .foregroundStyle(ThemeManager.Colors.neuralGradient)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .animation(ThemeManager.Animation.springBouncy.delay(0.2), value: isAnimating)
            
            Text("Your companion will guide you through the world,\nreact to discoveries, and grow alongside you")
                .font(ThemeManager.Typography.bodyMedium)
                .foregroundColor(ThemeManager.Colors.lumina.opacity(0.8))
                .multilineTextAlignment(.center)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(ThemeManager.Animation.easeInOut.delay(0.6), value: isAnimating)
        }
    }
    
    private var companionGridSection: some View {
        VStack(spacing: ThemeManager.Spacing.lg) {
            ForEach(Array(companions.enumerated()), id: \.offset) { index, companion in
                companionCard(for: companion, index: index)
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(
                        ThemeManager.Animation.springBouncy.delay(0.8 + Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
    }
    
    private func companionCard(for companion: CompanionType, index: Int) -> some View {
        Button(action: {
            handleCompanionSelection(companion)
        }) {
            HStack(spacing: ThemeManager.Spacing.lg) {
                // Sprite preview area
                ZStack {
                    Circle()
                        .fill(companion.primaryColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(
                                    selectedCompanion == companion ? 
                                    companion.primaryColor : Color.clear,
                                    lineWidth: 3
                                )
                        )
                    
                    // Animated sprite preview
                    Text(companion.sprite)
                        .font(.system(size: 40))
                        .scaleEffect(currentPreviewIndex == index ? 1.2 : 1.0)
                        .rotationEffect(.degrees(currentPreviewIndex == index ? 10 : 0))
                        .animation(.easeInOut(duration: 0.3), value: currentPreviewIndex)
                }
                
                VStack(alignment: .leading, spacing: ThemeManager.Spacing.xs) {
                    Text(companion.name)
                        .font(ThemeManager.Typography.headerMedium)
                        .foregroundColor(ThemeManager.Colors.lumina)
                    
                    Text(companion.personality)
                        .font(ThemeManager.Typography.bodySmall)
                        .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
                        .lineLimit(2)
                    
                    // Traits
                    HStack(spacing: ThemeManager.Spacing.xs) {
                        ForEach(companion.traits, id: \.self) { trait in
                            Text(trait)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(companion.primaryColor.opacity(0.3))
                                )
                                .foregroundColor(companion.primaryColor)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(ThemeManager.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        selectedCompanion == companion ?
                        companion.primaryColor.opacity(0.1) :
                        ThemeManager.Colors.glassMaterial
                    )
                    .stroke(
                        selectedCompanion == companion ?
                        companion.primaryColor.opacity(0.5) :
                        ThemeManager.Colors.glassStroke,
                        lineWidth: selectedCompanion == companion ? 2 : 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
            )
            .scaleEffect(selectedCompanion == companion ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedCompanion)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var nameInputSection: some View {
        VStack(spacing: ThemeManager.Spacing.lg) {
            // Selected companion preview
            if let companion = selectedCompanion {
                VStack(spacing: ThemeManager.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(companion.primaryColor.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(companion.primaryColor, lineWidth: 3)
                            )
                        
                        Text(companion.sprite)
                            .font(.system(size: 60))
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                    }
                    
                    Text("Meet your \(companion.name)!")
                        .font(ThemeManager.Typography.headlineBold)
                        .foregroundColor(companion.primaryColor)
                }
            }
            
            // Name input
            VStack(alignment: .leading, spacing: ThemeManager.Spacing.sm) {
                Text("Give your companion a name")
                    .font(ThemeManager.Typography.bodyMedium)
                    .foregroundColor(ThemeManager.Colors.lumina)
                
                TextField("Enter name...", text: $companionName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(ThemeManager.Typography.bodyLarge)
                    .foregroundColor(ThemeManager.Colors.lumina)
                    .padding(ThemeManager.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ThemeManager.Colors.glassMaterial)
                            .stroke(ThemeManager.Colors.glassStroke, lineWidth: 1)
                    )
                    .autocorrectionDisabled()
            }
        }
        .padding(ThemeManager.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeManager.Colors.glassMaterial)
                .stroke(ThemeManager.Colors.glassStroke, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
        )
    }
    
    private var actionButton: some View {
        Button(action: {
            if showNameInput {
                // Complete selection
                if let companion = selectedCompanion, !companionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let companionData = CompanionData(
                        type: companion,
                        name: companionName.trimmingCharacters(in: .whitespacesAndNewlines),
                        happiness: 50,
                        experience: 0
                    )
                    onCompanionSelected(companionData)
                }
            } else {
                // Move to name input
                if selectedCompanion != nil {
                    withAnimation(ThemeManager.Animation.springSmooth) {
                        showNameInput = true
                    }
                }
            }
        }) {
            HStack {
                if showNameInput {
                    Text("Start Adventure")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                } else {
                    Text("Choose This Companion")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(buttonBackgroundColor)
            )
        }
        .disabled(showNameInput ? companionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : selectedCompanion == nil)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(ThemeManager.Animation.easeInOut.delay(1.4), value: isAnimating)
    }
    
    // MARK: - Helper Methods
    
    private func handleCompanionSelection(_ companion: CompanionType) {
        selectedCompanion = companion
        // Haptic feedback for selection
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private var buttonBackgroundColor: Color {
        let isEnabled = showNameInput ? 
            !companionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : 
            selectedCompanion != nil
        
        return isEnabled ? 
            Color(red: 0.42, green: 0.37, blue: 1.0) : // Neural color as solid color
            Color.gray.opacity(0.3)
    }
}

// MARK: - Supporting Types
// CompanionData and CompanionType moved to Data/CompanionData.swift

#Preview {
    CompanionSelectionView { companion in
        print("Selected companion: \(companion.name) named \(companion.name)")
    }
    .preferredColorScheme(.dark)
}
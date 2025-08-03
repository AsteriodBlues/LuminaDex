//
//  DynamicIslandManager.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI
import Foundation

// MARK: - Dynamic Island Manager (iOS 16.1+ with Live Activities)

@MainActor
class DynamicIslandManager: ObservableObject {
    @Published var isLiveActivityActive = false
    @Published var currentRegion = "Kanto"
    @Published var activeSpriteCount = 0
    @Published var companionEmotion: EmotionState = .neutral
    
    private let companionManager: CompanionManager
    private var updateTimer: Timer?
    
    init(companionManager: CompanionManager) {
        self.companionManager = companionManager
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Observe companion emotion changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(companionEmotionChanged),
            name: NSNotification.Name("CompanionEmotionChanged"),
            object: nil
        )
    }
    
    @objc private func companionEmotionChanged(_ notification: Notification) {
        if let emotion = notification.object as? EmotionState {
            companionEmotion = emotion
            updateDynamicIslandContent()
        }
    }
    
    // MARK: - Public Interface
    
    func startLiveActivity(region: String, spriteCount: Int) {
        guard canUseLiveActivities else {
            print("Live Activities not available on this device/iOS version")
            return
        }
        
        currentRegion = region
        activeSpriteCount = spriteCount
        isLiveActivityActive = true
        
        // Start periodic updates
        startPeriodicUpdates()
        
        // Show Dynamic Island content
        showDynamicIslandContent()
        
        print("✅ Dynamic Island activity started for \(region)")
    }
    
    func updateActivity(region: String, spriteCount: Int) {
        guard isLiveActivityActive else { return }
        
        let regionChanged = currentRegion != region
        currentRegion = region
        activeSpriteCount = spriteCount
        
        if regionChanged {
            triggerRegionChangeAnimation()
        }
        
        updateDynamicIslandContent()
    }
    
    func endActivity() {
        isLiveActivityActive = false
        stopPeriodicUpdates()
        hideDynamicIslandContent()
        
        print("🔚 Dynamic Island activity ended")
    }
    
    // MARK: - Private Methods
    
    private var canUseLiveActivities: Bool {
        if #available(iOS 16.1, *) {
            // In a real implementation, we'd check ActivityAuthorizationInfo
            return true
        } else {
            return false
        }
    }
    
    private func startPeriodicUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.updateDynamicIslandContent()
        }
    }
    
    private func stopPeriodicUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func showDynamicIslandContent() {
        // Post notification for UI to show Dynamic Island simulation
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowDynamicIsland"),
            object: createIslandContent()
        )
    }
    
    private func updateDynamicIslandContent() {
        guard isLiveActivityActive else { return }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("UpdateDynamicIsland"),
            object: createIslandContent()
        )
    }
    
    private func hideDynamicIslandContent() {
        NotificationCenter.default.post(
            name: NSNotification.Name("HideDynamicIsland"),
            object: nil
        )
    }
    
    private func triggerRegionChangeAnimation() {
        NotificationCenter.default.post(
            name: NSNotification.Name("DynamicIslandRegionChange"),
            object: currentRegion
        )
    }
    
    private func createIslandContent() -> DynamicIslandContent {
        DynamicIslandContent(
            companionName: companionManager.currentCompanion?.name ?? "Companion",
            currentRegion: currentRegion,
            activeSpriteCount: activeSpriteCount,
            companionEmotion: companionEmotion,
            lastUpdated: Date()
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        updateTimer?.invalidate()
    }
}

// MARK: - Dynamic Island Content Model

struct DynamicIslandContent {
    let companionName: String
    let currentRegion: String
    let activeSpriteCount: Int
    let companionEmotion: EmotionState
    let lastUpdated: Date
    
    var regionAbbreviation: String {
        switch currentRegion {
        case "Kanto": return "KT"
        case "Johto": return "JT"
        case "Hoenn": return "HN"
        case "Sinnoh": return "SH"
        case "Unova": return "UV"
        case "Kalos": return "KL"
        case "Alola": return "AL"
        case "Galar": return "GL"
        case "Paldea": return "PD"
        default: return "??"
        }
    }
    
    var regionColor: Color {
        switch currentRegion {
        case "Kanto": return Color(hex: "FF6B6B")
        case "Johto": return Color(hex: "4ECDC4")
        case "Hoenn": return Color(hex: "45B7D1")
        case "Sinnoh": return Color(hex: "96CEB4")
        case "Unova": return Color(hex: "FFEAA7")
        case "Kalos": return Color(hex: "DDA0DD")
        case "Alola": return Color(hex: "FFD93D")
        case "Galar": return Color(hex: "6C5CE7")
        case "Paldea": return Color(hex: "FD79A8")
        default: return .gray
        }
    }
}

// MARK: - Dynamic Island Simulation View

struct DynamicIslandSimulation: View {
    @State private var isVisible = false
    @State private var content: DynamicIslandContent?
    @State private var isExpanded = false
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        VStack {
            if isVisible, let content = content {
                dynamicIslandView(content: content)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowDynamicIsland"))) { notification in
            if let content = notification.object as? DynamicIslandContent {
                self.content = content
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isVisible = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UpdateDynamicIsland"))) { notification in
            if let content = notification.object as? DynamicIslandContent {
                self.content = content
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HideDynamicIsland"))) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                isVisible = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DynamicIslandRegionChange"))) { _ in
            triggerRegionChangeAnimation()
        }
        .onAppear {
            startContinuousAnimation()
        }
    }
    
    private func dynamicIslandView(content: DynamicIslandContent) -> some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                if isExpanded {
                    expandedView(content: content)
                } else {
                    compactView(content: content)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
    }
    
    private func compactView(content: DynamicIslandContent) -> some View {
        HStack(spacing: 8) {
            // Leading: Companion sprite
            companionSpriteView(emotion: content.companionEmotion)
                .frame(width: 20, height: 20)
            
            // Center: Region name
            Text(content.regionAbbreviation)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            // Trailing: Activity indicator
            Circle()
                .fill(content.regionColor)
                .frame(width: 6, height: 6)
                .scaleEffect(1.0 + sin(animationPhase) * 0.3)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.black)
                .overlay(
                    Capsule()
                        .stroke(content.regionColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func expandedView(content: DynamicIslandContent) -> some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                companionSpriteView(emotion: content.companionEmotion)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(content.companionName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Exploring \(content.currentRegion)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(content.activeSpriteCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(content.regionColor)
                    
                    Text("sprites")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Mini map representation
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index == 2 ? content.regionColor : Color.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                        .scaleEffect(index == 2 ? (1.0 + sin(animationPhase * 2) * 0.2) : 1.0)
                }
            }
            
            // Activity status
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 4, height: 4)
                    .scaleEffect(1.0 + sin(animationPhase * 3) * 0.4)
                
                Text("Live Activity")
                    .font(.caption2)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("Tap to close")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(content.regionColor.opacity(0.3), lineWidth: 1)
                )
        )
        .frame(width: 280)
    }
    
    private func companionSpriteView(emotion: EmotionState) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            emotionColor(emotion).opacity(0.4),
                            emotionColor(emotion).opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 12
                    )
                )
                .scaleEffect(1.0 + sin(animationPhase * 1.5) * 0.1)
            
            Text(emotionSprite(emotion))
                .font(.system(size: 12))
                .scaleEffect(1.0 + sin(animationPhase * 2) * 0.05)
        }
    }
    
    private func emotionColor(_ emotion: EmotionState) -> Color {
        switch emotion {
        case .happy, .excited: return .green
        case .sad: return .blue
        case .scared: return .orange
        case .sleeping: return .purple
        case .curious: return .yellow
        default: return .gray
        }
    }
    
    private func emotionSprite(_ emotion: EmotionState) -> String {
        switch emotion {
        case .happy: return "😊"
        case .excited: return "🤩"
        case .sad: return "😢"
        case .scared: return "😰"
        case .sleeping: return "😴"
        case .curious: return "🤔"
        case .bored: return "😑"
        default: return "⚡"
        }
    }
    
    private func startContinuousAnimation() {
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
    }
    
    private func triggerRegionChangeAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            // Trigger a scale animation for region change
        }
    }
}

// MARK: - Extension for CompanionManager Integration

extension CompanionManager {
    func triggerDynamicIslandUpdate() {
        NotificationCenter.default.post(
            name: NSNotification.Name("CompanionEmotionChanged"),
            object: companionEmotionState
        )
    }
}

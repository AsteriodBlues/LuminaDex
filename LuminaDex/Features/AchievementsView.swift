//
//  AchievementsView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//

import SwiftUI

struct AchievementsView: View {
    let viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: AchievementCategory = .collection
    @State private var animateUnlocked = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Neural background
                NeuralNetworkBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header stats
                    achievementStats
                    
                    // Category selector
                    categoryPicker
                    
                    // Achievements grid
                    achievementGrid
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Neural Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Achievement Stats
    private var achievementStats: some View {
        HStack(spacing: 20) {
            AchievementStatCard(
                title: "Unlocked",
                value: "\(unlockedCount)",
                icon: "trophy.fill",
                gradient: [.yellow, .orange]
            )
            
            AchievementStatCard(
                title: "Progress",
                value: String(format: "%.0f%%", achievementProgress),
                icon: "chart.pie.fill",
                gradient: [.blue, .purple]
            )
            
            AchievementStatCard(
                title: "Total",
                value: "\(viewModel.achievements.count)",
                icon: "star.fill",
                gradient: [.green, .teal]
            )
        }
    }
    
    // MARK: - Category Picker
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Achievement Grid
    private var achievementGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredAchievements) { achievement in
                    AchievementCardView(
                        achievement: achievement,
                        animateUnlocked: animateUnlocked
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    private var filteredAchievements: [Achievement] {
        viewModel.achievements.filter { $0.category == selectedCategory }
    }
    
    private var unlockedCount: Int {
        viewModel.achievements.filter(\.isUnlocked).count
    }
    
    private var achievementProgress: Double {
        guard !viewModel.achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(viewModel.achievements.count) * 100
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: AchievementCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? category.color.opacity(0.3) : .clear,
                in: Capsule()
            )
            .overlay(
                Capsule().stroke(
                    isSelected ? category.color : .gray.opacity(0.3),
                    lineWidth: isSelected ? 2 : 1
                )
            )
            .foregroundColor(isSelected ? category.color : .secondary)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Achievement Card
struct AchievementCardView: View {
    let achievement: Achievement
    let animateUnlocked: Bool
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        achievement.category.color.opacity(0.2) :
                        .gray.opacity(0.1)
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(
                        achievement.isUnlocked ?
                        achievement.category.color :
                        .gray
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
            }
            
            // Title
            Text(achievement.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Description
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            // Progress
            if !achievement.isUnlocked {
                VStack(spacing: 4) {
                    HStack {
                        Text("\(achievement.progress)/\(achievement.requirement)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(Double(achievement.progress) / Double(achievement.requirement) * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    
                    ProgressView(value: Double(achievement.progress) / Double(achievement.requirement))
                        .progressViewStyle(LinearProgressViewStyle(tint: achievement.category.color))
                        .scaleEffect(y: 1.5)
                }
            } else {
                Label("Unlocked", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    achievement.isUnlocked ?
                    achievement.category.color.opacity(0.6) :
                    .gray.opacity(0.2),
                    lineWidth: achievement.isUnlocked ? 2 : 1
                )
        )
        .shadow(
            color: achievement.isUnlocked ?
            achievement.category.color.opacity(0.3) :
            .black.opacity(0.1),
            radius: achievement.isUnlocked ? 10 : 5,
            x: 0, y: 2
        )
        .onChange(of: animateUnlocked) { animate in
            if animate && achievement.isUnlocked {
                celebrateUnlock()
            }
        }
    }
    
    private func celebrateUnlock() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            rotation += 360
            scale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.3)) {
                scale = 1.0
            }
        }
    }
}

// MARK: - Supporting Components
extension AchievementCategory {
    var icon: String {
        switch self {
        case .collection: return "brain.head.profile"
        case .types: return "circle.grid.hex"
        case .stats: return "chart.bar"
        case .special: return "star.circle"
        }
    }
}

struct AchievementStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    .linearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.linearGradient(
                    colors: gradient.map { $0.opacity(0.3) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView(viewModel: CollectionViewModel())
    }
}
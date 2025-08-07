//
//  EnhancedAchievementsView.swift
//  LuminaDex
//
//  Polished achievements view with beautiful badges and animations
//

import SwiftUI

struct EnhancedAchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var selectedCategory: LuminaAchievementCategory? = nil
    @State private var showingDetail: LuminaAchievement? = nil
    @State private var searchText = ""
    @State private var sortBy: SortOption = .progress
    @State private var showOnlyUnlocked = false
    @State private var animateBadges = false
    
    enum SortOption: String, CaseIterable {
        case progress = "Progress"
        case alphabetical = "Name"
        case tier = "Tier"
        case category = "Category"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.15),
                        Color.blue.opacity(0.1),
                        Color.green.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stats Header
                    statsHeader
                        .padding()
                    
                    // Search and Filter Bar
                    searchAndFilterBar
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // Category Tabs
                    categoryTabs
                    
                    // Achievements Content
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementBadgeCard(
                                    achievement: achievement,
                                    animateBadge: animateBadges
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        showingDetail = achievement
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: { sortBy = option }) {
                                Label(option.rawValue, systemImage: sortBy == option ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .sheet(item: $showingDetail) { achievement in
                AchievementDetailView(achievement: achievement)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                    animateBadges = true
                }
            }
        }
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        VStack(spacing: 15) {
            // Total Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: totalProgress)
                    .stroke(
                        AngularGradient(
                            colors: [.purple, .blue, .green, .yellow, .orange, .purple],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: totalProgress)
                
                VStack(spacing: 4) {
                    Text("\(Int(totalProgress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Stats Cards
            HStack(spacing: 15) {
                EnhancedStatCard(
                    icon: "trophy.fill",
                    value: "\(unlockedCount)",
                    label: "Unlocked",
                    color: .yellow
                )
                
                EnhancedStatCard(
                    icon: "star.fill",
                    value: "\(achievementManager.totalPoints)",
                    label: "Points",
                    color: .purple
                )
                
                EnhancedStatCard(
                    icon: "crown.fill",
                    value: "\(platinumCount)",
                    label: "Platinum+",
                    color: .cyan
                )
            }
        }
    }
    
    // MARK: - Search and Filter Bar
    private var searchAndFilterBar: some View {
        HStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search achievements...", text: $searchText)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Filter toggle
            Button(action: { showOnlyUnlocked.toggle() }) {
                Image(systemName: showOnlyUnlocked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(showOnlyUnlocked ? .green : .secondary)
                    .font(.title3)
            }
        }
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All category
                CategoryTab(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: .gray,
                    isSelected: selectedCategory == nil,
                    count: achievementManager.achievements.count
                ) {
                    selectedCategory = nil
                }
                
                // Individual categories
                ForEach(LuminaAchievementCategory.allCases, id: \.self) { category in
                    let count = achievementManager.achievements.filter { $0.category == category }.count
                    CategoryTab(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category,
                        count: count
                    ) {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Computed Properties
    private var filteredAchievements: [LuminaAchievement] {
        var filtered = achievementManager.achievements
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by unlock status
        if showOnlyUnlocked {
            filtered = filtered.filter { $0.isUnlocked }
        }
        
        // Sort
        switch sortBy {
        case .progress:
            filtered.sort { $0.progressPercentage > $1.progressPercentage }
        case .alphabetical:
            filtered.sort { $0.title < $1.title }
        case .tier:
            filtered.sort { $0.tier.rawValue > $1.tier.rawValue }
        case .category:
            filtered.sort { $0.category.rawValue < $1.category.rawValue }
        }
        
        return filtered
    }
    
    private var totalProgress: Double {
        guard !achievementManager.achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(achievementManager.achievements.count)
    }
    
    private var unlockedCount: Int {
        achievementManager.achievements.filter { $0.isUnlocked }.count
    }
    
    private var platinumCount: Int {
        achievementManager.achievements.filter { 
            $0.isUnlocked && ($0.tier == .platinum || $0.tier == .diamond)
        }.count
    }
}

// MARK: - Achievement Badge Card
struct AchievementBadgeCard: View {
    let achievement: LuminaAchievement
    let animateBadge: Bool
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Badge Icon
            ZStack {
                // Badge background with tier color
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [
                                achievement.tier.color,
                                achievement.tier.color.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                // Tier border
                if achievement.isUnlocked {
                    Circle()
                        .stroke(
                            achievement.tier.color,
                            lineWidth: 3
                        )
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(
                                    achievement.tier.color.opacity(0.5),
                                    lineWidth: 6
                                )
                                .blur(radius: 4)
                        )
                }
                
                // Icon
                Image(systemName: achievement.icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                // Lock overlay for locked achievements
                if !achievement.isUnlocked && achievement.isSecret {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(Color.black.opacity(0.6)))
                        .offset(x: 25, y: -25)
                }
            }
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .onAppear {
                if animateBadge && achievement.isUnlocked {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        isAnimating = true
                    }
                }
            }
            
            // Achievement Info
            VStack(alignment: .leading, spacing: 6) {
                // Title and tier
                HStack {
                    Text(achievement.isSecret && !achievement.isUnlocked ? "???" : achievement.title)
                        .font(.headline)
                        .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    
                    if achievement.isUnlocked {
                        TierBadge(tier: achievement.tier)
                    }
                    
                    Spacer()
                }
                
                // Description
                Text(achievement.isSecret && !achievement.isUnlocked ? "Hidden achievement" : achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Progress bar
                if !achievement.isUnlocked {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("\(achievement.progress)/\(achievement.requirement)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(achievement.progressPercentage * 100))%")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(achievement.category.color)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                achievement.category.color,
                                                achievement.category.color.opacity(0.6)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * achievement.progressPercentage,
                                        height: 8
                                    )
                                    .animation(.spring(), value: achievement.progressPercentage)
                            }
                        }
                        .frame(height: 8)
                    }
                } else {
                    // Unlocked date and rewards
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        if let date = achievement.unlockedDate {
                            Text("Unlocked \(date, style: .date)")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        // Show first reward
                        if let firstReward = achievement.rewards.first {
                            Text(firstReward)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(achievement.tier.color.opacity(0.2)))
                                .foregroundColor(achievement.tier.color)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: achievement.isUnlocked ? 
                        achievement.tier.color.opacity(0.2) : 
                        .black.opacity(0.1),
                    radius: achievement.isUnlocked ? 8 : 4,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    achievement.isUnlocked ?
                    achievement.tier.color.opacity(0.3) :
                    Color.clear,
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Supporting Views
struct CategoryTab: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected ?
                            color.opacity(0.2) :
                            Color.gray.opacity(0.1)
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? color : .secondary)
                }
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? color : .secondary)
                
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? color : .secondary)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct TierBadge: View {
    let tier: LuminaAchievementTier
    
    var body: some View {
        Text(tier.label)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(tier.color)
                    .overlay(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
            )
            .foregroundColor(.white)
    }
}

struct EnhancedStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Achievement Detail View
struct AchievementDetailView: View {
    let achievement: LuminaAchievement
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Large Badge
                    ZStack {
                        Circle()
                            .fill(
                                achievement.isUnlocked ?
                                LinearGradient(
                                    colors: [
                                        achievement.tier.color,
                                        achievement.tier.color.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150, height: 150)
                        
                        if achievement.isUnlocked {
                            Circle()
                                .stroke(achievement.tier.color, lineWidth: 4)
                                .frame(width: 150, height: 150)
                        }
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    }
                    .scaleEffect(showConfetti ? 1.1 : 1.0)
                    .animation(.spring(), value: showConfetti)
                    
                    // Title and Tier
                    VStack(spacing: 8) {
                        Text(achievement.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        TierBadge(tier: achievement.tier)
                    }
                    
                    // Description
                    Text(achievement.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Progress
                    if !achievement.isUnlocked {
                        VStack(spacing: 8) {
                            Text("Progress")
                                .font(.headline)
                            
                            Text("\(achievement.progress) / \(achievement.requirement)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(achievement.category.color)
                            
                            ProgressView(value: achievement.progressPercentage)
                                .progressViewStyle(LinearProgressViewStyle(tint: achievement.category.color))
                                .frame(width: 200)
                                .scaleEffect(y: 2)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                    
                    // Rewards
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rewards")
                            .font(.headline)
                        
                        ForEach(achievement.rewards, id: \.self) { reward in
                            HStack {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(achievement.tier.color)
                                
                                Text(reward)
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(achievement.tier.color.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Unlock Date
                    if let date = achievement.unlockedDate {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.green)
                            
                            Text("Unlocked on \(date, style: .date)")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if achievement.isUnlocked {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = true
                }
            }
        }
    }
}
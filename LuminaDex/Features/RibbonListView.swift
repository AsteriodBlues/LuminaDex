//
//  RibbonListView.swift
//  LuminaDex
//
//  Modern ribbon collection view with fluid animations
//

import SwiftUI

struct RibbonListView: View {
    @State private var searchText = ""
    @State private var selectedCategory: RibbonCategory?
    @State private var selectedRarity: RibbonRarity?
    @State private var ribbons = RibbonCollection.allRibbons
    @State private var filteredRibbons: [Ribbon] = []
    @State private var isLoading = false
    @State private var showingDetail = false
    @State private var selectedRibbon: Ribbon?
    @State private var animateCards = false
    @State private var earnedRibbons: Set<String> = []
    
    @Namespace private var ribbonNamespace
    
    // Grid configuration
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.02, green: 0.02, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Header
                    progressHeader
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Category Filter
                    categoryFilter
                        .padding(.vertical, 12)
                    
                    // Rarity Filter
                    rarityFilter
                        .padding(.bottom, 12)
                    
                    // Ribbon Grid
                    ScrollView {
                        if isLoading {
                            loadingView
                        } else {
                            ribbonGrid
                        }
                    }
                }
            }
            .navigationTitle("Ribbons")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search ribbons...")
            .onChange(of: searchText) { _ in filterRibbons() }
            .onChange(of: selectedCategory) { _ in filterRibbons() }
            .onChange(of: selectedRarity) { _ in filterRibbons() }
            .onAppear {
                filterRibbons()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateCards = true
                }
                loadEarnedRibbons()
            }
        }
        .sheet(item: $selectedRibbon) { ribbon in
            RibbonDetailView(ribbon: ribbon, isEarned: earnedRibbons.contains(ribbon.id))
        }
    }
    
    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: 12) {
            progressSummaryCard
            categoryStatsCard
        }
    }
    
    private var progressSummaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Collection Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(progressText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            progressRing
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var progressText: String {
        "\(earnedRibbons.count) of \(ribbons.count) ribbons collected"
    }
    
    private var progressPercentage: Int {
        guard ribbons.count > 0 else { return 0 }
        return Int(Double(earnedRibbons.count) / Double(ribbons.count) * 100)
    }
    
    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: progressRingValue)
                .stroke(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 60, height: 60)
            
            Text("\(progressPercentage)%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var progressRingValue: CGFloat {
        guard ribbons.count > 0 else { return 0 }
        return CGFloat(earnedRibbons.count) / CGFloat(ribbons.count)
    }
    
    private var categoryStatsCard: some View {
        HStack(spacing: 16) {
            ForEach(RibbonCategory.allCases.prefix(4), id: \.self) { category in
                CategoryStatView(
                    category: category,
                    count: categoryCount(for: category)
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func categoryCount(for category: RibbonCategory) -> Int {
        ribbons.filter { $0.category == category && earnedRibbons.contains($0.id) }.count
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Categories
                RibbonFilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: .gray
                ) {
                    selectedCategory = nil
                }
                
                ForEach(RibbonCategory.allCases, id: \.self) { category in
                    RibbonFilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        color: category.color,
                        icon: category.icon
                    ) {
                        withAnimation(.spring()) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Rarity Filter
    private var rarityFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Rarities
                RibbonFilterChip(
                    title: "All Rarities",
                    isSelected: selectedRarity == nil,
                    color: .gray
                ) {
                    selectedRarity = nil
                }
                
                ForEach(RibbonRarity.allCases, id: \.self) { rarity in
                    RibbonFilterChip(
                        title: rarity.title,
                        isSelected: selectedRarity == rarity,
                        color: rarity.color,
                        sparkles: rarity.sparkleCount
                    ) {
                        withAnimation(.spring()) {
                            selectedRarity = selectedRarity == rarity ? nil : rarity
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Ribbon Grid
    private var ribbonGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(filteredRibbons.enumerated()), id: \.element.id) { index, ribbon in
                RibbonCard(
                    ribbon: ribbon,
                    isEarned: earnedRibbons.contains(ribbon.id),
                    namespace: ribbonNamespace
                )
                .scaleEffect(animateCards ? 1 : 0.8)
                .opacity(animateCards ? 1 : 0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.8)
                    .delay(Double(index) * 0.02),
                    value: animateCards
                )
                .onTapGesture {
                    HapticManager.impact(style: .light)
                    selectedRibbon = ribbon
                }
                .contextMenu {
                    Button(action: {
                        toggleEarned(ribbon)
                    }) {
                        Label(
                            earnedRibbons.contains(ribbon.id) ? "Mark as Not Earned" : "Mark as Earned",
                            systemImage: earnedRibbons.contains(ribbon.id) ? "checkmark.circle.fill" : "circle"
                        )
                    }
                    
                    Button(action: {
                        selectedRibbon = ribbon
                    }) {
                        Label("View Details", systemImage: "info.circle")
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading ribbons...")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Helper Methods
    private func filterRibbons() {
        var filtered = ribbons
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { ribbon in
                ribbon.name.localizedCaseInsensitiveContains(searchText) ||
                ribbon.description.localizedCaseInsensitiveContains(searchText) ||
                ribbon.requirements.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Rarity filter
        if let rarity = selectedRarity {
            filtered = filtered.filter { $0.rarity == rarity }
        }
        
        filteredRibbons = filtered
    }
    
    private func toggleEarned(_ ribbon: Ribbon) {
        withAnimation(.spring()) {
            if earnedRibbons.contains(ribbon.id) {
                earnedRibbons.remove(ribbon.id)
            } else {
                earnedRibbons.insert(ribbon.id)
                HapticManager.notification(type: .success)
            }
            saveEarnedRibbons()
        }
    }
    
    private func loadEarnedRibbons() {
        if let saved = UserDefaults.standard.array(forKey: "earnedRibbons") as? [String] {
            earnedRibbons = Set(saved)
        }
    }
    
    private func saveEarnedRibbons() {
        UserDefaults.standard.set(Array(earnedRibbons), forKey: "earnedRibbons")
    }
}

// MARK: - Ribbon Card
struct RibbonCard: View {
    let ribbon: Ribbon
    let isEarned: Bool
    let namespace: Namespace.ID
    
    @State private var isHovered = false
    @State private var sparkleAnimation = false
    
    var backgroundGradient: some View {
        Circle()
            .fill(ribbon.category.gradient)
            .frame(width: 70, height: 70)
            .blur(radius: 20)
            .opacity(0.5)
    }
    
    var radialBackground: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        ribbon.category.color.opacity(0.3),
                        ribbon.category.color.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 40
                )
            )
            .frame(width: 80, height: 80)
    }
    
    var earnedCheckmark: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 20, height: 20)
            .overlay(
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            )
            .offset(x: 25, y: -25)
    }
    
    var rarityStars: some View {
        HStack(spacing: 2) {
            ForEach(0..<ribbon.rarity.rawValue, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 6))
                    .foregroundColor(ribbon.rarity.color)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Ribbon Icon/Image
            ZStack {
                // Background layers
                backgroundGradient
                radialBackground
                
                // Try to show real ribbon image, fallback to rosette design
                if let imageURL = ribbon.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .scaleEffect(isHovered ? 1.1 : 1.0)
                        case .failure(_):
                            // Fallback to rosette on error
                            RibbonRosette(
                                category: ribbon.category,
                                rarity: ribbon.rarity,
                                isEarned: isEarned
                            )
                            .frame(width: 60, height: 60)
                            .scaleEffect(isHovered ? 1.1 : 1.0)
                        case .empty:
                            // Loading state
                            ProgressView()
                                .scaleEffect(0.5)
                        @unknown default:
                            RibbonRosette(
                                category: ribbon.category,
                                rarity: ribbon.rarity,
                                isEarned: isEarned
                            )
                            .frame(width: 60, height: 60)
                        }
                    }
                } else {
                    // Use rosette design if no URL
                    RibbonRosette(
                        category: ribbon.category,
                        rarity: ribbon.rarity,
                        isEarned: isEarned
                    )
                    .frame(width: 60, height: 60)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                }
                
                // Earned checkmark
                if isEarned {
                    earnedCheckmark
                }
                
                // Sparkles for rare ribbons
                if ribbon.rarity.rawValue >= 3 {
                    RibbonSparkles(rarity: ribbon.rarity, sparkleAnimation: sparkleAnimation)
                }
            }
            .frame(width: 80, height: 80)
            
            // Ribbon Info
            VStack(spacing: 2) {
                Text(ribbon.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                rarityStars
            }
        }
        .frame(width: 100, height: 140)
        .background(
            RibbonCardBackground(isEarned: isEarned, categoryColor: ribbon.category.color)
        )
        .opacity(isEarned ? 1 : 0.7)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovered = hovering
            }
        }
        .onAppear {
            sparkleAnimation = true
        }
    }
}

// MARK: - Ribbon Card Background
struct RibbonCardBackground: View {
    let isEarned: Bool
    let categoryColor: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                isEarned ?
                    AnyShapeStyle(.ultraThinMaterial) :
                    AnyShapeStyle(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isEarned ?
                            categoryColor.opacity(0.5) :
                            Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Ribbon Sparkles
struct RibbonSparkles: View {
    let rarity: RibbonRarity
    let sparkleAnimation: Bool
    
    var body: some View {
        ForEach(0..<rarity.sparkleCount, id: \.self) { index in
            RibbonSparkleView()
                .position(
                    x: 40 + cos(CGFloat(index) * .pi * 2 / CGFloat(rarity.sparkleCount)) * 35,
                    y: 40 + sin(CGFloat(index) * .pi * 2 / CGFloat(rarity.sparkleCount)) * 35
                )
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.2),
                    value: sparkleAnimation
                )
        }
    }
}

// MARK: - Ribbon Rosette Design
struct RibbonRosette: View {
    let category: RibbonCategory
    let rarity: RibbonRarity
    let isEarned: Bool
    
    @State private var shimmerAnimation = false
    
    var body: some View {
        ZStack {
            // Background glow for rare ribbons
            if rarity.rawValue >= 3 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                rarity.color.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .blur(radius: 5)
                    .scaleEffect(shimmerAnimation ? 1.2 : 1.0)
            }
            
            // Decorative outer petals
            ForEach(0..<12) { index in
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                category.color.opacity(0.8),
                                category.color.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 16)
                    .offset(y: -22)
                    .rotationEffect(.degrees(Double(index) * 30))
            }
            
            // Main ribbon body
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            category.color.opacity(0.9),
                            category.color.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 45, height: 45)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
            
            // Inner decorative ring
            ForEach(0..<8) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                rarity.color,
                                rarity.color.opacity(0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2, height: 12)
                    .offset(y: -12)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            
            // Center jewel
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            rarity.color,
                            rarity.color.opacity(0.5)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 12
                    )
                )
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    rarity.color.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: rarity.color.opacity(0.5), radius: 2)
            
            // Category icon in center
            Image(systemName: category.icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1)
        }
        .opacity(isEarned ? 1 : 0.6)
        .onAppear {
            if rarity.rawValue >= 3 {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                ) {
                    shimmerAnimation = true
                }
            }
        }
    }
}

// MARK: - Category Stat View
struct CategoryStatView: View {
    let category: RibbonCategory
    let count: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(category.color)
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(category.rawValue)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Ribbon Sparkle View
struct RibbonSparkleView: View {
    @State private var opacity: Double = 0
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 8))
            .foregroundColor(.yellow)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1...2))
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = Double.random(in: 0.3...1.0)
                }
            }
    }
}

// MARK: - Ribbon Filter Chip
struct RibbonFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    var icon: String? = nil
    var sparkles: Int = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if sparkles > 0 {
                    ForEach(0..<sparkles, id: \.self) { _ in
                        Image(systemName: "sparkle")
                            .font(.system(size: 6))
                    }
                }
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
            )
        }
    }
}
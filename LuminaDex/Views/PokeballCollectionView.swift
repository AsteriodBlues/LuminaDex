//
//  PokeballCollectionView.swift
//  LuminaDex
//
//  Interactive Pokeball Collection Display
//

import SwiftUI

struct PokeballCollectionView: View {
    @State private var selectedCategory: Pokeball.PokeballCategory? = nil
    @State private var selectedPokeball: Pokeball? = nil
    @State private var showingDetail = false
    @State private var searchText = ""
    @State private var sortBy: SortOption = .catchRate
    @State private var animateCards = false
    
    private let database = PokeballDatabase.shared
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    enum SortOption: String, CaseIterable {
        case catchRate = "Catch Rate"
        case name = "Name"
        case cost = "Cost"
        case generation = "Generation"
        
        var icon: String {
            switch self {
            case .catchRate: return "percent"
            case .name: return "textformat.abc"
            case .cost: return "dollarsign.circle"
            case .generation: return "clock"
            }
        }
    }
    
    var filteredPokeballs: [Pokeball] {
        var balls = database.allPokeballs
        
        // Filter by category
        if let category = selectedCategory {
            balls = balls.filter { $0.category == category }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            balls = database.searchPokeballs(query: searchText)
        }
        
        // Sort
        switch sortBy {
        case .catchRate:
            balls.sort { $0.catchRateMultiplier > $1.catchRateMultiplier }
        case .name:
            balls.sort { $0.displayName < $1.displayName }
        case .cost:
            balls.sort { $0.cost > $1.cost }
        case .generation:
            balls.sort { $0.introduction < $1.introduction }
        }
        
        return balls
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                    
                    // Category Filter
                    categoryFilter
                    
                    // Stats Header
                    statsHeader
                    
                    // Collection Grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(filteredPokeballs.enumerated()), id: \.element.id) { index, pokeball in
                                PokeballCard(
                                    pokeball: pokeball,
                                    delay: Double(index) * 0.05
                                )
                                .onTapGesture {
                                    selectedPokeball = pokeball
                                    showingDetail = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Pokéball Collection")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: { sortBy = option }) {
                                Label(option.rawValue, systemImage: option.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let pokeball = selectedPokeball {
                PokeballDetailView(pokeball: pokeball)
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search Pokéballs...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Categories
                PokeballCategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: .gray,
                    isSelected: selectedCategory == nil,
                    action: {
                        withAnimation(.spring()) {
                            selectedCategory = nil
                        }
                    }
                )
                
                // Individual Categories
                ForEach(Pokeball.PokeballCategory.allCases, id: \.self) { category in
                    PokeballCategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category,
                        action: {
                            withAnimation(.spring()) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: 20) {
            StatBadge(
                title: "Total",
                value: "\(filteredPokeballs.count)",
                color: .blue
            )
            
            StatBadge(
                title: "Special",
                value: "\(filteredPokeballs.filter { $0.isSpecial }.count)",
                color: .purple
            )
            
            StatBadge(
                title: "Categories",
                value: "\(Set(filteredPokeballs.map { $0.category }).count)",
                color: .green
            )
            
            if let best = filteredPokeballs.max(by: { $0.catchRateMultiplier < $1.catchRateMultiplier }) {
                StatBadge(
                    title: "Best",
                    value: best.displayName,
                    color: .orange
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Pokeball Card
struct PokeballCard: View {
    let pokeball: Pokeball
    let delay: Double
    @State private var isAnimated = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Pokeball Image
            ZStack {
                // Glow effect for special balls
                if pokeball.isSpecial {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    pokeball.color.opacity(0.5),
                                    pokeball.color.opacity(0.2),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                }
                
                AsyncImage(url: URL(string: pokeball.spriteURL)) { image in
                    image
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                } placeholder: {
                    Circle()
                        .fill(pokeball.color.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .tint(pokeball.color)
                        )
                }
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isPressed ? 360 : 0))
                .scaleEffect(isPressed ? 1.2 : 1.0)
            }
            .frame(height: 80)
            
            // Info
            VStack(spacing: 6) {
                Text(pokeball.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Catch Rate
                HStack(spacing: 4) {
                    Image(systemName: "percent")
                        .font(.system(size: 10))
                    Text("\(pokeball.catchRateMultiplier, specifier: "%.1f")×")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(pokeball.color)
                
                // Category Badge
                Text(pokeball.category.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(pokeball.category.color)
                    )
                
                // Price
                if pokeball.cost > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 10))
                        Text("\(pokeball.cost)")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.gray)
                } else {
                    Text("Special")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.purple)
                }
            }
            
            // Special Indicator
            if pokeball.isSpecial {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                    Text("SPECIAL")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundColor(.yellow)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(
                    color: pokeball.isSpecial ? pokeball.color.opacity(0.3) : .black.opacity(0.1),
                    radius: pokeball.isSpecial ? 10 : 5,
                    y: 2
                )
        )
        .scaleEffect(isAnimated ? 1.0 : 0.8)
        .opacity(isAnimated ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring().delay(delay)) {
                isAnimated = true
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPressed = false
            }
        }
    }
}

// MARK: - Pokeball Detail View
struct PokeballDetailView: View {
    let pokeball: Pokeball
    @Environment(\.dismiss) private var dismiss
    @State private var animateStats = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    heroSection
                    
                    // Stats Cards
                    statsSection
                    
                    // Description
                    descriptionCard
                    
                    // Conditions
                    if !pokeball.conditions.isEmpty {
                        conditionsCard
                    }
                    
                    // Effectiveness Chart
                    effectivenessChart
                }
                .padding()
            }
            .navigationTitle(pokeball.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            withAnimation(.spring().delay(0.2)) {
                animateStats = true
            }
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            // Large Pokeball Image
            ZStack {
                // Animated background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                pokeball.color.opacity(0.3),
                                pokeball.color.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                
                AsyncImage(url: URL(string: pokeball.spriteURL)) { image in
                    image
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 120, height: 120)
            }
            
            // Category and Generation
            HStack(spacing: 16) {
                Label(pokeball.category.rawValue, systemImage: pokeball.category.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(pokeball.category.color)
                
                Text("•")
                    .foregroundColor(.gray)
                
                Text(pokeball.introduction)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // Rarity Badge
            Text(pokeball.rarityLevel)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                PokeballStatCard(
                    title: "Catch Rate",
                    value: "\(pokeball.catchRateMultiplier)×",
                    subtitle: pokeball.effectivenessDescription,
                    color: .green
                )
                
                PokeballStatCard(
                    title: "Success",
                    value: pokeball.successRate,
                    subtitle: "Estimated",
                    color: .blue
                )
            }
            
            HStack(spacing: 16) {
                PokeballStatCard(
                    title: "Cost",
                    value: pokeball.cost > 0 ? "¥\(pokeball.cost)" : "N/A",
                    subtitle: pokeball.priceCategory,
                    color: .orange
                )
                
                PokeballStatCard(
                    title: "Sell Price",
                    value: pokeball.sellPrice > 0 ? "¥\(pokeball.sellPrice)" : "N/A",
                    subtitle: "50% of cost",
                    color: .purple
                )
            }
        }
        .opacity(animateStats ? 1 : 0)
        .offset(y: animateStats ? 0 : 20)
    }
    
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Description", systemImage: "text.alignleft")
                .font(.headline)
            
            Text(pokeball.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            Text("Effect")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
            
            Text(pokeball.effect)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(pokeball.color)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private var conditionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Special Conditions", systemImage: "exclamationmark.triangle")
                .font(.headline)
            
            ForEach(pokeball.conditions, id: \.self) { condition in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                        .padding(.top, 2)
                    
                    Text(condition)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(pokeball.color.opacity(0.1))
        )
    }
    
    private var effectivenessChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Effectiveness Comparison", systemImage: "chart.bar")
                .font(.headline)
            
            // Comparison bars
            VStack(spacing: 8) {
                EffectivenessBar(
                    name: pokeball.displayName,
                    multiplier: pokeball.catchRateMultiplier,
                    color: pokeball.color,
                    isHighlighted: true
                )
                
                EffectivenessBar(
                    name: "Poké Ball",
                    multiplier: 1.0,
                    color: .red,
                    isHighlighted: false
                )
                
                EffectivenessBar(
                    name: "Great Ball",
                    multiplier: 1.5,
                    color: .blue,
                    isHighlighted: false
                )
                
                EffectivenessBar(
                    name: "Ultra Ball",
                    multiplier: 2.0,
                    color: .yellow,
                    isHighlighted: false
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Supporting Views
struct PokeballCategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.15))
            )
        }
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PokeballStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct EffectivenessBar: View {
    let name: String
    let multiplier: Double
    let color: Color
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 12, weight: isHighlighted ? .semibold : .regular))
                .foregroundColor(isHighlighted ? color : .gray)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHighlighted ? color : color.opacity(0.6))
                        .frame(
                            width: min(geometry.size.width * (min(multiplier, 5.0) / 5.0), geometry.size.width),
                            height: 20
                        )
                }
            }
            .frame(height: 20)
            
            Text("\(multiplier, specifier: "%.1f")×")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isHighlighted ? color : .gray)
                .frame(width: 40, alignment: .trailing)
        }
    }
}
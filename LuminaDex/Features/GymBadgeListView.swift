//
//  GymBadgeListView.swift
//  LuminaDex
//
//  Gym Badge collection view with region filtering
//

import SwiftUI

struct GymBadgeListView: View {
    @State private var selectedRegion: GymBadge.Region = .kanto
    @State private var earnedBadges: Set<String> = []
    @State private var showingAllBadges = false
    @AppStorage("earnedBadges") private var earnedBadgesData: Data = Data()
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]
    
    private var progressPercentage: Int {
        let total = GymBadgeDatabase.allBadges.count
        guard total > 0 else { return 0 }
        return Int((Double(earnedBadges.count) / Double(total)) * 100)
    }
    
    private var progressValue: CGFloat {
        let total = GymBadgeDatabase.allBadges.count
        guard total > 0 else { return 0 }
        return CGFloat(earnedBadges.count) / CGFloat(total)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.05, green: 0.05, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Overview
                    progressHeader
                    
                    // Region Selector
                    regionSelector
                    
                    // Badge Grid
                    ScrollView {
                        badgeGrid
                    }
                }
            }
            .navigationTitle("Gym Badges")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAllBadges.toggle() }) {
                        Image(systemName: showingAllBadges ? "square.grid.2x2" : "square.grid.3x3")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            loadEarnedBadges()
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 12) {
            // Overall Progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Progress")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(earnedBadges.count) / \(GymBadgeDatabase.allBadges.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(
                            LinearGradient(
                                colors: [selectedRegion.color, selectedRegion.color.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: earnedBadges.count)
                    
                    Text("\(progressPercentage)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Region Progress
            if !showingAllBadges {
                let regionBadges = GymBadgeDatabase.getBadgesByRegion(selectedRegion)
                let regionEarned = regionBadges.filter { earnedBadges.contains($0.id) }.count
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(selectedRegion.color)
                    
                    Text("\(selectedRegion.displayName): \(regionEarned)/\(regionBadges.count) Badges")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if regionEarned == regionBadges.count {
                        Label("Complete!", systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(selectedRegion.color.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private var regionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: { showingAllBadges = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.title2)
                        Text("All")
                            .font(.caption)
                    }
                    .foregroundColor(showingAllBadges ? .white : .gray)
                    .frame(width: 60, height: 60)
                    .background(showingAllBadges ? Color.white.opacity(0.2) : Color.clear)
                    .cornerRadius(12)
                }
                
                ForEach(GymBadge.Region.allCases, id: \.self) { region in
                    Button(action: {
                        selectedRegion = region
                        showingAllBadges = false
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: regionIcon(for: region))
                                .font(.title2)
                            Text(region.displayName)
                                .font(.caption)
                        }
                        .foregroundColor(!showingAllBadges && selectedRegion == region ? .white : region.color)
                        .frame(width: 60, height: 60)
                        .background(
                            !showingAllBadges && selectedRegion == region ?
                            region.color.opacity(0.3) : Color.clear
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(region.color, lineWidth: !showingAllBadges && selectedRegion == region ? 2 : 0)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
    }
    
    private var badgeGrid: some View {
        let badges = showingAllBadges ? 
            GymBadgeDatabase.allBadges : 
            GymBadgeDatabase.getBadgesByRegion(selectedRegion)
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(badges) { badge in
                NavigationLink(destination: GymBadgeDetailView(badge: badge, isEarned: earnedBadges.contains(badge.id))) {
                    BadgeCardView(
                        badge: badge,
                        isEarned: earnedBadges.contains(badge.id),
                        onToggle: { toggleBadge(badge.id) }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
    
    private func regionIcon(for region: GymBadge.Region) -> String {
        switch region {
        case .kanto: return "1.circle"
        case .johto: return "2.circle"
        case .hoenn: return "3.circle"
        case .sinnoh: return "4.circle"
        case .unova: return "5.circle"
        case .kalos: return "6.circle"
        case .alola: return "7.circle"
        case .galar: return "8.circle"
        case .paldea: return "9.circle"
        }
    }
    
    private func toggleBadge(_ id: String) {
        withAnimation(.spring()) {
            if earnedBadges.contains(id) {
                earnedBadges.remove(id)
            } else {
                earnedBadges.insert(id)
            }
            saveEarnedBadges()
        }
    }
    
    private func saveEarnedBadges() {
        if let encoded = try? JSONEncoder().encode(Array(earnedBadges)) {
            earnedBadgesData = encoded
        }
    }
    
    private func loadEarnedBadges() {
        if let decoded = try? JSONDecoder().decode([String].self, from: earnedBadgesData) {
            earnedBadges = Set(decoded)
        }
    }
}

struct BadgeCardView: View {
    let badge: GymBadge
    let isEarned: Bool
    let onToggle: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Badge Image
            ZStack {
                // Badge background glow
                if isEarned {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [badge.type.color.opacity(0.5), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                }
                
                // Badge icon placeholder (using SF Symbol)
                Image(systemName: badgeIcon)
                    .font(.system(size: 40))
                    .foregroundColor(isEarned ? badge.type.color : .gray)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(isEarned ? 0.2 : 0.05))
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                isEarned ? badge.type.color : Color.gray.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // Earned checkmark
                if isEarned {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .background(Circle().fill(Color.black.opacity(0.7)))
                        .offset(x: 25, y: -25)
                }
            }
            
            // Badge name
            Text(badge.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isEarned ? .white : .gray)
                .lineLimit(1)
            
            // Gym Leader
            Text(badge.gymLeader)
                .font(.system(size: 10))
                .foregroundColor(isEarned ? badge.type.color : .gray)
        }
        .frame(width: 100, height: 130)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isEarned ? 0.1 : 0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isEarned ? badge.type.color.opacity(0.5) : Color.gray.opacity(0.2),
                    lineWidth: 1
                )
        )
        .onTapGesture {
            // Handle tap for navigation
        }
        .onLongPressGesture(
            minimumDuration: 0.5,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {
                onToggle()
            }
        )
    }
    
    private var badgeIcon: String {
        switch badge.type {
        case .rock: return "mountain.2.fill"
        case .water: return "drop.fill"
        case .electric: return "bolt.fill"
        case .grass: return "leaf.fill"
        case .poison: return "smoke.fill"
        case .psychic: return "brain"
        case .fire: return "flame.fill"
        case .ground: return "globe.americas.fill"
        case .flying: return "wind"
        case .bug: return "ant.fill"
        case .normal: return "circle.fill"
        case .ghost: return "eye.trianglebadge.exclamationmark"
        case .fighting: return "figure.boxing"
        case .steel: return "shield.fill"
        case .ice: return "snowflake"
        case .dragon: return "sparkles"
        case .dark: return "moon.fill"
        case .fairy: return "star.fill"
        default: return "questionmark.circle"
        }
    }
}
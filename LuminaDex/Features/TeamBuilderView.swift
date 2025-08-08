//
//  TeamBuilderView.swift
//  LuminaDex
//
//  Modern, fluid team builder interface with drag-and-drop
//

import SwiftUI
import UniformTypeIdentifiers

struct TeamBuilderView: View {
    @StateObject private var viewModel = TeamBuilderViewModel()
    @StateObject private var analysisEngine = TeamAnalysisEngine.shared
    @State private var selectedTab = 0
    @State private var showingPokemonPicker = false
    @State private var selectedSlot: Int?
    @State private var draggedPokemon: TeamMember?
    @State private var showAnalysis = false
    @State private var animateEntry = false
    @Namespace private var animation
    
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
                    // Custom Tab Bar
                    customTabBar
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        teamBuilderContent
                            .tag(0)
                        
                        analysisContent
                            .tag(1)
                        
                        suggestionsContent
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Team Builder")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.saveTeam() }) {
                            Label("Save Team", systemImage: "square.and.arrow.down")
                        }
                        
                        Button(action: { viewModel.shareTeam() }) {
                            Label("Share Team", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { viewModel.loadTemplate() }) {
                            Label("Load Template", systemImage: "doc.text")
                        }
                        
                        Button(action: { viewModel.clearTeam() }) {
                            Label("Clear Team", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingPokemonPicker) {
            PokemonPickerSheet(
                selectedSlot: selectedSlot,
                onSelect: { pokemon in
                    viewModel.addPokemon(pokemon, at: selectedSlot)
                    showingPokemonPicker = false
                }
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateEntry = true
            }
        }
    }
    
    // MARK: - Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                tabButton(
                    title: ["Builder", "Analysis", "Optimize"][index],
                    icon: ["square.grid.3x2.fill", "chart.pie.fill", "sparkles"][index],
                    tag: index
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Color.black.opacity(0.3)
                .background(.ultraThinMaterial)
        )
    }
    
    private func tabButton(title: String, icon: String, tag: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = tag
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(selectedTab == tag ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                selectedTab == tag ?
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .matchedGeometryEffect(id: "tab", in: animation)
                    : nil
            )
        }
    }
    
    // MARK: - Team Builder Content
    private var teamBuilderContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Team Name Input
                teamNameSection
                
                // Team Slots Grid
                teamSlotsGrid
                
                // Quick Stats
                if !viewModel.team.members.isEmpty {
                    quickStatsSection
                }
                
                // Team Actions
                teamActionsSection
            }
            .padding()
        }
    }
    
    private var teamNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team Name")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            TextField("Enter team name", text: $viewModel.team.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        }
        .opacity(animateEntry ? 1 : 0)
        .offset(y: animateEntry ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateEntry)
    }
    
    private var teamSlotsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(0..<6) { index in
                TeamSlotCard(
                    member: index < viewModel.team.members.count ? viewModel.team.members[index] : nil,
                    slotNumber: index + 1,
                    isAnimating: animateEntry
                )
                .onTapGesture {
                    selectedSlot = index
                    showingPokemonPicker = true
                    HapticManager.impact(style: .light)
                }
                .onDrop(of: [.text], isTargeted: nil) { providers in
                    handleDrop(at: index, providers: providers)
                }
                .onDrag {
                    if index < viewModel.team.members.count {
                        draggedPokemon = viewModel.team.members[index]
                        return NSItemProvider(object: String(index) as NSString)
                    }
                    return NSItemProvider()
                }
                .opacity(animateEntry ? 1 : 0)
                .scaleEffect(animateEntry ? 1 : 0.8)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                    .delay(Double(index) * 0.05 + 0.2),
                    value: animateEntry
                )
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Analysis")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                QuickStatCard(
                    title: "Coverage",
                    value: "\(Int(viewModel.team.typeEffectiveness.synergyScore))%",
                    icon: "shield.fill",
                    color: .blue
                )
                
                QuickStatCard(
                    title: "Balance",
                    value: viewModel.getBalanceText(),
                    icon: "scalemass.fill",
                    color: .green
                )
                
                QuickStatCard(
                    title: "Speed",
                    value: "\(viewModel.getAverageSpeed())",
                    icon: "hare.fill",
                    color: .orange
                )
            }
        }
        .opacity(animateEntry ? 1 : 0)
        .offset(y: animateEntry ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateEntry)
    }
    
    private var teamActionsSection: some View {
        HStack(spacing: 12) {
            TeamActionButton(
                title: "Analyze",
                icon: "chart.bar.fill",
                gradient: [.blue, .cyan]
            ) {
                withAnimation {
                    selectedTab = 1
                }
                Task {
                    await analysisEngine.analyzeTeam(viewModel.team)
                }
            }
            
            TeamActionButton(
                title: "Optimize",
                icon: "wand.and.stars",
                gradient: [.purple, .pink]
            ) {
                withAnimation {
                    selectedTab = 2
                }
            }
            
            TeamActionButton(
                title: "Export",
                icon: "square.and.arrow.up",
                gradient: [.green, .mint]
            ) {
                viewModel.exportTeam()
            }
        }
        .opacity(animateEntry ? 1 : 0)
        .offset(y: animateEntry ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: animateEntry)
    }
    
    // MARK: - Analysis Content
    private var analysisContent: some View {
        ScrollView {
            if let analysis = analysisEngine.currentAnalysis {
                VStack(spacing: 20) {
                    // Overall Score
                    OverallScoreCard(score: analysis.overallScore)
                    
                    // Type Coverage Matrix
                    TypeCoverageMatrix(
                        offensive: analysis.typeEffectiveness.offensiveCoverage,
                        defensive: analysis.typeEffectiveness.defensiveCoverage
                    )
                    
                    // Speed Tiers Chart
                    SpeedTiersChart(speedAnalysis: analysis.speedAnalysis)
                    
                    // Role Distribution
                    RoleDistributionChart(distribution: analysis.roleDistribution)
                    
                    // Strengths & Weaknesses
                    StrengthsWeaknessesCard(
                        strengths: analysis.strengths,
                        weaknesses: analysis.weaknesses
                    )
                }
                .padding()
            } else {
                EmptyAnalysisView()
            }
        }
    }
    
    // MARK: - Suggestions Content
    private var suggestionsContent: some View {
        ScrollView {
            if !analysisEngine.suggestions.isEmpty {
                VStack(spacing: 16) {
                    ForEach(analysisEngine.suggestions) { suggestion in
                        SuggestionCard(suggestion: suggestion) {
                            viewModel.applySuggestion(suggestion)
                        }
                    }
                }
                .padding()
            } else {
                EmptySuggestionsView()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func handleDrop(at index: Int, providers: [NSItemProvider]) -> Bool {
        guard let draggedPokemon = draggedPokemon else { return false }
        
        providers.first?.loadObject(ofClass: NSString.self) { item, _ in
            if let sourceIndexString = item as? String,
               let sourceIndex = Int(sourceIndexString) {
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.swapPokemon(from: sourceIndex, to: index)
                    }
                }
            }
        }
        
        return true
    }
}

// MARK: - Supporting Views
struct TeamSlotCard: View {
    let member: TeamMember?
    let slotNumber: Int
    let isAnimating: Bool
    @State private var isHovered = false
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    member != nil ?
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.2),
                                Color.purple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            member != nil ?
                                LinearGradient(
                                    colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.gray.opacity(0.3), .gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: 2
                        )
                )
            
            if let member = member, let pokemon = member.pokemon {
                VStack(spacing: 8) {
                    // Pokemon Sprite
                    AsyncImage(url: URL(string: pokemon.sprites.frontDefault ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    
                    // Pokemon Name
                    Text(pokemon.name.capitalized)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // Types
                    HStack(spacing: 4) {
                        ForEach(pokemon.types, id: \.self) { typeSlot in
                            TeamTypeBadge(type: typeSlot.pokemonType, size: .small)
                        }
                    }
                    
                    // Role Badge
                    Text(member.role.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(member.role.color.opacity(0.8))
                        )
                }
                .padding()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                        .scaleEffect(isPulsing ? 1.1 : 1.0)
                    
                    Text("Slot \(slotNumber)")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .padding()
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
            }
        }
        .frame(height: 180)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct TeamActionButton: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Haptic Manager
struct HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

// MARK: - Preview
struct TeamBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        TeamBuilderView()
            .preferredColorScheme(.dark)
    }
}
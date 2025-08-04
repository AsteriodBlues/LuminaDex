//
//  InteractiveChartSystem.swift
//  LuminaDex
//
//  Day 21 Evening: Chart Interactions - Tap for details, Pinch to zoom, Pan to scroll
//

import SwiftUI

// MARK: - Interactive Chart Container
struct InteractiveChartContainer<Content: View>: View {
    let content: Content
    let pokemon: Pokemon
    let onDetailTap: ((String, CGPoint) -> Void)?
    
    @State private var currentZoom: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showDetailPopover: Bool = false
    @State private var detailInfo: ChartDetailInfo? = nil
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    @State private var longPressLocation: CGPoint = .zero
    @State private var isLongPressing: Bool = false
    
    private let minZoom: CGFloat = 0.5
    private let maxZoom: CGFloat = 3.0
    
    init(pokemon: Pokemon, onDetailTap: ((String, CGPoint) -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.pokemon = pokemon
        self.onDetailTap = onDetailTap
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Main chart content with interactions
            content
                .scaleEffect(currentZoom)
                .offset(currentOffset)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: currentOffset)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: currentZoom)
                .simultaneousGesture(
                    // Pinch to Zoom Gesture
                    MagnificationGesture()
                        .onChanged { value in
                            let newZoom = currentZoom * value
                            currentZoom = max(minZoom, min(maxZoom, newZoom))
                            
                            // Haptic feedback on zoom limits
                            if newZoom <= minZoom || newZoom >= maxZoom {
                                hapticGenerator.impactOccurred(intensity: 0.5)
                            }
                        }
                        .onEnded { _ in
                            // Snap back if too zoomed out
                            if currentZoom < 0.8 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    currentZoom = 1.0
                                    currentOffset = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    // Pan to Scroll Gesture
                    DragGesture()
                        .onChanged { value in
                            // Only allow panning when zoomed in
                            if currentZoom > 1.0 {
                                let newOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                                
                                // Apply pan limits based on zoom level
                                let maxPan: CGFloat = 150 * (currentZoom - 1)
                                currentOffset = CGSize(
                                    width: max(-maxPan, min(maxPan, newOffset.width)),
                                    height: max(-maxPan, min(maxPan, newOffset.height))
                                )
                            }
                        }
                        .onEnded { _ in
                            lastOffset = currentOffset
                        }
                )
                .simultaneousGesture(
                    // Long Press for Details
                    LongPressGesture(minimumDuration: 0.5)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                // Long press started
                                isLongPressing = true
                                hapticGenerator.impactOccurred(intensity: 0.8)
                                
                            case .second(true, let drag):
                                // Track location during long press
                                if let dragValue = drag {
                                    longPressLocation = dragValue.location
                                    generateDetailInfo(at: dragValue.location)
                                }
                                
                            default:
                                break
                            }
                        }
                        .onEnded { _ in
                            isLongPressing = false
                            
                            // Show detail popover if we have info
                            if detailInfo != nil {
                                showDetailPopover = true
                            }
                        }
                )
            
            // Zoom Level Indicator
            if currentZoom != 1.0 {
                zoomIndicator
            }
            
            // Pan Reset Button (when zoomed and panned)
            if currentZoom > 1.0 && (abs(currentOffset.width) > 50 || abs(currentOffset.height) > 50) {
                resetViewButton
            }
            
            // Detail Popover
            if showDetailPopover, let info = detailInfo {
                detailPopoverView(info: info)
            }
            
            // Long Press Indicator
            if isLongPressing {
                longPressIndicator
            }
        }
        .onAppear {
            hapticGenerator.prepare()
        }
    }
    
    // MARK: - Zoom Level Indicator
    private var zoomIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: currentZoom > 1.0 ? "plus.magnifyingglass" : "minus.magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.cyan)
            
            Text("\(Int(currentZoom * 100))%")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(.thinMaterial)
                .overlay {
                    Capsule()
                        .stroke(.cyan.opacity(0.3), lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.2), radius: 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 20)
        .padding(.leading, 20)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
    
    // MARK: - Reset View Button
    private var resetViewButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentZoom = 1.0
                currentOffset = .zero
                lastOffset = .zero
            }
            hapticGenerator.impactOccurred(intensity: 0.6)
        }) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                Text("Reset")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(getTypeColor(for: pokemon))
                    .shadow(color: getTypeColor(for: pokemon).opacity(0.4), radius: 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.top, 20)
        .padding(.trailing, 20)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
    
    // MARK: - Long Press Indicator
    private var longPressIndicator: some View {
        ZStack {
            // Ripple effect
            Circle()
                .stroke(.cyan.opacity(0.3), lineWidth: 2)
                .frame(width: 60, height: 60)
                .scaleEffect(isLongPressing ? 1.5 : 1.0)
                .opacity(isLongPressing ? 0.3 : 0.8)
                .animation(.easeOut(duration: 0.3).repeatForever(autoreverses: false), value: isLongPressing)
            
            Circle()
                .stroke(.cyan.opacity(0.6), lineWidth: 3)
                .frame(width: 30, height: 30)
                .scaleEffect(isLongPressing ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true), value: isLongPressing)
            
            // Center dot
            Circle()
                .fill(.cyan)
                .frame(width: 8, height: 8)
        }
        .position(longPressLocation)
        .allowsHitTesting(false)
    }
    
    // MARK: - Detail Popover
    private func detailPopoverView(info: ChartDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with close button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(info.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(info.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        showDetailPopover = false
                        detailInfo = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Detail content
            VStack(alignment: .leading, spacing: 8) {
                ForEach(info.details, id: \.key) { detail in
                    HStack {
                        Text(detail.key)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(detail.value)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // Neural network insights
            if !info.mlInsights.isEmpty {
                Divider()
                
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.headline)
                        .foregroundColor(.cyan)
                    
                    Text("AI Insights")
                        .font(.headline)
                        .foregroundColor(.cyan)
                }
                
                ForEach(info.mlInsights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(.cyan)
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)
                        
                        Text(insight)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Share functionality
                    shareChartDetail(info: info)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                        Text("Share")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .fill(.blue.opacity(0.1))
                    }
                }
                
                Button(action: {
                    // Add to favorites functionality
                    addToFavorites(info: info)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.caption)
                        Text("Favorite")
                            .font(.caption)
                    }
                    .foregroundColor(.pink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .fill(.pink.opacity(0.1))
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.cyan.opacity(0.2), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.3), radius: 20)
        }
        .frame(maxWidth: 320)
        .position(x: min(max(longPressLocation.x, 160), UIScreen.main.bounds.width - 160),
                 y: max(longPressLocation.y - 150, 100))
        .transition(.scale(scale: 0.8).combined(with: .opacity))
        .zIndex(1000)
    }
    
    // MARK: - Helper Functions
    private func generateDetailInfo(at location: CGPoint) {
        // Simulate detecting what was tapped based on location
        // In a real implementation, you'd analyze the chart elements at this position
        
        let mockDetails = [
            ("Value", "127"),
            ("Percentile", "89th"),
            ("Confidence", "94%"),
            ("Last Updated", "2 min ago")
        ]
        
        let mockInsights = [
            "This stat is above average for this Pokemon type",
            "Neural network predicts potential for competitive play",
            "Correlation with speed suggests offensive role"
        ]
        
        detailInfo = ChartDetailInfo(
            title: "Attack Stat",
            category: "Physical Stats",
            details: mockDetails,
            mlInsights: mockInsights,
            location: location
        )
    }
    
    private func shareChartDetail(info: ChartDetailInfo) {
        // Implement sharing functionality
        print("Sharing chart detail: \(info.title)")
        hapticGenerator.impactOccurred(intensity: 0.4)
    }
    
    private func addToFavorites(info: ChartDetailInfo) {
        // Implement favorites functionality
        print("Added to favorites: \(info.title)")
        hapticGenerator.impactOccurred(intensity: 0.6)
    }
}

// MARK: - Chart Detail Info Model
struct ChartDetailInfo {
    let title: String
    let category: String
    let details: [(key: String, value: String)]
    let mlInsights: [String]
    let location: CGPoint
}

// MARK: - Interactive Charts View (combines both charts)
struct InteractiveChartsView: View {
    let pokemon: Pokemon
    let comparisonPokemon: Pokemon?
    
    @State private var selectedView: ChartView = .radar
    @State private var showChartControls: Bool = true
    
    enum ChartView: String, CaseIterable {
        case radar = "Radar"
        case barCharts = "Bar Charts"
        case combined = "Combined"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Chart View Selector
                    if showChartControls {
                        chartViewSelector
                    }
                    
                    // Main Chart Content
                    TabView(selection: $selectedView) {
                        // Radar Chart with Interactions
                        InteractiveChartContainer(pokemon: pokemon) { detail, location in
                            print("Radar chart detail tapped: \(detail) at \(location)")
                        } content: {
                            PokemonRadarChart(
                                pokemon: pokemon,
                                comparisonPokemon: comparisonPokemon
                            )
                        }
                        .tag(ChartView.radar)
                        
                        // Bar Charts with Interactions
                        InteractiveChartContainer(pokemon: pokemon) { detail, location in
                            print("Bar chart detail tapped: \(detail) at \(location)")
                        } content: {
                            MLEnhancedBarCharts(
                                pokemon: pokemon,
                                comparisonData: comparisonPokemon != nil ? [comparisonPokemon!] : nil
                            )
                        }
                        .tag(ChartView.barCharts)
                        
                        // Combined View
                        InteractiveChartContainer(pokemon: pokemon) { detail, location in
                            print("Combined chart detail tapped: \(detail) at \(location)")
                        } content: {
                            combinedChartsView
                        }
                        .tag(ChartView.combined)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                
                // Controls Toggle
                controlsToggleButton
            }
            .navigationTitle("Stats Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Export Charts", action: exportCharts)
                        Button("Share Analysis", action: shareAnalysis)
                        Button("Settings", action: openSettings)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(getTypeColor(for: pokemon))
                    }
                }
            }
        }
    }
    
    // MARK: - Chart View Selector
    private var chartViewSelector: some View {
        HStack(spacing: 16) {
            ForEach(ChartView.allCases, id: \.self) { view in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedView = view
                    }
                }) {
                    Text(view.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedView == view ? .white : .secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background {
                            if selectedView == view {
                                Capsule()
                                    .fill(getTypeColor(for: pokemon))
                                    .shadow(color: getTypeColor(for: pokemon).opacity(0.4), radius: 8)
                            } else {
                                Capsule()
                                    .fill(.regularMaterial)
                            }
                        }
                }
                .scaleEffect(selectedView == view ? 1.05 : 1.0)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Combined Charts View
    private var combinedChartsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Radar chart in compact form
                PokemonRadarChart(
                    pokemon: pokemon,
                    comparisonPokemon: comparisonPokemon
                )
                .frame(height: 250)
                
                Divider()
                    .padding(.horizontal)
                
                // Bar charts in compact form
                MLEnhancedBarCharts(
                    pokemon: pokemon,
                    comparisonData: comparisonPokemon != nil ? [comparisonPokemon!] : nil
                )
            }
            .padding()
        }
    }
    
    // MARK: - Controls Toggle Button
    private var controlsToggleButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                showChartControls.toggle()
            }
        }) {
            Image(systemName: showChartControls ? "eye.slash.fill" : "eye.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(12)
                .background {
                    Circle()
                        .fill(.thinMaterial)
                        .overlay {
                            Circle()
                                .fill(.black.opacity(0.3))
                        }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.bottom, 30)
        .padding(.leading, 20)
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.05),
                getTypeColor(for: pokemon).opacity(0.1),
                Color.black.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Action Functions
    private func exportCharts() {
        print("Exporting charts...")
    }
    
    private func shareAnalysis() {
        print("Sharing analysis...")
    }
    
    private func openSettings() {
        print("Opening settings...")
    }
}

// MARK: - Helper function for Pokemon Colors (reused)
private func getTypeColor(for pokemon: Pokemon) -> Color {
    guard let firstType = pokemon.types.first?.pokemonType else { return .blue }
    
    switch firstType {
    case .fire: return .red
    case .water: return .blue
    case .grass: return .green
    case .electric: return .yellow
    case .psychic: return .purple
    case .ice: return .cyan
    case .dragon: return .indigo
    case .dark: return Color(red: 0.2, green: 0.2, blue: 0.2)
    case .fairy: return .pink
    case .fighting: return .orange
    case .poison: return Color(red: 0.6, green: 0.2, blue: 0.8)
    case .ground: return Color(red: 0.8, green: 0.6, blue: 0.2)
    case .flying: return Color(red: 0.7, green: 0.7, blue: 1.0)
    case .bug: return Color(red: 0.6, green: 0.8, blue: 0.2)
    case .rock: return Color(red: 0.7, green: 0.6, blue: 0.3)
    case .ghost: return Color(red: 0.4, green: 0.3, blue: 0.6)
    case .steel: return Color(red: 0.7, green: 0.7, blue: 0.8)
    case .normal: return Color(red: 0.7, green: 0.7, blue: 0.7)
    @unknown default: return .blue
    }
}

// MARK: - Preview
#Preview {
    InteractiveChartsView(
        pokemon: createSamplePokemon(),
        comparisonPokemon: createRivalPokemon()
    )
}

// Sample data functions (same as previous)
private func createSamplePokemon() -> Pokemon {
    Pokemon(
        id: 25,
        name: "pikachu",
        height: 4,
        weight: 60,
        baseExperience: 112,
        order: 35,
        isDefault: true,
        sprites: createSampleSprites(),
        types: [PokemonTypeSlot(slot: 1, type: PokemonTypeInfo(name: "electric", url: ""))],
        abilities: [],
        stats: createSampleStats(),
        species: PokemonSpecies(name: "pikachu", url: ""),
        moves: [],
        gameIndices: []
    )
}

private func createRivalPokemon() -> Pokemon {
    Pokemon(
        id: 6,
        name: "charizard",
        height: 17,
        weight: 905,
        baseExperience: 267,
        order: 7,
        isDefault: true,
        sprites: createRivalSprites(),
        types: [PokemonTypeSlot(slot: 1, type: PokemonTypeInfo(name: "fire", url: ""))],
        abilities: [],
        stats: createRivalStats(),
        species: PokemonSpecies(name: "charizard", url: ""),
        moves: [],
        gameIndices: []
    )
}

private func createSampleSprites() -> PokemonSprites {
    PokemonSprites(
        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
        frontShiny: nil,
        frontFemale: nil,
        frontShinyFemale: nil,
        backDefault: nil,
        backShiny: nil,
        backFemale: nil,
        backShinyFemale: nil,
        other: nil
    )
}

private func createRivalSprites() -> PokemonSprites {
    PokemonSprites(
        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png",
        frontShiny: nil,
        frontFemale: nil,
        frontShinyFemale: nil,
        backDefault: nil,
        backShiny: nil,
        backFemale: nil,
        backShinyFemale: nil,
        other: nil
    )
}

private func createSampleStats() -> [PokemonStat] {
    [
        PokemonStat(baseStat: 35, effort: 0, stat: StatType(name: "hp", url: "")),
        PokemonStat(baseStat: 55, effort: 0, stat: StatType(name: "attack", url: "")),
        PokemonStat(baseStat: 40, effort: 0, stat: StatType(name: "defense", url: "")),
        PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-attack", url: "")),
        PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-defense", url: "")),
        PokemonStat(baseStat: 90, effort: 0, stat: StatType(name: "speed", url: ""))
    ]
}

private func createRivalStats() -> [PokemonStat] {
    [
        PokemonStat(baseStat: 78, effort: 0, stat: StatType(name: "hp", url: "")),
        PokemonStat(baseStat: 84, effort: 0, stat: StatType(name: "attack", url: "")),
        PokemonStat(baseStat: 78, effort: 0, stat: StatType(name: "defense", url: "")),
        PokemonStat(baseStat: 109, effort: 0, stat: StatType(name: "special-attack", url: "")),
        PokemonStat(baseStat: 85, effort: 0, stat: StatType(name: "special-defense", url: "")),
        PokemonStat(baseStat: 100, effort: 0, stat: StatType(name: "speed", url: ""))
    ]
}

//
//  PokemonDetailView.swift
//  LuminaDex - Clean Awwwards Implementation
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI
import ConfettiSwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    
    @State private var selectedTab: DetailTab = .overview
    @State private var isFavorite: Bool = false
    @State private var showDNAViewer: Bool = false
    @State private var animationPhase: CGFloat = 0
    @State private var scrollProgress: CGFloat = 0
    @State private var isLoaded: Bool = false
    @State private var showEvolutionChain: Bool = false
    @State private var confettiCounter: Int = 0
    @State private var showFormSwitcher: Bool = false
    @State private var isShowingShiny: Bool = false
    
    // Direct haptic generators instead of custom HapticsEngine
    @State private var lightHaptic = UIImpactFeedbackGenerator(style: .light)
    @State private var mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    @State private var heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    
    @StateObject private var companionManager = CompanionManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dynamic background
            backgroundView
            
            // Main content
            ScrollView {
                LazyVStack(spacing: 0) {
                    heroSection
                    dividerSection
                    statsSection
                    tabNavigationSection
                    contentSection
                }
            }
            .coordinateSpace(name: "scroll")
            
            // Floating UI
            floatingInterface
            
            // Companion
            CompanionOverlay(companionManager: companionManager)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            setupView()
        }
        .onChange(of: isFavorite) { _, newValue in
            if newValue {
                confettiCounter += 1
                mediumHaptic.impactOccurred()
            }
        }
        .confettiCannon(
            trigger: $confettiCounter,
            num: 50,
            confettis: [.text("🎉"), .text("✨"), .text("🌟")],
            colors: [pokemon.primaryType.color, .yellow, .orange],
            rainHeight: 600,
            radius: 400
        )
        .sheet(isPresented: $showDNAViewer) {
            UltraDNAHelixView(pokemon: pokemon)
        }
        .sheet(isPresented: $showEvolutionChain) {
            EvolutionChainView(pokemon: pokemon)
        }
    }
    
    // MARK: - Background
    
    private var backgroundView: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    pokemon.primaryType.color.opacity(0.3),
                    Color.black.opacity(0.8),
                    pokemon.primaryType.color.opacity(0.1),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated overlay
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            pokemon.primaryType.color.opacity(0.2),
                            Color.clear
                        ],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: 400
                    )
                )
                .ignoresSafeArea()
                .scaleEffect(1.0 + Darwin.sin(animationPhase) * 0.1)
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .named("scroll")).minY
            let progress = max(0, min(1, -minY / 300))
            
            ZStack {
                heroBackground(progress: progress)
                heroContent(progress: progress)
            }
            .frame(height: 500)
            .offset(y: minY > 0 ? -minY * 0.8 : 0)
            .onAppear {
                scrollProgress = progress
            }
        }
        .frame(height: 500)
    }
    
    private func heroBackground(progress: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 40)
            .fill(Color.black.opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(
                        LinearGradient(
                            colors: [
                                pokemon.primaryType.color.opacity(0.6),
                                pokemon.primaryType.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: pokemon.primaryType.color.opacity(0.3),
                radius: 20,
                x: 0,
                y: 10
            )
            .scaleEffect(1.0 - progress * 0.1)
    }
    
    private func heroContent(progress: CGFloat) -> some View {
        VStack(spacing: 24) {
            heroHeader(progress: progress)
            pokemonShowcase(progress: progress)
            titleSection(progress: progress)
        }
        .padding(24)
    }
    
    private func heroHeader(progress: CGFloat) -> some View {
        HStack {
            Button(action: {
                lightHaptic.impactOccurred()
                dismiss()
            }) {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
            .scaleEffect(1.0 - progress * 0.2)
            .opacity(1.0 - progress)
            
            Spacer()
            
            AnimatedFavoriteButton(
                isFavorite: $isFavorite,
                color: pokemon.primaryType.color
            )
            .scaleEffect(1.0 - progress * 0.2)
            .opacity(1.0 - progress)
        }
    }
    private func pokemonShowcase(progress: CGFloat) -> some View {
        ZStack {
            // Platform
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            pokemon.primaryType.color.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(1.0 + Darwin.sin(animationPhase) * 0.1)
            
            // Pokemon image with Shiny support
            ShinyPokemonView(pokemon: pokemon)
                .scaleEffect(1.0 - progress * 0.3)
                .offset(y: Darwin.sin(animationPhase * 0.5) * 8)
            
            // Energy rings
            ForEach(Array(pokemon.types.enumerated()), id: \.offset) { index, typeSlot in
                Circle()
                    .stroke(
                        typeSlot.pokemonType.color.opacity(0.4),
                        style: StrokeStyle(lineWidth: 3, dash: [10, 5])
                    )
                    .frame(width: 220 + CGFloat(index * 40), height: 220 + CGFloat(index * 40))
                    .rotationEffect(.degrees(animationPhase * CGFloat(index == 0 ? 20 : -20)))
                    .opacity(0.6 - progress * 0.6)
            }
        }
    }
    
    private func titleSection(progress: CGFloat) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text(pokemon.displayName)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                pokemon.primaryType.color,
                                .white
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(1.0 - progress * 0.2)
                
                Text("#\(String(format: "%03d", pokemon.id))")
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                    .scaleEffect(1.0 - progress * 0.3)
            }
            
            // Type badges
            HStack(spacing: 8) {
                ForEach(Array(pokemon.types.enumerated()), id: \.offset) { index, typeSlot in
                    typeBadge(type: typeSlot.pokemonType, index: index)
                        .scaleEffect(1.0 - progress * 0.2)
                }
            }
        }
        .opacity(1.0 - progress * 0.8)
    }
    
    private func typeBadge(type: PokemonType, index: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: type.icon)
                .font(.system(size: 16, weight: .semibold))
            
            Text(type.displayName)
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(type.color)
                .shadow(color: type.color.opacity(0.5), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(1.0 + Darwin.sin(animationPhase + CGFloat(index)) * 0.05)
    }
    
    // MARK: - Divider
    
    private var dividerSection: some View {
        Canvas { context, size in
            let path = Path { path in
                let amplitude: CGFloat = 20
                let frequency: CGFloat = 4
                
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                
                for x in stride(from: 0, through: size.width, by: 2) {
                    let y = Darwin.sin((x / size.width) * frequency * .pi + animationPhase) * amplitude + size.height / 2
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            context.stroke(
                path,
                with: .color(pokemon.primaryType.color.opacity(0.6)),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
        }
        .frame(height: 60)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(spacing: 40) {
            statsSectionHeader
            statsSectionContent
        }
        .padding(.vertical, 40)
    }
    
    private var statsSectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Battle Performance")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Neural Analysis")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(pokemon.primaryType.color)
                    .tracking(2)
            }
            
            Spacer()
            
            performanceRating
        }
    }
    
    private var statsSectionContent: some View {
        ZStack {
            centralHub
            connectionLines
            statOrbs
        }
        .frame(width: 350, height: 350)
        .background(Color.black.opacity(0.1))
    }
    
    private var connectionLines: some View {
        ForEach(0..<6, id: \.self) { index in
            connectionLine(for: index)
        }
    }
    
    private func connectionLine(for index: Int) -> some View {
        let angle = Double(index) * .pi / 3 - .pi / 2
        
        return Path { path in
            path.move(to: CGPoint(x: 175, y: 175))
            path.addLine(to: CGPoint(
                x: 175 + cos(angle) * 120,
                y: 175 + sin(angle) * 120
            ))
        }
        .stroke(
            Color.white.opacity(0.05),
            style: StrokeStyle(lineWidth: 1, dash: [4, 2])
        )
    }
    
    private var statOrbs: some View {
        ForEach(Array(pokemon.stats.enumerated()), id: \.offset) { index, stat in
            let angle = Double(index) * .pi / 3 - .pi / 2
            let radius: CGFloat = 120
            
            futuristicStatOrb(stat: stat, angle: angle, radius: radius, index: index)
        }
    }
    
    private var performanceRating: some View {
        let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
        let rating = getPerformanceRating(total: totalStats)
        
        return VStack(spacing: 8) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(rating.color.opacity(0.2), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                // Performance ring
                Circle()
                    .trim(from: 0, to: CGFloat(totalStats) / 800.0) // Max possible ~800
                    .stroke(
                        AngularGradient(
                            colors: [rating.color.opacity(0.6), rating.color, rating.color.opacity(0.8)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: totalStats)
                
                // Rating letter
                Text(rating.grade)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(rating.color)
            }
            
            Text("TIER \(rating.tier)")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundColor(rating.color.opacity(0.8))
                .tracking(1)
        }
    }
    
    private var holographicGrid: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            
            // Draw concentric circles
            for radiusInt in stride(from: 40, through: 160, by: 40) {
                let radius = CGFloat(radiusInt)
                let path = Path { path in
                    path.addEllipse(in: CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    ))
                }
                
                context.stroke(
                    path,
                    with: .color(.cyan.opacity(0.1)),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 8])
                )
            }
            
            // Draw radial lines
            for i in 0..<6 {
                let angle = Double(i) * .pi / 3
                let startPoint = CGPoint(
                    x: center.x + cos(angle) * 30,
                    y: center.y + sin(angle) * 30
                )
                let endPoint = CGPoint(
                    x: center.x + cos(angle) * 160,
                    y: center.y + sin(angle) * 160
                )
                
                let path = Path { path in
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
                
                context.stroke(
                    path,
                    with: .color(.cyan.opacity(0.05)),
                    lineWidth: 1
                )
            }
        }
    }
    
    private var centralHub: some View {
        let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
        
        return ZStack {
            // Outer glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            pokemon.primaryType.color.opacity(0.4),
                            pokemon.primaryType.color.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(1.0 + Darwin.sin(animationPhase * 0.5) * 0.1)
            
            // Main hub
            ZStack {
                // Background
                Circle()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        pokemon.primaryType.color.opacity(0.8),
                                        pokemon.primaryType.color.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                // Content
                VStack(spacing: 2) {
                    Text("\(totalStats)")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("TOTAL")
                        .font(.system(size: 7, weight: .bold, design: .rounded))
                        .foregroundColor(pokemon.primaryType.color.opacity(0.8))
                        .tracking(1)
                }
            }
            
            // Rotating outer ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.clear,
                            pokemon.primaryType.color.opacity(0.6),
                            Color.clear,
                            pokemon.primaryType.color.opacity(0.3),
                            Color.clear
                        ],
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: 90, height: 90)
                .rotationEffect(.degrees(animationPhase * 30))
        }
    }
    
    private func futuristicStatOrb(stat: PokemonStat, angle: Double, radius: CGFloat, index: Int) -> some View {
        let color = enhancedStatColor(for: stat.stat.name)
        let normalizedValue = CGFloat(stat.baseStat) / 255.0
        let orbSize: CGFloat = 70
        
        return VStack(spacing: 4) {
            // Main orb - simplified without rotation
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.4),
                                color.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 35
                        )
                    )
                    .frame(width: orbSize + 20, height: orbSize + 20)
                
                // Progress ring background
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 3)
                    .frame(width: orbSize, height: orbSize)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: normalizedValue)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: orbSize, height: orbSize)
                    .rotationEffect(.degrees(-90))
                
                // Inner circle
                Circle()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: orbSize - 10, height: orbSize - 10)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
                
                // Stat value
                VStack(spacing: 0) {
                    Text("\(stat.baseStat)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(stat.stat.shortName)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(color)
                }
            }
            
            // Label below orb
            Text(stat.stat.displayName)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .offset(
            x: cos(angle) * radius,
            y: sin(angle) * radius
        )
    }
    
    private func connectionBeam(angle: Double, radius: CGFloat, color: Color, intensity: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(0.8 * intensity),
                        color.opacity(0.4 * intensity),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: radius - 40, height: 2)
            .offset(x: (radius - 40) / 2)
            .rotationEffect(.radians(angle))
            .animation(.easeInOut(duration: 1.0).delay(0.3), value: intensity)
    }
    
    private func performanceIndicator(value: Int, color: Color) -> some View {
        let performance = getStatPerformance(value: value)
        
        return HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(index < performance.stars ? color : color.opacity(0.2))
                    .frame(width: 4, height: 4)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.6))
        )
    }
    
    private var dataStreams: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { stream in
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.clear,
                                pokemon.primaryType.color.opacity(0.4),
                                Color.clear,
                                pokemon.primaryType.color.opacity(0.2),
                                Color.clear
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 1, dash: [8, 16])
                    )
                    .frame(width: 60 + CGFloat(stream * 30), height: 60 + CGFloat(stream * 30))
                    .rotationEffect(.degrees(animationPhase * CGFloat(15 + stream * 10)))
            }
        }
    }
    
    private func enhancedStatColor(for statName: String) -> Color {
        switch statName {
        case "hp": return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "attack": return Color(red: 1.0, green: 0.6, blue: 0.2)
        case "defense": return Color(red: 0.3, green: 0.6, blue: 1.0)
        case "special-attack": return Color(red: 0.8, green: 0.4, blue: 1.0)
        case "special-defense": return Color(red: 0.4, green: 1.0, blue: 0.6)
        case "speed": return Color(red: 1.0, green: 1.0, blue: 0.3)
        default: return .white
        }
    }
    
    private func getPerformanceRating(total: Int) -> (grade: String, color: Color, tier: String) {
        // More impressive tier system based on competitive Pokemon standards
        switch total {
        case 0..<200: return ("F", .gray, "TINY")           // Baby Pokemon like Magikarp
        case 200..<300: return ("E", .brown, "WEAK")        // Early route Pokemon
        case 300..<380: return ("D", .red, "BASIC")         // Common Pokemon
        case 380..<450: return ("C", .orange, "DECENT")     // Average Pokemon
        case 450..<500: return ("B", .yellow, "STRONG")     // Good Pokemon
        case 500..<540: return ("A", .green, "ELITE")       // Very strong Pokemon
        case 540..<580: return ("A+", .mint, "CHAMPION")    // Pseudo-legendaries
        case 580..<600: return ("S", .blue, "LEGENDARY")    // Legendary Pokemon
        case 600..<680: return ("S+", .purple, "MYTHICAL")  // Strong legendaries
        case 680..<720: return ("SS", .pink, "DIVINE")      // Ultra beasts, box legendaries
        default: return ("SSS", .indigo, "GODLIKE")         // Mega Rayquaza, Eternamax
        }
    }
    
    private func getStatPerformance(value: Int) -> (stars: Int, grade: String) {
        switch value {
        case 0..<40: return (1, "F")
        case 40..<60: return (2, "D")
        case 60..<80: return (3, "C")
        case 80..<100: return (4, "B")
        case 100..<130: return (5, "A")
        default: return (5, "S")
        }
    }
    
    // MARK: - Tab Navigation
    
    private var tabNavigationSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    tabButton(tab: tab)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }
    
    private func tabButton(tab: DetailTab) -> some View {
        Button(action: {
            lightHaptic.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                if selectedTab == tab {
                    Text(tab.title)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
            .padding(.horizontal, selectedTab == tab ? 20 : 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(selectedTab == tab ? pokemon.primaryType.color : Color.clear)
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
    }
    
    private var typeChartContent: some View {
        VStack(spacing: 24) {
            // Type Effectiveness View
            TypeEffectivenessView(pokemon: pokemon)
                .padding(.vertical, 20)
            
            // Weakness/Resistance Card (Day 25)
            WeaknessResistanceCard(pokemon: pokemon)
            
            // Type Coverage Radar (Day 25)
            TypeCoverageRadar(pokemon: pokemon)
        }
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        Group {
            switch selectedTab {
            case .overview:
                overviewContent
            case .stats:
                statsContent
            case .moves:
                movesContent
            case .evolution:
                evolutionContent
            case .typeChart:
                typeChartContent
            case .training:
                trainingContent
            case .dna:
                dnaContent
            }
        }
        .padding(.horizontal, 20)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
    
    private var overviewContent: some View {
        LazyVStack(spacing: 24) { // Changed to LazyVStack for better performance
            // Form Switcher (Day 25)
            FormSwitcher(pokemon: pokemon)
                .padding(.bottom, 12)
            
            // Pokeball Catch Rate Calculator
            PokemonCatchRateCard(pokemon: pokemon)
                .padding(.horizontal)
            
            // Complete Info Display
            CompleteInfoDisplay(pokemon: pokemon)
            
            // Abilities with new Ability Cloud View
            abilitiesSection
            
            // DNA Access
            dnaAccessButton
        }
    }
    
    private var physicalCharacteristics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Physical Characteristics")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                characteristicCard(
                    title: "Height",
                    value: pokemon.formattedHeight,
                    icon: "ruler",
                    color: .blue
                )
                
                characteristicCard(
                    title: "Weight",
                    value: pokemon.formattedWeight,
                    icon: "scalemass",
                    color: .green
                )
                
                characteristicCard(
                    title: "BMI",
                    value: String(format: "%.1f", calculateBMI()),
                    icon: "chart.bar",
                    color: .orange
                )
            }
        }
    }
    
    private func characteristicCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var abilitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Abilities")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            // Use the new AbilityCloudView from Day 25
            AbilityCloudView(abilities: pokemon.abilities)
                .frame(height: 120)
        }
    }
    
    private func abilityCard(ability: PokemonAbilitySlot, index: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(ability.isHidden ? .purple : pokemon.primaryType.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ability.ability.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                if ability.isHidden {
                    Text("Hidden Ability")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.purple.opacity(0.8))
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
        .scaleEffect(1.0 + Darwin.sin(animationPhase + CGFloat(index) * 0.3) * 0.02)
    }
    
    private var dnaAccessButton: some View {
        Button(action: {
            mediumHaptic.impactOccurred()
            showDNAViewer = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.cyan, .blue, .purple],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(animationPhase * 20))
                    
                    Image(systemName: "atom")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analyze DNA Structure")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Explore \(pokemon.displayName)'s genetic makeup in 3D")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.5), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
        }
    }
    
    private var statsContent: some View {
        VStack(spacing: 24) {
            // Complete Info Display Stats Section
            CompleteInfoDisplay(pokemon: pokemon)
            
            // Stats Distribution
            StatsDistribution(pokemon: pokemon)
        }
    }
    
    private var movesContent: some View {
        VStack(spacing: 20) {
            Text("Move Pool")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Enhanced Moves Section with PokeAPI Integration
            PokemonMovesDetailSection(pokemonId: pokemon.id)
        }
    }
    
    private var evolutionContent: some View {
        VStack(spacing: 20) {
            Text("Evolution Analysis")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Button(action: {
                mediumHaptic.impactOccurred()
                showEvolutionChain = true
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.purple, .cyan, .blue],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-animationPhase * 15))
                        
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("View Evolution Chain")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Explore \(pokemon.displayName)'s evolutionary pathway")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.5), .cyan.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
            }
        }
        .padding()
    }
    
    private var trainingContent: some View {
        NavigationLink(destination: TrainingView(pokemon: pokemon)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Training Calculator")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Optimize EVs, IVs, and Natures")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 12) {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        Text("EVs")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Image(systemName: "dna")
                            .font(.system(size: 20))
                            .foregroundColor(.purple)
                        Text("IVs")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                        Text("Natures")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
            .background(pokemon.primaryType.color.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dnaContent: some View {
        VStack(spacing: 20) {
            Text("DNA Preview")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Button("Open DNA Viewer") {
                showDNAViewer = true
            }
            .foregroundColor(pokemon.primaryType.color)
        }
        .padding()
    }
    
    // MARK: - Floating Interface
    
    private var floatingInterface: some View {
        VStack {
            HStack {
                if scrollProgress > 0.3 {
                    Button(action: { dismiss() }) {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                if scrollProgress > 0.5 {
                    Text(pokemon.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                if scrollProgress > 0.3 {
                    Button(action: {}) {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            Spacer()
        }
        .opacity(scrollProgress > 0.3 ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: scrollProgress)
    }
    
    // MARK: - Helper Methods
    
    private func setupView() {
        startAnimations()
        companionManager.reactToNewPokemon(pokemon)
        
        // Debug: Check if stats are loaded
        print("📊 Pokemon \(pokemon.name) has \(pokemon.stats.count) stats")
        for (index, stat) in pokemon.stats.enumerated() {
            print("  Stat \(index): \(stat.stat.displayName) = \(stat.baseStat)")
        }
    }
    
    private func createDefaultStat(for index: Int) -> PokemonStat {
        let statNames = ["hp", "attack", "defense", "special-attack", "special-defense", "speed"]
        let statName = statNames[index % statNames.count]
        
        // Use Pokemon's collection stats as fallback if available
        let baseValue: Int
        switch statName {
        case "hp": baseValue = pokemon.collectionStats.hp
        case "attack": baseValue = pokemon.collectionStats.attack
        case "defense": baseValue = pokemon.collectionStats.defense
        case "special-attack": baseValue = pokemon.collectionStats.specialAttack
        case "special-defense": baseValue = pokemon.collectionStats.specialDefense
        case "speed": baseValue = pokemon.collectionStats.speed
        default: baseValue = 50
        }
        
        return PokemonStat(
            baseStat: baseValue,
            effort: 0,
            stat: StatType(name: statName, url: "")
        )
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            isLoaded = true
        }
    }
    
    private func calculateBMI() -> Double {
        let heightM = Double(pokemon.height) / 10.0
        let weightKg = Double(pokemon.weight) / 10.0
        return weightKg / (heightM * heightM)
    }
}

// MARK: - Supporting Types

enum DetailTab: String, CaseIterable {
    case overview = "Overview"
    case stats = "Stats"
    case moves = "Moves"
    case evolution = "Evolution"
    case typeChart = "Type Chart"
    case training = "Training"
    case dna = "DNA"
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .overview: return "info.circle"
        case .stats: return "chart.bar"
        case .moves: return "bolt"
        case .evolution: return "arrow.triangle.branch"
        case .typeChart: return "bolt.batteryblock.fill"
        case .training: return "figure.run"
        case .dna: return "atom"
        }
    }
}

// MARK: - Extensions

extension CompanionManager {
    func reactToNewPokemon(_ pokemon: Pokemon) {
        celebrateDiscovery()
        updateCompanionPosition(to: CGPoint(x: 80, y: 600))
    }
}


#Preview {
    PokemonDetailView(
        pokemon: Pokemon(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            baseExperience: 112,
            order: 35,
            isDefault: true,
            sprites: PokemonSprites(
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png",
                frontShiny: nil,
                frontFemale: nil,
                frontShinyFemale: nil,
                backDefault: nil,
                backShiny: nil,
                backFemale: nil,
                backShinyFemale: nil,
                other: PokemonSpritesOther(
                    dreamWorld: nil,
                    home: nil,
                    officialArtwork: PokemonOfficialArtwork(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png",
                        frontShiny: nil
                    )
                )
            ),
            types: [
                PokemonTypeSlot(slot: 1, type: PokemonTypeInfo(name: "electric", url: ""))
            ],
            abilities: [
                PokemonAbilitySlot(
                    isHidden: false,
                    slot: 1,
                    ability: PokemonAbility(name: "static", url: "")
                )
            ],
            stats: [
                PokemonStat(baseStat: 35, effort: 0, stat: StatType(name: "hp", url: "")),
                PokemonStat(baseStat: 55, effort: 0, stat: StatType(name: "attack", url: "")),
                PokemonStat(baseStat: 40, effort: 0, stat: StatType(name: "defense", url: "")),
                PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-attack", url: "")),
                PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-defense", url: "")),
                PokemonStat(baseStat: 90, effort: 2, stat: StatType(name: "speed", url: ""))
            ],
            species: PokemonSpecies(name: "pikachu", url: ""),
            moves: [],
            gameIndices: []
        )
    )
    .preferredColorScheme(.dark)
}

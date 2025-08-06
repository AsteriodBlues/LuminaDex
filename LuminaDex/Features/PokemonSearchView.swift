//
//  PokemonSearchView.swift
//  LuminaDx - NEXT-LEVEL AWWWARDS WINNER 🏆
//
//  The most incredible search experience ever created
//

import SwiftUI
import Combine

struct PokemonSearchView: View {
    @StateObject private var searchManager = SearchManager()
    @StateObject private var alakazamAssistant = AlakazamAssistant()
    
    @State private var searchText = ""
    @State private var isSearchActive = false
    @State private var showVoiceInput = false
    @State private var animationPhase: Double = 0
    @State private var orbOffset = CGSize.zero
    @State private var orbScale: Double = 1.0
    @State private var breathingScale: Double = 1.0
    @State private var pulsePhase: Double = 0
    @State private var energyFieldPhase: Double = 0
    @State private var cosmicRotation: Double = 0
    @State private var dimensionalShift: Double = 0
    @State private var showRippleEffect = false
    
    // Gesture states
    @State private var dragVelocity: CGSize = .zero
    @State private var lastDragPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // LEVEL 1: Cosmic Foundation
                cosmicBackground(size: geometry.size)
                
                // LEVEL 2: Dimensional Layers
                dimensionalEffects(size: geometry.size)
                
                // LEVEL 3: Main Content
                if isSearchActive {
                    futuristicSearchView(size: geometry.size)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.3).combined(with: .opacity),
                            removal: .scale(scale: 1.5).combined(with: .opacity)
                        ))
                } else {
                    heroExperienceView(size: geometry.size)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 1.3).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                }
                
                // LEVEL 4: Magical Assistant
                if alakazamAssistant.isVisible {
                    magicalAssistantView
                        .transition(.scale.combined(with: .opacity))
                }
                
                // LEVEL 5: Ripple Effects
                if showRippleEffect {
                    RippleEffect(center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2))
                        .transition(.opacity)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startQuantumAnimations()
        }
        .sheet(isPresented: $showVoiceInput) {
            QuantumVoiceSearchView()
        }
        .animation(.spring(response: 1.2, dampingFraction: 0.8), value: isSearchActive)
    }
    
    // MARK: - 🌌 COSMIC BACKGROUND SYSTEM
    
    private func cosmicBackground(size: CGSize) -> some View {
        ZStack {
            // Deep space gradient with multiple layers
            deepSpaceGradient
            
            // Animated constellation map
            ConstellationField(size: size, phase: animationPhase)
            
            // Quantum particle streams
            QuantumParticleSystem(size: size, phase: energyFieldPhase)
            
            // Nebula clouds with depth
            NebulaSystem(size: size, phase: dimensionalShift)
            
            // Neural network web
            NeuralWebSystem(size: size, phase: cosmicRotation)
        }
        .ignoresSafeArea()
    }
    
    private var deepSpaceGradient: some View {
        ZStack {
            // Base cosmic void
            RadialGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.12),
                    Color(red: 0.01, green: 0.01, blue: 0.08),
                    Color.black,
                    Color(red: 0.05, green: 0.02, blue: 0.15)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 1000
            )
            
            // Animated cosmic rays
            LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.1, blue: 0.8).opacity(0.15),
                    Color.clear,
                    Color(red: 0.1, green: 0.4, blue: 0.9).opacity(0.12),
                    Color.clear,
                    Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.1),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .scaleEffect(1.0 + sin(animationPhase * 0.2) * 0.3)
            .rotationEffect(.degrees(cosmicRotation * 10))
            .blendMode(.screen)
        }
    }
    
    private func dimensionalEffects(size: CGSize) -> some View {
        ZStack {
            // Dimensional portals
            ForEach(0..<3, id: \.self) { index in
                DimensionalPortal(
                    index: index,
                    size: size,
                    phase: dimensionalShift + Double(index) * 2.0
                )
            }
            
            // Energy field distortions
            EnergyFieldDistortion(size: size, phase: energyFieldPhase)
        }
    }
    
    // MARK: - 🎭 HERO EXPERIENCE VIEW
    
    private func heroExperienceView(size: CGSize) -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: size.height * 0.12)
            
            // Epic title sequence
            epicTitleSequence
            
            Spacer()
                .frame(height: size.height * 0.08)
            
            // The ultimate search orb
            ultimateSearchOrb(size: size)
            
            Spacer()
                .frame(height: size.height * 0.1)
            
            // Perfectly positioned action constellation
            actionConstellation(size: size)
            
            Spacer()
                .frame(height: size.height * 0.12)
        }
    }
    
    private var epicTitleSequence: some View {
        VStack(spacing: 30) {
            // Main title with reality-bending effects
            ZStack {
                // Title shadow/glow layers
                Text("Discover")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(titleShadowGradient)
                    .blur(radius: 20)
                    .scaleEffect(1.05)
                
                Text("Discover")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(epicTitleGradient)
                    .shadow(color: Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.8), radius: 30, x: 0, y: 15)
            }
            .scaleEffect(1.0 + sin(animationPhase * 0.6) * 0.03)
            .rotationEffect(.degrees(sin(animationPhase * 0.3) * 2))
            
            // Subtitle with dimensional shift
            ZStack {
                Text("Pokémon")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(subtitleShadowGradient)
                    .blur(radius: 20)
                    .scaleEffect(1.05)
                
                Text("Pokémon")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(epicSubtitleGradient)
                    .shadow(color: Color(red: 0.0, green: 0.83, blue: 1.0).opacity(0.8), radius: 30, x: 0, y: 15)
            }
            .scaleEffect(1.0 + sin(animationPhase * 0.6 + 0.5) * 0.03)
            .offset(x: sin(animationPhase * 0.4) * 10)
            
            // Mystical instruction text
            Text("Touch the quantum orb to transcend reality")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(instructionGradient)
                .tracking(3.0)
                .opacity(0.7 + sin(animationPhase * 1.2) * 0.3)
                .scaleEffect(breathingScale * 0.95)
                .shadow(color: .white.opacity(0.3), radius: 10)
        }
    }
    
    private var epicTitleGradient: some ShapeStyle {
        LinearGradient(
            colors: [
                .white,
                Color(red: 0.8, green: 0.6, blue: 1.0),
                Color(red: 0.42, green: 0.37, blue: 1.0),
                Color(red: 0.6, green: 0.8, blue: 1.0),
                .white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var epicSubtitleGradient: some ShapeStyle {
        LinearGradient(
            colors: [
                .white,
                Color(red: 0.4, green: 0.9, blue: 1.0),
                Color(red: 0.0, green: 0.83, blue: 1.0),
                Color(red: 0.2, green: 1.0, blue: 0.8),
                .white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var titleShadowGradient: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.6),
                Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var subtitleShadowGradient: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.83, blue: 1.0).opacity(0.6),
                Color(red: 0.2, green: 1.0, blue: 0.8).opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var instructionGradient: some ShapeStyle {
        LinearGradient(
            colors: [
                .white.opacity(0.9),
                Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.8),
                .white.opacity(0.9)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - 🔮 ULTIMATE SEARCH ORB
    
    private func ultimateSearchOrb(size: CGSize) -> some View {
        ZStack {
            // Quantum energy field
            ForEach(0..<6, id: \.self) { ringIndex in
                QuantumEnergyRing(
                    ringIndex: ringIndex,
                    animationPhase: animationPhase,
                    pulsePhase: pulsePhase,
                    size: size
                )
            }
            
            // The ultimate orb itself
            Button(action: activateSearchWithStyle) {
                UltimateOrbContent(
                    animationPhase: animationPhase,
                    breathingScale: breathingScale,
                    pulsePhase: pulsePhase,
                    showRipple: showRippleEffect
                )
            }
            .scaleEffect(orbScale)
            .offset(orbOffset)
            .rotationEffect(.degrees(sin(animationPhase * 0.5) * 5))
            .gesture(quantumOrbGesture)
            .onHover { isHovering in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    orbScale = isHovering ? 1.08 : 1.0
                }
            }
        }
    }
    
    private var quantumOrbGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.6)) {
                    orbOffset = CGSize(
                        width: value.translation.width * 0.15,
                        height: value.translation.height * 0.15
                    )
                    orbScale = 1.15 + min(abs(value.translation.width + value.translation.height) / 1000, 0.2)
                }
                
                // Calculate drag velocity for physics effects
                dragVelocity = CGSize(
                    width: value.location.x - lastDragPosition.x,
                    height: value.location.y - lastDragPosition.y
                )
                lastDragPosition = value.location
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.9, dampingFraction: 0.6)) {
                    orbOffset = .zero
                    orbScale = 1.0
                }
                
                // Epic haptic sequence
                triggerQuantumHaptics()
                
                // Delayed activation with style
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    activateSearchWithStyle()
                }
            }
    }
    
    // MARK: - 🌟 ACTION CONSTELLATION (Fixed Positioning)
    
    private func actionConstellation(size: CGSize) -> some View {
        HStack(spacing: size.width * 0.12) {
            ConstellationActionButton(
                icon: "mic.fill",
                title: "Voice",
                constellation: .voice,
                primaryColor: Color(red: 0.0, green: 1.0, blue: 0.53),
                secondaryColor: Color(red: 0.2, green: 0.9, blue: 0.7),
                animationPhase: animationPhase,
                size: size
            ) {
                showVoiceInput = true
            }
            
            ConstellationActionButton(
                icon: "slider.horizontal.3",
                title: "Filters",
                constellation: .filters,
                primaryColor: Color(red: 0.0, green: 0.83, blue: 1.0),
                secondaryColor: Color(red: 0.3, green: 0.7, blue: 1.0),
                animationPhase: animationPhase + 0.7,
                size: size
            ) {
                // TODO: Filters
            }
            
            ConstellationActionButton(
                icon: "star.fill",
                title: "Favorites",
                constellation: .favorites,
                primaryColor: Color(red: 0.42, green: 0.37, blue: 1.0),
                secondaryColor: Color(red: 0.6, green: 0.5, blue: 1.0),
                animationPhase: animationPhase + 1.4,
                size: size
            ) {
                // TODO: Favorites
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }
    
    // MARK: - 🚀 FUTURISTIC SEARCH VIEW
    
    private func futuristicSearchView(size: CGSize) -> some View {
        VStack(spacing: 0) {
            quantumSearchHeader(size: size)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 24) {
                        searchContent
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 24)
                }
                .background(.ultraThinMaterial.opacity(0.1))
            }
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
    }
    
    private func quantumSearchHeader(size: CGSize) -> some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: deactivateSearchWithStyle) {
                    QuantumButton(
                        icon: "xmark",
                        color: .white.opacity(0.9),
                        backgroundColor: Color.black.opacity(0.3),
                        glowColor: .red
                    )
                }
                
                Spacer()
                
                Text("Quantum Search")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(red: 0.8, green: 0.9, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 10)
                
                Spacer()
                
                Button(action: { showVoiceInput = true }) {
                    QuantumButton(
                        icon: "mic.fill",
                        color: Color(red: 0.0, green: 1.0, blue: 0.53),
                        backgroundColor: Color(red: 0.0, green: 1.0, blue: 0.53).opacity(0.2),
                        glowColor: Color(red: 0.0, green: 1.0, blue: 0.53)
                    )
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 70)
            
            quantumSearchBar(size: size)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
    }
    
    private func quantumSearchBar(size: CGSize) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Color(red: 0.42, green: 0.37, blue: 1.0))
                    .shadow(color: Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.5), radius: 8)
                
                // Animated search rays
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.3))
                        .frame(width: 20, height: 1)
                        .offset(x: 15)
                        .rotationEffect(.degrees(Double(index) * 90 + animationPhase * 90))
                        .opacity(0.6 + sin(animationPhase * 2 + Double(index)) * 0.4)
                }
            }
            
            TextField("Search across all dimensions...", text: $searchText)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .tint(Color(red: 0.42, green: 0.37, blue: 1.0))
                .onChange(of: searchText) { _, newValue in
                    searchManager.updateSearchQuery(newValue)
                    
                    // Show search hints
                    if !newValue.isEmpty {
                        alakazamAssistant.showHint(for: newValue)
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                        .shadow(color: .white.opacity(0.3), radius: 5)
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.8),
                            Color(red: 0.0, green: 0.83, blue: 1.0).opacity(0.6),
                            Color(red: 0.0, green: 1.0, blue: 0.53).opacity(0.4),
                            Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.8)
                        ],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .shadow(color: Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.4), radius: 25, x: 0, y: 12)
        )
        .padding(.horizontal, 28)
        .padding(.bottom, 24)
    }
    
    private var searchContent: some View {
        Group {
            if searchManager.isLoading {
                quantumLoadingView
            } else if searchManager.searchResults.isEmpty && !searchText.isEmpty {
                voidEmptyView
            } else if !searchText.isEmpty {
                resultsView
            } else {
                dimensionalSuggestionsView
            }
        }
    }
    
    private var quantumLoadingView: some View {
        VStack(spacing: 40) {
            HStack(spacing: 30) {
                QuantumLoadingOrb(color: Color(red: 1.0, green: 0.4, blue: 0.4), delay: 0.0, phase: animationPhase)
                QuantumLoadingOrb(color: Color(red: 0.0, green: 0.83, blue: 1.0), delay: 0.3, phase: animationPhase)
                QuantumLoadingOrb(color: Color(red: 0.0, green: 1.0, blue: 0.53), delay: 0.6, phase: animationPhase)
            }
            
            VStack(spacing: 16) {
                Text("Scanning the multiverse...")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.5), radius: 10)
                
                Text("Locating legendary creatures across dimensions")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 100)
    }
    
    private var voidEmptyView: some View {
        VStack(spacing: 40) {
            ZStack {
                Text("🌌")
                    .font(.system(size: 100))
                    .scaleEffect(1.0 + sin(animationPhase * 2) * 0.15)
                    .shadow(color: .purple.opacity(0.8), radius: 20)
                
                // Void particles around the emoji
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: cos(animationPhase * 2 + Double(index) * .pi / 4) * 60,
                            y: sin(animationPhase * 2 + Double(index) * .pi / 4) * 60
                        )
                        .blur(radius: 1)
                }
            }
            
            VStack(spacing: 20) {
                Text("Lost in the Void")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 15)
                
                Text("No creatures found in this dimension.\nTry adjusting your quantum frequency.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // Show help suggestion
            Button("Get Search Tips") {
                alakazamAssistant.offerHelp()
            }
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(Color(red: 0.42, green: 0.37, blue: 1.0))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .stroke(Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.5), lineWidth: 2)
            )
        }
        .padding(.top, 100)
    }
    
    private var resultsView: some View {
        LazyVStack(spacing: 20) {
            ForEach(searchManager.searchResults, id: \.id) { pokemon in
                QuantumSearchResultCard(pokemon: pokemon, animationPhase: animationPhase)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            if !searchManager.searchResults.isEmpty {
                alakazamAssistant.celebrateSuccess()
            }
        }
    }
    
    private var dimensionalSuggestionsView: some View {
        VStack(alignment: .leading, spacing: 36) {
            Text("Dimensional Gateways")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .blue.opacity(0.5), radius: 10)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 24) {
                DimensionalGateway(
                    title: "Fire Realm",
                    subtitle: "Blazing creatures",
                    icon: "flame.fill",
                    portalColors: [Color(red: 1.0, green: 0.3, blue: 0.3), Color(red: 1.0, green: 0.6, blue: 0.2)],
                    animationPhase: animationPhase
                ) {
                    searchText = "fire"
                }
                
                DimensionalGateway(
                    title: "Mystic Legends",
                    subtitle: "Ancient powers",
                    icon: "crown.fill",
                    portalColors: [Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 1.0, green: 0.5, blue: 0.8)],
                    animationPhase: animationPhase + 0.5
                ) {
                    searchText = "legendary"
                }
                
                DimensionalGateway(
                    title: "Origin World",
                    subtitle: "First discoveries",
                    icon: "globe.americas.fill",
                    portalColors: [Color(red: 0.0, green: 0.83, blue: 1.0), Color(red: 0.42, green: 0.37, blue: 1.0)],
                    animationPhase: animationPhase + 1.0
                ) {
                    searchText = "kanto"
                }
                
                DimensionalGateway(
                    title: "Thunder Domain",
                    subtitle: "Electric spirits",
                    icon: "bolt.fill",
                    portalColors: [Color(red: 1.0, green: 0.9, blue: 0.0), Color(red: 0.0, green: 1.0, blue: 0.53)],
                    animationPhase: animationPhase + 1.5
                ) {
                    searchText = "electric"
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - 🧙‍♂️ MAGICAL ASSISTANT
    
    private var magicalAssistantView: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        // Assistant aura
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.purple.opacity(0.6),
                                        Color.purple.opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 10)
                            .scaleEffect(1.0 + sin(animationPhase * 3) * 0.2)
                        
                        Text("🧙‍♂️")
                            .font(.system(size: 60))
                            .scaleEffect(1.0 + sin(animationPhase * 2.5) * 0.1)
                            .rotationEffect(.degrees(sin(animationPhase * 1.5) * 10))
                            .shadow(color: Color.purple.opacity(0.8), radius: 25)
                    }
                    
                    if !alakazamAssistant.currentMessage.isEmpty {
                        Text(alakazamAssistant.currentMessage)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .stroke(
                                        AngularGradient(
                                            colors: [
                                                Color.purple,
                                                Color.blue,
                                                Color.purple
                                            ],
                                            center: .center
                                        ),
                                        lineWidth: 3
                                    )
                                    .shadow(color: Color.purple.opacity(0.6), radius: 20, x: 0, y: 8)
                            )
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.top, 160)
            .padding(.trailing, 36)
            
            Spacer()
        }
    }
    
    // MARK: - 🎬 ACTIONS & ANIMATIONS
    
    private func activateSearchWithStyle() {
        // Trigger ripple effect
        showRippleEffect = true
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            isSearchActive = true
        }
        
        // Hide ripple after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showRippleEffect = false
        }
        
        alakazamAssistant.appear()
        triggerQuantumHaptics()
    }
    
    private func deactivateSearchWithStyle() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            isSearchActive = false
            searchText = ""
        }
        alakazamAssistant.disappear()
    }
    
    private func triggerQuantumHaptics() {
        let heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)
        heavyFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
            mediumFeedback.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let lightFeedback = UIImpactFeedbackGenerator(style: .light)
            lightFeedback.impactOccurred()
        }
    }
    
    private func startQuantumAnimations() {
        // Main cosmic animation
        withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
        
        // Breathing effect
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
            breathingScale = 1.08
        }
        
        // Pulse effect
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            pulsePhase = 1.0
        }
        
        // Energy field
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            energyFieldPhase = 2 * .pi
        }
        
        // Cosmic rotation
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            cosmicRotation = 1.0
        }
        
        // Dimensional shift
        withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
            dimensionalShift = 2 * .pi
        }
    }
}

// MARK: - 🌟 QUANTUM COMPONENTS

struct ConstellationField: View {
    let size: CGSize
    let phase: Double
    
    var body: some View {
        Canvas { context, canvasSize in
            // Draw constellation stars
            for i in 0..<50 {
                let x = (sin(Double(i) * 0.5 + phase * 0.1) * 0.4 + 0.5) * canvasSize.width
                let y = (cos(Double(i) * 0.7 + phase * 0.08) * 0.4 + 0.5) * canvasSize.height
                let opacity = 0.3 + sin(phase * 2 + Double(i)) * 0.4
                let starSize = 2.0 + sin(phase + Double(i) * 0.3) * 1.5
                
                let rect = CGRect(x: x - starSize/2, y: y - starSize/2, width: starSize, height: starSize)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
            }
        }
    }
}

struct QuantumParticleSystem: View {
    let size: CGSize
    let phase: Double
    
    var body: some View {
        ForEach(0..<30, id: \.self) { index in
            Circle()
                .fill(particleColor(index: index).opacity(0.7))
                .frame(width: 3, height: 3)
                .position(
                    x: size.width * 0.5 + cos(phase * 0.6 + Double(index) * 0.4) * (size.width * 0.45),
                    y: size.height * 0.5 + sin(phase * 0.4 + Double(index) * 0.6) * (size.height * 0.45)
                )
                .opacity(0.4 + sin(phase * 2.5 + Double(index)) * 0.4)
                .scaleEffect(0.3 + sin(phase * 1.8 + Double(index) * 0.4) * 0.7)
                .blur(radius: 1.5)
        }
    }
    
    private func particleColor(index: Int) -> Color {
        let colors = [
            Color(red: 0.42, green: 0.37, blue: 1.0),
            Color(red: 0.0, green: 0.83, blue: 1.0),
            Color(red: 0.0, green: 1.0, blue: 0.53),
            .white,
            Color(red: 1.0, green: 0.6, blue: 0.8)
        ]
        return colors[index % colors.count]
    }
}

struct NebulaSystem: View {
    let size: CGSize
    let phase: Double
    
    var body: some View {
        ForEach(0..<4, id: \.self) { index in
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            nebulaColor(index: index).opacity(0.15),
                            nebulaColor(index: index).opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 200)
                .rotationEffect(.degrees(phase * 5 + Double(index) * 30))
                .position(
                    x: size.width * 0.5 + cos(phase * 0.3 + Double(index) * 1.5) * 150,
                    y: size.height * 0.5 + sin(phase * 0.2 + Double(index) * 1.2) * 200
                )
                .blur(radius: 30)
                .blendMode(.screen)
        }
    }
    
    private func nebulaColor(index: Int) -> Color {
        let colors = [
            Color(red: 0.6, green: 0.3, blue: 1.0),
            Color(red: 0.2, green: 0.7, blue: 1.0),
            Color(red: 0.4, green: 1.0, blue: 0.6),
            Color(red: 1.0, green: 0.5, blue: 0.7)
        ]
        return colors[index % colors.count]
    }
}

struct NeuralWebSystem: View {
    let size: CGSize
    let phase: Double
    
    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            
            for i in 0..<12 {
                let angle = Double(i) * .pi / 6 + phase * 0.05
                let length = min(canvasSize.width, canvasSize.height) * 0.4
                
                let endPoint = CGPoint(
                    x: center.x + cos(angle) * length,
                    y: center.y + sin(angle) * length
                )
                
                let path = Path { path in
                    path.move(to: center)
                    path.addLine(to: endPoint)
                }
                
                let opacity = 0.05 + sin(phase * 2 + Double(i)) * 0.03
                
                context.stroke(
                    path,
                    with: .color(Color.cyan.opacity(opacity)),
                    style: StrokeStyle(
                        lineWidth: 0.8,
                        dash: [15, 30],
                        dashPhase: phase * 8
                    )
                )
            }
        }
    }
}

struct DimensionalPortal: View {
    let index: Int
    let size: CGSize
    let phase: Double
    
    var body: some View {
        let portalSize = 100.0 + Double(index) * 30
        let position = CGPoint(
            x: size.width * 0.5 + cos(phase + Double(index) * 2.0) * (size.width * 0.3),
            y: size.height * 0.5 + sin(phase + Double(index) * 2.0) * (size.height * 0.25)
        )
        
        ZStack {
            // Portal energy
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.clear,
                            portalColor.opacity(0.6),
                            Color.clear,
                            portalColor.opacity(0.3),
                            Color.clear
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: portalSize, height: portalSize)
                .rotationEffect(.degrees(phase * 30 + Double(index) * 60))
            
            // Portal core
            Circle()
                .fill(portalColor.opacity(0.1))
                .frame(width: portalSize * 0.6, height: portalSize * 0.6)
                .blur(radius: 5)
        }
        .position(position)
        .opacity(0.7)
    }
    
    private var portalColor: Color {
        let colors = [
            Color(red: 0.42, green: 0.37, blue: 1.0),
            Color(red: 0.0, green: 0.83, blue: 1.0),
            Color(red: 0.0, green: 1.0, blue: 0.53)
        ]
        return colors[index % colors.count]
    }
}

struct EnergyFieldDistortion: View {
    let size: CGSize
    let phase: Double
    
    var body: some View {
        Canvas { context, canvasSize in
            for i in 0..<8 {
                let progress = (phase + Double(i) * 0.5).truncatingRemainder(dividingBy: 2 * .pi) / (2 * .pi)
                let x = progress * canvasSize.width
                let y = canvasSize.height * 0.5 + sin(progress * .pi * 4) * 50
                
                let path = Path { path in
                    path.move(to: CGPoint(x: x - 20, y: y))
                    path.addLine(to: CGPoint(x: x + 20, y: y))
                }
                
                context.stroke(
                    path,
                    with: .color(Color.white.opacity(0.1)),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round)
                )
            }
        }
    }
}

struct QuantumEnergyRing: View {
    let ringIndex: Int
    let animationPhase: Double
    let pulsePhase: Double
    let size: CGSize
    
    var body: some View {
        let ringSize = 180.0 + Double(ringIndex * 50)
        let rotationSpeed = 8.0 + Double(ringIndex * 4)
        let ringOpacity = 0.9 - Double(ringIndex) * 0.12
        let pulseIntensity = 1.0 + sin(pulsePhase * 2 + Double(ringIndex) * 0.5) * 0.3
        
        Circle()
            .stroke(
                AngularGradient(
                    colors: [
                        Color.clear,
                        ringColor.opacity(ringOpacity * pulseIntensity),
                        Color.clear,
                        ringSecondaryColor.opacity(ringOpacity * 0.8 * pulseIntensity),
                        Color.clear,
                        ringTertiaryColor.opacity(ringOpacity * 0.6 * pulseIntensity),
                        Color.clear
                    ],
                    center: .center,
                    startAngle: .degrees(animationPhase * rotationSpeed * 20),
                    endAngle: .degrees(animationPhase * rotationSpeed * 20 + 360)
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: ringSize, height: ringSize)
            .rotationEffect(.degrees(animationPhase * rotationSpeed))
            .blur(radius: CGFloat(ringIndex) * 1.2)
            .scaleEffect(1.0 + sin(animationPhase * 1.8 + Double(ringIndex)) * 0.08)
    }
    
    private var ringColor: Color {
        Color(red: 0.42, green: 0.37, blue: 1.0)
    }
    
    private var ringSecondaryColor: Color {
        Color(red: 0.0, green: 0.83, blue: 1.0)
    }
    
    private var ringTertiaryColor: Color {
        Color(red: 0.0, green: 1.0, blue: 0.53)
    }
}

struct UltimateOrbContent: View {
    let animationPhase: Double
    let breathingScale: Double
    let pulsePhase: Double
    let showRipple: Bool
    
    // Helper view properties
    private var outerEnergyField: some View {
        Circle()
            .fill(outerFieldGradient)
            .frame(width: 280, height: 280)
            .scaleEffect(1.0 + sin(animationPhase * 2.2) * 0.2)
            .blur(radius: 30)
            .opacity(0.8)
    }
    
    private var secondaryEnergyLayer: some View {
        Circle()
            .fill(secondaryFieldGradient)
            .frame(width: 220, height: 220)
            .scaleEffect(1.0 + sin(animationPhase * 1.8 + 0.5) * 0.15)
            .blur(radius: 20)
            .opacity(0.6)
    }
    
    private var mainOrbBody: some View {
        ZStack {
            // Base orb with gradient
            Circle()
                .fill(mainOrbGradient)
                .frame(width: 180, height: 180)
            
            // Prismatic overlay
            Circle()
                .fill(prismaticOverlay)
                .frame(width: 180, height: 180)
                .blendMode(.overlay)
            
            // Glass reflection effect
            Circle()
                .fill(glassReflectionGradient)
                .frame(width: 180, height: 180)
            
            // Border ring
            Circle()
                .stroke(borderGradient, lineWidth: 4)
                .frame(width: 180, height: 180)
        }
    }
    
    private var searchIcon: some View {
        ZStack {
            // Icon glow
            Image(systemName: "magnifyingglass")
                .font(.system(size: 70, weight: .light))
                .foregroundColor(Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.8))
                .blur(radius: 8)
                .scaleEffect(1.2)
            
            // Main icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 70, weight: .light))
                .foregroundStyle(iconGradient)
                .shadow(color: .black.opacity(0.5), radius: 10)
        }
        .scaleEffect(1.0 + sin(animationPhase * 3.5) * 0.1)
        .rotationEffect(.degrees(sin(animationPhase * 0.8) * 3))
    }
    
    private var quantumParticles: some View {
        ForEach(0..<8, id: \.self) { index in
            Circle()
                .fill(particleGradient)
                .frame(width: 8, height: 8)
                .offset(
                    x: cos(animationPhase * 2.8 + Double(index) * .pi / 4) * 70,
                    y: sin(animationPhase * 2.8 + Double(index) * .pi / 4) * 70
                )
                .opacity(0.8 + sin(animationPhase * 3.5 + Double(index)) * 0.2)
                .blur(radius: 2)
                .scaleEffect(0.6 + sin(animationPhase * 2.2 + Double(index)) * 0.6)
        }
    }
    
    private var energyStreams: some View {
        ForEach(0..<4, id: \.self) { index in
            Rectangle()
                .fill(streamGradient)
                .frame(width: 60, height: 2)
                .offset(x: 45)
                .rotationEffect(.degrees(Double(index) * 90 + animationPhase * 120))
                .opacity(0.7 + sin(animationPhase * 4 + Double(index)) * 0.3)
                .blur(radius: 1)
        }
    }
    
    var body: some View {
        ZStack {
            // Background layers
            Group {
                outerEnergyField
                secondaryEnergyLayer
            }
            
            // Main orb
            mainOrbBody
                .shadow(color: Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.8), radius: 40, x: 0, y: 20)
                .scaleEffect(breathingScale)
            
            // Foreground elements
            Group {
                searchIcon
                quantumParticles
                energyStreams
            }
        }
    }
    
    private var outerFieldGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.6),
                Color(red: 0.0, green: 0.83, blue: 1.0).opacity(0.4),
                Color(red: 0.0, green: 1.0, blue: 0.53).opacity(0.3),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 140
        )
    }
    
    private var secondaryFieldGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color(red: 0.6, green: 0.5, blue: 1.0).opacity(0.8),
                Color(red: 0.3, green: 0.7, blue: 1.0).opacity(0.5),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 110
        )
    }
    
    private var mainOrbGradient: AngularGradient {
        AngularGradient(
            colors: [
                Color(red: 0.42, green: 0.37, blue: 1.0),
                Color(red: 0.0, green: 0.83, blue: 1.0),
                Color(red: 0.0, green: 1.0, blue: 0.53),
                Color(red: 0.6, green: 0.4, blue: 1.0),
                Color(red: 0.42, green: 0.37, blue: 1.0)
            ],
            center: .center
        )
    }
    
    private var prismaticOverlay: RadialGradient {
        RadialGradient(
            colors: [
                Color.white.opacity(0.3),
                Color.clear,
                Color.black.opacity(0.1)
            ],
            center: .center,
            startRadius: 0,
            endRadius: 90
        )
    }
    
    private var glassReflectionGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.white.opacity(0.8),
                Color.white.opacity(0.2),
                Color.clear,
                Color.black.opacity(0.3)
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: 90
        )
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.8),
                Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.6),
                Color.white.opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white,
                Color(red: 0.9, green: 0.95, blue: 1.0),
                .white.opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var particleGradient: RadialGradient {
        RadialGradient(
            colors: [
                .white,
                Color(red: 0.8, green: 0.9, blue: 1.0),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 4
        )
    }
    
    private var streamGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                Color.white.opacity(0.8),
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

enum ConstellationType {
    case voice, filters, favorites
}

struct ConstellationActionButton: View {
    let icon: String
    let title: String
    let constellation: ConstellationType
    let primaryColor: Color
    let secondaryColor: Color
    let animationPhase: Double
    let size: CGSize
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: 18) {
                ZStack {
                    // Constellation background
                    constellationBackground
                    
                    // Main button core
                    mainButtonCore
                    
                    // Icon with quantum effects
                    quantumIcon
                }
                .frame(width: buttonSize, height: buttonSize)
                
                // Title with cosmic styling
                cosmicTitle
            }
        }
        .scaleEffect(isPressed ? 0.92 : (isHovered ? 1.05 : 1.0))
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) { isPressing in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isPressed = isPressing
            }
        } perform: {}
        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
    }
    
    private var buttonSize: CGFloat {
        min(size.width * 0.2, 90)
    }
    
    private var constellationBackground: some View {
        ZStack {
            // Outer constellation ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.clear,
                            primaryColor.opacity(0.6),
                            Color.clear,
                            secondaryColor.opacity(0.4),
                            Color.clear
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: buttonSize * 1.4, height: buttonSize * 1.4)
                .rotationEffect(.degrees(animationPhase * 15))
                .opacity(isHovered ? 1.0 : 0.6)
            
            // Inner energy field
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            primaryColor.opacity(0.4),
                            primaryColor.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: buttonSize * 0.8
                    )
                )
                .frame(width: buttonSize * 1.6, height: buttonSize * 1.6)
                .blur(radius: 8)
                .scaleEffect(1.0 + sin(animationPhase * 2.5) * 0.15)
        }
    }
    
    private var mainButtonCore: some View {
        ZStack {
            // Base button
            Circle()
                .fill(buttonGradient)
                .frame(width: buttonSize, height: buttonSize)
            
            // Glass overlay
            Circle()
                .fill(glassOverlayGradient)
                .frame(width: buttonSize, height: buttonSize)
            
            // Border
            Circle()
                .stroke(borderRingGradient, lineWidth: 2.5)
                .frame(width: buttonSize, height: buttonSize)
        }
        .shadow(color: primaryColor.opacity(0.6), radius: 25, x: 0, y: 10)
    }
    
    private var quantumIcon: some View {
        ZStack {
            // Icon glow
            Image(systemName: icon)
                .font(.system(size: buttonSize * 0.35, weight: .medium))
                .foregroundColor(primaryColor.opacity(0.8))
                .blur(radius: 6)
                .scaleEffect(1.3)
            
            // Main icon
            Image(systemName: icon)
                .font(.system(size: buttonSize * 0.35, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: primaryColor.opacity(0.8), radius: 10)
                .shadow(color: .black.opacity(0.5), radius: 5)
        }
        .scaleEffect(1.0 + sin(animationPhase * 3) * 0.08)
        .rotationEffect(.degrees(sin(animationPhase * 1.5) * 5))
    }
    
    private var cosmicTitle: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(titleGradient)
            .tracking(1.5)
            .shadow(color: primaryColor.opacity(0.5), radius: 8)
            .shadow(color: .black.opacity(0.3), radius: 3)
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var glassOverlayGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.white.opacity(0.4),
                Color.white.opacity(0.1),
                Color.clear,
                Color.black.opacity(0.2)
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: buttonSize * 0.5
        )
    }
    
    private var borderRingGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.8),
                Color.white.opacity(0.4),
                Color.white.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var titleGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white,
                Color(red: 0.9, green: 0.95, blue: 1.0).opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct QuantumButton: View {
    let icon: String
    let color: Color
    let backgroundColor: Color
    let glowColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 56, height: 56)
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.4), lineWidth: 2)
                )
                .shadow(color: glowColor.opacity(0.4), radius: 15, x: 0, y: 8)
            
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(color)
                .shadow(color: glowColor.opacity(0.6), radius: 8)
        }
    }
}

struct QuantumLoadingOrb: View {
    let color: Color
    let delay: Double
    let phase: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Outer energy field
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)
                .blur(radius: 8)
                .scaleEffect(isAnimating ? 1.5 : 0.8)
            
            // Core orb
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            color,
                            color.opacity(0.7),
                            color,
                            color.opacity(0.9)
                        ],
                        center: .center
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                )
                .scaleEffect(isAnimating ? 1.2 : 0.9)
                .rotationEffect(.degrees(phase * 60))
        }
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
                .delay(delay)
            ) {
                isAnimating = true
            }
        }
    }
}

struct QuantumSearchResultCard: View {
    let pokemon: Pokemon
    let animationPhase: Double
    
    var body: some View {
        HStack(spacing: 24) {
            // Quantum pokemon preview
            ZStack {
                // Energy field
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                pokemon.primaryColor.opacity(0.5),
                                pokemon.primaryColor.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 8)
                    .scaleEffect(1.0 + sin(animationPhase * 2) * 0.1)
                
                // Main preview circle
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    pokemon.primaryColor,
                                    pokemon.primaryColor.opacity(0.6),
                                    pokemon.primaryColor
                                ],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 80, height: 80)
                    
                    Text("🔮")
                        .font(.system(size: 35))
                        .scaleEffect(1.0 + sin(animationPhase * 1.5) * 0.05)
                }
                .shadow(color: pokemon.primaryColor.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(pokemon.displayName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                Text("#\(String(format: "%03d", pokemon.id))")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 10) {
                    ForEach(pokemon.types, id: \.slot) { typeSlot in
                        Text(typeSlot.pokemonType.displayName)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(typeSlot.pokemonType.color)
                                    .shadow(color: typeSlot.pokemonType.color.opacity(0.6), radius: 10)
                            )
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .shadow(color: .white.opacity(0.3), radius: 5)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .stroke(
                    LinearGradient(
                        colors: [
                            pokemon.primaryColor.opacity(0.6),
                            pokemon.primaryColor.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .shadow(color: pokemon.primaryColor.opacity(0.3), radius: 25, x: 0, y: 12)
        )
    }
}

struct DimensionalGateway: View {
    let title: String
    let subtitle: String
    let icon: String
    let portalColors: [Color]
    let animationPhase: Double
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                ZStack {
                    // Portal energy field
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    portalColors[0].opacity(0.4),
                                    portalColors[1].opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)
                        .scaleEffect(1.0 + sin(animationPhase * 2) * 0.2)
                    
                    // Portal ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.clear,
                                    portalColors[0],
                                    Color.clear,
                                    portalColors[1],
                                    Color.clear
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(animationPhase * 30))
                    
                    // Main portal
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: portalColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(portalGlassGradient)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: icon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 6)
                    }
                    .shadow(color: portalColors[0].opacity(0.6), radius: 20, x: 0, y: 10)
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .stroke(
                        LinearGradient(
                            colors: portalColors.map { $0.opacity(0.4) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .shadow(color: portalColors[0].opacity(0.3), radius: 20, x: 0, y: 10)
            )
        }
        .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) { isPressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = isPressing
            }
        } perform: {}
        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
    }
    
    private var portalGlassGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.white.opacity(0.4),
                Color.white.opacity(0.1),
                Color.clear,
                Color.black.opacity(0.2)
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: 40
        )
    }
}

struct RippleEffect: View {
    let center: CGPoint
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 1
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        Color(red: 0.42, green: 0.37, blue: 1.0).opacity(rippleOpacity),
                        lineWidth: 4
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(rippleScale)
                    .position(center)
                    .animation(
                        .easeOut(duration: 1.5).delay(Double(index) * 0.2),
                        value: rippleScale
                    )
            }
        }
        .onAppear {
            withAnimation {
                rippleScale = 4.0
                rippleOpacity = 0.0
            }
        }
    }
}

struct QuantumVoiceSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isListening = false
    @State private var waveAnimation: Double = 0
    
    var body: some View {
        ZStack {
            // Quantum background
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating particles
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 3, height: 3)
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...700)
                    )
                    .opacity(0.4 + sin(waveAnimation + Double(index)) * 0.4)
                    .blur(radius: 1)
            }
            
            VStack(spacing: 50) {
                // Voice visualization with quantum effects
                ZStack {
                    // Quantum field
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        Color.clear,
                                        Color(red: 0.0, green: 1.0, blue: 0.53).opacity(0.6),
                                        Color.clear,
                                        Color(red: 0.0, green: 0.83, blue: 1.0).opacity(0.4),
                                        Color.clear
                                    ],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 180 + CGFloat(index * 40), height: 180 + CGFloat(index * 40))
                            .scaleEffect(isListening ? 1.3 : 0.7)
                            .opacity(isListening ? 0.9 : 0.3)
                            .rotationEffect(.degrees(waveAnimation * 10 + Double(index * 30)))
                            .animation(
                                .easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                                value: isListening
                            )
                    }
                    
                    // Central microphone
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.0, green: 1.0, blue: 0.53).opacity(0.8),
                                        Color(red: 0.0, green: 0.83, blue: 1.0).opacity(0.6),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 10)
                            .scaleEffect(isListening ? 1.2 : 1.0)
                        
                        Text("🎤")
                            .font(.system(size: 80))
                            .scaleEffect(isListening ? 1.1 : 1.0)
                            .shadow(color: Color(red: 0.0, green: 1.0, blue: 0.53).opacity(0.8), radius: 20)
                    }
                    .animation(.easeInOut(duration: 0.3), value: isListening)
                }
                
                VStack(spacing: 20) {
                    Text("Quantum Voice Interface")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .white,
                                    Color(red: 0.0, green: 1.0, blue: 0.53),
                                    Color(red: 0.0, green: 0.83, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(red: 0.0, green: 1.0, blue: 0.53).opacity(0.5), radius: 15)
                    
                    Text(isListening ? "Listening across dimensions..." : "Speak your command")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.3), radius: 5)
                }
                
                VStack(spacing: 24) {
                    Button(action: {
                        isListening.toggle()
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()
                    }) {
                        Text(isListening ? "Stop Listening" : "Start Voice Command")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 18)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.0, green: 1.0, blue: 0.53),
                                                Color(red: 0.0, green: 0.83, blue: 1.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color(red: 0.0, green: 1.0, blue: 0.53).opacity(0.6), radius: 20, x: 0, y: 8)
                            )
                    }
                    
                    Button("Return to Search") {
                        dismiss()
                    }
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.42, green: 0.37, blue: 1.0))
                    .shadow(color: Color(red: 0.42, green: 0.37, blue: 1.0).opacity(0.5), radius: 10)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                waveAnimation = 2 * .pi
            }
        }
    }
}

// MARK: - Enhanced SearchManager with Repository Integration

class SearchManager: ObservableObject {
    @Published var searchResults: [Pokemon] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var recentSearches: [String] = []
    @Published var selectedFilters: SearchFilters = SearchFilters()
    
    private let repository = PokemonRepository.shared
    private var cancellables = Set<AnyCancellable>()
    private let recentSearchesKey = "recentSearches"
    
    init() {
        loadRecentSearches()
        setupReactiveSearch()
    }
    
    func updateSearchQuery(_ query: String) {
        searchQuery = query
        
        if !query.isEmpty {
            performQuantumSearch(query: query)
        } else {
            searchResults = []
        }
    }
    
    private func setupReactiveSearch() {
        // Debounced search for real-time results
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    self?.performQuantumSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    private func performQuantumSearch(query: String) {
        isLoading = true
        
        Task {
            do {
                // Natural language processing
                let processedQuery = processNaturalLanguage(query)
                
                // Perform search based on query type
                let results = try await performSearch(for: processedQuery)
                
                await MainActor.run {
                    self.searchResults = results
                    self.isLoading = false
                    self.addToRecentSearches(query)
                }
            } catch {
                await MainActor.run {
                    self.searchResults = []
                    self.isLoading = false
                    print("Search error: \(error)")
                }
            }
        }
    }
    
    private func processNaturalLanguage(_ query: String) -> ProcessedQuery {
        let lowercased = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Type-based searches
        for type in PokemonType.allCases {
            if lowercased.contains(type.rawValue) {
                return .type(type)
            }
        }
        
        // Generation searches
        if lowercased.contains("gen") || lowercased.contains("generation") {
            for i in 1...9 {
                if lowercased.contains("\(i)") {
                    return .generation(i)
                }
            }
        }
        
        // Region searches
        let regions = ["kanto", "johto", "hoenn", "sinnoh", "unova", "kalos", "alola", "galar", "paldea"]
        for region in regions {
            if lowercased.contains(region) {
                return .region(region)
            }
        }
        
        // Special categories
        if lowercased.contains("legendary") || lowercased.contains("legend") {
            return .category(.legendary)
        }
        if lowercased.contains("starter") {
            return .category(.starter)
        }
        if lowercased.contains("evolution") || lowercased.contains("evolve") {
            return .category(.evolution)
        }
        
        // Default to name search with fuzzy matching
        return .name(query)
    }
    
    private func performSearch(for query: ProcessedQuery) async throws -> [Pokemon] {
        switch query {
        case .name(let name):
            return try await fuzzySearchByName(name)
        case .type(let type):
            return try await searchByType(type)
        case .generation(let gen):
            return try await searchByGeneration(gen)
        case .region(let region):
            return try await searchByRegion(region)
        case .category(let category):
            return try await searchByCategory(category)
        }
    }
    
    // Fixed fuzzy search method
    private func fuzzySearchByName(_ name: String) async throws -> [Pokemon] {
        // Get all Pokemon list items first
        let allPokemon = try await repository.fetchPokemonList(limit: 1000, offset: 0)
        
        // Filter and calculate distances synchronously
        let relevantMatches = allPokemon.compactMap { pokemonItem -> (PokemonListItem, Int)? in
            let distance = levenshteinDistance(name.lowercased(), pokemonItem.name.lowercased())
            let threshold = max(2, name.count / 3) // Allow 1/3 character differences
            
            if distance <= threshold || pokemonItem.name.lowercased().contains(name.lowercased()) {
                return (pokemonItem, distance)
            }
            return nil
        }
        
        // Sort by relevance (lower distance = higher relevance)
        let sortedMatches = relevantMatches.sorted { match1, match2 in
            let (pokemon1Item, distance1) = match1
            let (pokemon2Item, distance2) = match2
            
            // Exact matches first
            if pokemon1Item.name.lowercased() == name.lowercased() { return true }
            if pokemon2Item.name.lowercased() == name.lowercased() { return false }
            
            // Then starts with
            let name1Starts = pokemon1Item.name.lowercased().hasPrefix(name.lowercased())
            let name2Starts = pokemon2Item.name.lowercased().hasPrefix(name.lowercased())
            if name1Starts != name2Starts { return name1Starts }
            
            // Then by distance (lower is better)
            if distance1 != distance2 { return distance1 < distance2 }
            
            // Finally by ID (original order)
            return pokemon1Item.id < pokemon2Item.id
        }
        
        // Take top 20 results and fetch full Pokemon data
        let topMatches = Array(sortedMatches.prefix(20))
        
        // Fetch full Pokemon data using TaskGroup for concurrent requests
        return await withTaskGroup(of: (Pokemon?, Int).self) { group in
            // Add tasks for each Pokemon
            for (index, (pokemonItem, _)) in topMatches.enumerated() {
                group.addTask {
                    do {
                        let pokemon = try await self.repository.fetchPokemon(id: pokemonItem.id)
                        return (pokemon, index) // Include index to maintain order
                    } catch {
                        print("Failed to fetch Pokemon \(pokemonItem.id): \(error)")
                        return (nil, index)
                    }
                }
            }
            
            // Collect results and maintain order
            var results: [(Pokemon, Int)] = []
            for await (pokemon, index) in group {
                if let pokemon = pokemon {
                    results.append((pokemon, index))
                }
            }
            
            // Sort by original order and return Pokemon array
            return results
                .sorted { $0.1 < $1.1 } // Sort by index to maintain relevance order
                .map { $0.0 } // Extract just the Pokemon objects
        }
    }
    
    private func searchByType(_ type: PokemonType) async throws -> [Pokemon] {
        let typeResults = try await repository.fetchPokemonByType(type)
        
        // Take first 20 results
        let limitedResults = Array(typeResults.prefix(20))
        
        // Use TaskGroup for concurrent fetching
        return await withTaskGroup(of: (Pokemon?, Int).self) { group in
            for (index, item) in limitedResults.enumerated() {
                group.addTask {
                    do {
                        let pokemon = try await self.repository.fetchPokemon(id: item.id)
                        return (pokemon, index)
                    } catch {
                        print("Failed to fetch Pokemon \(item.id): \(error)")
                        return (nil, index)
                    }
                }
            }
            
            var results: [(Pokemon, Int)] = []
            for await (pokemon, index) in group {
                if let pokemon = pokemon {
                    results.append((pokemon, index))
                }
            }
            
            return results
                .sorted { $0.1 < $1.1 } // Maintain order
                .map { $0.0 }
        }
    }
    
    private func searchByGeneration(_ generation: Int) async throws -> [Pokemon] {
        // Generation ranges (approximate)
        let ranges: [Int: Range<Int>] = [
            1: 1..<152,
            2: 152..<252,
            3: 252..<387,
            4: 387..<494,
            5: 494..<650,
            6: 650..<722,
            7: 722..<810,
            8: 810..<906,
            9: 906..<1011
        ]
        
        guard let range = ranges[generation] else { return [] }
        
        // Take first 20 from the range
        let pokemonIds = Array(range.prefix(20))
        
        return await withTaskGroup(of: (Pokemon?, Int).self) { group in
            for (index, id) in pokemonIds.enumerated() {
                group.addTask {
                    do {
                        let pokemon = try await self.repository.fetchPokemon(id: id)
                        return (pokemon, index)
                    } catch {
                        print("Failed to fetch Pokemon \(id): \(error)")
                        return (nil, index)
                    }
                }
            }
            
            var results: [(Pokemon, Int)] = []
            for await (pokemon, index) in group {
                if let pokemon = pokemon {
                    results.append((pokemon, index))
                }
            }
            
            return results
                .sorted { $0.1 < $1.1 } // Maintain ID order
                .map { $0.0 }
        }
    }
    
    private func searchByRegion(_ region: String) async throws -> [Pokemon] {
        // This would need region data integration
        // For now, map to generations
        let regionToGen: [String: Int] = [
            "kanto": 1, "johto": 2, "hoenn": 3, "sinnoh": 4,
            "unova": 5, "kalos": 6, "alola": 7, "galar": 8, "paldea": 9
        ]
        
        if let generation = regionToGen[region.lowercased()] {
            return try await searchByGeneration(generation)
        }
        
        return []
    }
    
    private func searchByCategory(_ category: SearchCategory) async throws -> [Pokemon] {
        let pokemonIds: [Int]
        
        switch category {
        case .legendary:
            // Legendary Pokemon IDs (expanded list)
            pokemonIds = [150, 151, 144, 145, 146, 249, 250, 251, 243, 244, 245,
                         377, 378, 379, 380, 381, 382, 383, 384, 385, 386,
                         480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493]
            
        case .starter:
            // All starter Pokemon IDs
            pokemonIds = [1, 4, 7, 152, 155, 158, 252, 255, 258, 387, 390, 393,
                         495, 498, 501, 650, 653, 656, 722, 725, 728, 810, 813, 816]
            
        case .evolution:
            // Pokemon that evolve (sample set)
            pokemonIds = [1, 4, 7, 10, 13, 16, 19, 21, 23, 25, 27, 29, 32, 35, 37, 39, 41, 43, 46, 48]
        }
        
        // Take first 20 results
        let limitedIds = Array(pokemonIds.prefix(20))
        
        return await withTaskGroup(of: (Pokemon?, Int).self) { group in
            for (index, id) in limitedIds.enumerated() {
                group.addTask {
                    do {
                        let pokemon = try await self.repository.fetchPokemon(id: id)
                        return (pokemon, index)
                    } catch {
                        print("Failed to fetch Pokemon \(id): \(error)")
                        return (nil, index)
                    }
                }
            }
            
            var results: [(Pokemon, Int)] = []
            for await (pokemon, index) in group {
                if let pokemon = pokemon {
                    results.append((pokemon, index))
                }
            }
            
            return results
                .sorted { $0.1 < $1.1 } // Maintain order
                .map { $0.0 }
        }
    }
    
    // MARK: - Recent Searches
    
    private func addToRecentSearches(_ query: String) {
        guard !query.isEmpty else { return }
        
        // Remove if already exists
        recentSearches.removeAll { $0.lowercased() == query.lowercased() }
        
        // Add to beginning
        recentSearches.insert(query, at: 0)
        
        // Keep only last 10
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    // MARK: - Filters
    
    func applyFilters(_ filters: SearchFilters) {
        selectedFilters = filters
        if !searchQuery.isEmpty {
            performQuantumSearch(query: searchQuery)
        }
    }
    
    func clearFilters() {
        selectedFilters = SearchFilters()
        if !searchQuery.isEmpty {
            performQuantumSearch(query: searchQuery)
        }
    }
}

// MARK: - Supporting Types

enum ProcessedQuery {
    case name(String)
    case type(PokemonType)
    case generation(Int)
    case region(String)
    case category(SearchCategory)
}

enum SearchCategory {
    case legendary
    case starter
    case evolution
}

struct SearchFilters {
    var types: Set<PokemonType> = []
    var generations: Set<Int> = []
    var minStats: Int? = nil
    var maxStats: Int? = nil
    var hasEvolution: Bool? = nil
    
    var isActive: Bool {
        !types.isEmpty || !generations.isEmpty || minStats != nil || maxStats != nil || hasEvolution != nil
    }
}

// MARK: - Fuzzy Matching Algorithm

func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
    let a = Array(s1)
    let b = Array(s2)
    let m = a.count
    let n = b.count
    
    if m == 0 { return n }
    if n == 0 { return m }
    
    var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
    
    for i in 0...m {
        matrix[i][0] = i
    }
    
    for j in 0...n {
        matrix[0][j] = j
    }
    
    for i in 1...m {
        for j in 1...n {
            let cost = a[i-1] == b[j-1] ? 0 : 1
            matrix[i][j] = min(
                matrix[i-1][j] + 1,      // deletion
                matrix[i][j-1] + 1,      // insertion
                matrix[i-1][j-1] + cost  // substitution
            )
        }
    }
    
    return matrix[m][n]
}

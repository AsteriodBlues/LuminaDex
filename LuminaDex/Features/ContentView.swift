//
//  ContentView.swift
//  LuminaDx
//
//  Created by Ritwik on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var companionManager = CompanionManager()
    @EnvironmentObject var dataFetcher: PokemonDataFetcher
    @EnvironmentObject var database: DatabaseManager
    @State private var selectedTab = 0
    @State private var showWorldMap = false
    @State private var showCompanionSelection = false
    @State private var isAnimating = false
    @State private var needsDataLoading = false
    @State private var hasCheckedDatabase = false
    
    var body: some View {
        Group {
            if needsDataLoading || dataFetcher.isLoading {
                DataLoadingView()
                    .environmentObject(dataFetcher)
            } else if showCompanionSelection {
                companionSelectionView
            } else if companionManager.currentCompanion != nil {
                mainTabView
            } else {
                welcomeScreen
            }
        }
        .onAppear {
            if !hasCheckedDatabase {
                Task {
                    // Check if we need to fetch data
                    let info = try? await database.getDatabaseInfo()
                    if info?.pokemonCount == 0 {
                        print("🚀 Starting initial data fetch...")
                        needsDataLoading = true
                        await dataFetcher.fetchAllPokemonData()
                        needsDataLoading = false
                    }
                    hasCheckedDatabase = true
                }
            }
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // Neural Flow Map
            ZStack {
                NeuralFlowMapView(companionManager: companionManager)
                CompanionOverlay(companionManager: companionManager)
                CompanionControlPanel(companionManager: companionManager)
            }
            .tabItem {
                Image(systemName: "brain.head.profile")
                Text("Neural Flow")
            }
            .tag(0)
            
            // Collection View
            CollectionView()
                .tabItem {
                    Image(systemName: "square.grid.3x3.fill")
                    Text("Collection")
                }
                .tag(1)
            
            // Search & Discovery
            PokemonSearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(2)
            
            // Team Builder
            TeamBuilderView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Team")
                }
                .tag(3)
            
            // Move Encyclopedia
            MoveEncyclopediaView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Moves")
                }
                .tag(4)
            
            // Pokeball Collection
            PokeballCollectionView()
                .tabItem {
                    Image(systemName: "circle.circle.fill")
                    Text("Pokéballs")
                }
                .tag(5)
            
            // Berry Collection
            BerryListView()
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Berries")
                }
                .tag(6)
            
            // Gym Badges
            GymBadgeListView()
                .tabItem {
                    Image(systemName: "shield.fill")
                    Text("Badges")
                }
                .tag(7)
            
            // Characters
            CharacterListView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Characters")
                }
                .tag(8)
            
            // Ribbons
            RibbonListView()
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Ribbons")
                }
                .tag(9)
            
            // Achievements
            EnhancedAchievementsView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Achievements")
                }
                .tag(10)
            
            // Profile & Stats
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(11)
        }
        .accentColor(ThemeManager.Colors.neural)
    }
    
    private var companionSelectionView: some View {
        CompanionSelectionView { selectedCompanion in
            companionManager.selectCompanion(selectedCompanion)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                showCompanionSelection = false
            }
            
            // Position companion in center of screen initially
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                companionManager.updateCompanionPosition(to: CGPoint(x: 200, y: 400))
            }
        }
        .transition(.asymmetric(
            insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
            removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
        ))
    }
    
    private var welcomeScreen: some View {
        ZStack {
            // Background gradient
            ThemeManager.Colors.spaceGradient
                .ignoresSafeArea()
            
            VStack(spacing: ThemeManager.Spacing.xl) {
                // Hero title with Dynamic Island preview
                VStack(spacing: ThemeManager.Spacing.md) {
                    Text("LuminaDex")
                        .font(ThemeManager.Typography.displayHeavy)
                        .foregroundStyle(ThemeManager.Colors.neuralGradient)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(ThemeManager.Animation.springBouncy.delay(0.2), value: isAnimating)
                    
                    Text("The Future of Pokémon Discovery")
                        .font(ThemeManager.Typography.bodyLarge)
                        .foregroundColor(ThemeManager.Colors.lumina.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(ThemeManager.Animation.easeInOut.delay(0.6), value: isAnimating)
                    
                    // Dynamic Island preview
                    if isAnimating {
                        dynamicIslandPreview
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                            .animation(ThemeManager.Animation.springBouncy.delay(1.0), value: isAnimating)
                    }
                }
                
                // Feature highlights
                featureHighlights
                
                // Launch button
                launchButton
            }
            .padding(ThemeManager.Spacing.xl)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private var dynamicIslandPreview: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(.yellow)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Text("⚡")
                            .font(.system(size: 10))
                    )
                
                Text("KT")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Circle()
                    .fill(.green)
                    .frame(width: 4, height: 4)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.black)
                    .overlay(
                        Capsule()
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
            
            Text("Live Activity on Dynamic Island")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var featureHighlights: some View {
        VStack(spacing: ThemeManager.Spacing.lg) {
            // Feature cards
            VStack(spacing: ThemeManager.Spacing.md) {
                featureCard(
                    icon: "brain.head.profile",
                    title: "Neural Network Map",
                    description: "Explore regions as living neural nodes with flowing energy streams",
                    delay: 0.8
                )
                
                featureCard(
                    icon: "heart.fill",
                    title: "Living Companion System",
                    description: "Your AI companion grows, learns, and reacts to discoveries",
                    delay: 1.0
                )
                
                featureCard(
                    icon: "sparkles",
                    title: "Dynamic Island Integration",
                    description: "Live activities show your exploration progress in real-time",
                    delay: 1.2
                )
            }
        }
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(ThemeManager.Animation.easeInOut.delay(0.8), value: isAnimating)
    }
    
    private func featureCard(icon: String, title: String, description: String, delay: Double) -> some View {
        HStack(spacing: ThemeManager.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(ThemeManager.Colors.auroraGradient)
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(ThemeManager.Animation.springSmooth.delay(delay), value: isAnimating)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ThemeManager.Typography.headlineBold)
                    .foregroundColor(ThemeManager.Colors.lumina)
                
                Text(description)
                    .font(ThemeManager.Typography.bodySmall)
                    .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(ThemeManager.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.Colors.glassMaterial)
                .stroke(ThemeManager.Colors.glassStroke, lineWidth: 1)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .animation(ThemeManager.Animation.springBouncy.delay(delay), value: isAnimating)
    }
    
    private var launchButton: some View {
        Button(action: {
            if companionManager.currentCompanion != nil {
                // Already has companion, go to main app
                return
            } else {
                showCompanionSelection = true
            }
        }) {
            HStack(spacing: 12) {
                if companionManager.currentCompanion != nil {
                    Text("Enter the Neural Flow")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Text("Choose Your Companion")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeManager.Colors.neuralGradient)
                    .shadow(color: ThemeManager.Colors.neural.opacity(0.3), radius: 8)
            )
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .shadow(color: ThemeManager.Colors.neural.opacity(0.5), radius: isAnimating ? 15 : 0)
        }
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(ThemeManager.Animation.springBouncy.delay(1.6), value: isAnimating)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
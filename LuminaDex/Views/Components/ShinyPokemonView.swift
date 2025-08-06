//
//  ShinyPokemonView.swift
//  LuminaDex
//
//  Shiny Pokemon Display System
//

import SwiftUI
import NukeUI

struct ShinyPokemonView: View {
    let pokemon: Pokemon
    @State private var isShiny = false
    @State private var sparkleAnimation = false
    @State private var showingShinyAlert = false
    @State private var hasFoundShiny = false
    
    // Shiny odds (1 in 4096 normally, 1 in 512 with charm)
    @AppStorage("hasShinyCharm") private var hasShinyCharm = false
    
    private var shinyOdds: Int {
        hasShinyCharm ? 512 : 4096
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Pokemon Image with Shiny Toggle
            ZStack {
                // Background glow for shiny
                if isShiny {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.yellow.opacity(0.8),
                                    Color.yellow.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .blur(radius: 20)
                        .scaleEffect(sparkleAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: sparkleAnimation)
                }
                
                // Pokemon Sprite
                LazyImage(url: URL(string: spriteURL)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else if state.error != nil {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
                .frame(width: 200, height: 200)
                
                // Sparkle effects for shiny
                if isShiny {
                    ForEach(0..<8, id: \.self) { index in
                        SparkleView()
                            .position(sparklePosition(for: index))
                            .animation(
                                .easeInOut(duration: Double.random(in: 1.5...3))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: sparkleAnimation
                            )
                    }
                }
            }
            .frame(width: 250, height: 250)
            .onAppear {
                sparkleAnimation = true
            }
            
            // Shiny Toggle Controls
            HStack(spacing: 20) {
                // Normal/Shiny Toggle
                Button(action: {
                    withAnimation(.spring()) {
                        isShiny.toggle()
                        
                        if isShiny && !hasFoundShiny {
                            checkForShinyEncounter()
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isShiny ? "sparkles" : "circle")
                            .font(.system(size: 16))
                        Text(isShiny ? "Shiny" : "Normal")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(isShiny ? .yellow : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isShiny ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(isShiny ? Color.yellow : Color.gray, lineWidth: 1)
                            )
                    )
                }
                
                // Shiny Hunt Button
                Button(action: startShinyHunt) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                        Text("Hunt")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.mint)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.mint.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.mint, lineWidth: 1)
                            )
                    )
                }
            }
            
            // Shiny Info Card
            if isShiny {
                ShinyInfoCard(pokemon: pokemon, hasFoundShiny: hasFoundShiny)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
        .alert("✨ Shiny Found!", isPresented: $showingShinyAlert) {
            Button("Awesome!") {
                hasFoundShiny = true
                saveShinyEncounter()
            }
        } message: {
            Text("Congratulations! You found a shiny \(pokemon.displayName)! The odds were 1 in \(shinyOdds)!")
        }
    }
    
    private var spriteURL: String {
        if isShiny {
            return pokemon.sprites.frontShiny ?? 
                   "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/\(pokemon.id).png"
        } else {
            return pokemon.sprites.officialArtwork
        }
    }
    
    private func sparklePosition(for index: Int) -> CGPoint {
        let angle = Double(index) * (360.0 / 8.0) * .pi / 180
        let radius: Double = 100
        let x = 125 + radius * cos(angle)
        let y = 125 + radius * sin(angle)
        return CGPoint(x: x, y: y)
    }
    
    private func checkForShinyEncounter() {
        let roll = Int.random(in: 1...shinyOdds)
        if roll == 1 {
            showingShinyAlert = true
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
    }
    
    private func startShinyHunt() {
        // Implement shiny hunting mini-game
        // This could open a new view for shiny hunting
    }
    
    private func saveShinyEncounter() {
        // Save to UserDefaults or database
        UserDefaults.standard.set(true, forKey: "shiny_\(pokemon.id)")
    }
}

// MARK: - Sparkle View
struct SparkleView: View {
    @State private var scale: Double = 0.5
    @State private var opacity: Double = 0.0
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 16))
            .foregroundColor(.yellow)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    scale = 1.5
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Shiny Info Card
struct ShinyInfoCard: View {
    let pokemon: Pokemon
    let hasFoundShiny: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Shiny Variant")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if hasFoundShiny {
                    Label("Captured", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            
            Text("Shiny Pokémon are extremely rare color variations with special sparkle effects. They have the same stats but feature unique colorations.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 16) {
                ShinyStatItem(
                    title: "Base Odds",
                    value: "1/4096",
                    icon: "percent",
                    color: .blue
                )
                
                ShinyStatItem(
                    title: "With Charm",
                    value: "1/512",
                    icon: "star.circle",
                    color: .yellow
                )
                
                ShinyStatItem(
                    title: "Rarity",
                    value: "Ultra Rare",
                    icon: "crown",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Shiny Stat Item
struct ShinyStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Shiny Toggle Button (For Grid/List Views)
struct ShinyToggleButton: View {
    @Binding var showShiny: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                showShiny.toggle()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: showShiny ? "sparkles" : "sparkle")
                    .font(.system(size: 14))
                Text(showShiny ? "Shiny" : "Normal")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(showShiny ? .black : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(showShiny ? Color.yellow : Color.gray.opacity(0.3))
            )
        }
    }
}

// MARK: - Shiny Collection Tracker
struct ShinyCollectionTracker: View {
    let totalPokemon: Int
    @AppStorage("shinyCount") private var shinyCount = 0
    
    private var percentage: Double {
        guard totalPokemon > 0 else { return 0 }
        return Double(shinyCount) / Double(totalPokemon) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Shiny Collection")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(shinyCount)/\(totalPokemon)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (percentage / 100), height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(String(format: "%.1f", percentage))% Complete")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}
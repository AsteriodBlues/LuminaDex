//
//  PokemonGridCard.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//

import SwiftUI

struct PokemonGridCard: View {
    let pokemon: Pokemon
    let viewModel: CollectionViewModel
    @State private var isPressed = false
    @State private var spriteRotation = 0.0
    @State private var showCelebration = false
    @State private var pulseScale = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("#\(String(format: "%03d", pokemon.id))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                
                Spacer()
                
                Button(action: { 
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        viewModel.toggleFavorite(for: pokemon)
                        spriteRotation += 360
                        if pokemon.isFavorite {
                            showHeartCelebration()
                        }
                    }
                }) {
                    Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(pokemon.isFavorite ? .red : .gray)
                        .font(.system(size: 16, weight: .semibold))
                }
                .scaleEffect(pokemon.isFavorite ? 1.2 : 1.0)
                .animation(.spring(response: 0.3), value: pokemon.isFavorite)
            }
            
            // Interactive Pokemon Sprite
            ZStack {
                // Sprite with reactions
                ImageManager.shared.loadThumbnail(url: pokemon.sprites.frontDefault)
                    .frame(width: 60, height: 60)
                .scaleEffect(isPressed ? 0.85 : pulseScale)
                .rotationEffect(.degrees(spriteRotation))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
                .animation(.spring(response: 0.6, dampingFraction: 0.5), value: spriteRotation)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        spriteRotation += 15
                        triggerHappyReaction()
                    }
                }
                
                // Celebration particles
                if showCelebration {
                    CelebrationParticles()
                }
            }
            
            // Name with dynamic color
            Text(pokemon.displayName.capitalized)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(pokemon.isCaught ? .primary : .secondary)
                .animation(.easeInOut, value: pokemon.isCaught)
            
            // Types with improved design
            HStack(spacing: 4) {
                ForEach(pokemon.types, id: \.slot) { typeSlot in
                    HStack(spacing: 2) {
                        Text(typeSlot.pokemonType.emoji)
                            .font(.caption2)
                        Text(typeSlot.pokemonType.rawValue.capitalized)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(typeSlot.pokemonType.color.opacity(0.2), in: Capsule())
                    .overlay(Capsule().stroke(typeSlot.pokemonType.color.opacity(0.6), lineWidth: 1))
                }
            }
            
            // Enhanced Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Discovery")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(pokemon.progress))%")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(progressColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        // Progress fill with gradient
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [progressColor.opacity(0.8), progressColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (pokemon.progress / 100.0), height: 6)
                            .animation(.easeInOut(duration: 0.5), value: pokemon.progress)
                    }
                }
                .frame(height: 6)
            }
            
            // Status indicators
            HStack(spacing: 8) {
                if pokemon.isCaught {
                    Label("Caught", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
                
                if pokemon.progress > 0 && pokemon.progress < 100 {
                    Label("Exploring", systemImage: "eye.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Rarity indicator
                if pokemon.id <= 151 {
                    Text("Gen I")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1), in: Capsule())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    pokemon.isFavorite ? 
                        .linearGradient(colors: [.red.opacity(0.6), .pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        .linearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: pokemon.isFavorite ? 2 : 1
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(pokemon.isFavorite ? 0.2 : 0.1), radius: pokemon.isFavorite ? 15 : 10, x: 0, y: 5)
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.3)) {
                triggerCuriousReaction()
            }
        }
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                viewModel.toggleCaught(for: pokemon)
                if pokemon.isCaught {
                    showCatchCelebration()
                }
            }
        }
        .onAppear {
            startIdleAnimation()
        }
    }
    
    // MARK: - Computed Properties
    private var progressColor: Color {
        switch pokemon.progress {
        case 0..<25: return .red
        case 25..<50: return .orange
        case 50..<75: return .yellow
        case 75..<100: return .blue
        default: return .green
        }
    }
    
    // MARK: - Sprite Reactions
    private func getSpriteEmoji() -> String {
        if pokemon.isCaught {
            return "😊" // Happy when caught
        } else if pokemon.progress > 50 {
            return "🤔" // Curious when partially discovered
        } else if pokemon.isFavorite {
            return "😍" // Love eyes when favorited
        } else {
            return pokemon.sprite
        }
    }
    
    private func triggerHappyReaction() {
        withAnimation(.easeInOut(duration: 0.3)) {
            pulseScale = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                pulseScale = 1.0
            }
        }
    }
    
    private func triggerCuriousReaction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            spriteRotation += 5
        }
    }
    
    private func showHeartCelebration() {
        showCelebration = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showCelebration = false
        }
    }
    
    private func showCatchCelebration() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            spriteRotation += 720 // Two full rotations
            pulseScale = 1.3
        }
        
        showCelebration = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                pulseScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCelebration = false
        }
    }
    
    private func startIdleAnimation() {
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 3...6), repeats: true) { _ in
            if !isPressed && !showCelebration {
                withAnimation(.easeInOut(duration: 0.5)) {
                    pulseScale = 1.05
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        pulseScale = 1.0
                    }
                }
            }
        }
    }
}

// MARK: - Celebration Particles
struct CelebrationParticles: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(Color.random)
                    .frame(width: 4, height: 4)
                    .offset(
                        x: animate ? CGFloat.random(in: -30...30) : 0,
                        y: animate ? CGFloat.random(in: -30...30) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 0.8)
                        .delay(Double(index) * 0.1),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

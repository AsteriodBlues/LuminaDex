//
//  TypeEffectivenessView.swift
//  LuminaDex
//
//  Day 18: Interactive Type Relationships with Sprite Battles
//

import SwiftUI

struct TypeEffectivenessView: View {
    let pokemon: Pokemon
    @State private var selectedAttackingType: PokemonType = .normal
    @State private var showBattleDemo = false
    @State private var animationPhase: CGFloat = 0
    @State private var battleResult: BattleResult?
    
    // Battle animation states
    @State private var attackingSprite = AnimatedBattleSprite()
    @State private var defendingSprite = AnimatedBattleSprite()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with battle arena
            battleArenaHeader
            
            // Type effectiveness matrix
            typeMatrix
            
            // Battle demonstration area
            if showBattleDemo {
                battleDemoSection
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
            
            // Quick reference guide
            quickReferenceGuide
        }
        .background(
            LinearGradient(
                colors: [
                    ThemeManager.Colors.deepSpace,
                    pokemon.primaryType.color.opacity(0.1),
                    ThemeManager.Colors.deepSpace
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            startAnimations()
        }
    }
    
    private var battleArenaHeader: some View {
        headerContent
            .padding(ThemeManager.Spacing.lg)
            .background(headerBackground)
            .padding(.horizontal, ThemeManager.Spacing.lg)
            .padding(.top, ThemeManager.Spacing.lg)
    }
    
    private var headerContent: some View {
        VStack(spacing: ThemeManager.Spacing.md) {
            titleSection
            typesSection
            instructionText
        }
    }
    
    private var titleSection: some View {
        HStack {
            sparkIcon(rotation: animationPhase * 10)
            titleText
            sparkIcon(rotation: -animationPhase * 10)
        }
    }
    
    private func sparkIcon(rotation: CGFloat) -> some View {
        Image(systemName: "bolt.batteryblock.fill")
            .foregroundColor(.yellow)
            .rotationEffect(.degrees(rotation))
    }
    
    private var titleText: some View {
        Text("Type Effectiveness")
            .font(ThemeManager.Typography.displaySemibold)
            .foregroundStyle(ThemeManager.Colors.neuralGradient)
    }
    
    private var typesSection: some View {
        HStack(spacing: ThemeManager.Spacing.sm) {
            ForEach(pokemon.types, id: \.slot) { typeSlot in
                TypeBadge(
                    type: typeSlot.pokemonType,
                    isDefending: true,
                    glowIntensity: 0.6 + sin(Double(animationPhase + CGFloat(typeSlot.slot))) * 0.3
                )
            }
        }
    }
    
    private var instructionText: some View {
        Text("Tap any attacking type to see battle effectiveness")
            .font(ThemeManager.Typography.bodySmall)
            .foregroundColor(ThemeManager.Colors.lumina.opacity(0.7))
            .multilineTextAlignment(.center)
    }
    
    private var headerBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(ThemeManager.Colors.glassMaterial)
            .stroke(ThemeManager.Colors.glassStroke, lineWidth: 1)
    }
    
    private var typeMatrix: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
            ForEach(PokemonType.allCases.filter { $0 != .unknown }, id: \.self) { attackingType in
                TypeEffectivenessCell(
                    attackingType: attackingType,
                    defendingTypes: pokemon.types.map { $0.pokemonType },
                    isSelected: selectedAttackingType == attackingType,
                    animationPhase: animationPhase
                ) {
                    handleTypeSelection(attackingType)
                }
            }
        }
        .padding(ThemeManager.Spacing.lg)
    }
    
    private var battleDemoSection: some View {
        battleDemoContent
            .padding(ThemeManager.Spacing.lg)
            .background(battleDemoBackground)
            .padding(.horizontal, ThemeManager.Spacing.lg)
    }
    
    private var battleDemoContent: some View {
        VStack(spacing: ThemeManager.Spacing.lg) {
            battleArena
            
            if let result = battleResult {
                BattleResultCard(result: result, animationPhase: animationPhase)
            }
            
            simulateBattleButton
        }
    }
    
    private var battleDemoBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(ThemeManager.Colors.glassMaterial)
            .stroke(ThemeManager.Colors.glassStroke, lineWidth: 1)
    }
    
    private var battleArena: some View {
        ZStack {
            arenaFloor
            battleSprites
        }
    }
    
    private var arenaFloor: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(arenaGradient)
            .frame(height: 200)
            .overlay(energyParticles)
    }
    
    private var arenaGradient: RadialGradient {
        RadialGradient(
            colors: [
                selectedAttackingType.color.opacity(0.2),
                ThemeManager.Colors.deepSpace.opacity(0.8),
                ThemeManager.Colors.deepSpace
            ],
            center: .center,
            startRadius: 50,
            endRadius: 200
        )
    }
    
    private var energyParticles: some View {
        ForEach(0..<15, id: \.self) { index in
            Circle()
                .fill(selectedAttackingType.color.opacity(0.6))
                .frame(width: 4, height: 4)
                .offset(
                    x: cos(Double(animationPhase + CGFloat(index) * 0.4)) * 80,
                    y: sin(Double(animationPhase + CGFloat(index) * 0.4)) * 40
                )
                .opacity(0.7 + sin(Double(animationPhase * 2 + CGFloat(index))) * 0.3)
        }
    }
    
    private var battleSprites: some View {
        HStack(spacing: 80) {
            attackingSpriteSection
            vsIndicator
            defendingSpriteSection
        }
    }
    
    private var attackingSpriteSection: some View {
        VStack {
            BattleSpriteView(
                sprite: attackingSprite,
                type: selectedAttackingType,
                isAttacking: true
            )
            
            Text(selectedAttackingType.displayName)
                .font(ThemeManager.Typography.captionBold)
                .foregroundColor(selectedAttackingType.color)
        }
    }
    
    private var vsIndicator: some View {
        ZStack {
            energyBeam
            vsText
        }
    }
    
    private var energyBeam: some View {
        Rectangle()
            .fill(energyBeamGradient)
            .frame(width: 60, height: 4)
            .scaleEffect(x: 1.0 + sin(Double(animationPhase * 4)) * 0.2, y: 1.0)
    }
    
    private var energyBeamGradient: LinearGradient {
        LinearGradient(
            colors: [
                selectedAttackingType.color.opacity(0.8),
                selectedAttackingType.color.opacity(0.3),
                pokemon.primaryType.color.opacity(0.3),
                pokemon.primaryType.color.opacity(0.8)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var vsText: some View {
        Text("VS")
            .font(ThemeManager.Typography.headlineBold)
            .foregroundColor(.white)
            .background(
                Circle()
                    .fill(ThemeManager.Colors.deepSpace)
                    .frame(width: 40, height: 40)
            )
    }
    
    private var defendingSpriteSection: some View {
        VStack {
            BattleSpriteView(
                sprite: defendingSprite,
                type: pokemon.primaryType,
                isAttacking: false
            )
            
            Text(pokemon.displayName)
                .font(ThemeManager.Typography.captionBold)
                .foregroundColor(pokemon.primaryType.color)
        }
    }
    
    private var simulateBattleButton: some View {
        Button(action: simulateBattle) {
            HStack {
                Image(systemName: "play.circle.fill")
                Text("Simulate Battle")
                    .font(ThemeManager.Typography.bodyMedium.weight(.semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, ThemeManager.Spacing.xl)
            .padding(.vertical, ThemeManager.Spacing.md)
            .background(simulateBattleButtonBackground)
        }
    }
    
    private var simulateBattleButtonBackground: some View {
        Capsule()
            .fill(selectedAttackingType.gradient)
            .shadow(color: selectedAttackingType.color.opacity(0.5), radius: 8)
    }
    
    private var quickReferenceGuide: some View {
        VStack(alignment: .leading, spacing: ThemeManager.Spacing.sm) {
            Text("Quick Reference")
                .font(ThemeManager.Typography.headerMedium)
                .foregroundColor(ThemeManager.Colors.lumina)
            
            HStack(spacing: ThemeManager.Spacing.xl) {
                EffectivenessIndicator(
                    multiplier: 2.0,
                    label: "Super Effective",
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
                
                EffectivenessIndicator(
                    multiplier: 1.0,
                    label: "Normal Damage",
                    color: .gray,
                    icon: "equal.circle.fill"
                )
                
                EffectivenessIndicator(
                    multiplier: 0.5,
                    label: "Not Very Effective",
                    color: .orange,
                    icon: "arrow.down.circle.fill"
                )
                
                EffectivenessIndicator(
                    multiplier: 0.0,
                    label: "No Effect",
                    color: .red,
                    icon: "xmark.circle.fill"
                )
            }
        }
        .padding(ThemeManager.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.Colors.glassMaterial)
                .stroke(ThemeManager.Colors.glassStroke, lineWidth: 1)
        )
        .padding(ThemeManager.Spacing.lg)
    }
    
    // MARK: - Helper Methods
    
    private func handleTypeSelection(_ type: PokemonType) {
        selectedAttackingType = type
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showBattleDemo = true
        }
        
        // Reset battle state
        battleResult = nil
        resetSpriteAnimations()
    }
    
    private func simulateBattle() {
        let effectiveness = TypeEffectiveness.effectiveness(
            attackingType: selectedAttackingType,
            defendingTypes: pokemon.types.map { $0.pokemonType }
        )
        
        battleResult = BattleResult(
            attackingType: selectedAttackingType,
            defendingPokemon: pokemon,
            effectiveness: effectiveness,
            damage: calculateDamage(effectiveness: effectiveness)
        )
        
        // Trigger battle animations
        triggerBattleAnimations()
    }
    
    private func calculateDamage(effectiveness: Double) -> Int {
        let baseDamage = 100
        return Int(Double(baseDamage) * effectiveness)
    }
    
    private func triggerBattleAnimations() {
        // Attacking sprite animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            attackingSprite.isCharging = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                attackingSprite.isAttacking = true
                defendingSprite.isHit = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            resetSpriteAnimations()
        }
    }
    
    private func resetSpriteAnimations() {
        withAnimation(.easeOut(duration: 0.3)) {
            attackingSprite = AnimatedBattleSprite()
            defendingSprite = AnimatedBattleSprite()
        }
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
    }
}

// MARK: - Supporting Views

struct TypeEffectivenessCell: View {
    let attackingType: PokemonType
    let defendingTypes: [PokemonType]
    let isSelected: Bool
    let animationPhase: CGFloat
    let onTap: () -> Void
    
    private var effectiveness: Double {
        TypeEffectiveness.effectiveness(attackingType: attackingType, defendingTypes: defendingTypes)
    }
    
    private var effectivenessColor: Color {
        switch effectiveness {
        case 2.0...: return .green
        case 1.0: return .gray
        case 0.5..<1.0: return .orange
        case 0.0: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Type icon with glow
                ZStack {
                    Circle()
                        .fill(attackingType.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? attackingType.color : attackingType.color.opacity(0.5),
                                    lineWidth: isSelected ? 3 : 1
                                )
                        )
                    
                    Image(systemName: attackingType.icon)
                        .font(.system(size: 16))
                        .foregroundColor(attackingType.color)
                        .scaleEffect(isSelected ? 1.2 : 1.0)
                }
                .scaleEffect(1.0 + (isSelected ? sin(Double(animationPhase * 2)) * 0.1 : 0))
                
                // Type name
                Text(attackingType.displayName)
                    .font(.caption2)
                    .foregroundColor(ThemeManager.Colors.lumina)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Effectiveness indicator
                Text(String(format: "%.1fx", effectiveness))
                    .font(.caption.weight(.bold))
                    .foregroundColor(effectivenessColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(effectivenessColor.opacity(0.2))
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

struct TypeBadge: View {
    let type: PokemonType
    let isDefending: Bool
    let glowIntensity: CGFloat
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: type.icon)
                .font(.system(size: 14))
            
            Text(type.displayName)
                .font(ThemeManager.Typography.captionBold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(type.color)
                .shadow(color: type.color.opacity(glowIntensity), radius: 8)
        )
        .overlay(
            Capsule()
                .stroke(
                    isDefending ? Color.white.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

struct BattleSpriteView: View {
    let sprite: AnimatedBattleSprite
    let type: PokemonType
    let isAttacking: Bool
    
    var body: some View {
        ZStack {
            // Sprite base
            Circle()
                .fill(type.color.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(type.color, lineWidth: 2)
                )
                .scaleEffect(sprite.isCharging ? 1.2 : (sprite.isHit ? 0.9 : 1.0))
                .offset(x: sprite.isAttacking ? (isAttacking ? 20 : -20) : 0)
            
            // Type icon as sprite
            Image(systemName: type.icon)
                .font(.system(size: 24))
                .foregroundColor(type.color)
                .scaleEffect(sprite.isCharging ? 1.3 : (sprite.isHit ? 0.8 : 1.0))
                .offset(x: sprite.isAttacking ? (isAttacking ? 20 : -20) : 0)
            
            // Attack effect
            if sprite.isAttacking && isAttacking {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(type.color)
                        .frame(width: 6, height: 6)
                        .offset(x: 30 + CGFloat(index) * 10)
                        .opacity(0.8)
                        .scaleEffect(0.5 + CGFloat(index) * 0.2)
                }
            }
            
            // Hit effect
            if sprite.isHit && !isAttacking {
                ForEach(0..<8, id: \.self) { index in
                    let angle = CGFloat(index) * .pi / 4
                    Circle()
                        .fill(Color.red)
                        .frame(width: 4, height: 4)
                        .offset(
                            x: cos(angle) * 25,
                            y: sin(angle) * 25
                        )
                        .opacity(0.7)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: sprite.isCharging)
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: sprite.isAttacking)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: sprite.isHit)
    }
}

struct BattleResultCard: View {
    let result: BattleResult
    let animationPhase: CGFloat
    
    var body: some View {
        VStack(spacing: ThemeManager.Spacing.sm) {
            Text(result.effectivenessText)
                .font(ThemeManager.Typography.headerMedium)
                .foregroundColor(result.effectivenessColor)
                .scaleEffect(1.0 + sin(Double(animationPhase * 3)) * 0.05)
            
            Text("\(result.damage) damage")
                .font(ThemeManager.Typography.bodyLarge.weight(.bold))
                .foregroundColor(ThemeManager.Colors.lumina)
            
            HStack {
                Text("Multiplier:")
                    .foregroundColor(ThemeManager.Colors.lumina.opacity(0.8))
                
                Text(String(format: "%.1fx", result.effectiveness))
                    .foregroundColor(result.effectivenessColor)
                    .font(.system(.body, design: .monospaced).weight(.bold))
            }
            .font(ThemeManager.Typography.bodyMedium)
        }
        .padding(ThemeManager.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(result.effectivenessColor.opacity(0.1))
                .stroke(result.effectivenessColor.opacity(0.3), lineWidth: 1)
        )
        .transition(.scale.combined(with: .opacity))
    }
}

struct EffectivenessIndicator: View {
    let multiplier: Double
    let label: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(String(format: "%.1fx", multiplier))
                .font(.caption.weight(.bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(ThemeManager.Colors.lumina.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Data Models

struct BattleResult {
    let attackingType: PokemonType
    let defendingPokemon: Pokemon
    let effectiveness: Double
    let damage: Int
    
    var effectivenessText: String {
        TypeEffectiveness.effectivenessText(multiplier: effectiveness)
    }
    
    var effectivenessColor: Color {
        switch effectiveness {
        case 2.0...: return .green
        case 1.0: return .gray
        case 0.5..<1.0: return .orange
        case 0.0: return .red
        default: return .gray
        }
    }
}

struct AnimatedBattleSprite {
    var isCharging: Bool = false
    var isAttacking: Bool = false
    var isHit: Bool = false
}

#Preview {
    TypeEffectivenessView(
        pokemon: Pokemon(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            baseExperience: 112,
            order: 35,
            isDefault: true,
            sprites: PokemonSprites(
                frontDefault: nil,
                frontShiny: nil,
                frontFemale: nil,
                frontShinyFemale: nil,
                backDefault: nil,
                backShiny: nil,
                backFemale: nil,
                backShinyFemale: nil,
                other: nil
            ),
            types: [
                PokemonTypeSlot(slot: 1, type: PokemonTypeInfo(name: "electric", url: ""))
            ],
            abilities: [],
            stats: [],
            species: PokemonSpecies(name: "pikachu", url: ""),
            moves: [],
            gameIndices: []
        )
    )
    .preferredColorScheme(.dark)
}

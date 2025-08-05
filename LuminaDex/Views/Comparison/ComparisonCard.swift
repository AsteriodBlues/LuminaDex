//
//  ComparisonCard.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import SwiftUI

struct ComparisonCard: View {
    let pokemon: Pokemon
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Pokemon Image
            AsyncImage(url: URL(string: pokemon.sprites.officialArtwork)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            } placeholder: {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(pokemon.primaryType.color.opacity(0.1))
                    .scaleEffect(1.2)
            )
            
            // Pokemon Name
            Text(pokemon.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // Type Badges
            HStack(spacing: 4) {
                ForEach(pokemon.types.prefix(2), id: \.slot) { typeSlot in
                    Text(typeSlot.pokemonType.displayName)
                        .font(.system(size: 8))
                        .fontWeight(.medium)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(typeSlot.pokemonType.color)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
            
            // Quick Stats
            VStack(spacing: 2) {
                let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
                
                Text("BST: \(totalStats)")
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                // Mini stat bars
                HStack(spacing: 2) {
                    ForEach(pokemon.stats.prefix(6), id: \.stat.name) { stat in
                        Rectangle()
                            .fill(getStatColor(for: stat.stat.name))
                            .frame(width: 8, height: max(2, CGFloat(stat.baseStat) / 25))
                            .cornerRadius(1)
                    }
                }
            }
        }
        .padding(8)
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            pokemon.primaryType.color.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(pokemon.primaryType.color.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            isAnimating = true
        }
    }
    
    private func getStatColor(for statName: String) -> Color {
        switch statName {
        case "hp":
            return .red
        case "attack":
            return .orange
        case "defense":
            return .blue
        case "special-attack":
            return .purple
        case "special-defense":
            return .green
        case "speed":
            return .yellow
        default:
            return .gray
        }
    }
}

// MARK: - Detailed Comparison Card
struct DetailedComparisonCard: View {
    let pokemon: Pokemon
    let showAllStats: Bool
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                AsyncImage(url: URL(string: pokemon.sprites.officialArtwork)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(pokemon.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        ForEach(pokemon.types, id: \.slot) { typeSlot in
                            Text(typeSlot.pokemonType.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(typeSlot.pokemonType.color)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Height")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(pokemon.formattedHeight)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Weight")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(pokemon.formattedWeight)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Spacer()
                
                if showAllStats {
                    Button(action: { isExpanded.toggle() }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Stats Section
            if showAllStats || isExpanded {
                statsSection
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Base Stats")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(pokemon.stats, id: \.stat.name) { stat in
                HStack {
                    Text(stat.stat.displayName)
                        .font(.caption)
                        .frame(width: 80, alignment: .leading)
                    
                    Text("\(stat.baseStat)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 40, alignment: .trailing)
                    
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(getStatColor(for: stat.stat.name))
                                .frame(width: CGFloat(stat.baseStat) / 255 * geometry.size.width)
                            
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(height: 8)
                    .background(Color(.systemGray4))
                    .cornerRadius(4)
                }
            }
            
            // Total Stats
            let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
            HStack {
                Text("Total")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(width: 80, alignment: .leading)
                
                Text("\(totalStats)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 40, alignment: .trailing)
                
                Spacer()
            }
        }
    }
    
    private func getStatColor(for statName: String) -> Color {
        switch statName {
        case "hp":
            return .red
        case "attack":
            return .orange
        case "defense":
            return .blue
        case "special-attack":
            return .purple
        case "special-defense":
            return .green
        case "speed":
            return .yellow
        default:
            return .gray
        }
    }
}

#Preview {
    VStack {
        ComparisonCard(pokemon: Pokemon.mockPokemon)
        DetailedComparisonCard(pokemon: Pokemon.mockPokemon, showAllStats: true)
    }
    .padding()
}

// MARK: - Mock Data Extension
extension Pokemon {
    static var mockPokemon: Pokemon {
        Pokemon(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            baseExperience: 112,
            order: 35,
            isDefault: true,
            sprites: PokemonSprites(
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
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
                PokemonTypeSlot(
                    slot: 1,
                    type: PokemonTypeInfo(name: "electric", url: "")
                )
            ],
            abilities: [],
            stats: [
                PokemonStat(baseStat: 35, effort: 0, stat: StatType(name: "hp", url: "")),
                PokemonStat(baseStat: 55, effort: 0, stat: StatType(name: "attack", url: "")),
                PokemonStat(baseStat: 40, effort: 0, stat: StatType(name: "defense", url: "")),
                PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-attack", url: "")),
                PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-defense", url: "")),
                PokemonStat(baseStat: 90, effort: 0, stat: StatType(name: "speed", url: ""))
            ],
            species: PokemonSpecies(name: "pikachu", url: ""),
            moves: nil,
            gameIndices: nil
        )
    }
}
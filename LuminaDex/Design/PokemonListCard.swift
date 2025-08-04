//
//  PokemonListCard.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//

import SwiftUI

struct PokemonListCard: View {
    let pokemon: Pokemon
    let viewModel: CollectionViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Pokemon Sprite
            ImageManager.shared.loadThumbnail(url: pokemon.sprites.frontDefault)
                .frame(width: 60, height: 60)
            .background(.ultraThinMaterial, in: Circle())
            
            // Pokemon Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pokemon.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("#\(String(format: "%03d", pokemon.id))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    ForEach(pokemon.types, id: \.slot) { typeSlot in
                        Text(typeSlot.pokemonType.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(typeSlot.pokemonType.color.opacity(0.3), in: Capsule())
                    }
                    
                    Spacer()
                    
                    Text("HP: \(pokemon.collectionStats.hp)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("ATK: \(pokemon.collectionStats.attack)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Progress
                ProgressView(value: pokemon.progress / 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 0.8)
            }
            
            // Actions
            VStack {
                Button(action: { viewModel.toggleFavorite(for: pokemon) }) {
                    Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(pokemon.isFavorite ? .red : .gray)
                }
                
                if pokemon.isCaught {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

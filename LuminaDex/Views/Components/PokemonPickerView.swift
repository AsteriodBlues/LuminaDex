//
//  PokemonPickerView.swift
//  LuminaDex
//
//  Pokemon Selection Picker
//

import SwiftUI

struct PokemonPickerView: View {
    @StateObject private var viewModel = CollectionViewModel()
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    let onSelection: (Pokemon) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                    ForEach(filteredPokemon) { pokemon in
                        PokemonPickerCard(pokemon: pokemon) {
                            onSelection(pokemon)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.opacity(0.95))
            .navigationTitle("Select Pokémon")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search Pokémon...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private var filteredPokemon: [Pokemon] {
        if searchText.isEmpty {
            return viewModel.pokemon
        } else {
            return viewModel.pokemon.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct PokemonPickerCard: View {
    let pokemon: Pokemon
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ImageManager.shared.loadThumbnail(url: pokemon.sprites.frontDefault)
                    .frame(width: 60, height: 60)
                
                Text(pokemon.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("#\(String(format: "%03d", pokemon.id))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(width: 100, height: 120)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
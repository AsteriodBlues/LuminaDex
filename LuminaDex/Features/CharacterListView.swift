//
//  CharacterListView.swift
//  LuminaDex
//
//  Pokemon series character collection view
//

import SwiftUI

struct CharacterListView: View {
    @State private var selectedRole: Character.CharacterRole? = nil
    @State private var searchText = ""
    @State private var favoriteCharacters: Set<String> = []
    @AppStorage("favoriteCharacters") private var favoriteCharactersData: Data = Data()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredCharacters: [Character] {
        let characters = selectedRole != nil ? 
            CharacterDatabase.getCharactersByRole(selectedRole!) : 
            CharacterDatabase.mainCharacters
        
        if searchText.isEmpty {
            return characters
        } else {
            return characters.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.hometown.localizedCaseInsensitiveContains(searchText) ||
                $0.region.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.05, green: 0.05, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Role filter
                    roleFilter
                    
                    // Character grid
                    ScrollView {
                        characterGrid
                    }
                }
            }
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { selectedRole = nil }) {
                            Label("All Characters", systemImage: "person.3.fill")
                        }
                        Divider()
                        ForEach(Character.CharacterRole.allCases, id: \.self) { role in
                            Button(action: { selectedRole = role }) {
                                Label(role.rawValue, systemImage: role.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            loadFavorites()
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search characters...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }
    
    private var roleFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All characters
                RoleChip(
                    title: "All",
                    icon: "person.3.fill",
                    isSelected: selectedRole == nil,
                    color: .gray,
                    action: { selectedRole = nil }
                )
                
                ForEach(Character.CharacterRole.allCases, id: \.self) { role in
                    RoleChip(
                        title: role.rawValue,
                        icon: role.icon,
                        isSelected: selectedRole == role,
                        color: role.color,
                        action: { selectedRole = role }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
    }
    
    private var characterGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredCharacters) { character in
                NavigationLink(destination: CharacterDetailView(character: character)) {
                    CharacterCardView(
                        character: character,
                        isFavorite: favoriteCharacters.contains(character.id),
                        onFavoriteToggle: { toggleFavorite(character.id) }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
    
    private func toggleFavorite(_ id: String) {
        withAnimation(.spring()) {
            if favoriteCharacters.contains(id) {
                favoriteCharacters.remove(id)
            } else {
                favoriteCharacters.insert(id)
            }
            saveFavorites()
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(Array(favoriteCharacters)) {
            favoriteCharactersData = encoded
        }
    }
    
    private func loadFavorites() {
        if let decoded = try? JSONDecoder().decode([String].self, from: favoriteCharactersData) {
            favoriteCharacters = Set(decoded)
        }
    }
}

struct RoleChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? color : Color.white.opacity(0.1)
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(color, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

struct CharacterCardView: View {
    let character: Character
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    @State private var imageLoaded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Character image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: character.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [character.role.color.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 180)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .onAppear { imageLoaded = true }
                    case .failure(_):
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [character.role.color.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 180)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .scaleEffect(imageLoaded ? 1.0 : 0.95)
                .animation(.spring(response: 0.3), value: imageLoaded)
                
                // Favorite button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(8)
            }
            
            // Character info
            VStack(alignment: .leading, spacing: 8) {
                // Name and role
                HStack {
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: character.role.icon)
                        .font(.caption)
                        .foregroundColor(character.role.color)
                }
                
                // Region and hometown
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Text("\(character.region) • \(character.hometown)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                // Role badge
                HStack {
                    Text(character.role.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(character.role.color.opacity(0.3))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Pokemon team count
                    HStack(spacing: 2) {
                        Image(systemName: "circle.circle.fill")
                            .font(.caption2)
                        Text("\(character.pokemonTeam.count)")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(character.role.color.opacity(0.3), lineWidth: 1)
        )
    }
}
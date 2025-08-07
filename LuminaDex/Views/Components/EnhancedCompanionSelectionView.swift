//
//  CompanionSelectionView.swift
//  LuminaDex
//
//  Companion selection interface with real Pokemon sprites
//

import SwiftUI

struct EnhancedCompanionSelectionView: View {
    @ObservedObject var companionManager: CompanionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCompanion: CompanionType?
    @State private var companionName: String = ""
    @State private var spriteImages: [CompanionType: UIImage] = [:]
    @State private var isLoadingSprites = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Choose Your Companion")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Select a Pokemon to accompany you on your journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Companion grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(CompanionType.allCases, id: \.self) { type in
                            CompanionCard(
                                type: type,
                                isSelected: selectedCompanion == type,
                                sprite: spriteImages[type],
                                isLoading: isLoadingSprites
                            ) {
                                withAnimation(.spring()) {
                                    selectedCompanion = type
                                    if companionName.isEmpty {
                                        companionName = type.name
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Selected companion details
                    if let selected = selectedCompanion {
                        VStack(spacing: 16) {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Companion Details")
                                    .font(.headline)
                                
                                // Name input
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Nickname")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Enter nickname", text: $companionName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                // Personality
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Personality")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(selected.personality)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                // Traits
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Traits")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        ForEach(selected.traits, id: \.self) { trait in
                                            Text(trait)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    Capsule()
                                                        .fill(selected.primaryColor.opacity(0.2))
                                                )
                                                .foregroundColor(selected.primaryColor)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Confirm button
                    Button(action: confirmSelection) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Choose Companion")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedCompanion != nil ? Color.blue : Color.gray)
                        )
                    }
                    .disabled(selectedCompanion == nil || companionName.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadAllSprites()
        }
    }
    
    private func loadAllSprites() {
        isLoadingSprites = true
        let group = DispatchGroup()
        
        for type in CompanionType.allCases {
            group.enter()
            
            guard let url = URL(string: type.spriteURL) else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                
                if let data = data,
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.spriteImages[type] = image
                    }
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            isLoadingSprites = false
        }
    }
    
    private func confirmSelection() {
        guard let selected = selectedCompanion else { return }
        
        let companion = CompanionData(
            type: selected,
            name: companionName,
            happiness: 80,
            experience: 0
        )
        
        companionManager.selectCompanion(companion)
        dismiss()
    }
}

// MARK: - Companion Card
struct CompanionCard: View {
    let type: CompanionType
    let isSelected: Bool
    let sprite: UIImage?
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Sprite container
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    type.primaryColor.opacity(0.3),
                                    type.primaryColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if let sprite = sprite {
                        Image(uiImage: sprite)
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                    } else {
                        Text(type.sprite)
                            .font(.system(size: 50))
                    }
                    
                    // Selection indicator
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(type.primaryColor, lineWidth: 3)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(type.primaryColor)
                                    .background(Circle().fill(Color.white))
                                    .font(.title2)
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                
                // Name
                Text(type.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? type.primaryColor : .primary)
                
                // Pokemon ID
                Text("#\(String(format: "%03d", type.pokemonId))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
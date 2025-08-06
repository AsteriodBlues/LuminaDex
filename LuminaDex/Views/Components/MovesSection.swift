//
//  MovesSection.swift
//  LuminaDex
//
//  Day 24: Enhanced moves display with categories
//

import SwiftUI

struct MovesSection: View {
    let moves: [PokemonMove]
    @State private var selectedCategory: MoveCategory = .all
    @State private var searchText = ""
    @State private var expandedMoves: Set<String> = []
    
    enum MoveCategory: String, CaseIterable {
        case all = "All"
        case physical = "Physical"
        case special = "Special"
        case status = "Status"
        
        var icon: String {
            switch self {
            case .all: return "circle.grid.3x3"
            case .physical: return "bolt.circle"
            case .special: return "sparkles"
            case .status: return "shield"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .gray
            case .physical: return .orange
            case .special: return .purple
            case .status: return .green
            }
        }
    }
    
    var filteredMoves: [PokemonMove] {
        moves.filter { move in
            let matchesCategory = selectedCategory == .all || getMoveCategory(move) == selectedCategory
            let matchesSearch = searchText.isEmpty || move.move.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
        .sorted { $0.move.name < $1.move.name }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("Moves", systemImage: "sparkles")
                    .font(.headline)
                
                Spacer()
                
                Text("\(filteredMoves.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.gray.opacity(0.2)))
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search moves...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemBackground)))
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MoveCategory.allCases, id: \.self) { category in
                        MoveCategoryChip(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.spring()) {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
            
            // Moves List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredMoves, id: \.move.name) { move in
                        MoveCard(
                            move: move,
                            isExpanded: expandedMoves.contains(move.move.name)
                        ) {
                            withAnimation(.spring()) {
                                if expandedMoves.contains(move.move.name) {
                                    expandedMoves.remove(move.move.name)
                                } else {
                                    expandedMoves.insert(move.move.name)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
    
    private func getMoveCategory(_ move: PokemonMove) -> MoveCategory {
        // In a real app, this would be determined from move data
        // For now, using a simple heuristic based on name
        let name = move.move.name.lowercased()
        if name.contains("punch") || name.contains("kick") || name.contains("tackle") {
            return .physical
        } else if name.contains("beam") || name.contains("blast") || name.contains("psychic") {
            return .special
        } else if name.contains("protect") || name.contains("growl") || name.contains("leer") {
            return .status
        }
        return .physical
    }
}

// MARK: - Move Category Chip
struct MoveCategoryChip: View {
    let category: MovesSection.MoveCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : category.color.opacity(0.2))
            )
            .overlay(
                Capsule()
                    .stroke(category.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Move Card
struct MoveCard: View {
    let move: PokemonMove
    let isExpanded: Bool
    let onTap: () -> Void
    
    @State private var isAnimating = false
    
    var formattedMoveName: String {
        move.move.name
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onTap) {
                HStack {
                    // Move Icon
                    ZStack {
                        Circle()
                            .fill(getMoveColor().opacity(0.2))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: getMoveIcon())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(getMoveColor())
                    }
                    
                    // Move Name
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedMoveName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            if let level = getLearnLevel() {
                                Label("Lv.\(level)", systemImage: "arrow.up.circle")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let method = getLearnMethod() {
                                Text(method)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.gray.opacity(0.2)))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Expand Icon
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    // Move Details
                    HStack(spacing: 16) {
                        MoveStatItem(label: "Power", value: "80")
                        MoveStatItem(label: "Accuracy", value: "100%")
                        MoveStatItem(label: "PP", value: "15")
                    }
                    
                    Text("A powerful move that may cause the target to flinch.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.tertiarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isExpanded ? getMoveColor().opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnimating = true
            }
        }
    }
    
    private func getMoveIcon() -> String {
        let name = move.move.name.lowercased()
        if name.contains("punch") || name.contains("kick") {
            return "hand.raised"
        } else if name.contains("beam") || name.contains("blast") {
            return "bolt"
        } else if name.contains("protect") || name.contains("defense") {
            return "shield"
        }
        return "sparkles"
    }
    
    private func getMoveColor() -> Color {
        let name = move.move.name.lowercased()
        if name.contains("fire") || name.contains("flame") {
            return .orange
        } else if name.contains("water") || name.contains("aqua") {
            return .blue
        } else if name.contains("grass") || name.contains("leaf") {
            return .green
        }
        return .purple
    }
    
    private func getLearnLevel() -> Int? {
        // In a real app, this would come from move.versionGroupDetails
        return Int.random(in: 1...50)
    }
    
    private func getLearnMethod() -> String? {
        // In a real app, this would come from move.versionGroupDetails
        ["Level up", "TM", "HM", "Egg", "Tutor"].randomElement()
    }
}

// MARK: - Move Stat Item
struct MoveStatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}
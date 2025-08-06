//
//  AbilityCloudView.swift
//  LuminaDex
//
//  Day 24: Animated ability cloud visualization
//

import SwiftUI

struct AbilityCloudView: View {
    let abilities: [PokemonAbilitySlot]
    @State private var animatedAbilities: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Abilities")
                .font(.headline)
                .foregroundColor(.primary)
            
            FlowLayout(spacing: 8) {
                ForEach(0..<abilities.count, id: \.self) { index in
                    let abilitySlot = abilities[index]
                    let abilityName = abilitySlot.ability.name
                    
                    AbilityChip(
                        abilitySlot: abilitySlot,
                        isAnimated: animatedAbilities.contains(abilityName)
                    )
                    .onAppear {
                        let delay = Double(index) * 0.1
                        withAnimation(.spring().delay(delay)) {
                            animatedAbilities.insert(abilityName)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Ability Chip
struct AbilityChip: View {
    let abilitySlot: PokemonAbilitySlot
    let isAnimated: Bool
    @State private var isHovering = false
    @State private var showDetails = false
    
    var chipColor: Color {
        abilitySlot.isHidden ? Color.purple : Color.blue
    }
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            HStack(spacing: 6) {
                if abilitySlot.isHidden {
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 10))
                }
                
                Text(abilitySlot.ability.displayName)
                    .font(.system(size: 13, weight: .medium))
                
                if abilitySlot.slot == 1 {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    Capsule()
                        .fill(chipColor)
                    
                    if isHovering {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .shadow(color: chipColor.opacity(0.3), radius: 4, x: 0, y: 2)
            .scaleEffect(isAnimated ? (isHovering ? 1.1 : 1.0) : 0.8)
            .opacity(isAnimated ? 1.0 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovering = hovering
            }
        }
        .popover(isPresented: $showDetails) {
            AbilityDetailView(abilitySlot: abilitySlot)
                .frame(width: 250)
        }
    }
}

// MARK: - Ability Detail View
struct AbilityDetailView: View {
    let abilitySlot: PokemonAbilitySlot
    @State private var abilityDescription = "Loading..."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(abilitySlot.ability.displayName)
                    .font(.headline)
                
                Spacer()
                
                if abilitySlot.isHidden {
                    Label("Hidden", systemImage: "eye.slash.fill")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            
            Text(abilityDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            if abilitySlot.slot == 1 {
                Label("Primary Ability", systemImage: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .onAppear {
            loadAbilityDescription()
        }
    }
    
    private func loadAbilityDescription() {
        // In a real app, this would fetch from the database
        abilityDescription = getAbilityDescription(abilitySlot.ability.name)
    }
    
    private func getAbilityDescription(_ name: String) -> String {
        // Sample descriptions for common abilities
        switch name {
        case "overgrow":
            return "Powers up Grass-type moves when the Pokémon's HP is low."
        case "blaze":
            return "Powers up Fire-type moves when the Pokémon's HP is low."
        case "torrent":
            return "Powers up Water-type moves when the Pokémon's HP is low."
        case "chlorophyll":
            return "Boosts the Pokémon's Speed stat in harsh sunlight."
        case "solar-power":
            return "In harsh sunlight, the Pokémon's Sp. Atk stat is boosted, but its HP decreases every turn."
        default:
            return "A unique ability that affects battle performance."
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for element in result.rows {
            let rowY = element.yOffset + bounds.minY
            var x = bounds.minX
            
            for viewIndex in element.viewIndices {
                let view = subviews[viewIndex]
                let viewSize = view.sizeThatFits(ProposedViewSize(width: nil, height: element.height))
                view.place(at: CGPoint(x: x, y: rowY), proposal: ProposedViewSize(viewSize))
                x += viewSize.width + spacing
            }
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var rows: [Row] = []
        
        struct Row {
            var viewIndices: [Int]
            var yOffset: CGFloat
            var height: CGFloat
        }
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentRowIndices: [Int] = []
            var currentRowHeight: CGFloat = 0
            var yOffset: CGFloat = 0
            
            for (index, view) in subviews.enumerated() {
                let viewSize = view.sizeThatFits(ProposedViewSize(width: nil, height: nil))
                
                if currentX + viewSize.width > maxWidth && !currentRowIndices.isEmpty {
                    // Start new row
                    rows.append(Row(
                        viewIndices: currentRowIndices,
                        yOffset: yOffset,
                        height: currentRowHeight
                    ))
                    
                    yOffset += currentRowHeight + spacing
                    currentX = 0
                    currentRowIndices = []
                    currentRowHeight = 0
                }
                
                currentRowIndices.append(index)
                currentX += viewSize.width + spacing
                currentRowHeight = max(currentRowHeight, viewSize.height)
            }
            
            if !currentRowIndices.isEmpty {
                rows.append(Row(
                    viewIndices: currentRowIndices,
                    yOffset: yOffset,
                    height: currentRowHeight
                ))
            }
            
            size.width = maxWidth
            size.height = rows.last.map { $0.yOffset + $0.height } ?? 0
        }
    }
}
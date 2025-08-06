//
//  FilterView.swift
//  LuminaDex
//
//  Day 24: Comprehensive filter interface
//

import SwiftUI

struct FilterView: View {
    @StateObject private var viewModel: FilterViewModel
    @Binding var isPresented: Bool
    let onApply: (FilterCriteria) -> Void
    
    init(isPresented: Binding<Bool>, 
         initialCriteria: FilterCriteria = FilterCriteria(),
         onApply: @escaping (FilterCriteria) -> Void) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: FilterViewModel(criteria: initialCriteria))
        self.onApply = onApply
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Type Filter Section
                    typeFilterSection
                    
                    // Generation Filter Section
                    generationFilterSection
                    
                    // Stats Filter Section
                    statsFilterSection
                    
                    // Special Filters Section
                    specialFiltersSection
                    
                    // Size Filter Section
                    sizeFilterSection
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Filter Pokemon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.resetFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply(viewModel.criteria)
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Type Filter Section
    private var typeFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Types", systemImage: "circle.grid.hex")
                    .font(.headline)
                
                Spacer()
                
                Picker("Logic", selection: $viewModel.criteria.typeLogic) {
                    ForEach(FilterCriteria.TypeFilterLogic.allCases, id: \.self) { logic in
                        Text(logic.rawValue).tag(logic)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
            }
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80), spacing: 8)
            ], spacing: 8) {
                ForEach(PokemonType.allCases, id: \.self) { type in
                    TypeFilterChip(
                        type: type,
                        isSelected: viewModel.criteria.types.contains(type),
                        onTap: {
                            viewModel.toggleType(type)
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Generation Filter Section
    private var generationFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Generations", systemImage: "number.circle")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 60), spacing: 8)
            ], spacing: 8) {
                ForEach(1...9, id: \.self) { gen in
                    GenerationChip(
                        generation: gen,
                        isSelected: viewModel.criteria.generations.contains(gen),
                        onTap: {
                            viewModel.toggleGeneration(gen)
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Stats Filter Section
    private var statsFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Base Stats", systemImage: "chart.bar")
                .font(.headline)
            
            ForEach(["hp", "attack", "defense", "special-attack", "special-defense", "speed"], id: \.self) { stat in
                StatRangeSlider(
                    statName: stat,
                    minValue: Binding(
                        get: { viewModel.criteria.minStats[stat] ?? 0 },
                        set: { viewModel.criteria.minStats[stat] = $0 }
                    ),
                    maxValue: Binding(
                        get: { viewModel.criteria.maxStats[stat] ?? 255 },
                        set: { viewModel.criteria.maxStats[stat] = $0 }
                    )
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Special Filters Section
    private var specialFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Special", systemImage: "star")
                .font(.headline)
            
            VStack(spacing: 8) {
                FilterToggle(
                    title: "Legendary",
                    icon: "crown",
                    value: Binding(
                        get: { viewModel.criteria.isLegendary ?? false },
                        set: { viewModel.criteria.isLegendary = $0 ? true : nil }
                    )
                )
                
                FilterToggle(
                    title: "Mythical",
                    icon: "sparkles",
                    value: Binding(
                        get: { viewModel.criteria.isMythical ?? false },
                        set: { viewModel.criteria.isMythical = $0 ? true : nil }
                    )
                )
                
                FilterToggle(
                    title: "Baby",
                    icon: "face.smiling",
                    value: Binding(
                        get: { viewModel.criteria.isBaby ?? false },
                        set: { viewModel.criteria.isBaby = $0 ? true : nil }
                    )
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Size Filter Section
    private var sizeFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Size", systemImage: "ruler")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Height filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Height (m)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Min", value: $viewModel.criteria.minHeight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        Text("to")
                            .foregroundColor(.secondary)
                        
                        TextField("Max", value: $viewModel.criteria.maxHeight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                // Weight filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight (kg)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Min", value: $viewModel.criteria.minWeight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        Text("to")
                            .foregroundColor(.secondary)
                        
                        TextField("Max", value: $viewModel.criteria.maxWeight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Type Filter Chip
struct TypeFilterChip: View {
    let type: PokemonType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.caption)
                Text(type.displayName)
                    .font(.caption)
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : type.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? type.color : type.color.opacity(0.2)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(type.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Generation Chip
struct GenerationChip: View {
    let generation: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("Gen \(generation)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 60, height: 36)
                .background(
                    isSelected ? Color.blue : Color.gray.opacity(0.2)
                )
                .cornerRadius(8)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Stat Range Slider
struct StatRangeSlider: View {
    let statName: String
    @Binding var minValue: Int
    @Binding var maxValue: Int
    
    var displayName: String {
        statName.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(minValue) - \(maxValue)")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            
            // Simple text input for now (would need custom slider for range)
            HStack {
                TextField("Min", value: $minValue, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                
                Spacer()
                
                TextField("Max", value: $maxValue, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Filter Toggle
struct FilterToggle: View {
    let title: String
    let icon: String
    @Binding var value: Bool
    
    var body: some View {
        Toggle(isOn: $value) {
            Label(title, systemImage: icon)
                .font(.subheadline)
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }
}
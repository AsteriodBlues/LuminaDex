//
//  FilterModal.swift
//  LuminaDex
//
//  Day 24: Quick filter modal for common filters
//

import SwiftUI

struct FilterModal: View {
    @Binding var isPresented: Bool
    @Binding var filterOptions: QuickFilterOptions
    let onApply: () -> Void
    
    struct QuickFilterOptions {
        var showLegendary = true
        var showMythical = true
        var showStarter = true
        var showBaby = true
        var showEvolved = true
        var minGeneration = 1
        var maxGeneration = 9
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Special Categories
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Special Categories", systemImage: "star")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            FilterToggleRow(
                                title: "Legendary Pokémon",
                                icon: "crown",
                                isOn: $filterOptions.showLegendary,
                                color: .orange
                            )
                            
                            FilterToggleRow(
                                title: "Mythical Pokémon",
                                icon: "sparkles",
                                isOn: $filterOptions.showMythical,
                                color: .purple
                            )
                            
                            FilterToggleRow(
                                title: "Starter Pokémon",
                                icon: "flame",
                                isOn: $filterOptions.showStarter,
                                color: .green
                            )
                            
                            FilterToggleRow(
                                title: "Baby Pokémon",
                                icon: "face.smiling",
                                isOn: $filterOptions.showBaby,
                                color: .pink
                            )
                            
                            FilterToggleRow(
                                title: "Evolved Forms",
                                icon: "arrow.up.circle",
                                isOn: $filterOptions.showEvolved,
                                color: .blue
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    
                    // Generation Range
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Generation Range", systemImage: "number.circle")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("From Gen")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Picker("Min Gen", selection: $filterOptions.minGeneration) {
                                    ForEach(1...9, id: \.self) { gen in
                                        Text("\(gen)").tag(gen)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            HStack {
                                Text("To Gen")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Picker("Max Gen", selection: $filterOptions.maxGeneration) {
                                    ForEach(1...9, id: \.self) { gen in
                                        Text("\(gen)").tag(gen)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    
                    // Quick Presets
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Quick Presets", systemImage: "sparkles")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            PresetButton(title: "Gen 1 Only", icon: "1.circle") {
                                filterOptions.minGeneration = 1
                                filterOptions.maxGeneration = 1
                            }
                            
                            PresetButton(title: "Legendaries", icon: "crown") {
                                filterOptions.showLegendary = true
                                filterOptions.showMythical = true
                                filterOptions.showStarter = false
                                filterOptions.showBaby = false
                                filterOptions.showEvolved = false
                            }
                            
                            PresetButton(title: "Starters", icon: "flame") {
                                filterOptions.showLegendary = false
                                filterOptions.showMythical = false
                                filterOptions.showStarter = true
                                filterOptions.showBaby = false
                                filterOptions.showEvolved = false
                            }
                            
                            PresetButton(title: "Reset All", icon: "arrow.counterclockwise") {
                                filterOptions = QuickFilterOptions()
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Quick Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Filter Toggle Row
struct FilterToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(isOn ? color : .secondary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: color))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preset Button
struct PresetButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
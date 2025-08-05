//
//  SizeComparisonView.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import SwiftUI

struct SizeComparisonView: View {
    let pokemon: [Pokemon]
    @State private var selectedMeasurement: MeasurementType = .height
    @State private var animationProgress: Double = 0
    
    enum MeasurementType: String, CaseIterable {
        case height = "Height"
        case weight = "Weight"
        case both = "Both"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Measurement selector
            measurementPicker
            
            // Size comparison visualization
            switch selectedMeasurement {
            case .height:
                heightComparisonView
            case .weight:
                weightComparisonView
            case .both:
                combinedComparisonView
            }
            
            // Statistics summary
            statisticsSummary
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var measurementPicker: some View {
        Picker("Measurement Type", selection: $selectedMeasurement) {
            ForEach(MeasurementType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var heightComparisonView: some View {
        let maxHeight = pokemon.map(\.height).max() ?? 1
        
        return VStack(spacing: 12) {
            headerView
            pokemonHeightGrid(maxHeight: maxHeight)
        }
    }
    
    private var headerView: some View {
        Text("Height Comparison")
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    private func pokemonHeightGrid(maxHeight: Int) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(pokemon, id: \.id) { pokemon in
                pokemonHeightCard(pokemon: pokemon, maxHeight: maxHeight)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func pokemonHeightCard(pokemon: Pokemon, maxHeight: Int) -> some View {
        let heightScale = getHeightScale(for: pokemon, maxHeight: maxHeight)
        let frameHeight = CGFloat(pokemon.height) / CGFloat(maxHeight) * 120 * animationProgress
        
        return VStack(spacing: 8) {
            pokemonSpriteView(pokemon: pokemon, heightScale: heightScale, frameHeight: frameHeight)
            pokemonInfoView(pokemon: pokemon)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func pokemonSpriteView(pokemon: Pokemon, heightScale: Double, frameHeight: CGFloat) -> some View {
        AsyncImage(url: URL(string: pokemon.sprites.officialArtwork)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(heightScale * animationProgress)
        } placeholder: {
            ProgressView()
                .frame(width: 40, height: 40)
        }
        .frame(width: 60, height: frameHeight)
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animationProgress)
    }
    
    private func pokemonInfoView(pokemon: Pokemon) -> some View {
        VStack(spacing: 2) {
            Text(pokemon.formattedHeight)
                .font(.caption)
                .fontWeight(.bold)
            
            Text(pokemon.name.capitalized)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    private var weightComparisonView: some View {
        VStack(spacing: 12) {
            Text("Weight Comparison")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Weight bars
            VStack(spacing: 8) {
                ForEach(pokemon, id: \.id) { pokemon in
                    weightBar(for: pokemon)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func weightBar(for pokemon: Pokemon) -> some View {
        let maxWeight = self.pokemon.map(\.weight).max() ?? 1
        let weightPercentage = Double(pokemon.weight) / Double(maxWeight)
        
        return HStack {
            // Pokemon info
            HStack(spacing: 8) {
                AsyncImage(url: URL(string: pokemon.sprites.defaultSprite)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(pokemon.name.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(pokemon.formattedWeight)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, alignment: .leading)
            
            // Weight bar
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [pokemon.primaryType.color, pokemon.primaryType.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * weightPercentage * animationProgress)
                        .animation(.easeOut(duration: 1.0), value: animationProgress)
                    
                    Spacer(minLength: 0)
                }
            }
            .frame(height: 20)
            .background(Color(.systemGray4))
            .cornerRadius(10)
            
            // Weight value
            Text(pokemon.formattedWeight)
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 50, alignment: .trailing)
        }
    }
    
    private var combinedComparisonView: some View {
        VStack(spacing: 16) {
            Text("Size Comparison Matrix")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Scatter plot style comparison
            GeometryReader { geometry in
                let plotSize = min(geometry.size.width, geometry.size.height) - 60
                let maxWeight = pokemon.map(\.weight).max() ?? 1
                let maxHeight = pokemon.map(\.height).max() ?? 1
                
                ZStack {
                    // Grid lines
                    gridLines(size: plotSize)
                    
                    // Pokemon points
                    ForEach(pokemon, id: \.id) { pokemon in
                        let x = CGFloat(pokemon.weight) / CGFloat(maxWeight) * plotSize
                        let y = plotSize - (CGFloat(pokemon.height) / CGFloat(maxHeight) * plotSize)
                        
                        pokemonPoint(pokemon: pokemon)
                            .position(x: 30 + x * animationProgress, y: 30 + y)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(Double(pokemon.id % 5) * 0.1), value: animationProgress)
                    }
                }
                .frame(width: plotSize + 60, height: plotSize + 60)
            }
            .frame(height: 250)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Axis labels
            HStack {
                Text("Weight →")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                VStack {
                    Text("↑")
                    Text("Height")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
    
    private func gridLines(size: CGFloat) -> some View {
        ZStack {
            // Vertical lines
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: size)
                    .offset(x: CGFloat(i) * size / 4 - size / 2)
            }
            
            // Horizontal lines
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: size, height: 1)
                    .offset(y: CGFloat(i) * size / 4 - size / 2)
            }
        }
    }
    
    private func pokemonPoint(pokemon: Pokemon) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(pokemon.primaryType.color)
                .frame(width: 20, height: 20)
                .overlay(
                    AsyncImage(url: URL(string: pokemon.sprites.defaultSprite)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Text(String(pokemon.name.prefix(1)).uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
                )
            
            Text(pokemon.name.capitalized)
                .font(.system(size: 8))
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }
    
    private var statisticsSummary: some View {
        VStack(spacing: 12) {
            Text("Size Statistics")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                // Height stats
                VStack(alignment: .leading, spacing: 4) {
                    Text("Height")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    if let tallest = pokemon.max(by: { $0.height < $1.height }) {
                        Label("Tallest: \(tallest.name.capitalized)", systemImage: "arrow.up")
                            .font(.caption2)
                    }
                    
                    if let shortest = pokemon.min(by: { $0.height < $1.height }) {
                        Label("Shortest: \(shortest.name.capitalized)", systemImage: "arrow.down")
                            .font(.caption2)
                    }
                }
                
                Spacer()
                
                // Weight stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Weight")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    if let heaviest = pokemon.max(by: { $0.weight < $1.weight }) {
                        Label("Heaviest: \(heaviest.name.capitalized)", systemImage: "scalemass")
                            .font(.caption2)
                    }
                    
                    if let lightest = pokemon.min(by: { $0.weight < $1.weight }) {
                        Label("Lightest: \(lightest.name.capitalized)", systemImage: "feather")
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func getHeightScale(for pokemon: Pokemon, maxHeight: Int) -> Double {
        let minScale = 0.4
        let maxScale = 1.0
        let heightRatio = Double(pokemon.height) / Double(maxHeight)
        return minScale + (maxScale - minScale) * heightRatio
    }
}

#Preview {
    SizeComparisonView(pokemon: [Pokemon.mockPokemon])
        .padding()
}
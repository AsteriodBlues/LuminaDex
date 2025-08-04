import SwiftUI
import Combine

struct DataLoadingView: View {
    @EnvironmentObject var dataFetcher: PokemonDataFetcher
    @State private var showingDetails = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App Icon/Logo area
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("LuminaDex")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Loading Pokémon Data")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Progress Section
                VStack(spacing: 20) {
                    // Main Progress Bar
                    VStack(spacing: 8) {
                        HStack {
                            Text("Overall Progress")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(Int(dataFetcher.progress * 100))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        
                        ProgressView(value: min(max(dataFetcher.progress, 0.0), 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(y: 2)
                    }
                    
                    // Current Operation
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Operation:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(dataFetcher.currentOperation)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Detailed Progress (if expanded)
                    if showingDetails {
                        detailedProgressView
                    }
                    
                    // Toggle Details Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingDetails.toggle()
                        }
                    }) {
                        HStack {
                            Text(showingDetails ? "Hide Details" : "Show Details")
                            Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Error Section (if any)
                if dataFetcher.hasErrors {
                    errorSection
                }
                
                Spacer()
                
                // Footer
                Text("This may take a few minutes on first launch")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var detailedProgressView: some View {
        VStack(spacing: 12) {
            // Pokemon Progress
            progressRow(
                title: "Pokémon",
                current: dataFetcher.pokemonFetched,
                total: dataFetcher.totalPokemon,
                color: .red
            )
            
            // Moves Progress
            progressRow(
                title: "Moves",
                current: dataFetcher.movesFetched,
                total: dataFetcher.totalMoves,
                color: .green
            )
            
            // Abilities Progress
            progressRow(
                title: "Abilities",
                current: dataFetcher.abilitiesFetched,
                total: dataFetcher.totalAbilities,
                color: .purple
            )
            
            // Items Progress
            progressRow(
                title: "Items",
                current: dataFetcher.itemsFetched,
                total: dataFetcher.totalItems,
                color: .orange
            )
        }
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private var errorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Some Issues Occurred")
                    .font(.headline)
                    .foregroundColor(.orange)
                Spacer()
            }
            
            Text("\(dataFetcher.errors.count) error(s) - Data loading will continue")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("View Errors") {
                // TODO: Show error details
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func progressRow(title: String, current: Int, total: Int, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            
            ProgressView(value: min(Double(current), Double(total)), total: Double(max(total, 1)))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
            
            Text("\(current)/\(total)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .trailing)
        }
    }
}

// MARK: - Preview
struct DataLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DataLoadingView()
            .environmentObject({
                let fetcher = PokemonDataFetcher.shared
                fetcher.progress = 0.6
                fetcher.currentOperation = "Fetching Pokémon 512/1025..."
                fetcher.pokemonFetched = 512
                fetcher.movesFetched = 200
                fetcher.abilitiesFetched = 100
                fetcher.itemsFetched = 50
                return fetcher
            }())
    }
}
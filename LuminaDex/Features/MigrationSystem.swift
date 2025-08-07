//
//  MigrationSystem.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

// MARK: - Migration Flow System

class MigrationManager: ObservableObject {
    @Published var migrationStreams: [MigrationStream] = []
    @Published var seasonalEvents: [SeasonalEvent] = []
    
    private var migrationTimer: Timer?
    private let migrationInterval: TimeInterval = 30.0 // New migration every 30 seconds
    
    init() {
        setupMigrationPatterns()
        startMigrationCycle()
    }
    
    private func setupMigrationPatterns() {
        // Initialize with some baseline migration patterns
        migrationStreams = [
            createMigrationStream(from: "Kanto", to: "Johto", species: .bird, intensity: .medium),
            createMigrationStream(from: "Hoenn", to: "Sinnoh", species: .water, intensity: .light),
            createMigrationStream(from: "Unova", to: "Kalos", species: .electric, intensity: .heavy)
        ]
    }
    
    private func startMigrationCycle() {
        migrationTimer = Timer.scheduledTimer(withTimeInterval: migrationInterval, repeats: true) { _ in
            self.triggerNewMigration()
            self.updateExistingMigrations()
        }
    }
    
    private func triggerNewMigration() {
        let regions = ["Kanto", "Johto", "Hoenn", "Sinnoh", "Unova", "Kalos", "Alola", "Galar", "Paldea"]
        let species = PokemonSpeciesType.allCases
        let intensities = MigrationIntensity.allCases
        
        guard let fromRegion = regions.randomElement(),
              let toRegion = regions.randomElement(),
              fromRegion != toRegion,
              let speciesType = species.randomElement(),
              let intensity = intensities.randomElement() else { return }
        
        let newMigration = createMigrationStream(
            from: fromRegion,
            to: toRegion,
            species: speciesType,
            intensity: intensity
        )
        
        withAnimation(.easeInOut(duration: 2.0)) {
            migrationStreams.append(newMigration)
        }
        
        // Remove old migrations after 2 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
            withAnimation(.easeOut(duration: 1.0)) {
                self.migrationStreams.removeAll { $0.id == newMigration.id }
            }
        }
    }
    
    private func updateExistingMigrations() {
        for stream in migrationStreams {
            // Update migration progress and particle positions
            stream.updateProgress()
        }
    }
    
    private func createMigrationStream(
        from: String,
        to: String,
        species: PokemonSpeciesType,
        intensity: MigrationIntensity
    ) -> MigrationStream {
        MigrationStream(
            id: UUID(),
            fromRegion: from,
            toRegion: to,
            species: species,
            intensity: intensity,
            startTime: Date(),
            duration: TimeInterval.random(in: 60...180) // 1-3 minutes
        )
    }
    
    func celebrateMigration(at region: String) {
        // Trigger special migration celebration
        let celebrationMigration = createMigrationStream(
            from: region,
            to: "All Regions",
            species: .legendary,
            intensity: .celebration
        )
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            migrationStreams.append(celebrationMigration)
        }
        
        // Remove celebration after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            withAnimation(.easeOut(duration: 2.0)) {
                self.migrationStreams.removeAll { $0.id == celebrationMigration.id }
            }
        }
    }
}

// MARK: - Migration Stream Model

class MigrationStream: ObservableObject, Identifiable {
    let id: UUID
    let fromRegion: String
    let toRegion: String
    let species: PokemonSpeciesType
    let intensity: MigrationIntensity
    let startTime: Date
    let duration: TimeInterval
    
    @Published var progress: CGFloat = 0.0
    @Published var particles: [MigrationParticle] = []
    
    init(id: UUID, fromRegion: String, toRegion: String, species: PokemonSpeciesType, intensity: MigrationIntensity, startTime: Date, duration: TimeInterval) {
        self.id = id
        self.fromRegion = fromRegion
        self.toRegion = toRegion
        self.species = species
        self.intensity = intensity
        self.startTime = startTime
        self.duration = duration
        
        generateParticles()
        startAnimation()
    }
    
    private func generateParticles() {
        let particleCount = intensity.particleCount
        
        for i in 0..<particleCount {
            let particle = MigrationParticle(
                id: UUID(),
                species: species,
                offset: CGFloat(i) / CGFloat(particleCount),
                speed: CGFloat.random(in: 0.8...1.2)
            )
            particles.append(particle)
        }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: duration)) {
            progress = 1.0
        }
    }
    
    func updateProgress() {
        let elapsed = Date().timeIntervalSince(startTime)
        progress = min(CGFloat(elapsed / duration), 1.0)
        
        // Update particle positions
        for particle in particles {
            particle.updatePosition(streamProgress: progress)
        }
    }
}

// MARK: - Migration Particle

class MigrationParticle: ObservableObject, Identifiable {
    let id: UUID
    let species: PokemonSpeciesType
    let offset: CGFloat
    let speed: CGFloat
    
    @Published var position: CGFloat = 0.0
    @Published var scale: CGFloat = 1.0
    @Published var opacity: Double = 1.0
    
    init(id: UUID, species: PokemonSpeciesType, offset: CGFloat, speed: CGFloat) {
        self.id = id
        self.species = species
        self.offset = offset
        self.speed = speed
    }
    
    func updatePosition(streamProgress: CGFloat) {
        // Particle position along the migration path
        position = min((streamProgress + offset) * speed, 1.0)
        
        // Fade in/out at beginning and end
        if position < 0.1 {
            opacity = Double(position * 10)
        } else if position > 0.9 {
            opacity = Double((1.0 - position) * 10)
        } else {
            opacity = 1.0
        }
        
        // Subtle scale animation
        scale = 0.8 + sin(position * .pi * 4) * 0.2
    }
}

// MARK: - Supporting Types

enum PokemonSpeciesType: String, CaseIterable {
    case bird = "🐦"
    case water = "🐟"
    case electric = "⚡"
    case fire = "🔥"
    case grass = "🌿"
    case ice = "❄️"
    case psychic = "🔮"
    case dragon = "🐉"
    case legendary = "✨"
    
    var color: Color {
        switch self {
        case .bird: return .cyan
        case .water: return .blue
        case .electric: return .yellow
        case .fire: return .red
        case .grass: return .green
        case .ice: return .white
        case .psychic: return .purple
        case .dragon: return .orange
        case .legendary: return .gold
        }
    }
    
    var emoji: String {
        return rawValue
    }
}

enum MigrationIntensity: String, CaseIterable {
    case light, medium, heavy, celebration
    
    var particleCount: Int {
        switch self {
        case .light: return 3
        case .medium: return 6
        case .heavy: return 12
        case .celebration: return 20
        }
    }
    
    var streamWidth: CGFloat {
        switch self {
        case .light: return 2.0
        case .medium: return 4.0
        case .heavy: return 6.0
        case .celebration: return 8.0
        }
    }
    
    var color: Color {
        switch self {
        case .light: return .green
        case .medium: return .yellow
        case .heavy: return .orange
        case .celebration: return .purple
        }
    }
}

// MARK: - Seasonal Events

struct SeasonalEvent: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let triggerRegions: [String]
    let specialSpecies: PokemonSpeciesType
    let duration: TimeInterval
    let isActive: Bool
    
    static let allEvents: [SeasonalEvent] = [
        SeasonalEvent(
            name: "Great Migration",
            description: "Massive bird Pokémon migration across regions",
            triggerRegions: ["Kanto", "Johto", "Hoenn"],
            specialSpecies: .bird,
            duration: 300, // 5 minutes
            isActive: false
        ),
        SeasonalEvent(
            name: "Electric Storm Gathering",
            description: "Electric types converging for a storm event",
            triggerRegions: ["Unova", "Kalos"],
            specialSpecies: .electric,
            duration: 180, // 3 minutes
            isActive: false
        ),
        SeasonalEvent(
            name: "Legendary Awakening",
            description: "Legendary Pokémon emerging across all regions",
            triggerRegions: ["All"],
            specialSpecies: .legendary,
            duration: 600, // 10 minutes
            isActive: false
        )
    ]
}

// MARK: - Main Migration System View

struct MigrationSystemView: View {
    @StateObject private var migrationManager = MigrationManager()
    @State private var selectedStream: MigrationStream?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Migration Patterns")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track Pokemon movements across regions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Active Migrations
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Migrations")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if migrationManager.migrationStreams.isEmpty {
                        Text("No active migrations")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(migrationManager.migrationStreams) { stream in
                            MigrationCard(stream: stream)
                                .onTapGesture {
                                    selectedStream = stream
                                }
                        }
                    }
                }
                
                // Seasonal Events
                if !migrationManager.seasonalEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Seasonal Events")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(migrationManager.seasonalEvents) { event in
                            SeasonalEventCard(event: event)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MigrationCard: View {
    @ObservedObject var stream: MigrationStream
    
    private var isActive: Bool {
        stream.progress < 1.0 && stream.progress > 0.0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(stream.species.emoji)
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(stream.fromRegion)
                        .fontWeight(.medium)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                    Text(stream.toRegion)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text(stream.species.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(stream.intensity.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(stream.intensity.color)
                }
            }
            
            Spacer()
            
            // Migration progress indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: stream.progress)
                    .stroke(
                        isActive ? Color.green : Color.gray,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(stream.progress * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isActive ? .green : .gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
        .padding(.horizontal)
    }
}

struct SeasonalEventCard: View {
    let event: SeasonalEvent
    
    private var eventIcon: String {
        switch event.specialSpecies {
        case .bird: return "bird.fill"
        case .water: return "drop.fill"
        case .electric: return "bolt.fill"
        case .fire: return "flame.fill"
        case .grass: return "leaf.fill"
        case .psychic: return "brain.head.profile"
        case .dragon: return "sparkles"
        case .legendary: return "star.circle.fill"
        case .ice: return "snowflake"
        }
    }
    
    private var eventColor: Color {
        event.specialSpecies.color
    }
    
    var body: some View {
        HStack {
            Image(systemName: eventIcon)
                .font(.title2)
                .foregroundColor(eventColor)
            
            VStack(alignment: .leading) {
                Text(event.name)
                    .fontWeight(.medium)
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(eventColor.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// MARK: - Migration View Component

struct MigrationStreamView: View {
    @ObservedObject var stream: MigrationStream
    let fromPosition: CGPoint
    let toPosition: CGPoint
    let cameraOffset: CGSize
    let zoomScale: CGFloat
    
    var body: some View {
        ZStack {
            // Migration path
            Path { path in
                let adjustedFrom = CGPoint(
                    x: fromPosition.x * zoomScale + cameraOffset.width,
                    y: fromPosition.y * zoomScale + cameraOffset.height
                )
                let adjustedTo = CGPoint(
                    x: toPosition.x * zoomScale + cameraOffset.width,
                    y: toPosition.y * zoomScale + cameraOffset.height
                )
                
                path.move(to: adjustedFrom)
                path.addLine(to: adjustedTo)
            }
            .stroke(
                stream.species.color.opacity(0.3),
                style: StrokeStyle(
                    lineWidth: stream.intensity.streamWidth * zoomScale,
                    lineCap: .round,
                    dash: [10, 5]
                )
            )
            
            // Migration particles
            ForEach(stream.particles) { particle in
                Text(stream.species.emoji)
                    .font(.system(size: 16 * zoomScale))
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(
                        interpolatePosition(
                            from: fromPosition,
                            to: toPosition,
                            progress: particle.position
                        )
                    )
            }
        }
    }
    
    private func interpolatePosition(from: CGPoint, to: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(
            x: (from.x + (to.x - from.x) * progress) * zoomScale + cameraOffset.width,
            y: (from.y + (to.y - from.y) * progress) * zoomScale + cameraOffset.height
        )
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}
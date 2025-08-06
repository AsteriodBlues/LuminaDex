//
//  BerryDetailView.swift
//  LuminaDex
//
//  Detailed berry information view
//

import SwiftUI
import Charts

struct BerryDetailView: View {
    let berry: Berry
    @State private var selectedTab = 0
    @State private var animateFlavorChart = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header with berry image
                    headerSection
                    
                    // Tab selector
                    Picker("Info", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Flavors").tag(1)
                        Text("Growth").tag(2)
                        Text("Usage").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case 0:
                            overviewSection
                        case 1:
                            flavorsSection
                        case 2:
                            growthSection
                        case 3:
                            usageSection
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { /* Share functionality */ }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Berry image with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                BerryCategory.categorize(berry).color.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                AsyncImage(url: URL(string: berry.spriteURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 120, height: 120)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                    case .failure(_):
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                            .frame(width: 120, height: 120)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .padding(.top, 20)
            
            // Berry name and category
            VStack(spacing: 8) {
                Text(berry.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Label(BerryCategory.categorize(berry).rawValue, systemImage: "tag.fill")
                    .font(.caption)
                    .foregroundColor(BerryCategory.categorize(berry).color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BerryCategory.categorize(berry).color.opacity(0.2))
                    .cornerRadius(20)
            }
        }
    }
    
    private var overviewSection: some View {
        VStack(spacing: 16) {
            // Basic stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                BerryStatCard(title: "Size", value: "\(berry.size) mm", icon: "ruler", color: Color.blue)
                BerryStatCard(title: "Firmness", value: berry.firmness.capitalized, icon: "hand.tap.fill", color: Color.purple)
                BerryStatCard(title: "Smoothness", value: "\(berry.smoothness)", icon: "waveform", color: Color.green)
                BerryStatCard(title: "Natural Gift", value: "\(berry.naturalGiftPower)", icon: "gift.fill", color: Color.orange)
            }
            
            // Type effectiveness if Natural Gift is used
            if let giftType = berry.naturalGiftType {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Natural Gift Type")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: giftType.icon)
                        Text(giftType.displayName)
                    }
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(giftType.color.opacity(0.3))
                    .cornerRadius(20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
    
    private var flavorsSection: some View {
        VStack(spacing: 16) {
            // Flavor chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Flavor Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Radar chart or bar chart for flavors
                VStack(spacing: 8) {
                    FlavorBar(flavor: "Spicy", value: berry.flavors.spicy, color: .red)
                    FlavorBar(flavor: "Dry", value: berry.flavors.dry, color: .blue)
                    FlavorBar(flavor: "Sweet", value: berry.flavors.sweet, color: .pink)
                    FlavorBar(flavor: "Bitter", value: berry.flavors.bitter, color: .green)
                    FlavorBar(flavor: "Sour", value: berry.flavors.sour, color: .yellow)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Preferred by Pokémon with these natures
            if let dominantFlavor = berry.flavors.dominant {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred by Natures")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Pokémon with natures that like \(dominantFlavor.rawValue) flavors will enjoy this berry.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateFlavorChart = true
            }
        }
    }
    
    private var growthSection: some View {
        VStack(spacing: 16) {
            // Growth stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Cultivation Info")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Label("\(berry.growthTime) hours", systemImage: "clock.fill")
                    Spacer()
                    Text("Growth Time")
                        .foregroundColor(.gray)
                }
                .font(.body)
                .foregroundColor(.white)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                HStack {
                    Label("\(berry.maxHarvest) berries", systemImage: "leaf.fill")
                    Spacer()
                    Text("Max Harvest")
                        .foregroundColor(.gray)
                }
                .font(.body)
                .foregroundColor(.white)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                HStack {
                    Label("\(berry.soilDryness) hours", systemImage: "drop.fill")
                    Spacer()
                    Text("Soil Dryness Rate")
                        .foregroundColor(.gray)
                }
                .font(.body)
                .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Growth stages visualization
            GrowthStagesView(growthTime: berry.growthTime)
        }
    }
    
    private var usageSection: some View {
        VStack(spacing: 16) {
            // Competitive usage
            VStack(alignment: .leading, spacing: 12) {
                Text("Competitive Usage")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(berry.item.effect)
                    .font(.body)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Recommended Pokémon
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommended For")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(getRecommendedUsage())
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func getRecommendedUsage() -> String {
        switch BerryCategory.categorize(berry) {
        case .healing:
            return "Great for bulky Pokémon and stall teams. Provides consistent recovery in longer battles."
        case .statusCure:
            return "Essential for Pokémon vulnerable to status conditions. Pairs well with Rest or Natural Cure ability."
        case .statBoost:
            return "Perfect for sweepers and setup Pokémon. Activates at low HP to provide a crucial stat boost."
        case .typeResist:
            return "Ideal for Pokémon with 4x weaknesses. Reduces super-effective damage when hit."
        case .pinch:
            return "Excellent for Pokémon with Gluttony ability. Provides healing at higher HP thresholds."
        case .evReducing:
            return "Used for EV training. Reduces specific EVs by 10 points while increasing happiness."
        case .other:
            return "Has unique effects that can be useful in specific situations or strategies."
        }
    }
}

struct BerryStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct FlavorBar: View {
    let flavor: String
    let value: Int
    let color: Color
    @State private var animatedValue: CGFloat = 0
    
    var body: some View {
        HStack {
            Text(flavor)
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * animatedValue, height: 20)
                }
            }
            .frame(height: 20)
            
            Text("\(value)")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 30, alignment: .trailing)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedValue = CGFloat(value) / 40.0 // Max flavor value is typically 40
            }
        }
    }
}

struct GrowthStagesView: View {
    let growthTime: Int
    
    var stages: [(String, String)] {
        [
            ("seedling", "Planted"),
            ("sprout", "Sprouted"),
            ("bud", "Budding"),
            ("flower", "Flowering"),
            ("berry", "Berry")
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Growth Stages")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 4) {
                ForEach(0..<stages.count, id: \.self) { index in
                    VStack(spacing: 4) {
                        Image(systemName: getStageIcon(index))
                            .font(.title3)
                            .foregroundColor(.green)
                        
                        Text(stages[index].1)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                        Text("\(growthTime / 4 * index)h")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                    
                    if index < stages.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func getStageIcon(_ stage: Int) -> String {
        switch stage {
        case 0: return "circle.fill"
        case 1: return "leaf"
        case 2: return "leaf.fill"
        case 3: return "sparkles"
        case 4: return "star.fill"
        default: return "leaf"
        }
    }
}
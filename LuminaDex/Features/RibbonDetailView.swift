//
//  RibbonDetailView.swift
//  LuminaDex
//
//  Detailed ribbon view with modern animations
//

import SwiftUI

struct RibbonDetailView: View {
    let ribbon: Ribbon
    let isEarned: Bool
    
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false
    @State private var rotationAngle: Double = 0
    @State private var sparklePositions: [CGPoint] = []
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Section
                        heroSection
                            .scaleEffect(animateIn ? 1 : 0.5)
                            .opacity(animateIn ? 1 : 0)
                        
                        // Info Cards
                        VStack(spacing: 16) {
                            descriptionCard
                                .offset(y: animateIn ? 0 : 50)
                                .opacity(animateIn ? 1 : 0)
                            
                            requirementsCard
                                .offset(y: animateIn ? 0 : 50)
                                .opacity(animateIn ? 1 : 0)
                                .animation(.spring().delay(0.1), value: animateIn)
                            
                            detailsCard
                                .offset(y: animateIn ? 0 : 50)
                                .opacity(animateIn ? 1 : 0)
                                .animation(.spring().delay(0.2), value: animateIn)
                            
                            if let specialEvent = ribbon.specialEvent {
                                eventCard(specialEvent)
                                    .offset(y: animateIn ? 0 : 50)
                                    .opacity(animateIn ? 1 : 0)
                                    .animation(.spring().delay(0.3), value: animateIn)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(ribbon.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateIn = true
            }
            startAnimations()
            generateSparklePositions()
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.02, green: 0.02, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated gradient orbs
            GeometryReader { geometry in
                ForEach(0..<3) { index in
                    Circle()
                        .fill(ribbon.category.gradient)
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .opacity(0.3)
                        .offset(
                            x: cos(rotationAngle + Double(index) * 2.0944) * 100,
                            y: sin(rotationAngle + Double(index) * 2.0944) * 100
                        )
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 3
                        )
                }
            }
            
            // Sparkles for rare ribbons
            if ribbon.rarity.rawValue >= 3 {
                ForEach(sparklePositions.indices, id: \.self) { index in
                    SparkleParticle()
                        .position(sparklePositions[index])
                }
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 20) {
            // Large Ribbon Display
            ZStack {
                // Glow effect
                Circle()
                    .fill(ribbon.category.gradient)
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)
                    .opacity(pulseAnimation ? 0.6 : 0.3)
                
                // Show real ribbon image or rosette
                if let imageURL = ribbon.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(rotationAngle * 10))
                                .shadow(color: ribbon.category.color.opacity(0.5), radius: 10)
                        case .failure(_):
                            // Fallback to rosette
                            LargeRibbonRosette(
                                category: ribbon.category,
                                rarity: ribbon.rarity,
                                isEarned: isEarned
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(rotationAngle * 10))
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: ribbon.category.color))
                        @unknown default:
                            LargeRibbonRosette(
                                category: ribbon.category,
                                rarity: ribbon.rarity,
                                isEarned: isEarned
                            )
                            .frame(width: 120, height: 120)
                        }
                    }
                } else {
                    LargeRibbonRosette(
                        category: ribbon.category,
                        rarity: ribbon.rarity,
                        isEarned: isEarned
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotationAngle * 10))
                }
                
                // Earned badge
                if isEarned {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title)
                                .foregroundColor(.green)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                        .frame(width: 40, height: 40)
                                )
                        }
                    }
                    .frame(width: 150, height: 150)
                }
            }
            .frame(height: 180)
            
            // Title and Category
            VStack(spacing: 8) {
                Text(ribbon.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    // Category Badge
                    HStack(spacing: 4) {
                        Image(systemName: ribbon.category.icon)
                            .font(.caption)
                        Text(ribbon.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(ribbon.category.gradient)
                    )
                    
                    // Rarity Badge
                    HStack(spacing: 2) {
                        ForEach(0..<ribbon.rarity.rawValue, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                        }
                        Text(ribbon.rarity.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(ribbon.rarity.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(ribbon.rarity.color.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(ribbon.rarity.color.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    // MARK: - Info Cards
    private var descriptionCard: some View {
        RibbonInfoCard(
            title: "Description",
            icon: "text.quote",
            color: .blue
        ) {
            Text(ribbon.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var requirementsCard: some View {
        RibbonInfoCard(
            title: "Requirements",
            icon: "checklist",
            color: .green
        ) {
            HStack {
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text(ribbon.requirements)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
    
    private var detailsCard: some View {
        RibbonInfoCard(
            title: "Details",
            icon: "info.circle",
            color: .purple
        ) {
            VStack(alignment: .leading, spacing: 12) {
                RibbonDetailRow(label: "Generation", value: "Gen \(ribbon.generation)")
                
                if let region = ribbon.region {
                    RibbonDetailRow(label: "Region", value: region)
                }
                
                if let contest = ribbon.contest {
                    RibbonDetailRow(label: "Contest Type", value: contest.rawValue, color: contest.color)
                }
                
                RibbonDetailRow(label: "Rarity", value: ribbon.rarity.title, color: ribbon.rarity.color)
            }
        }
    }
    
    private func eventCard(_ event: String) -> some View {
        RibbonInfoCard(
            title: "Special Event",
            icon: "sparkles",
            color: .yellow
        ) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Event Ribbon")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(event)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func startAnimations() {
        withAnimation(
            .linear(duration: 20)
            .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
        
        withAnimation(
            .easeInOut(duration: 2)
            .repeatForever(autoreverses: true)
        ) {
            pulseAnimation = true
        }
    }
    
    private func generateSparklePositions() {
        sparklePositions = (0..<10).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            )
        }
    }
}

// MARK: - Large Ribbon Rosette
struct LargeRibbonRosette: View {
    let category: RibbonCategory
    let rarity: RibbonRarity
    let isEarned: Bool
    
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Outer decorative ring
            ForEach(0..<12) { index in
                Diamond()
                    .fill(category.gradient)
                    .frame(width: 15, height: 30)
                    .offset(y: -50)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .opacity(isEarned ? 1 : 0.5)
            }
            
            // Middle ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            category.color,
                            category.color.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 80, height: 80)
            
            // Inner pattern
            ForEach(0..<8) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(category.gradient)
                    .frame(width: 6, height: 30)
                    .offset(y: -25)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            
            // Center gem
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            rarity.color,
                            rarity.color.opacity(0.2)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 45, height: 45)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
            
            // Category icon
            Image(systemName: category.icon)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 2)
        }
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            withAnimation(
                .linear(duration: 30)
                .repeatForever(autoreverses: false)
            ) {
                rotationAngle = 360
            }
        }
    }
}

// MARK: - Helper Views
struct RibbonInfoCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct RibbonDetailRow: View {
    let label: String
    let value: String
    var color: Color = .white
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.move(to: CGPoint(x: center.x, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: center.y))
        path.closeSubpath()
        
        return path
    }
}

struct SparkleParticle: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: CGFloat.random(in: 8...16)))
            .foregroundColor(.yellow)
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = Double.random(in: 0.3...0.8)
                    scale = CGFloat.random(in: 0.8...1.2)
                    yOffset = CGFloat.random(in: -20...20)
                }
            }
    }
}
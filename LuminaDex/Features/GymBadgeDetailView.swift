//
//  GymBadgeDetailView.swift
//  LuminaDex
//
//  Detailed view for individual gym badges
//

import SwiftUI

struct GymBadgeDetailView: View {
    let badge: GymBadge
    @State var isEarned: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [badge.type.color.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Badge display
                    badgeHeader
                    
                    // Badge info cards
                    infoSection
                    
                    // Gym Leader section
                    gymLeaderSection
                    
                    // Requirements section
                    requirementsSection
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEarned.toggle() }) {
                    Image(systemName: isEarned ? "checkmark.seal.fill" : "checkmark.seal")
                        .foregroundColor(isEarned ? .green : .gray)
                }
            }
        }
    }
    
    private var badgeHeader: some View {
        VStack(spacing: 16) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [badge.type.color.opacity(0.5), Color.clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                
                Image(systemName: badgeIcon)
                    .font(.system(size: 80))
                    .foregroundColor(badge.type.color)
                    .shadow(color: badge.type.color, radius: isEarned ? 10 : 0)
            }
            .scaleEffect(isEarned ? 1.1 : 1.0)
            .animation(.spring(), value: isEarned)
            
            // Badge name
            VStack(spacing: 8) {
                Text(badge.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Badge #\(badge.badgeNumber) • \(badge.region.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 20)
    }
    
    private var infoSection: some View {
        VStack(spacing: 16) {
            InfoCard(title: "Gym Leader", value: badge.gymLeader, icon: "person.fill", color: badge.type.color)
            InfoCard(title: "Location", value: badge.city, icon: "location.fill", color: badge.type.color)
            InfoCard(title: "Type Specialty", value: badge.type.displayName, icon: badge.type.icon, color: badge.type.color)
            
            if let tm = badge.tmReward {
                InfoCard(title: "TM Reward", value: tm, icon: "disc.fill", color: .purple)
            }
        }
        .padding(.horizontal)
    }
    
    private var gymLeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Gym Leader", systemImage: "person.text.rectangle")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(badge.gymLeader)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(badge.type.displayName) Type Specialist")
                        .font(.caption)
                        .foregroundColor(badge.type.color)
                }
                
                Spacer()
                
                Image(systemName: "figure.wave")
                    .font(.largeTitle)
                    .foregroundColor(badge.type.color)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Badge Effects", systemImage: "star.fill")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                if let levelCap = badge.levelCap {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("Pokémon up to Lv. \(levelCap) will obey")
                            .foregroundColor(.white)
                    }
                }
                
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                    Text(badge.description)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var badgeIcon: String {
        switch badge.type {
        case .rock: return "mountain.2.fill"
        case .water: return "drop.fill"
        case .electric: return "bolt.fill"
        case .grass: return "leaf.fill"
        case .poison: return "smoke.fill"
        case .psychic: return "brain"
        case .fire: return "flame.fill"
        case .ground: return "globe.americas.fill"
        case .flying: return "wind"
        case .bug: return "ant.fill"
        case .normal: return "circle.fill"
        case .ghost: return "eye.trianglebadge.exclamationmark"
        case .fighting: return "figure.boxing"
        case .steel: return "shield.fill"
        case .ice: return "snowflake"
        case .dragon: return "sparkles"
        case .dark: return "moon.fill"
        case .fairy: return "star.fill"
        default: return "questionmark.circle"
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
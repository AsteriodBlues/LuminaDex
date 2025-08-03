//
//  ProfileView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Neural Network Background
                NeuralNetworkBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader
                        
                        // Stats Overview
                        statsOverview
                        
                        // Recent Activity
                        recentActivity
                        
                        // Settings Section
                        settingsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Neural Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(ThemeManager.Colors.neuralGradient)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(ThemeManager.Colors.neuralGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            // Name and Title
            VStack(spacing: 4) {
                Text("Neural Explorer")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Collection Master")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Stats Overview
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discovery Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ProfileStatCard(
                    title: "Discovered",
                    value: "42",
                    icon: "eye.fill",
                    gradient: [.blue, .purple]
                )
                
                ProfileStatCard(
                    title: "Caught",
                    value: "28",
                    icon: "checkmark.circle.fill",
                    gradient: [.green, .teal]
                )
                
                ProfileStatCard(
                    title: "Favorites",
                    value: "15",
                    icon: "heart.fill",
                    gradient: [.pink, .red]
                )
                
                ProfileStatCard(
                    title: "Achievements",
                    value: "7",
                    icon: "trophy.fill",
                    gradient: [.yellow, .orange]
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Recent Activity
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                activityItem(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: "Caught Charizard",
                    subtitle: "2 hours ago"
                )
                
                activityItem(
                    icon: "heart.fill",
                    color: .pink,
                    title: "Favorited Blastoise",
                    subtitle: "5 hours ago"
                )
                
                activityItem(
                    icon: "trophy.fill",
                    color: .yellow,
                    title: "Unlocked Fire Master",
                    subtitle: "1 day ago"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private func activityItem(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                settingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Discovery alerts and updates"
                ) {
                    // Handle notifications settings
                }
                
                settingsRow(
                    icon: "icloud.fill",
                    title: "Cloud Sync",
                    subtitle: "Sync collection across devices"
                ) {
                    // Handle cloud sync
                }
                
                settingsRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Neural interface theme"
                ) {
                    // Handle dark mode toggle
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private func settingsRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ThemeManager.Colors.neuralGradient)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("General") {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Notifications")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Image(systemName: "icloud.fill")
                        Text("Cloud Sync")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                Section("Display") {
                    HStack {
                        Image(systemName: "moon.fill")
                        Text("Always Dark Mode")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Reduced Motion")
                        Spacer()
                        Toggle("", isOn: .constant(false))
                    }
                }
                
                Section("Data") {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Sync Collection")
                            Spacer()
                        }
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Reset Progress")
                            Spacer()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview
// MARK: - Profile Stat Card
struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    .linearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.linearGradient(
                    colors: gradient.map { $0.opacity(0.3) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
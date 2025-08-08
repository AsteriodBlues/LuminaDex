//
//  TeamBuilderHelpers.swift
//  LuminaDex
//
//  Helper views and components for Team Builder
//

import SwiftUI

// MARK: - Success Overlay
struct SuccessOverlay: View {
    @Binding var isShowing: Bool
    let message: String
    let icon: String
    
    var body: some View {
        ZStack {
            if isShowing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: icon)
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isShowing ? 1 : 0.5)
                    
                    Text(message)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.black.opacity(0.8))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(
                                    LinearGradient(
                                        colors: [.green.opacity(0.5), .mint.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
                .scaleEffect(isShowing ? 1 : 0.8)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isShowing)
        .onAppear {
            if isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }
}

// MARK: - Export Options Sheet
struct ExportOptionsSheet: View {
    @Binding var isPresented: Bool
    let team: PokemonTeam
    let onExport: (ExportFormat) -> Void
    
    enum ExportFormat {
        case showdown
        case json
        case qrCode
        case image
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Team")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    ExportOptionCard(
                        title: "Showdown Format",
                        subtitle: "Compatible with Pokemon Showdown",
                        icon: "doc.text",
                        gradient: [.blue, .cyan]
                    ) {
                        onExport(.showdown)
                        isPresented = false
                    }
                    
                    ExportOptionCard(
                        title: "JSON File",
                        subtitle: "Share with other LuminaDex users",
                        icon: "doc.badge.gearshape",
                        gradient: [.purple, .pink]
                    ) {
                        onExport(.json)
                        isPresented = false
                    }
                    
                    ExportOptionCard(
                        title: "QR Code",
                        subtitle: "Quick sharing via camera",
                        icon: "qrcode",
                        gradient: [.orange, .red]
                    ) {
                        onExport(.qrCode)
                        isPresented = false
                    }
                    
                    ExportOptionCard(
                        title: "Image",
                        subtitle: "Beautiful team visualization",
                        icon: "photo",
                        gradient: [.green, .mint]
                    ) {
                        onExport(.image)
                        isPresented = false
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.02, green: 0.02, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.white)
            )
        }
    }
}

struct ExportOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: gradient.map { $0.opacity(0.3) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Template Selection View
struct TemplateSelectionView: View {
    @Binding var isPresented: Bool
    let onSelect: (PokemonTeam) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Choose a Template")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text("Start with a pre-built team strategy")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    ForEach(TeamTemplate.templates, id: \.id) { template in
                        TemplateCard(template: template) {
                            onSelect(template)
                            isPresented = false
                        }
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.02, green: 0.02, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.white)
            )
        }
    }
}

struct TemplateCard: View {
    let template: PokemonTeam
    let onSelect: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            onSelect()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(template.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Format badge
                    Text(template.format.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(template.format.color.opacity(0.8))
                        )
                }
                
                // Tags
                HStack(spacing: 8) {
                    ForEach(template.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
                
                // Team preview
                if !template.members.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(template.members.prefix(6), id: \.id) { member in
                            if let pokemon = member.pokemon {
                                AsyncImage(url: URL(string: pokemon.sprites.frontDefault ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 40, height: 40)
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: isHovered ? 
                                [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                                [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isHovered ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Battle Format Extension
extension BattleFormat {
    var color: Color {
        switch self {
        case .singles6v6: return .blue
        case .singles3v3: return .orange
        case .doubles4v4: return .purple
        case .doubles6v6: return .indigo
        case .vgc: return .red
        case .littleCup: return .pink
        case .monotype: return .green
        }
    }
}
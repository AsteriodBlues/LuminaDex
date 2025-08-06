//
//  FormSwitcher.swift
//  LuminaDex
//
//  Day 25: Pokemon Form Switcher UI
//

import SwiftUI
import Nuke
import NukeUI

struct FormSwitcher: View {
    let pokemon: Pokemon
    @StateObject private var formManager = PokemonFormManager()
    @State private var selectedForm: PokemonForm?
    @State private var showingFormSelector = false
    @State private var morphAnimation: CGFloat = 0
    @State private var particleAnimation = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Current Form Display
            currentFormView
            
            // Form Selector Button
            if formManager.availableForms.count > 1 {
                formSelectorButton
            }
        }
        .onAppear {
            formManager.loadForms(for: pokemon.id)
        }
        .sheet(isPresented: $showingFormSelector) {
            FormSelectorSheet(
                forms: formManager.availableForms,
                currentForm: formManager.currentForm,
                onSelect: { form in
                    switchToForm(form)
                    showingFormSelector = false
                }
            )
        }
    }
    
    private var currentFormView: some View {
        ZStack {
            // Morphing background
            if let currentForm = formManager.currentForm {
                MorphingBackground(
                    formType: currentForm.formType,
                    animation: morphAnimation
                )
            }
            
            // Form Image with transition
            if let currentForm = formManager.currentForm {
                LazyImage(url: URL(string: currentForm.sprites.primarySprite)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 1.2).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    } else if state.error != nil {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
                .processors([.resize(size: CGSize(width: 500, height: 500))])
                .priority(.veryHigh)
                .id(currentForm.id) // Force view refresh on form change
                
                // Particle effects
                if particleAnimation {
                    ParticleEffectView(formType: currentForm.formType)
                }
            }
        }
        .frame(height: 300)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    private var formSelectorButton: some View {
        Button(action: { showingFormSelector = true }) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Change Form")
                    .font(.system(size: 16, weight: .semibold))
                
                if let currentForm = formManager.currentForm {
                    Text("(\(currentForm.formType.rawValue))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                formManager.currentForm?.formType.color ?? .blue,
                                (formManager.currentForm?.formType.color ?? .blue).opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: formManager.currentForm?.formType.color.opacity(0.5) ?? .clear, radius: 10)
        }
    }
    
    private func switchToForm(_ form: PokemonForm) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            formManager.switchToForm(form)
            morphAnimation += 1
            particleAnimation = true
        }
        
        // Reset particle animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            particleAnimation = false
        }
    }
}

// MARK: - Form Selector Sheet
struct FormSelectorSheet: View {
    let forms: [PokemonForm]
    let currentForm: PokemonForm?
    let onSelect: (PokemonForm) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(forms) { form in
                        FormCard(
                            form: form,
                            isSelected: form.id == currentForm?.id,
                            onSelect: { onSelect(form) }
                        )
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Select Form")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Form Card
struct FormCard: View {
    let form: PokemonForm
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Form Image
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    form.formType.color.opacity(0.3),
                                    form.formType.color.opacity(0.1)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                    
                    LazyImage(url: URL(string: form.sprites.primarySprite)) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        } else {
                            ProgressView()
                        }
                    }
                    .processors([.resize(size: CGSize(width: 200, height: 200))])
                    
                    if isSelected {
                        Circle()
                            .stroke(form.formType.color, lineWidth: 3)
                            .frame(width: 120, height: 120)
                    }
                }
                
                // Form Name
                VStack(spacing: 4) {
                    Label(form.formType.rawValue, systemImage: form.formType.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(form.formType.color)
                    
                    if form.isBattleOnly {
                        Text("Battle Only")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? form.formType.color : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Morphing Background
struct MorphingBackground: View {
    let formType: PokemonFormType
    let animation: CGFloat
    
    var body: some View {
        ZStack {
            // Liquid blob effect
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                formType.color.opacity(0.4),
                                formType.color.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 150, height: 150)
                    .offset(
                        x: cos(animation + Double(index) * 2.09) * 30,
                        y: sin(animation + Double(index) * 2.09) * 30
                    )
                    .scaleEffect(1.0 + sin(animation + Double(index)) * 0.2)
                    .animation(
                        .spring(response: 1.0, dampingFraction: 0.6),
                        value: animation
                    )
            }
        }
        .blur(radius: 20)
    }
}

// MARK: - Particle Effect View
struct ParticleEffectView: View {
    let formType: PokemonFormType
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var size: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(formType.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles()
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(x: size.width / 2, y: size.height / 2),
                velocity: CGVector(
                    dx: Double.random(in: -100...100),
                    dy: Double.random(in: -100...100)
                ),
                size: CGFloat.random(in: 4...12),
                opacity: 1.0
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeOut(duration: 1.5)) {
            for index in particles.indices {
                particles[index].position.x += particles[index].velocity.dx
                particles[index].position.y += particles[index].velocity.dy
                particles[index].opacity = 0
            }
        }
    }
}
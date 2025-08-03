//
//  DNAHelixViewer.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI
import MetalKit

// MARK: - DNA Helix Viewer

struct DNAHelixViewer: View {
    let pokemon: Pokemon
    
    @State private var rotationAngle: CGFloat = 0
    @State private var zoomLevel: CGFloat = 1.0
    @State private var selectedGene: DNAGene?
    @State private var isAnalyzing = false
    @State private var showLabInterface = false
    @State private var animationPhase: CGFloat = 0
    
    @StateObject private var labAssistants = LabAssistantManager()
    @StateObject private var dnaAnalyzer = DNAAnalyzer()
    
    var body: some View {
        ZStack {
            // Scientific lab background
            labBackground
            
            // Main DNA helix display
            VStack(spacing: 0) {
                // Header with Pokemon info
                dnaHeaderSection
                
                // 3D DNA Helix Container
                ZStack {
                    // Metal-powered 3D helix
                    MetalDNAHelixView(
                        pokemon: pokemon,
                        rotationAngle: rotationAngle,
                        zoomLevel: zoomLevel,
                        selectedGene: selectedGene,
                        animationPhase: animationPhase
                    )
                    .gesture(
                        SimultaneousGesture(
                            RotationGesture()
                                .onChanged { value in
                                    rotationAngle = value.radians
                                },
                            MagnificationGesture()
                                .onChanged { value in
                                    zoomLevel = max(0.5, min(3.0, value))
                                }
                        )
                    )
                    
                    // Lab assistants overlay
                    labAssistantsOverlay
                    
                    // Gene information popup
                    if let gene = selectedGene {
                        geneInformationPanel(gene: gene)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .stroke(pokemon.primaryType.color.opacity(0.3), lineWidth: 2)
                )
                
                // Controls and analysis panel
                controlsSection
            }
            .padding()
            
            // Lab interface overlay
            if showLabInterface {
                labInterfaceOverlay
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .onAppear {
            startContinuousAnimation()
            dnaAnalyzer.analyzePokemon(pokemon)
            labAssistants.initializeAssistants()
        }
    }
    
    // MARK: - Background
    
    private var labBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "0A0A0B"),
                    Color(hex: "1A1A2E"),
                    Color(hex: "16213E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Holographic grid pattern
            Canvas { context, size in
                let gridSpacing: CGFloat = 30
                let lineWidth: CGFloat = 0.5
                let opacity = 0.1 + sin(animationPhase) * 0.05
                
                for x in stride(from: 0, through: size.width, by: gridSpacing) {
                    let path = Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    context.stroke(path, with: .color(.cyan.opacity(opacity)), lineWidth: lineWidth)
                }
                
                for y in stride(from: 0, through: size.height, by: gridSpacing) {
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(.cyan.opacity(opacity)), lineWidth: lineWidth)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var dnaHeaderSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(pokemon.displayName) DNA Analysis")
                    .font(ThemeManager.Typography.displaySemibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [pokemon.primaryType.color, pokemon.primaryType.color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                HStack(spacing: 12) {
                    Text("Type: \(pokemon.primaryType.displayName)")
                        .font(ThemeManager.Typography.bodyMedium)
                        .foregroundColor(.white.opacity(0.8))
                    
                    if pokemon.types.count > 1 {
                        Text("• \(pokemon.types[1].type.displayName)")
                            .font(ThemeManager.Typography.bodyMedium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Analysis status
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isAnalyzing ? .yellow : .green)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnalyzing ? (1.0 + sin(animationPhase * 4) * 0.3) : 1.0)
                        
                        Text(isAnalyzing ? "Analyzing..." : "Analysis Complete")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Lab interface toggle
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showLabInterface.toggle()
                }
            }) {
                Image(systemName: showLabInterface ? "xmark.circle.fill" : "atom")
                    .font(.system(size: 24))
                    .foregroundColor(pokemon.primaryType.color)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 40, height: 40)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .stroke(pokemon.primaryType.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Lab Assistants Overlay
    
    private var labAssistantsOverlay: some View {
        ZStack {
            // Alakazam - Top left (analyzing)
            VStack {
                HStack {
                    labAssistantView(
                        assistant: labAssistants.alakazam,
                        position: .topLeft
                    )
                    Spacer()
                }
                Spacer()
            }
            
            // Porygon - Top right (computing)
            VStack {
                HStack {
                    Spacer()
                    labAssistantView(
                        assistant: labAssistants.porygon,
                        position: .topRight
                    )
                }
                Spacer()
            }
            
            // Magnezone - Bottom left (scanning)
            VStack {
                Spacer()
                HStack {
                    labAssistantView(
                        assistant: labAssistants.magnezone,
                        position: .bottomLeft
                    )
                    Spacer()
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func labAssistantView(assistant: LabAssistant, position: AssistantPosition) -> some View {
        VStack(spacing: 4) {
            ZStack {
                // Assistant glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                assistant.primaryColor.opacity(0.4),
                                assistant.primaryColor.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                    .scaleEffect(1.0 + sin(animationPhase * assistant.animationSpeed) * 0.2)
                
                // Assistant sprite
                Text(assistant.sprite)
                    .font(.system(size: 28))
                    .scaleEffect(1.0 + sin(animationPhase * assistant.animationSpeed + assistant.phaseOffset) * 0.1)
                
                // Activity indicator
                if assistant.isActive {
                    Circle()
                        .fill(assistant.primaryColor)
                        .frame(width: 6, height: 6)
                        .offset(x: 20, y: -20)
                        .scaleEffect(1.0 + sin(animationPhase * 3) * 0.5)
                }
            }
            
            // Assistant status
            Text(assistant.currentAction)
                .font(.caption2)
                .foregroundColor(assistant.primaryColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
        }
        .padding(8)
    }
    
    // MARK: - Gene Information Panel
    
    private func geneInformationPanel(gene: DNAGene) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(gene.name)
                    .font(ThemeManager.Typography.headerMedium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selectedGene = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Text(gene.description)
                .font(ThemeManager.Typography.bodySmall)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(nil)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expression Level")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    ProgressView(value: gene.expressionLevel, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: gene.associatedType.color))
                        .frame(width: 100)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Type Affinity")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(gene.associatedType.displayName)
                        .font(.caption)
                        .foregroundColor(gene.associatedType.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(gene.associatedType.color.opacity(0.2))
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .stroke(gene.associatedType.color.opacity(0.5), lineWidth: 1)
        )
        .frame(width: 280)
        .shadow(color: gene.associatedType.color.opacity(0.3), radius: 10)
    }
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
        VStack(spacing: 16) {
            // Zoom and rotation controls
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Rotation")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Slider(value: $rotationAngle, in: 0...(2 * .pi))
                        .accentColor(pokemon.primaryType.color)
                        .frame(width: 120)
                }
                
                VStack(spacing: 8) {
                    Text("Zoom")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Slider(value: $zoomLevel, in: 0.5...3.0)
                        .accentColor(pokemon.primaryType.color)
                        .frame(width: 120)
                }
                
                Spacer()
                
                // Quick actions
                VStack(spacing: 8) {
                    Button("Reset View") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            rotationAngle = 0
                            zoomLevel = 1.0
                            selectedGene = nil
                        }
                    }
                    .font(.caption)
                    .foregroundColor(pokemon.primaryType.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .stroke(pokemon.primaryType.color.opacity(0.3), lineWidth: 1)
                    )
                    
                    Button("Auto Analyze") {
                        triggerAutoAnalysis()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(pokemon.primaryType.color.opacity(0.8))
                    )
                }
            }
            
            // Gene sequence display
            geneSequenceDisplay
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var geneSequenceDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gene Sequence Analysis")
                .font(ThemeManager.Typography.headlineBold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 4) {
                    ForEach(dnaAnalyzer.geneSequence, id: \.id) { gene in
                        geneButton(gene: gene)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func geneButton(gene: DNAGene) -> some View {
        Button(action: {
            handleGeneSelection(gene)
        }) {
            VStack(spacing: 2) {
                Rectangle()
                    .fill(gene.associatedType.color)
                    .frame(width: 8, height: 20)
                    .scaleEffect(selectedGene?.id == gene.id ? 1.2 : 1.0)
                
                Text(gene.code)
                    .font(.system(size: 8, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleGeneSelection(_ gene: DNAGene) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedGene = selectedGene?.id == gene.id ? nil : gene
        }
    }
    
    // MARK: - Lab Interface Overlay
    
    private var labInterfaceOverlay: some View {
        VStack {
            Spacer()
            labInterfaceContent
        }
    }
    
    private var labInterfaceContent: some View {
        VStack(spacing: 16) {
            Text("Laboratory Interface")
                .font(ThemeManager.Typography.headerLarge)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                analysisResultsSection
                labControlsSection
            }
        }
        .padding()
        .background(labInterfaceBackground)
        .padding()
    }
    
    private var analysisResultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DNA Analysis Results")
                .font(ThemeManager.Typography.headlineBold)
                .foregroundColor(.white)
            
            ForEach(dnaAnalyzer.analysisResults, id: \.title) { result in
                analysisResultRow(result: result)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func analysisResultRow(result: AnalysisResult) -> some View {
        HStack {
            Text(result.title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(result.value)
                .font(.caption)
                .foregroundColor(pokemon.primaryType.color)
        }
    }
    
    private var labControlsSection: some View {
        VStack(spacing: 12) {
            Button("Deep Scan") {
                triggerDeepScan()
            }
            .buttonStyle(LabButtonStyle(color: pokemon.primaryType.color))
            
            Button("Gene Fusion") {
                triggerGeneFusion()
            }
            .buttonStyle(LabButtonStyle(color: .cyan))
            
            Button("Export Data") {
                exportAnalysisData()
            }
            .buttonStyle(LabButtonStyle(color: .green))
        }
    }
    
    private var labInterfaceBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .stroke(.white.opacity(0.2), lineWidth: 1)
    }
    
    // MARK: - Helper Methods
    
    private func startContinuousAnimation() {
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
    }
    
    private func triggerAutoAnalysis() {
        isAnalyzing = true
        labAssistants.startAnalysis()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isAnalyzing = false
            labAssistants.completeAnalysis()
        }
    }
    
    private func triggerDeepScan() {
        // Implement deep scan functionality
        labAssistants.triggerSpecialAction(.deepScan)
    }
    
    private func triggerGeneFusion() {
        // Implement gene fusion functionality
        labAssistants.triggerSpecialAction(.geneFusion)
    }
    
    private func exportAnalysisData() {
        // Implement data export
        labAssistants.triggerSpecialAction(.dataExport)
    }
}

// MARK: - Lab Button Style

struct LabButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(configuration.isPressed ? 0.6 : 0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Assistant Position

enum AssistantPosition {
    case topLeft, topRight, bottomLeft, bottomRight
}

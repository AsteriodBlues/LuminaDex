//
//  TypedActivityIndicator.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import SwiftUI

struct TypedActivityIndicator: View {
    let type: PokemonType
    let style: IndicatorStyle
    let size: CGFloat
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    enum IndicatorStyle {
        case spinning
        case pulsing
        case bouncing
        case pokeball
        case typeIcon
        case wave
    }
    
    var body: some View {
        Group {
            switch style {
            case .spinning:
                spinningIndicator
            case .pulsing:
                pulsingIndicator
            case .bouncing:
                bouncingIndicator
            case .pokeball:
                pokeballIndicator
            case .typeIcon:
                typeIconIndicator
            case .wave:
                waveIndicator
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private var spinningIndicator: some View {
        ZStack {
            Circle()
                .stroke(type.color.opacity(0.3), lineWidth: 4)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        colors: [type.color, type.color.opacity(0.1)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotationAngle)
        }
    }
    
    private var pulsingIndicator: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(type.color.opacity(0.6 - Double(index) * 0.2))
                    .frame(width: size * (1.0 + CGFloat(index) * 0.3) * pulseScale, height: size * (1.0 + CGFloat(index) * 0.3) * pulseScale)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .delay(Double(index) * 0.2)
                        .repeatForever(autoreverses: true),
                        value: pulseScale
                    )
            }
            
            Image(systemName: type.icon)
                .font(.system(size: size * 0.4))
                .foregroundColor(.white)
        }
    }
    
    private var bouncingIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(type.color)
                    .frame(width: size * 0.25, height: size * 0.25)
                    .offset(y: isAnimating ? -size * 0.3 : 0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .delay(Double(index) * 0.2)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
    }
    
    private var pokeballIndicator: some View {
        ZStack {
            // Pokeball base
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.red, Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                )
            
            // Pokeball center line
            Rectangle()
                .fill(Color.black)
                .frame(width: size, height: 3)
            
            // Pokeball center button
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.3, height: size * 0.3)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                )
            
            // Type color overlay
            Circle()
                .fill(type.color.opacity(0.3))
                .frame(width: size * 0.2, height: size * 0.2)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)
        }
        .rotationEffect(.degrees(rotationAngle))
        .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: rotationAngle)
    }
    
    private var typeIconIndicator: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(type.color.opacity(0.2))
                .frame(width: size, height: size)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseScale)
            
            // Type icon
            Image(systemName: type.icon)
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundColor(type.color)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.linear(duration: 3.0).repeatForever(autoreverses: false), value: rotationAngle)
            
            // Orbiting dots
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(type.color)
                    .frame(width: 6, height: 6)
                    .offset(y: -size * 0.6)
                    .rotationEffect(.degrees(rotationAngle + Double(index) * 120))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: rotationAngle)
            }
        }
    }
    
    private var waveIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(type.color)
                    .frame(width: 6, height: size * 0.8)
                    .scaleEffect(y: isAnimating ? CGFloat.random(in: 0.3...1.0) : 0.3)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .delay(Double(index) * 0.1)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
    }
    
    private func startAnimations() {
        withAnimation {
            isAnimating = true
            rotationAngle = 360
            pulseScale = 1.2
        }
    }
}

// MARK: - Progress Circle Indicator
struct TypedProgressIndicator: View {
    let type: PokemonType
    let progress: Double
    let size: CGFloat
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(type.color.opacity(0.2), lineWidth: 8)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [type.color.opacity(0.7), type.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            // Progress text
            VStack(spacing: 2) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundColor(type.color)
                
                Image(systemName: type.icon)
                    .font(.system(size: size * 0.15))
                    .foregroundColor(type.color.opacity(0.7))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newProgress in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = newProgress
            }
        }
    }
}

// MARK: - Loading Bar Indicator
struct TypedLoadingBar: View {
    let type: PokemonType
    let progress: Double
    let width: CGFloat
    let height: CGFloat
    @State private var animatedProgress: Double = 0
    @State private var shimmerOffset: CGFloat = -1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(type.color.opacity(0.2))
                    .frame(width: width, height: height)
                
                // Progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [type.color.opacity(0.8), type.color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width * animatedProgress, height: height)
                    .overlay(
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: height / 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color.clear, Color.white.opacity(0.4), Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 50)
                            .offset(x: shimmerOffset * (width + 50))
                            .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: shimmerOffset)
                    )
                    .clipped()
                
                // Type icon at the end
                HStack {
                    Spacer()
                    Image(systemName: type.icon)
                        .font(.system(size: height * 0.6))
                        .foregroundColor(.white)
                        .opacity(animatedProgress > 0.1 ? 1 : 0)
                }
                .frame(width: width * animatedProgress, height: height)
            }
        }
        .frame(width: width, height: height)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = progress
            }
            shimmerOffset = 1
        }
        .onChange(of: progress) { newProgress in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newProgress
            }
        }
    }
}

// MARK: - Breathing Dot Indicator
struct BreathingDotIndicator: View {
    let type: PokemonType
    let dotCount: Int
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<dotCount, id: \.self) { index in
                let phaseOffset = animationOffset + Double(index) * 0.5
                let sinValue = sin(phaseOffset)
                let scaleValue = 1 + sinValue * 0.5
                let opacityValue = 0.5 + sinValue * 0.5
                
                Circle()
                    .fill(type.color)
                    .frame(width: 12, height: 12)
                    .scaleEffect(scaleValue)
                    .opacity(opacityValue)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                animationOffset = .pi * 2
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 20) {
            TypedActivityIndicator(type: .electric, style: .spinning, size: 50)
            TypedActivityIndicator(type: .fire, style: .pulsing, size: 50)
            TypedActivityIndicator(type: .water, style: .bouncing, size: 50)
        }
        
        HStack(spacing: 20) {
            TypedActivityIndicator(type: .grass, style: .pokeball, size: 50)
            TypedActivityIndicator(type: .psychic, style: .typeIcon, size: 50)
            TypedActivityIndicator(type: .dragon, style: .wave, size: 50)
        }
        
        TypedProgressIndicator(type: .fairy, progress: 0.7, size: 80)
        
        TypedLoadingBar(type: .dark, progress: 0.6, width: 200, height: 20)
        
        BreathingDotIndicator(type: .steel, dotCount: 5)
    }
    .padding()
}
//
//  TypedActivityIndicator.swift
//  LuminaDex
//
//  Day 24: Type-themed activity indicators
//

import SwiftUI

struct TypedActivityIndicator: View {
    let type: PokemonType
    let size: CGFloat
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    init(type: PokemonType = .normal, size: CGFloat = 40) {
        self.type = type
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [type.color, type.color.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
            
            // Inner pulse
            Circle()
                .fill(type.color.opacity(0.3))
                .frame(width: size * 0.6, height: size * 0.6)
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Type icon
            Image(systemName: type.icon)
                .font(.system(size: size * 0.3))
                .foregroundColor(type.color)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 1.0)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            withAnimation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.2
                opacity = 0.5
            }
        }
    }
}

// MARK: - Pokeball Loading Animation
struct PokeballLoadingIndicator: View {
    @State private var rotation: Double = 0
    @State private var isOpen = false
    let size: CGFloat
    
    init(size: CGFloat = 60) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Pokeball background
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
            
            // Top half
            Circle()
                .fill(Color.red)
                .frame(width: size, height: size)
                .mask(
                    Rectangle()
                        .frame(width: size, height: size/2)
                        .offset(y: isOpen ? -size/4 : 0)
                )
            
            // Center line
            Rectangle()
                .fill(Color.black)
                .frame(width: size, height: 3)
            
            // Center button
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.25, height: size * 0.25)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                )
                .overlay(
                    Circle()
                        .fill(Color.gray)
                        .frame(width: size * 0.15, height: size * 0.15)
                )
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
            ) {
                isOpen = true
            }
            
            withAnimation(
                .linear(duration: 2.0)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
    }
}

// MARK: - Progress Circle
struct TypedProgressCircle: View {
    let type: PokemonType
    let progress: Double
    let size: CGFloat
    
    init(type: PokemonType = .normal, progress: Double, size: CGFloat = 100) {
        self.type = type
        self.progress = min(max(progress, 0), 1)
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(type.color.opacity(0.2), lineWidth: 8)
                .frame(width: size, height: size)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [type.color, type.color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)
            
            // Center content
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.system(size: size * 0.25))
                    .foregroundColor(type.color)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.15, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
    }
}
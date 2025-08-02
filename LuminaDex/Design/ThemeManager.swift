//
//  ThemeManager.swift
//  LuminaDex
//
//  Created by Ritwik on 8/1/25.
//

import SwiftUI

// MARK: - ThemeManager
struct ThemeManager {
    
    // MARK: - Color System
    struct Colors {
        // Base colors
        static let deepSpace = Color(hex: "0A0A0B")
        static let lumina = Color(hex: "FAFBFC")
        
        // Primary accents
        static let neural = Color(hex: "6B5FFF")
        static let plasma = Color(hex: "00D4FF")
        static let aurora = Color(hex: "00FF88")
        
        // Gradient definitions
        static let neuralGradient = LinearGradient(
            colors: [neural, plasma],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let auroraGradient = LinearGradient(
            colors: [aurora, plasma],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let spaceGradient = LinearGradient(
            colors: [deepSpace, Color(hex: "1A1A1F")],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Glassmorphism effects
        static let glassMaterial = Color.white.opacity(0.1)
        static let glassStroke = Color.white.opacity(0.2)
    }
    
    // MARK: - Typography
    struct Typography {
        // Display fonts for headers
        static let displayHeavy = Font.custom("SF Pro Display", size: 34)
            .weight(.heavy)
        
        static let displaySemibold = Font.custom("SF Pro Display", size: 28)
            .weight(.semibold)
        
        // Section headers
        static let headerLarge = Font.custom("SF Pro Display", size: 24)
            .weight(.semibold)
        
        static let headerMedium = Font.custom("SF Pro Display", size: 20)
            .weight(.semibold)
        
        // Body text
        static let bodyLarge = Font.custom("SF Pro Text", size: 17)
            .weight(.regular)
        
        static let bodyMedium = Font.custom("SF Pro Text", size: 15)
            .weight(.regular)
        
        // Data display
        static let monoMedium = Font.custom("SF Mono", size: 14)
            .weight(.medium)
        
        // Additional typography styles
        static let headlineBold = Font.custom("SF Pro Display", size: 18)
            .weight(.bold)
        
        static let bodySmall = Font.custom("SF Pro Text", size: 13)
            .weight(.regular)
        
        static let captionMedium = Font.custom("SF Pro Text", size: 12)
            .weight(.medium)
        
        static let captionBold = Font.custom("SF Pro Text", size: 12)
            .weight(.bold)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }
    
    // MARK: - Animation
    struct Animation {
        static let springBouncy = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.7)
        static let springSmooth = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

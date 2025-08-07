//
//  AchievementNotificationOverlay.swift
//  LuminaDex
//
//  Overlay view for achievement notifications
//

import SwiftUI

struct AchievementNotificationOverlay: View {
    @EnvironmentObject var achievementTracker: AchievementTracker
    
    var body: some View {
        ZStack {
            if achievementTracker.showNotification, 
               let achievement = achievementTracker.currentUnlock {
                AchievementNotificationView(
                    achievement: achievement,
                    isShowing: $achievementTracker.showNotification
                )
                .zIndex(999)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: achievementTracker.showNotification)
            }
        }
        .allowsHitTesting(achievementTracker.showNotification)
    }
}
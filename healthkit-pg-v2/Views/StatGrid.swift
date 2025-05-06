import SwiftUI

struct StatGrid: View {
    let snapshot: HealthSnapshot
    let state: TamagotchiState
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 18) {
            GamifiedProgressBar(
                icon: "figure.walk",
                title: "Steps",
                value: Double(snapshot.steps),
                goal: 10_000,
                gradient: gradient,
                valueFormat: "%.0f",
                accessibilityLabel: "Steps",
                accessibilityHint: "Daily step count progress",
                showTrophy: snapshot.steps >= 10_000,
                animatePulse: snapshot.steps >= 10_000
            )
            GamifiedProgressBar(
                icon: "bed.double.fill",
                title: "Sleep",
                value: snapshot.totalSleep,
                goal: 8.0,
                gradient: gradient,
                valueFormat: "%.1f h",
                accessibilityLabel: "Sleep",
                accessibilityHint: "Total sleep hours progress",
                showTrophy: snapshot.totalSleep >= 8.0,
                animatePulse: snapshot.totalSleep >= 8.0
            )
            GamifiedProgressBar(
                icon: "flame.fill",
                title: "Energy",
                value: snapshot.activeEnergyKcal,
                goal: 500.0,
                gradient: gradient,
                valueFormat: "%.0f kcal",
                accessibilityLabel: "Active energy",
                accessibilityHint: "Active energy progress",
                showTrophy: snapshot.activeEnergyKcal >= 500.0,
                animatePulse: snapshot.activeEnergyKcal >= 500.0
            )
            GamifiedProgressBar(
                icon: "heart.fill",
                title: "Resting HR",
                value: snapshot.restingHR,
                goal: 60.0,
                gradient: gradient,
                valueFormat: "%.0f bpm",
                accessibilityLabel: "Resting heart rate",
                accessibilityHint: "Resting heart rate gauge",
                showTrophy: snapshot.restingHR > 0 && snapshot.restingHR <= 60,
                animatePulse: snapshot.restingHR > 0 && snapshot.restingHR <= 60
            )
        }
        .padding(.horizontal, 8)
    }
} 
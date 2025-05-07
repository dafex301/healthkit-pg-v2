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
                gradient: LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing),
                valueFormat: "%.0f",
                accessibilityLabel: "Steps",
                accessibilityHint: "Daily step count progress",
                showTrophy: snapshot.steps >= 10_000,
                animatePulse: snapshot.steps >= 10_000,
                barColor: .blue,
                isReversed: false
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
                animatePulse: snapshot.totalSleep >= 8.0,
                barColor: .indigo,
                isReversed: false
            )
            GamifiedProgressBar(
                icon: "flame.fill",
                title: "Energy",
                value: snapshot.activeEnergyKcal,
                goal: 500.0,
                gradient: LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing),
                valueFormat: "%.0f kcal",
                accessibilityLabel: "Active energy",
                accessibilityHint: "Active energy progress",
                showTrophy: snapshot.activeEnergyKcal >= 500.0,
                animatePulse: snapshot.activeEnergyKcal >= 500.0,
                barColor: .orange,
                isReversed: false
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
                animatePulse: snapshot.restingHR > 0 && snapshot.restingHR <= 60,
                barColor: .red,
                isReversed: true
            )
            // GamifiedProgressBar(
            //     icon: "figure.run.circle.fill",
            //     title: "Exercise",
            //     value: snapshot.exerciseMinutes,
            //     goal: 30.0,
            //     gradient: LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing),
            //     valueFormat: "%.0f min",
            //     accessibilityLabel: "Exercise minutes",
            //     accessibilityHint: "Exercise minutes progress",
            //     showTrophy: snapshot.exerciseMinutes >= 30.0,
            //     animatePulse: snapshot.exerciseMinutes >= 30.0,
            //     barColor: .green
            // )
            // GamifiedProgressBar(
            //     icon: "bed.double.fill",
            //     title: "Stand",
            //     value: Double(snapshot.standHours),
            //     goal: 12.0,
            //     gradient: LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing),
            //     valueFormat: "%.0f h",
            //     accessibilityLabel: "Stand hours",
            //     accessibilityHint: "Stand hours progress",
            //     showTrophy: snapshot.standHours >= 12,
            //     animatePulse: snapshot.standHours >= 12,
            //     barColor: .pink
            // )
        }
        .padding(.horizontal, 8)
    }
} 

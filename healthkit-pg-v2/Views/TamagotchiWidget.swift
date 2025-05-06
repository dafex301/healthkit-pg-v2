import SwiftUI

/// A gamified SwiftUI view displaying the Tamagotchi avatar, progress, and state.
struct TamagotchiWidget: View {
    let snapshot: HealthSnapshot
    private var state: TamagotchiState { evaluate(snapshot) }
    
    // Progress calculations
    private var stepProgress: Double { min(Double(snapshot.steps) / 10000, 1.0) }
    private var sleepProgress: Double { min(snapshot.totalSleep / 8.0, 1.0) }
    private var energyProgress: Double { min(snapshot.activeEnergyKcal / 500.0, 1.0) }
    
    // Example streak and badge logic (can be improved with more data)
    private var fakeStreak: Int { snapshot.steps >= 7000 && snapshot.totalSleep >= 7 ? 3 : 0 }
    private var has10kStepsBadge: Bool { snapshot.steps >= 10000 }
    private var hasSleepBadge: Bool { snapshot.totalSleep >= 8 }
    private var hasEnergyBadge: Bool { snapshot.activeEnergyKcal >= 500 }
    
    var body: some View {
        ZStack {
            // Dynamic background
            LinearGradient(gradient: Gradient(colors: backgroundColors(for: state)), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .animation(.easeInOut, value: state)
            VStack(spacing: 16) {
                // Avatar with animation
                Image(state.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .accessibilityLabel(Text(state.accessibilityDescription))
                    .shadow(radius: 12)
                    .scaleEffect(state == .energizedRedPanda ? 1.1 : 1.0)
                    .rotationEffect(.degrees(state == .wiredStressedChinchilla ? 5 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: state)
                // Progress bars
                VStack(spacing: 10) {
                    ProgressBar(title: "Steps", value: Double(snapshot.steps), goal: 10000, icon: "figure.walk", color: .green, progress: stepProgress)
                    ProgressBar(title: "Sleep", value: snapshot.totalSleep, goal: 8, icon: "bed.double.fill", color: .blue, progress: sleepProgress, valueFormat: "%.1f h")
                    ProgressBar(title: "Energy", value: snapshot.activeEnergyKcal, goal: 500, icon: "flame.fill", color: .orange, progress: energyProgress, valueFormat: "%.0f kcal")
                }
                .padding(.horizontal)
                // Streaks & Badges
                HStack(spacing: 16) {
                    if fakeStreak > 0 {
                        Label("Streak: \(fakeStreak) days", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(6)
                            .background(Capsule().fill(Color(.systemGray6)))
                    }
                    if has10kStepsBadge {
                        BadgeView(label: "10k Steps", systemImage: "shoeprints.fill", color: .green)
                    }
                    if hasSleepBadge {
                        BadgeView(label: "8h Sleep", systemImage: "moon.zzz.fill", color: .blue)
                    }
                    if hasEnergyBadge {
                        BadgeView(label: "500 kcal", systemImage: "bolt.fill", color: .orange)
                    }
                }
                .padding(.bottom, 2)
                // Gamified description, tip, and target
                VStack(spacing: 4) {
                    Text(state.gamifiedDescription)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                    Label(state.tip, systemImage: "lightbulb.fill")
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                    Label(state.targetText, systemImage: "target")
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6).opacity(0.85))
                        .shadow(radius: 2)
                )
            }
            .padding(.top, 8)
        }
    }
    
    private func backgroundColors(for state: TamagotchiState) -> [Color] {
        switch state {
        case .knockedOutSleepy: return [Color.gray.opacity(0.7), .black]
        case .groggySloth: return [Color(.systemTeal), Color(.systemGray4)]
        case .lazyButRestedPanda: return [Color(.systemGreen), Color(.systemGray5)]
        case .wiredStressedChinchilla: return [Color.yellow, Color.orange]
        case .balancedKoala: return [Color(.systemBlue), Color(.systemGreen)]
        case .energizedRedPanda: return [Color.red, Color.orange]
        case .overtrainedHusky: return [Color(.systemIndigo), Color(.systemGray)]
        case .zenNinjaFox: return [Color.purple, Color(.systemTeal)]
        }
    }
}

struct ProgressBar: View {
    let title: String
    let value: Double
    let goal: Double
    let icon: String
    let color: Color
    let progress: Double
    var valueFormat: String = "%.0f"
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .frame(width: 60, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule().fill(color).frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 12)
            Text(String(format: valueFormat, value))
                .font(.caption2)
                .frame(width: 50, alignment: .trailing)
            Text("/ \(Int(goal))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(height: 18)
    }
}

struct BadgeView: View {
    let label: String
    let systemImage: String
    let color: Color
    var body: some View {
        Label(label, systemImage: systemImage)
            .font(.caption2.bold())
            .padding(6)
            .background(Capsule().fill(color.opacity(0.15)))
            .foregroundStyle(color)
    }
} 
import SwiftUI

/// A gamified SwiftUI view displaying the Tamagotchi avatar, progress, and state.
struct TamagotchiWidget: View {
    let snapshot: HealthSnapshot
    @Binding var selectedDate: Date
    @State private var previousSeverity: Int? = nil
    @State private var avatarScale: CGFloat = 1.0
    @State private var didDowngrade: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var avatarShake: CGFloat = 0
    
    private var state: TamagotchiState { evaluate(snapshot) }
    private var gradient: LinearGradient { Color.stateGradient(for: state.severityRank) }
    
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
            gradient
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 24) {
                HStack {
                    Text("Tamagotchi")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: { showDatePicker = true }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .accessibilityLabel("Select Date")
                }
                .padding(.horizontal)
                ZStack {
                    Circle()
                        .stroke(gradient, lineWidth: 12)
                        .frame(width: 220)
                        .blur(radius: 4)
                        .opacity(0.35)
                    Image(state.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .scaleEffect(avatarScale)
                        .offset(x: avatarShake)
                        .animation(.spring(response: 0.35), value: avatarScale)
                        .animation(.spring(response: 0.25), value: avatarShake)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.18, dampingFraction: 0.2)) {
                                avatarShake = -18
                                avatarScale = 1.12
                            }
                            HapticManager.impact(.heavy)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
                                withAnimation(.spring(response: 0.18, dampingFraction: 0.2)) { avatarShake = 18 }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                withAnimation(.spring(response: 0.18, dampingFraction: 0.2)) {
                                    avatarShake = 0; avatarScale = 1.0
                                }
                            }
                        }
                        .onChange(of: state.severityRank) { old, new in
                            if let prev = previousSeverity {
                                if new < prev {
                                    avatarScale = 1.15
                                    HapticManager.success()
                                } else if new > prev {
                                    avatarScale = 0.92
                                    didDowngrade = true
                                    HapticManager.warning()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                                    avatarScale = 1.0
                                }
                            }
                            previousSeverity = new
                        }
                        .accessibilityLabel(Text(state.accessibilityDescription))
                }
                StatGrid(snapshot: snapshot, state: state, gradient: gradient)
                AdviceCard(state: state, didDowngrade: didDowngrade)
                    .padding(.horizontal)
                    .onChange(of: didDowngrade) { _, _ in
                        if didDowngrade {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                didDowngrade = false
                            }
                        }
                    }
                Spacer(minLength: 0)
            }
            .padding(.top, 8)
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                Button("Done") { showDatePicker = false }
                    .font(.headline)
                    .padding(.bottom)
            }
            .presentationDetents([.medium, .large])
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
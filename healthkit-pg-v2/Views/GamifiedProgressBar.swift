import SwiftUI

struct GamifiedProgressBar: View {
    let icon: String
    let title: String
    let value: Double
    let goal: Double
    let gradient: LinearGradient
    let valueFormat: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let showTrophy: Bool
    let animatePulse: Bool
    
    @State private var pulse: Bool = false
    
    var percent: Double { min(value / goal, 1.0) }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: 0x1C1C1E).opacity(0.6))
                        .frame(height: 16)
                    Capsule()
                        .fill(gradient)
                        .frame(width: CGFloat(percent) * 140, height: 16)
                        .scaleEffect(pulse ? 1.08 : 1.0)
                        .opacity(pulse ? 0.85 : 1.0)
                        .animation(animatePulse ? .spring(response: 0.3, dampingFraction: 0.4) : .none, value: pulse)
                        .onChange(of: animatePulse) { _, newValue in
                            if newValue { pulse = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { pulse = false } }
                        }
                    GeometryReader { geo in
                        HStack {
                            Spacer()
                            Text("\(Int(percent * 100))%")
                                .font(.caption2.monospacedDigit().weight(.medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.trailing, 6)
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
            }
            .frame(width: 150)
            Spacer(minLength: 0)
            Text(String(format: valueFormat, value))
                .font(.callout.monospacedDigit().weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 54, alignment: .trailing)
            if showTrophy {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                    .transition(.scale)
                    .animation(.spring(), value: showTrophy)
            }
        }
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(Int(percent * 100)) percent of goal")
        .accessibilityHint(accessibilityHint)
    }
} 
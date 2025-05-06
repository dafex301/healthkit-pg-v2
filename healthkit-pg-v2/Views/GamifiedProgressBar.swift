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
    let barColor: Color
    
    @State private var pulse: Bool = false
    
    var percent: Double { min(value / goal, 1.0) }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 16)
                    GeometryReader { geo in
                        Capsule()
                            .fill(barColor)
                            .frame(width: geo.size.width * percent, height: 16)
                            .scaleEffect(pulse ? 1.08 : 1.0)
                            .opacity(pulse ? 0.85 : 1.0)
                            .animation(animatePulse ? .spring(response: 0.3, dampingFraction: 0.4) : .none, value: pulse)
                            .onChange(of: animatePulse) { _, newValue in
                                if newValue { pulse = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { pulse = false } }
                            }
                        HStack {
                            Spacer()
                            Text("\(Int(percent * 100))%")
                                .font(.caption2.monospacedDigit().weight(.medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.trailing, 6)
                                .fixedSize()
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
            }
            
            // Fixed spacer
            Spacer().frame(width: 8)
            
            // Value display
            HStack(spacing: 2) {
                Text(String(format: valueFormat, value))
                    .font(.callout.monospacedDigit().weight(.medium))
                    .foregroundStyle(.white)
                    .frame(minWidth: 40, alignment: .trailing)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .fixedSize()
                if showTrophy {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                        .transition(.scale)
                        .animation(.spring(), value: showTrophy)
                }
            }
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(Int(percent * 100)) percent of goal")
        .accessibilityHint(accessibilityHint)
    }
}

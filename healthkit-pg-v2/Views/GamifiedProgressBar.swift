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
    let isReversed: Bool
    
    @State private var pulse: Bool = false
    @State private var animatedPercent: Double = 0
    @State private var animatedValue: Double = 0
    
    var percent: Double {
        if isReversed {
            let maxHRValue = 100.0
            let clampedValue = min(max(value, goal), maxHRValue)
            return max(0, min(1, (maxHRValue - clampedValue) / (maxHRValue - goal)))
        } else {
            return min(value / goal, 1.0)
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 16)
                    GeometryReader { geo in
                        Capsule()
                            .fill(barColor)
                            .frame(width: geo.size.width * animatedPercent, height: 16)
                            .scaleEffect(pulse ? 1.08 : 1.0)
                            .opacity(pulse ? 0.85 : 1.0)
                            .animation(animatePulse ? .spring(response: 0.3, dampingFraction: 0.4) : .none, value: pulse)
                            .onChange(of: animatePulse) { _, newValue in
                                if newValue { pulse = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { pulse = false } }
                            }
                        HStack {
                            Spacer()
                            Text("\(Int(animatedPercent * 100))%")
                                .font(.caption2.monospacedDigit().weight(.medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.trailing, 6)
                                .fixedSize()
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
            }
            
            Spacer(minLength: 5)
            
            // Value display
            HStack(spacing: 2) {
                Text(String(format: valueFormat, animatedValue))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 60, alignment: .trailing)
                    .font(.callout.monospacedDigit().weight(.medium))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
//                    .lineLimit(1)
//                if showTrophy {
//                    Image(systemName: "trophy.fill")
//                        .foregroundStyle(.yellow)
//                        .transition(.scale)
//                        .animation(.spring(), value: showTrophy)
//                }
            }
//            .frame(minWidth: 100)
//            .background(.gray)
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(Int(animatedPercent * 100)) percent of goal")
        .accessibilityHint(accessibilityHint)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedPercent = percent
                animatedValue = value
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.easeOut(duration: 1.0)) {
                animatedPercent = percent
                animatedValue = newValue
            }
        }
        .onChange(of: goal) { _, _ in
            withAnimation(.easeOut(duration: 1.0)) {
                animatedPercent = percent
                animatedValue = value
            }
        }
    }
}

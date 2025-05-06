import SwiftUI

struct AdviceCard: View {
    let state: TamagotchiState
    let didDowngrade: Bool
    
    @State private var wiggle: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // State Description Card
            HStack(spacing: 8) {
                Text(state.leadEmoji)
                    .font(.largeTitle)
                Text(state.gamifiedDescription)
                    .font(.headline.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .accessibilityHint("Status summary")
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.thinMaterial)
                    .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 2)
            )
            .offset(x: wiggle)
            // Tip Card
            HStack(alignment: .top, spacing: 8) {
                Text("💡")
                    .font(.title2)
                Text(state.tip)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.yellow)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.yellow.opacity(0.12))
            )
            // Goal Card
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "target")
                    .foregroundStyle(.blue)
                    .font(.title3)
                Text(state.targetText)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.blue.opacity(0.10))
            )
        }
        .padding(.horizontal, 2)
        .onChange(of: didDowngrade) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.2)) {
                    wiggle = -16
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.2)) { wiggle = 16 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.2)) { wiggle = 0 }
                }
            }
        }
    }
}

extension TamagotchiState {
    var leadEmoji: String {
        switch self {
        case .knockedOutSleepy: return "😴"
        case .groggySloth: return "😪"
        case .lazyButRestedPanda: return "🐼"
        case .wiredStressedChinchilla: return "😬"
        case .balancedKoala: return "🧘‍♂️"
        case .energizedRedPanda: return "🎉"
        case .overtrainedHusky: return "🥵"
        case .zenNinjaFox: return "��"
        }
    }
} 
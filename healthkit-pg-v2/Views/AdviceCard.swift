import SwiftUI

struct AdviceCard: View {
    let state: TamagotchiState
    let didDowngrade: Bool
    
    @State private var wiggle: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(state.leadEmoji)
                    .font(.largeTitle)
                Text(state.gamifiedDescription)
                    .font(.headline.weight(.bold))
                    .accessibilityHint("Status summary")
            }
            .padding(.bottom, 2)
            Text("💡 " + state.tip)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.yellow)
                .lineLimit(2)
            HStack(spacing: 4) {
                Image(systemName: "target")
                    .foregroundStyle(.blue)
                Text(state.targetText)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.thinMaterial)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                .innerShadow(radius: 6)
        )
        .offset(x: wiggle)
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

private extension View {
    func innerShadow(radius: CGFloat) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: radius)
                .blur(radius: radius)
                .offset(x: 0, y: 2)
                .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
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
import SwiftUI

struct AdviceCard: View {
    let state: TamagotchiState
    let didDowngrade: Bool
    
    @State private var wiggle: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Tip Card
            HStack(alignment: .center, spacing: 8) {
                Text("💡")
                    .font(.title2)
                Text(state.tip)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.yellow)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                Spacer()
            }
            .padding(16) // Changed from 14 to 16 to match the state card
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous) // Changed from 14 to 16
                    .fill(Color.yellow.opacity(0.3))
            )
        }
        .padding(16) // Added consistent outer padding instead of just horizontal
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
        case .zenNinjaFox: return "🦊"
        }
    }
}

import SwiftUI

/// A minimal SwiftUI view displaying the Tamagotchi avatar and gamified state.
struct TamagotchiWidget: View {
    let date: Date
    @StateObject private var vm: TamagotchiViewModel
    
    init(date: Date) {
        self.date = date
        _vm = StateObject(wrappedValue: TamagotchiViewModel(initialDate: date))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(vm.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .accessibilityLabel(Text(vm.currentState.accessibilityDescription))
                .shadow(radius: 8)
            Text(vm.currentState.gamifiedDescription)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(.primary)
            VStack(spacing: 4) {
                Label(vm.currentState.tip, systemImage: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundStyle(.yellow)
                Label(vm.currentState.targetText, systemImage: "target")
                    .font(.footnote)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .shadow(radius: 2)
            )
        }
        .padding(.top, 8)
        .onChange(of: date) { _, newDate in
            vm.selectedDate = newDate
        }
    }
} 
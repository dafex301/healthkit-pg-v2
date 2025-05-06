import SwiftUI

/// A minimal SwiftUI view displaying the Tamagotchi avatar.
struct TamagotchiWidget: View {
    let date: Date
    @StateObject private var vm: TamagotchiViewModel
    
    init(date: Date) {
        self.date = date
        _vm = StateObject(wrappedValue: TamagotchiViewModel(initialDate: date))
    }
    
    var body: some View {
        VStack {
            Image(vm.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .accessibilityLabel(Text(vm.currentState.accessibilityDescription))
        }
        .padding(.top, 8)
        .onChange(of: date) { _, newDate in
            vm.selectedDate = newDate
        }
    }
} 
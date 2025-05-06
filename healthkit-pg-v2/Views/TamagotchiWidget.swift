import SwiftUI

/// A minimal SwiftUI view displaying the Tamagotchi avatar.
struct TamagotchiWidget: View {
    @StateObject var vm: TamagotchiViewModel = TamagotchiViewModel()
    
    var body: some View {
        VStack {
            Image(vm.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .accessibilityLabel(Text(vm.currentState.accessibilityDescription))
        }
        .padding(.top, 8)
    }
} 
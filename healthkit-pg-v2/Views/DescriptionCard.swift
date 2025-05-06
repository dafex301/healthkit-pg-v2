//
//  DescriptionCard.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 06/05/25.
//

import SwiftUI

struct DescriptionCard: View {
    let state: TamagotchiState
    let didDowngrade: Bool
    
    @State private var wiggle: CGFloat = 0
    
    var body: some View {
        // State Description Card
        HStack(spacing: 8) {
            Text(state.leadEmoji)
                .font(.largeTitle)
            Text(state.gamifiedDescription)
                .font(.headline.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .accessibilityHint("Status summary")
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
                .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 2)
        )
        .offset(x: wiggle)
    }
}

//#Preview {
//    DescriptionCard()
//}

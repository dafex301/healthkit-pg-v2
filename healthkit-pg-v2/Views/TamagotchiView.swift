//
//  TamagotchiView.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 06/05/25.
//

import SwiftUI
import HealthKit

struct TamagotchiView: View {
    @ObservedObject var healthManager: HealthKitManager
    @Binding var selectedDate: Date
    @Binding var currentSnapshot: HealthSnapshot?
    @Binding var isLoadingSnapshot: Bool
    
    var body: some View {
        VStack {
            if let snapshot = currentSnapshot {
                TamagotchiWidget(snapshot: snapshot, selectedDate: $selectedDate)
            } else if isLoadingSnapshot {
                ProgressView("Loading your Tamagotchi...")
                    .padding(.top, 40)
            } else {
                Text("No data for this date.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 40)
            }
//            Spacer()
        }
    }
}

#if DEBUG
struct TamagotchiView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TamagotchiView(
                healthManager: HealthKitManager(),
                selectedDate: .constant(Date()),
                currentSnapshot: .constant(HealthSnapshot(
                    totalSleep: 7.5,
                    deepSleep: 1.2,
                    steps: 8000,
                    distanceKm: 5.2,
                    activeEnergyKcal: 450,
                    restingHR: 62
                )),
                isLoadingSnapshot: .constant(false)
            )
        }
    }
}
#endif

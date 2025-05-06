import Foundation
import Combine
import SwiftUI

/// ViewModel for TamagotchiWidget, manages avatar state based on health metrics.
@MainActor
class TamagotchiViewModel: ObservableObject {
    /// The current Tamagotchi state.
    @Published var currentState: TamagotchiState
    /// The asset name for the current avatar image.
    @Published var assetName: String
    /// The selected date for which to show the Tamagotchi state.
    @Published var selectedDate: Date {
        didSet {
            Task { await fetchSnapshot(for: selectedDate) }
        }
    }
    
    private let healthKitManager: HealthKitManager
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the view model and subscribes to HealthKitManager.
    init(healthKitManager: HealthKitManager = HealthKitManager(), initialDate: Date = Calendar.current.startOfDay(for: Date())) {
        self.healthKitManager = healthKitManager
        self.selectedDate = initialDate
        self.currentState = .knockedOutSleepy
        self.assetName = TamagotchiState.knockedOutSleepy.assetName
        subscribe()
        Task { await fetchSnapshot(for: selectedDate) }
    }
    
    /// Subscribes to HealthKitManager's snapshotPublisher.
    private func subscribe() {
        healthKitManager.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.handle(snapshot: snapshot)
            }
            .store(in: &cancellables)
    }
    
    /// Handles a new HealthSnapshot and updates state.
    private func handle(snapshot: HealthSnapshot) {
        let newState = evaluate(snapshot)
        currentState = newState
        assetName = newState.assetName
    }
    
    /// Fetches a snapshot for the given date and updates state.
    private func fetchSnapshot(for date: Date) async {
        do {
            _ = try await healthKitManager.fetchSnapshot(for: date)
        } catch {
            // Optionally handle error
        }
    }
} 
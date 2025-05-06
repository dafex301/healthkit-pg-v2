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
    
    private let healthKitManager: HealthKitManager
    private var cancellables = Set<AnyCancellable>()
    
    // Use static computed properties for AppStorage access
    private static var cachedStateRawValue: String {
        get { UserDefaults.standard.string(forKey: "tamagotchiStateRawValue") ?? TamagotchiState.knockedOutSleepy.rawValue }
        set { UserDefaults.standard.set(newValue, forKey: "tamagotchiStateRawValue") }
    }
    private static var cachedDateISO: String {
        get { UserDefaults.standard.string(forKey: "tamagotchiStateDateISO") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "tamagotchiStateDateISO") }
    }
    
    /// Initializes the view model and subscribes to HealthKitManager.
    init(healthKitManager: HealthKitManager = HealthKitManager()) {
        self.healthKitManager = healthKitManager
        let todayISO = Self.todayISOString
        let initialState: TamagotchiState
        let cachedState = Self.cachedStateRawValue
        let cachedDate = Self.cachedDateISO
        if let cached = TamagotchiState(rawValue: cachedState), cachedDate == todayISO {
            initialState = cached
        } else {
            initialState = .knockedOutSleepy
        }
        self.currentState = initialState
        self.assetName = initialState.assetName
        subscribe()
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
    
    /// Handles a new HealthSnapshot and updates state if allowed by caching rule.
    private func handle(snapshot: HealthSnapshot) {
        let newState = evaluate(snapshot)
        let todayISO = Self.todayISOString
        let cachedRank = TamagotchiState(rawValue: Self.cachedStateRawValue)?.severityRank ?? 0
        if Self.cachedDateISO != todayISO || newState.severityRank < cachedRank {
            // Allow update if new day or less severe
            currentState = newState
            assetName = newState.assetName
            Self.cachedStateRawValue = newState.rawValue
            Self.cachedDateISO = todayISO
        } else {
            // Keep cached state
            currentState = TamagotchiState(rawValue: Self.cachedStateRawValue) ?? .knockedOutSleepy
            assetName = currentState.assetName
        }
    }
    
    /// Triggers a refresh of the Tamagotchi state.
    func refresh() async {
        do {
            _ = try await healthKitManager.fetchTodaySnapshot()
        } catch {
            // Optionally handle error
        }
    }
    
    /// Returns today's ISO8601 date string (yyyy-MM-dd).
    private static var todayISOString: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: Date())
    }
} 
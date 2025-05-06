import Foundation

/// Evaluates a HealthSnapshot and returns the corresponding TamagotchiState.
/// - Parameter snapshot: The health snapshot to evaluate.
/// - Returns: The TamagotchiState for the given snapshot.
func evaluate(_ s: HealthSnapshot) -> TamagotchiState {
    // 1. knockedOutSleepy: s.totalSleep < 6h OR s.deepSleep < 0.45h
    if s.totalSleep < 6 || s.deepSleep < 0.45 {
        return .knockedOutSleepy
    }
    // 2. groggySloth: 6h ≤ s.totalSleep < 7h && s.steps < 3_000
    if s.totalSleep >= 6, s.totalSleep < 7, s.steps < 3_000 {
        return .groggySloth
    }
    // 3. lazyButRestedPanda: s.totalSleep ≥ 7h && s.steps < 3_000
    if s.totalSleep >= 7, s.steps < 3_000 {
        return .lazyButRestedPanda
    }
    // 4. wiredStressedChinchilla: s.restingHR ≥ 90 && s.steps < 2_000
    if s.restingHR >= 90, s.steps < 2_000 {
        return .wiredStressedChinchilla
    }
    // 5. balancedKoala: 7h ≤ s.totalSleep ≤ 9h && 3_000 ≤ s.steps < 10_000 && s.activeEnergyKcal ≥ 300
    if s.totalSleep >= 7, s.totalSleep <= 9, s.steps >= 3_000, s.steps < 10_000, s.activeEnergyKcal >= 300 {
        return .balancedKoala
    }
    // 6. energizedRedPanda: (s.steps ≥ 10_000 OR s.distanceKm ≥ 8) && s.totalSleep ≥ 7h
    if (s.steps >= 10_000 || s.distanceKm >= 8), s.totalSleep >= 7 {
        return .energizedRedPanda
    }
    // 7. overtrainedHusky: s.steps ≥ 15_000 && s.totalSleep < 6h
    if s.steps >= 15_000, s.totalSleep < 6 {
        return .overtrainedHusky
    }
    // 8. zenNinjaFox: 45 ≤ s.restingHR ≤ 60 && 7h ≤ s.totalSleep ≤ 9h && 5_000 ≤ s.steps ≤ 12_000
    if s.restingHR >= 45, s.restingHR <= 60, s.totalSleep >= 7, s.totalSleep <= 9, s.steps >= 5_000, s.steps <= 12_000 {
        return .zenNinjaFox
    }
    // Default fallback
    return .balancedKoala
} 
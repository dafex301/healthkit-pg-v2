import Foundation

/// Represents a snapshot of key health metrics for Tamagotchi evaluation.
struct HealthSnapshot: Equatable, Codable {
    /// Total sleep in hours.
    var totalSleep: Double
    /// Deep sleep in hours.
    var deepSleep: Double
    /// Step count.
    var steps: Int
    /// Distance in kilometers.
    var distanceKm: Double
    /// Active energy in kilocalories.
    var activeEnergyKcal: Double
    /// Resting heart rate in bpm.
    var restingHR: Double
} 
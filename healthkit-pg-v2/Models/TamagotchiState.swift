import Foundation

/// Represents the Tamagotchi avatar state based on health metrics.
enum TamagotchiState: String, CaseIterable, Codable, Identifiable {
    case knockedOutSleepy
    case groggySloth
    case lazyButRestedPanda
    case wiredStressedChinchilla
    case balancedKoala
    case energizedRedPanda
    case overtrainedHusky
    case zenNinjaFox

    /// The asset name for the corresponding avatar image.
    var assetName: String {
        switch self {
        case .knockedOutSleepy: return "knocked-out-sleepy"
        case .groggySloth: return "groggy-sloth"
        case .lazyButRestedPanda: return "lazy-but-rested-panda"
        case .wiredStressedChinchilla: return "wired-stressed-chinchilla"
        case .balancedKoala: return "balanced-koala"
        case .energizedRedPanda: return "energized-red-panda"
        case .overtrainedHusky: return "overtrained-husky"
        case .zenNinjaFox: return "zen-ninja-fox"
        }
    }

    /// Accessibility description for the avatar state.
    var accessibilityDescription: String {
        switch self {
        case .knockedOutSleepy: return "Knocked out and sleepy"
        case .groggySloth: return "Groggy sloth"
        case .lazyButRestedPanda: return "Lazy but rested panda"
        case .wiredStressedChinchilla: return "Wired and stressed chinchilla"
        case .balancedKoala: return "Balanced koala"
        case .energizedRedPanda: return "Energized red panda"
        case .overtrainedHusky: return "Overtrained husky"
        case .zenNinjaFox: return "Zen ninja fox"
        }
    }

    /// Severity rank (0 = most severe, higher = less severe)
    var severityRank: Int {
        switch self {
        case .knockedOutSleepy: return 0
        case .groggySloth: return 1
        case .lazyButRestedPanda: return 2
        case .wiredStressedChinchilla: return 3
        case .balancedKoala: return 4
        case .energizedRedPanda: return 5
        case .overtrainedHusky: return 6
        case .zenNinjaFox: return 7
        }
    }

    /// Unique identifier for Identifiable conformance.
    var id: String { rawValue }
} 
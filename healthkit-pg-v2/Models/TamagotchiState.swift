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

    /// Gamified description of the avatar's current state.
    var gamifiedDescription: String {
        switch self {
        case .knockedOutSleepy:
            return "😴 Eyes half-closed, head bobbing. Your Tamagotchi is running on empty!"
        case .groggySloth:
            return "😪 Slouching with a tiny zzz bubble. Feeling sluggish from too little sleep and too few steps."
        case .lazyButRestedPanda:
            return "🐼 Content smile, sitting still. Well-rested, but missing out on adventure!"
        case .wiredStressedChinchilla:
            return "😬 Darting eyes, jittery shake. High heart rate, low movement – stress detected!"
        case .balancedKoala:
            return "🧘‍♂️ Soft smile, gentle breathing. A balanced day for your Tamagotchi!"
        case .energizedRedPanda:
            return "🎉 Big grin, bouncing in place! Energy and activity maxed out – celebration time!"
        case .overtrainedHusky:
            return "🥵 Panting, sweat drops, sluggish tail. Overdoing it without enough rest."
        case .zenNinjaFox:
            return "🦊 Calm, floating lotus pose. Peak readiness! Your Tamagotchi is in zen mode."
        }
    }

    /// Gamified tip or trick for the user.
    var tip: String {
        switch self {
        case .knockedOutSleepy:
            return "Tip: Try to get to bed earlier tonight. Even a short nap can help!"
        case .groggySloth:
            return "Tip: A brisk 10-minute walk can wake up your Tamagotchi."
        case .lazyButRestedPanda:
            return "Tip: You're well-rested! Now, let's get those activity rings moving."
        case .wiredStressedChinchilla:
            return "Tip: Take a break, breathe deeply, or try a short meditation."
        case .balancedKoala:
            return "Tip: Keep up the consistency! Small wins add up."
        case .energizedRedPanda:
            return "Tip: Amazing! Celebrate your progress and share your streak."
        case .overtrainedHusky:
            return "Tip: Rest and recovery are as important as activity. Try foam rolling or stretching."
        case .zenNinjaFox:
            return "Tip: You're in the zone! Challenge yourself with a new workout or focus sprint."
        }
    }

    /// Target or goal text for the user.
    var targetText: String {
        switch self {
        case .knockedOutSleepy:
            return "Goal: Sleep at least 6 hours and get some deep sleep (>0.45h)."
        case .groggySloth:
            return "Goal: Reach 3,000 steps and aim for 7+ hours of sleep."
        case .lazyButRestedPanda:
            return "Goal: Get moving! Try to hit 3,000+ steps today."
        case .wiredStressedChinchilla:
            return "Goal: Lower your resting heart rate and take 2,000+ steps."
        case .balancedKoala:
            return "Goal: 7–9h sleep, 3,000–10,000 steps, and 300+ kcal active energy."
        case .energizedRedPanda:
            return "Goal: Keep up 10,000+ steps, 8+ km, or 500+ kcal with 7+ hours sleep."
        case .overtrainedHusky:
            return "Goal: Rest up! Try to sleep 6+ hours after a big activity day."
        case .zenNinjaFox:
            return "Goal: 7–9h sleep, 5,000–12,000 steps, and resting HR 45–60 bpm."
        }
    }

    /// Unique identifier for Identifiable conformance.
    var id: String { rawValue }
} 
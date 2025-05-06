import SwiftUI

extension Color {
    /// Returns a gradient keyed to the TamagotchiState severity rank.
    static func stateGradient(for severityRank: Int) -> LinearGradient {
        switch severityRank {
        case 0...1:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: 0x2C2C2E), .black]),
                startPoint: .top, endPoint: .bottom)
        case 2...4:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: 0x34C759), Color(hex: 0x0A84FF)]),
                startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: 0x0A84FF), Color(hex: 0x5E5CE6)]),
                startPoint: .top, endPoint: .bottom)
        }
    }
    
    /// Helper to create Color from hex code.
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
} 
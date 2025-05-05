//
//  HKWorkoutActivityTypeExtension.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 05/05/25.
//

// Extensions/HKWorkoutActivityTypeExtension.swift
import HealthKit

extension HKWorkoutActivityType {
    var description: String {
        switch self {
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .walking:
            return "Walking"
        case .swimming:
            return "Swimming"
        case .yoga:
            return "Yoga"
        case .traditionalStrengthTraining:
            return "Strength Training"
        case .functionalStrengthTraining:
            return "Functional Strength Training"
        case .highIntensityIntervalTraining:
            return "HIIT"
        default:
            return "Other"
        }
    }
}

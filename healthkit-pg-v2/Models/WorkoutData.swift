//
//  WorkoutData.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 05/05/25.
//

import Foundation

struct WorkoutData {
    let id: UUID
    let type: String
//    let duration: TimeInterval
//    let calories: Double
    let distance: Double
    let startDate: Date
    let endDate: Date
    
//    var formattedDuration: String {
//        let hours = Int(duration) / 3600
//        let minutes = (Int(duration) % 3600) / 60
//        let seconds = Int(duration) % 60
//        
//        if hours > 0 {
//            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
//        } else {
//            return String(format: "%02d:%02d", minutes, seconds)
//        }
//    }
    
    var formattedDuration: String {
        return "Duration..."
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
}

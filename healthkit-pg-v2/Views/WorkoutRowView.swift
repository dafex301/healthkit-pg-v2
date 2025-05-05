//
//  WorkoutRowView.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 05/05/25.
//

// Views/WorkoutRowView.swift
import SwiftUI

struct WorkoutRowView: View {
    let workout: WorkoutData
    
    var body: some View {
        HStack {
            Image(systemName: iconForWorkoutType(workout.type))
                .foregroundColor(.green)
                .font(.system(size: 24))
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(workout.type)
                    .font(.headline)
                
                Text(workout.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(workout.formattedDuration)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.0f kcal", 555))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    func iconForWorkoutType(_ type: String) -> String {
        switch type {
        case "Running":
            return "figure.run"
        case "Cycling":
            return "figure.outdoor.cycle"
        case "Walking":
            return "figure.walk"
        case "Swimming":
            return "figure.pool.swim"
        case "Strength Training":
            return "dumbbell.fill"
        case "HIIT":
            return "bolt.fill"
        case "Yoga":
            return "figure.mind.and.body"
        default:
            return "figure.mixed.cardio"
        }
    }
}

//
//  WorkoutDetailView.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 05/05/25.
//

// Views/WorkoutDetailView.swift
import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutData
    
    var body: some View {
        List {
            Section(header: Text("Workout Details")) {
                DetailRowView(title: "Type", value: workout.type)
                DetailRowView(title: "Duration", value: workout.formattedDuration)
                DetailRowView(title: "Date", value: workout.formattedDate)
                DetailRowView(title: "Calories", value: String(format: "%.0f kcal", 100 * workout.distance))
                DetailRowView(title: "Distance", value: String(format: "%.2f km", workout.distance / 1000))
            }
        }
        .navigationTitle(workout.type)
    }
}

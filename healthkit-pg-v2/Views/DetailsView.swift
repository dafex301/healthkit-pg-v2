//
//  DetailsView.swift
//  healthkit-pg-v2
//
//  Created by Claude on 06/05/25.
//

import SwiftUI
import HealthKit

struct DetailsView: View {
    @ObservedObject var healthManager: HealthKitManager
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding([.top, .horizontal])
            List {
                Section(header: Text("Today's Stats")) {
                    StatRowView(title: "Steps", value: "\(healthManager.stepCount)", icon: "figure.walk")
                    StatRowView(title: "Active Energy", value: "\(Int(healthManager.activeEnergy)) kcal", icon: "flame.fill")
                    StatRowView(title: "Heart Rate", value: "\(Int(healthManager.heartRate)) bpm", icon: "heart.fill")
                    StatRowView(title: "Distance", value: "\(String(format: "%.2f", healthManager.distance)) km", icon: "figure.walk")
                }
                Section(header: Text("Today's Sleep")) {
                    StatRowView(title: "Total Sleep", value: String(format: "%.1f h", healthManager.totalSleepMinutes/60), icon: "bed.double.fill")
                    StatRowView(title: "REM", value: String(format: "%.0f min", healthManager.remSleepMinutes), icon: "moon.zzz.fill")
                    StatRowView(title: "Deep", value: String(format: "%.0f min", healthManager.deepSleepMinutes), icon: "tortoise.fill")
                    StatRowView(title: "Core", value: String(format: "%.0f min", healthManager.coreSleepMinutes), icon: "circle.grid.cross")
                    StatRowView(title: "Awake", value: String(format: "%.0f min", healthManager.awakeMinutes), icon: "eye.fill")
                    StatRowView(title: "Nap", value: String(format: "%.0f min", healthManager.napSleepMinutes), icon: "bed.double.fill")
                }
                Section(header: Text("Profile")) {
                    StatRowView(title: "Weight", value: "\(String(format: "%.1f", healthManager.weight)) kg", icon: "scalemass.fill")
                    StatRowView(title: "Height", value: "\(String(format: "%.1f", healthManager.height)) cm", icon: "ruler.fill")
                    StatRowView(title: "Age", value: "\(healthManager.age) years", icon: "calendar")
                    StatRowView(title: "Biological Sex", value: healthManager.biologicalSex, icon: "person.fill")
                }
                Section(header: Text("Last 7 Days Workouts")) {
                    ForEach(healthManager.workouts, id: \.id) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            WorkoutRowView(workout: workout)
                        }
                    }
                }
                Section {
                    Button("Refresh Data") {
                        healthManager.fetchAllHealthData()
                    }
                    Button("Save New Weight: 70kg") {
                        healthManager.saveNewWeight(weight: 70.0)
                    }
                }
            }
        }
        .navigationTitle("Stats & Details")
    }
}

#if DEBUG
struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailsView(
                healthManager: HealthKitManager(),
                selectedDate: .constant(Date())
            )
        }
    }
}
#endif

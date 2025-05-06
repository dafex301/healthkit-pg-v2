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
    
    // State variables for new weight entry
    @State private var showingWeightSheet = false
    @State private var newWeight = ""
    @State private var weightDate = Date()
    @State private var weightEndDate = Date()
    @State private var showWeightSavedAlert = false
    @State private var showingConfirmation = false
    
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
                    
                    Button("Add New Weight Entry") {
                        // Initialize with current weight
                        newWeight = String(format: "%.1f", healthManager.weight)
                        weightDate = Date()
                        weightEndDate = Date()
                        showingWeightSheet = true
                    }
                }
            }
        }
        .navigationTitle("Stats & Details")
        .sheet(isPresented: $showingWeightSheet) {
            weightEntrySheet
        }
        .alert("Weight Saved", isPresented: $showWeightSavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your new weight entry has been saved successfully.")
        }
    }
    
    // Weight entry sheet
    private var weightEntrySheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter New Weight")) {
                    // Weight input field with kg suffix
                    HStack {
                        TextField("Weight", text: $newWeight)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 22, weight: .medium))
                        Text("kg")
                            .foregroundColor(.secondary)
                            .font(.system(size: 22))
                    }
                    .padding(.vertical, 8)
                    
                    // Date picker for the weight entry (start)
                    DatePicker("Start Date", selection: $weightDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding(.vertical, 8)
                    // Date picker for the weight entry (end)
                    DatePicker("End Date", selection: $weightEndDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Recent Averages")) {
                    HStack {
                        Text("Current Weight")
                        Spacer()
                        Text(String(format: "%.1f kg", healthManager.weight))
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                
                Section {
                    // Some helpful information about weight tracking
                    Text("Regular weight tracking can help you monitor your progress toward fitness and health goals.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Weight Entry")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingWeightSheet = false
                },
                trailing: Button("Save") {
                    if isValidWeight(newWeight) {
                        saveWeight()
                    }
                }
                .font(.headline)
                .foregroundColor(.blue)
                .disabled(newWeight.isEmpty || !isValidWeight(newWeight))
            )
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // Save weight to HealthKit
    private func saveWeight() {
        guard let weightValue = Double(newWeight.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        
        // Save the weight with the selected start and end date
        healthManager.saveNewWeight(weight: weightValue, startDate: weightDate, endDate: weightEndDate)
        
        showingWeightSheet = false
        showWeightSavedAlert = true
        
        // Refresh the data after saving
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            healthManager.fetchAllHealthData()
        }
    }
    
    // Validate that the weight input is a valid number
    private func isValidWeight(_ weightStr: String) -> Bool {
        let formattedStr = weightStr.replacingOccurrences(of: ",", with: ".")
        
        // Check if it's a valid number
        guard let weightValue = Double(formattedStr) else {
            return false
        }
        
        // Valid weight range (e.g., 20kg to 300kg)
        return weightValue >= 20 && weightValue <= 300
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

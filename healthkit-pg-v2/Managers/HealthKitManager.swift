//
//  HealthKitManager.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 05/05/25.
//
// Managers/HealthKitManager.swift
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    // Published properties for UI updates
    @Published var stepCount: Int = 0
    @Published var activeEnergy: Double = 0
    @Published var heartRate: Double = 0
    @Published var distance: Double = 0
    @Published var weight: Double = 0
    @Published var height: Double = 0
    @Published var age: Int = 0
    @Published var biologicalSex: String = "Unknown"
    @Published var workouts: [WorkoutData] = []
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            print("HealthKit is available on this device")
        } else {
            print("HealthKit is not available on this device")
        }
    }
    
    func requestAuthorization() {
        // Define the types of data we want to read from HealthKit
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.workoutType()
        ]
        
        // Define the types of data we want to write to HealthKit
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        // Request authorization
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
            if success {
                print("HealthKit authorization successful")
                
                // Fetch all health data once we have authorization
                DispatchQueue.main.async {
                    self.fetchAllHealthData()
                }
            } else {
                print("HealthKit authorization failed")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchAllHealthData() {
        readStepCount()
        readActiveEnergy()
        readLatestHeartRate()
        readDistance()
        readWeight()
        readHeight()
        getBiologicalSexAndAge()
        queryWorkouts()
    }
    
    // MARK: - Reading Health Data
    
    func readStepCount() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        // Create predicate for today's date
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Create a query to sum up all step counts for today
        let query = HKStatisticsQuery(quantityType: stepCountType,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch step count: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Process the result on the main thread
            DispatchQueue.main.async {
                self?.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                print("Today's step count: \(self?.stepCount ?? 0) steps")
            }
        }
        
        healthStore.execute(query)
    }
    
    func readActiveEnergy() {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        // Create predicate for today's date
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Create a query to sum up all active energy for today
        let query = HKStatisticsQuery(quantityType: activeEnergyType,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch active energy: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Process the result on the main thread
            DispatchQueue.main.async {
                self?.activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
                print("Today's active energy: \(self?.activeEnergy ?? 0) kcal")
            }
        }
        
        healthStore.execute(query)
    }
    
    func readLatestHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        // Sort by date to get the latest heart rate reading
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Query to fetch the latest heart rate sample
        let query = HKSampleQuery(sampleType: heartRateType,
                                 predicate: nil,
                                 limit: 1,
                                 sortDescriptors: [sortDescriptor]) { [weak self] (_, samples, error) in
            guard let samples = samples,
                  let mostRecentSample = samples.first as? HKQuantitySample else {
                print("Failed to fetch heart rate: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Process the result on the main thread
            DispatchQueue.main.async {
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self?.heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
                print("Latest heart rate: \(self?.heartRate ?? 0) bpm")
            }
        }
        
        healthStore.execute(query)
    }
    
    func readDistance() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        // Create predicate for today's date
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Create a query to sum up all distance for today
        let query = HKStatisticsQuery(quantityType: distanceType,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch distance: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Process the result on the main thread
            DispatchQueue.main.async {
                // Convert from meters to kilometers
                self?.distance = sum.doubleValue(for: HKUnit.meter()) / 1000
                print("Today's distance: \(self?.distance ?? 0) km")
            }
        }
        
        healthStore.execute(query)
    }
    
    func readWeight() {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        
        let query = HKSampleQuery(sampleType: weightType,
                                 predicate: nil,
                                 limit: 1,
                                 sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { [weak self] (_, samples, error) in
            guard let samples = samples,
                  let mostRecentSample = samples.first as? HKQuantitySample else {
                print("Failed to fetch weight: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                let weightUnit = HKUnit.gramUnit(with: .kilo)
                self?.weight = mostRecentSample.quantity.doubleValue(for: weightUnit)
                print("Latest weight: \(self?.weight ?? 0) kg")
            }
        }
        
        healthStore.execute(query)
    }
    
    func readHeight() {
        guard let heightType = HKQuantityType.quantityType(forIdentifier: .height) else { return }
        
        let query = HKSampleQuery(sampleType: heightType,
                                 predicate: nil,
                                 limit: 1,
                                 sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { [weak self] (_, samples, error) in
            guard let samples = samples,
                  let mostRecentSample = samples.first as? HKQuantitySample else {
                print("Failed to fetch height: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                // Convert from meters to centimeters
                let heightUnit = HKUnit.meter()
                self?.height = mostRecentSample.quantity.doubleValue(for: heightUnit) * 100
                print("Latest height: \(self?.height ?? 0) cm")
            }
        }
        
        healthStore.execute(query)
    }
    
    func getBiologicalSexAndAge() {
        // Get biological sex
        do {
            let biologicalSex = try healthStore.biologicalSex()
            var sexString = "Unknown"
            
            switch biologicalSex.biologicalSex {
            case .female:
                sexString = "Female"
            case .male:
                sexString = "Male"
            case .other:
                sexString = "Other"
            default:
                sexString = "Not Set"
            }
            
            DispatchQueue.main.async {
                self.biologicalSex = sexString
                print("Biological sex: \(sexString)")
            }
        } catch {
            print("Error getting biological sex: \(error.localizedDescription)")
        }
        
        // Get date of birth (to calculate age)
        do {
            let dateOfBirth = try healthStore.dateOfBirthComponents()
            
            if let year = dateOfBirth.year,
               let month = dateOfBirth.month,
               let day = dateOfBirth.day {
                
                let calendar = Calendar.current
                let today = calendar.dateComponents([.year, .month, .day], from: Date())
                
                var age = today.year! - year
                
                // Adjust age if birthday hasn't occurred yet this year
                if today.month! < month || (today.month! == month && today.day! < day) {
                    age -= 1
                }
                
                DispatchQueue.main.async {
                    self.age = age
                    print("Age: \(age) years")
                }
            }
        } catch {
            print("Error getting date of birth: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Writing Data to HealthKit
    
    func saveNewWeight(weight: Double) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        
        // Create a weight quantity
        let weightUnit = HKUnit.gramUnit(with: .kilo)
        let weightQuantity = HKQuantity(unit: weightUnit, doubleValue: weight)
        
        // Create a weight sample
        let now = Date()
        let weightSample = HKQuantitySample(type: weightType,
                                           quantity: weightQuantity,
                                           start: now,
                                           end: now)
        
        // Save the weight sample to HealthKit
        healthStore.save(weightSample) { [weak self] (success, error) in
            if success {
                print("Successfully saved weight of \(weight) kg")
                
                // Update the UI
                DispatchQueue.main.async {
                    self?.weight = weight
                }
            } else {
                print("Failed to save weight: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Querying Workouts
    
    func queryWorkouts() {
        // Predicate for the last 7 days
        let calendar = Calendar.current
        let now = Date()
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: oneWeekAgo, end: now, options: .strictStartDate)
        
        // Query all workouts from the last 7 days
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                 predicate: predicate,
                                 limit: HKObjectQueryNoLimit,
                                 sortDescriptors: [sortDescriptor]) { [weak self] (_, samples, error) in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Failed to fetch workouts: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                // Convert HKWorkout to our WorkoutData model
                self?.workouts = workouts.map { workout in
                    return WorkoutData(
                        id: workout.uuid,
                        type: workout.workoutActivityType.rawValue.description,
//                        duration: workout.,
//                        calories: workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0,
                        distance: workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0,
                        startDate: workout.startDate,
                        endDate: workout.endDate
                    )
                }
                
                print("Found \(workouts.count) workouts in the last 7 days")
            }
        }
        
        healthStore.execute(query)
    }
}

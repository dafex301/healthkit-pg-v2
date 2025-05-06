//
//  HealthKitManager.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 05/05/25.
//
// Managers/HealthKitManager.swift
import HealthKit
import SwiftUI
import Combine

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
    @Published var totalSleepMinutes: Double = 0
    @Published var remSleepMinutes: Double = 0
    @Published var deepSleepMinutes: Double = 0
    @Published var coreSleepMinutes: Double = 0
    @Published var awakeMinutes: Double = 0
    @Published var napSleepMinutes: Double = 0
    
    /// Publishes new HealthSnapshot values when available.
    public let snapshotPublisher = PassthroughSubject<HealthSnapshot, Never>()
    
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
        fetchAllHealthData(for: Date())
    }
    
    func fetchAllHealthData(for date: Date) {
        readStepCount(for: date)
        readActiveEnergy(for: date)
        readLatestHeartRate(for: date)
        readDistance(for: date)
        readWeight()
        readHeight()
        getBiologicalSexAndAge()
        queryWorkouts(for: date)
        readSleepData(for: date)
    }
    
    // MARK: - Reading Health Data
    
    func readStepCount(for date: Date) {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepCountType,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch step count: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self?.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                print("Step count: \(self?.stepCount ?? 0) steps")
            }
        }
        healthStore.execute(query)
    }
    
    func readActiveEnergy(for date: Date) {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: activeEnergyType,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch active energy: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self?.activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
                print("Active energy: \(self?.activeEnergy ?? 0) kcal")
            }
        }
        healthStore.execute(query)
    }
    
    func readLatestHeartRate(for date: Date) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType,
                                 predicate: predicate,
                                 limit: 1,
                                 sortDescriptors: [sortDescriptor]) { [weak self] (_, samples, error) in
            guard let samples = samples,
                  let mostRecentSample = samples.first as? HKQuantitySample else {
                print("Failed to fetch heart rate: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self?.heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
                print("Latest heart rate: \(self?.heartRate ?? 0) bpm")
            }
        }
        healthStore.execute(query)
    }
    
    func readDistance(for date: Date) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch distance: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self?.distance = sum.doubleValue(for: HKUnit.meter()) / 1000
                print("Distance: \(self?.distance ?? 0) km")
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
    
    func saveNewWeight(weight: Double, date: Date = Date()) {
        saveNewWeight(weight: weight, startDate: date, endDate: date)
    }
    
    func saveNewWeight(weight: Double, startDate: Date, endDate: Date) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        
        // Create a weight quantity
        let weightUnit = HKUnit.gramUnit(with: .kilo)
        let weightQuantity = HKQuantity(unit: weightUnit, doubleValue: weight)
        
        // Create a weight sample with the specified start and end date
        let weightSample = HKQuantitySample(type: weightType,
                                           quantity: weightQuantity,
                                           start: startDate,
                                           end: endDate)
        
        // Save the weight sample to HealthKit
        healthStore.save(weightSample) { [weak self] (success, error) in
            if success {
                print("Successfully saved weight of \(weight) kg at start \(startDate) end \(endDate)")
                
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
    
    func queryWorkouts(for date: Date) {
//        let calendar = Calendar.current
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
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
                self?.workouts = workouts.map { workout in
                    return WorkoutData(
                        id: workout.uuid,
                        type: workout.workoutActivityType.rawValue.description,
                        distance: workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0,
                        startDate: workout.startDate,
                        endDate: workout.endDate
                    )
                }
                print("Found \(workouts.count) workouts for selected date")
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Sleep Data
    func readSleepData(for date: Date) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let calendar = Calendar.current
        // Define main sleep window: 6 PM previous day to 10 AM current day
        let startOfMainSleep = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: -1, to: date)!)!
        let endOfMainSleep = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!
        // For nap detection, also fetch up to 6 PM current day
        let endOfNapWindow = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: date)!
        // Query all sleep samples from 6 PM previous day to 6 PM current day
        let predicate = HKQuery.predicateForSamples(withStart: startOfMainSleep, end: endOfNapWindow, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] (_, samples, error) in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                print("Failed to fetch sleep data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            var rem: Double = 0
            var deep: Double = 0
            var core: Double = 0
            var awake: Double = 0
            var unspecified: Double = 0
            var napMinutes: Double = 0
            var mainSleepMinutes: Double = 0
            for sample in samples {
                let minutes = sample.endDate.timeIntervalSince(sample.startDate) / 60
                let start = sample.startDate
                // Only count REM, Deep, Core for sleep
                let isSleep = sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                              sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                              sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue
                if isSleep {
                    // Classify as main sleep or nap
                    if start >= startOfMainSleep && start < endOfMainSleep {
                        mainSleepMinutes += minutes
                    } else if start >= endOfMainSleep && start < endOfNapWindow {
                        napMinutes += minutes
                    }
                }
                switch sample.value {
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    rem += minutes
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    deep += minutes
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    core += minutes
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    awake += minutes
                case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                    unspecified += minutes
                default:
                    break
                }
            }
            let total = rem + deep + core // Only sum REM, Deep, and Core for total sleep
            DispatchQueue.main.async {
                self?.totalSleepMinutes = mainSleepMinutes
                self?.napSleepMinutes = napMinutes
                self?.remSleepMinutes = rem
                self?.deepSleepMinutes = deep
                self?.coreSleepMinutes = core
                self?.awakeMinutes = awake
                print("Main Sleep: \(mainSleepMinutes) min, Nap: \(napMinutes) min, total=\(total) min, rem=\(rem), deep=\(deep), core=\(core), awake=\(awake), unspecified=\(unspecified)")
            }
        }
        healthStore.execute(query)
    }
    
    func readStepCount() {
        readStepCount(for: Date())
    }
    
    func readActiveEnergy() {
        readActiveEnergy(for: Date())
    }
    
    func readLatestHeartRate() {
        readLatestHeartRate(for: Date())
    }
    
    func readDistance() {
        readDistance(for: Date())
    }
    
    func readSleepData() {
        readSleepData(for: Date())
    }
    
    func queryWorkouts() {
        queryWorkouts(for: Date())
    }
    
    /// Fetches a HealthSnapshot for the given date, asynchronously.
    /// - Parameter date: The date for which to fetch the snapshot.
    /// - Returns: A HealthSnapshot with the metrics for the given date.
    func fetchSnapshot(for date: Date) async throws -> HealthSnapshot {
        // Helper to run HK queries synchronously
        func fetch<T>(_ block: (@escaping (T) -> Void) -> Void) async -> T? {
            await withCheckedContinuation { continuation in
                block { value in
                    continuation.resume(returning: value)
                }
            }
        }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        // Step Count
        let steps: Int = await fetch { completion in
            guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { completion(0); return }
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                completion(Int(value))
            }
            self.healthStore.execute(query)
        } ?? 0
        // Distance (km)
        let distanceKm: Double = await fetch { completion in
            guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { completion(0); return }
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                completion(value / 1000)
            }
            self.healthStore.execute(query)
        } ?? 0
        // Active Energy (kcal)
        let activeEnergyKcal: Double = await fetch { completion in
            guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { completion(0); return }
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                completion(value)
            }
            self.healthStore.execute(query)
        } ?? 0
        // Sleep (total, deep)
        let (totalSleep, deepSleep): (Double, Double) = await fetch { completion in
            guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { completion((0,0)); return }
            let calendar = Calendar.current
            let startOfMainSleep = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: -1, to: date)!)!
            let endOfMainSleep = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfMainSleep, end: endOfMainSleep, options: .strictStartDate)
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                var total: Double = 0
                var deep: Double = 0
                if let samples = samples as? [HKCategorySample] {
                    for sample in samples {
                        let minutes = sample.endDate.timeIntervalSince(sample.startDate) / 60
                        if sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue || sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue || sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue {
                            total += minutes
                        }
                        if sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue {
                            deep += minutes
                        }
                    }
                }
                completion((total / 60, deep / 60)) // hours
            }
            self.healthStore.execute(query)
        } ?? (0,0)
        // Resting HR (use lowest HR sample for the day as a proxy)
        let restingHR: Double = await fetch { completion in
            guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { completion(0); return }
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
            let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, _ in
                if let samples = samples as? [HKQuantitySample], let minSample = samples.min(by: { $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) < $1.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) }) {
                    let hr = minSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    completion(hr)
                } else {
                    completion(0)
                }
            }
            self.healthStore.execute(query)
        } ?? 0
        let snapshot = HealthSnapshot(totalSleep: totalSleep, deepSleep: deepSleep, steps: steps, distanceKm: distanceKm, activeEnergyKcal: activeEnergyKcal, restingHR: restingHR)
        snapshotPublisher.send(snapshot)
        return snapshot
    }
}

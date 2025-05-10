## TamagotchiWidget & HealthKit Integration
![App Screenshot](https://drive.google.com/uc?export=view&id=1mVdUDVqb4XaE1DsUxhP1NaSorHeWddA2)


### Permissions Steps
1. On first launch, the app will request HealthKit permissions. Grant access to all requested metrics (steps, sleep, heart rate, etc.).
2. If permissions are denied, the TamagotchiWidget will not update with real data.

### Testing on Simulator
- HealthKit is only available on real devices. On Simulator, the TamagotchiWidget will show a fallback or static state.
- To test the widget logic, you can inject mock `HealthSnapshot` data in the `TamagotchiViewModel` or use the included unit tests in `HealthSnapshotEvaluatorTests.swift`.
- To run tests: `Product > Test` in Xcode or `xcodebuild test` from the command line.

### TamagotchiWidget Feature
- The TamagotchiWidget displays a Tamagotchi-style avatar that changes based on your daily health metrics.
- The avatar state is determined by a decision table using your sleep, steps, distance, active energy, and resting heart rate.
- The widget persists the last state per day and only updates to a less severe state until the next day.
- All avatar images are included in the asset catalog. 

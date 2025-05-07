// ContentView.swift
import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject var healthManager = HealthKitManager()
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var currentSnapshot: HealthSnapshot? = nil
    @State private var isLoadingSnapshot = false
    
    var body: some View {
        TabView {
            // Tamagotchi Tab
            NavigationView {
                TamagotchiView(
                    healthManager: healthManager,
                    selectedDate: $selectedDate,
                    currentSnapshot: $currentSnapshot,
                    isLoadingSnapshot: $isLoadingSnapshot
                )
            }
            .tabItem {
                Label("Tamagotchi", systemImage: "gamecontroller.fill")
            }
            
            // Detail/Stats Tab
            NavigationView {
                DetailsView(healthManager: healthManager, selectedDate: $selectedDate)
            }
            .tabItem {
                Label("Details", systemImage: "list.bullet.rectangle")
            }
        }
        // Set the active tab item color to white
        .accentColor(.white)
        .environment(\.colorScheme, .dark)
        // Apply our custom tab bar appearance
        .onAppear {
            healthManager.requestAuthorization()
            loadSnapshot(for: selectedDate)
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            healthManager.fetchAllHealthData(for: newValue)
            loadSnapshot(for: newValue)
        }
    }
    
    private func loadSnapshot(for date: Date) {
        isLoadingSnapshot = true
        Task {
            do {
                let snapshot = try await healthManager.fetchSnapshot(for: date)
                await MainActor.run {
                    self.currentSnapshot = snapshot
                    self.isLoadingSnapshot = false
                }
            } catch {
                await MainActor.run {
                    self.currentSnapshot = nil
                    self.isLoadingSnapshot = false
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

import XCTest

final class HealthSnapshotEvaluatorTests: XCTestCase {
    func testKnockedOutSleepy() {
        let s = HealthSnapshot(totalSleep: 5.5, deepSleep: 0.3, steps: 5000, distanceKm: 2, activeEnergyKcal: 200, restingHR: 70)
        XCTAssertEqual(evaluate(s), .knockedOutSleepy)
    }
    func testGroggySloth() {
        let s = HealthSnapshot(totalSleep: 6.5, deepSleep: 0.5, steps: 2000, distanceKm: 1, activeEnergyKcal: 100, restingHR: 70)
        XCTAssertEqual(evaluate(s), .groggySloth)
    }
    func testLazyButRestedPanda() {
        let s = HealthSnapshot(totalSleep: 7.5, deepSleep: 0.6, steps: 1000, distanceKm: 0.8, activeEnergyKcal: 80, restingHR: 65)
        XCTAssertEqual(evaluate(s), .lazyButRestedPanda)
    }
    func testWiredStressedChinchilla() {
        let s = HealthSnapshot(totalSleep: 7, deepSleep: 0.5, steps: 1000, distanceKm: 1, activeEnergyKcal: 100, restingHR: 95)
        XCTAssertEqual(evaluate(s), .wiredStressedChinchilla)
    }
    func testBalancedKoala() {
        let s = HealthSnapshot(totalSleep: 8, deepSleep: 0.7, steps: 5000, distanceKm: 4, activeEnergyKcal: 350, restingHR: 70)
        XCTAssertEqual(evaluate(s), .balancedKoala)
    }
    func testEnergizedRedPanda() {
        let s = HealthSnapshot(totalSleep: 7.5, deepSleep: 0.7, steps: 12000, distanceKm: 9, activeEnergyKcal: 400, restingHR: 70)
        XCTAssertEqual(evaluate(s), .energizedRedPanda)
    }
    func testOvertrainedHusky() {
        let s = HealthSnapshot(totalSleep: 5.5, deepSleep: 0.3, steps: 16000, distanceKm: 12, activeEnergyKcal: 500, restingHR: 70)
        XCTAssertEqual(evaluate(s), .overtrainedHusky)
    }
    func testZenNinjaFox() {
        let s = HealthSnapshot(totalSleep: 8, deepSleep: 0.7, steps: 6000, distanceKm: 5, activeEnergyKcal: 350, restingHR: 55)
        XCTAssertEqual(evaluate(s), .zenNinjaFox)
    }
} 
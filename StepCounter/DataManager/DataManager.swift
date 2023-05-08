import SwiftUI
import HealthKit
import Foundation

/// Main data manager for the app
class DataManager: NSObject, ObservableObject {
    
    /// Dynamic properties that the UI will react to
    @Published var fullScreen: FullScreenMode?
    @Published var todaySteps: String = "- - -"
    @Published var caloriesCount: String = "- -"
    @Published var walkRunDistance: String = "- -"
    @Published var showGoalSetupView: Bool = false
    @Published var hourlyStepsData: [Date: Double] = [Date: Double]()
    @Published var performance: [String: Double] = [String: Double]()
    @Published var dailyAverage: String = "- -"
    @Published var thisMonthTotal: String = "- -"
    
    /// Dynamic properties that the UI will react to AND store values in UserDefaults
    @AppStorage("dailyGoal") var dailyGoal: String = ""
    @AppStorage("monthlyGoal") var monthlyGoal: String = "100000"
    @AppStorage(AppConfig.premiumVersion) var isPremiumUser: Bool = false {
        didSet { Interstitial.shared.isPremiumUser = isPremiumUser }
    }
    
    /// Internal properties
    internal let healthStore = HKHealthStore()
    internal var didShowTodayConfetti: Bool = false
    
    /// Completion rate
    var completionRate: Double {
        guard let today = todaySteps.double, let daily = dailyGoal.double else { return 0.0 }
        return today <= daily ? (((today * 100.0) / daily) / 100.0) : 1.0
    }
    
    /// Calendar days
    var calendarDays: [Date] {
        var days = [Date]()
        for index in 0..<7 {
            let date = Calendar(identifier: .gregorian).date(byAdding: .day, value: -index, to: Date())!
            days.append(date)
        }
        days.removeLast()
        days.insert(Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: Date())!, at: 0)
        return days.reversed()
    }
    
    /// Check if the user completed today's goal
    var didCompleteGoal: Bool {
        if fullScreen == nil, !didShowTodayConfetti, isPremiumUser {
            guard let daily = dailyGoal.double, let steps = todaySteps.double else { return false }
            return steps >= daily
        }
        return false
    }
    
    /// Get badge achievement status
    func didEarnBadge(type: DailyAchievementType) -> Bool {
        UserDefaults.standard.bool(forKey: type.rawValue)
    }
}

// MARK: - Fetch steps data
extension DataManager {
    
    /// Get all the steps for today
    func fetchTodaySteps() {
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        else { return }
        let authorizationType: Set = [steps, calories, distance]
        healthStore.requestAuthorization(toShare: nil, read: authorizationType) { granted, error in
            guard granted else {
                presentAlert(title: "Oops!", message: error?.localizedDescription ?? "Health data permissions required")
                return
            }
            let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                guard let quantity = result?.sumQuantity() else { return }
                DispatchQueue.main.async {
                    self.fetchHourlySteps()
                    self.fetchWalkingRunningDistance()
                    self.fetchActiveEnergyBurned()
                    self.todaySteps = quantity.doubleValue(for: .count()).formatted
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    /// Get hourly steps count for today
    private func fetchHourlySteps() {
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        var interval = DateComponents()
        interval.hour = 1
        let query = HKStatisticsCollectionQuery.init(quantityType: steps, quantitySamplePredicate: nil, options: .cumulativeSum,
                                                     anchorDate: .startOfDay, intervalComponents: interval)
        query.initialResultsHandler = { query, results, error in
            var hourlyData: [Date: Double] = [Date: Double]()
            results?.enumerateStatistics(from: .startOfDay, to: Date(), with: { result, stop in
                hourlyData[result.startDate] = result.sumQuantity()?.doubleValue(for: .count()) ?? 0.0
            })
            DispatchQueue.main.async {
                self.hourlyStepsData = hourlyData
            }
        }
        healthStore.execute(query)
    }
    
    /// Get calories burned
    private func fetchActiveEnergyBurned() {
        guard let calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let quantity = result?.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.caloriesCount = quantity.doubleValue(for: .kilocalorie()).formatted
            }
        }
        self.healthStore.execute(query)
    }
    
    /// Get walking/running distance
    private func fetchWalkingRunningDistance() {
        guard let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let quantity = result?.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.walkRunDistance = quantity.doubleValue(for: .mile()).formatted
            }
        }
        self.healthStore.execute(query)
    }
}

// MARK: - Fetch fun stats data
extension DataManager {
    
    /// Fetch fun stats data
    func fetchFunStatsData() {
        fetchSteps(startDate: .sevenDaysAgo) { data in
            DispatchQueue.main.async {
                data.forEach { date, value in
                    self.performance[date.longFormat] = value
                    var achievements: [DailyAchievementType] = [DailyAchievementType]()
                    
                    /// Update the badge if needed
                    switch value {
                    case 3001...6000: achievements = [.beginner]
                    case 6001...10000: achievements = [.beginner, .wellDone]
                    case 10001...20000: achievements = [.beginner, .wellDone, .greatJob]
                    case 20001...40000: achievements = [.beginner, .wellDone, .greatJob, .awesome]
                    case 40001...80000: achievements = [.beginner, .wellDone, .greatJob, .awesome, .unstoppable]
                    case 80001...: achievements = DailyAchievementType.allCases
                    default: break
                    }
                    
                    achievements.forEach { UserDefaults.standard.set(true, forKey: $0.rawValue) }
                    UserDefaults.standard.synchronize()
                }
                
                /// Update the daily average value
                if self.performance.count > 0 {
                    let daysWithSteps = self.performance.filter({ $0.value > 0.0 })
                    let daysWithStepsCount = Double(daysWithSteps.count)
                    self.dailyAverage = daysWithStepsCount > 0.0 ? (daysWithSteps.compactMap({ $0.value }).reduce(0, +) / daysWithStepsCount).formatted : "- -"
                }
            }
        }
        fetchCurrentMonthStepsCount()
    }
    
    /// Fetch total steps for this month so far
    private func fetchCurrentMonthStepsCount() {
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfMonth, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let quantity = result?.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.thisMonthTotal = quantity.doubleValue(for: .count()).formatted
            }
        }
        healthStore.execute(query)
    }
    
    /// Fetch steps with a given start date
    private func fetchSteps(startDate: Date, completion: @escaping (_ data: [Date: Double]) -> Void) {
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        anchorComponents.hour = 0
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let anchorDate = Calendar.current.date(from: anchorComponents)
        else { return }
        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery.init(quantityType: steps, quantitySamplePredicate: nil, options: .cumulativeSum,
                                                     anchorDate: anchorDate, intervalComponents: interval)
        query.initialResultsHandler = { query, results, error in
            var dailyData: [Date: Double] = [Date: Double]()
            results?.enumerateStatistics(from: startDate, to: Date(), with: { result, stop in
                dailyData[result.startDate] = result.sumQuantity()?.doubleValue(for: .count()) ?? 0.0
            })
            completion(dailyData)
        }
        healthStore.execute(query)
    }
}


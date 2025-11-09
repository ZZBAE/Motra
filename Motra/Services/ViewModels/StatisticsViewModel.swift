//
//  StatisticsViewModel.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/10/25.
//

import SwiftUI

class StatisticsViewModel: ObservableObject {
    @Published var statistics: Statistics?
    @Published var chartData: [ChartData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: StatisticsRepository
    
    init(repository: StatisticsRepository = CoreDataStatisticsRepository()) {
        self.repository = repository
        Task {
            await calculateStatistics(for: .weekly)
        }
    }
    
    // MARK: - 통계 계산
    @MainActor
    func calculateStatistics(for period: PeriodStatistics.TimePeriod) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let stats = try await repository.getStatistics(for: period)
            let chart = try await repository.getChartData(for: period)
            
            self.statistics = stats
            self.chartData = chart
        } catch {
            errorMessage = "통계 계산 실패: \(error.localizedDescription)"
            self.statistics = nil
            self.chartData = []
        }
        
        isLoading = false
    }
    
    // MARK: - 계산된 통계값들
    var totalDistance: Double {
        statistics?.totalDistance ?? 0
    }
    
    var totalDistanceFormatted: String {
        statistics?.totalDistanceInKm ?? "0.00"
    }
    
    var totalTime: TimeInterval {
        statistics?.totalTime ?? 0
    }
    
    var totalTimeFormatted: String {
        statistics?.totalTimeFormatted ?? "0분"
    }
    
    var totalCalories: Double {
        statistics?.totalCalories ?? 0
    }
    
    var totalCaloriesFormatted: String {
        statistics?.totalCaloriesFormatted ?? "0 kcal"
    }
    
    var workoutCount: Int {
        statistics?.workoutCount ?? 0
    }
    
    var averageDistance: Double {
        statistics?.averageDistance ?? 0
    }
    
    var averageDistanceFormatted: String {
        statistics?.averageDistanceInKm ?? "0.00"
    }
    
    var averagePace: Double {
        statistics?.averagePace ?? 0
    }
    
    var averagePaceFormatted: String {
        statistics?.averagePaceFormatted ?? "--:--"
    }
    
    var workoutsByType: [String: Int] {
        statistics?.workoutsByType ?? [:]
    }
}

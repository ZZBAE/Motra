//
//  Statistics.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/10/25.
//

import Foundation

// MARK: - 기간별 통계
struct Statistics {
    let totalDistance: Double      // 미터
    let totalTime: TimeInterval    // 초
    let totalCalories: Double
    let workoutCount: Int
    let averageDistance: Double    // 미터
    let averagePace: Double        // 초/km
    let workoutsByType: [String: Int]  // 운동 타입별 횟수
    
    var totalDistanceInKm: String {
        String(format: "%.2f", totalDistance / 1000.0)
    }
    
    var totalTimeFormatted: String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d시간 %d분", hours, minutes)
        } else {
            return String(format: "%d분", minutes)
        }
    }
    
    var totalCaloriesFormatted: String {
        String(format: "%.0f kcal", totalCalories)
    }
    
    var averageDistanceInKm: String {
        String(format: "%.2f", averageDistance / 1000.0)
    }
    
    var averagePaceFormatted: String {
        guard averagePace > 0 else { return "--:--" }
        let minutes = Int(averagePace / 60)
        let seconds = Int(averagePace.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - 차트 데이터
struct ChartData {
    let label: String
    let value: Double
    
    init(label: String, value: Double) {
        self.label = label
        self.value = value
    }
}

// MARK: - 기간별 통계 데이터
struct PeriodStatistics {
    let period: TimePeriod
    let statistics: Statistics
    let chartData: [ChartData]
    
    enum TimePeriod {
        case weekly
        case monthly
        case yearly
        
        var displayName: String {
            switch self {
            case .weekly: return "주간"
            case .monthly: return "월간"
            case .yearly: return "연간"
            }
        }
    }
}

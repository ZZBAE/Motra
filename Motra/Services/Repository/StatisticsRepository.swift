//
//  StatisticsRepository.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/10/25.
//

import Foundation

protocol StatisticsRepository {
    func getStatistics(for period: PeriodStatistics.TimePeriod) async throws -> Statistics
    func getChartData(for period: PeriodStatistics.TimePeriod) async throws -> [ChartData]
}

class CoreDataStatisticsRepository: StatisticsRepository {
    private let exerciseRepository: ExerciseRepository
    
    init(exerciseRepository: ExerciseRepository = CoreDataExerciseRepository()) {
        self.exerciseRepository = exerciseRepository
    }
    
    func getStatistics(for period: PeriodStatistics.TimePeriod) async throws -> Statistics {
        let exercises = try await exerciseRepository.fetchExercises()
        let filtered = filterExercises(exercises, for: period)
        
        let totalDistance = filtered.reduce(0) { $0 + $1.distance }
        let totalTime = filtered.reduce(0) { $0 + $1.duration }
        let totalCalories = filtered.reduce(0) { $0 + $1.calories }
        let workoutCount = filtered.count
        let averageDistance = workoutCount > 0 ? totalDistance / Double(workoutCount) : 0
        let averagePace = filtered.reduce(0) { $0 + $1.pace } / Double(max(workoutCount, 1))
        
        var workoutsByType: [String: Int] = [:]
        for exercise in filtered {
            workoutsByType[exercise.exerciseType, default: 0] += 1
        }
        
        return Statistics(
            totalDistance: totalDistance,
            totalTime: totalTime,
            totalCalories: totalCalories,
            workoutCount: workoutCount,
            averageDistance: averageDistance,
            averagePace: averagePace,
            workoutsByType: workoutsByType
        )
    }
    
    func getChartData(for period: PeriodStatistics.TimePeriod) async throws -> [ChartData] {
        let exercises = try await exerciseRepository.fetchExercises()
        let filtered = filterExercises(exercises, for: period)
        
        var dataByDate: [String: Double] = [:]
        let formatter = DateFormatter()
        
        for exercise in filtered {
            let dateKey: String
            switch period {
            case .weekly:
                formatter.dateFormat = "M/d"
                dateKey = formatter.string(from: exercise.startDate)
                
            case .monthly:
                formatter.dateFormat = "d일"
                dateKey = formatter.string(from: exercise.startDate)
                
            case .yearly:
                formatter.dateFormat = "M월"
                dateKey = formatter.string(from: exercise.startDate)
            }
            
            dataByDate[dateKey, default: 0] += exercise.distance
        }
        
        return dataByDate
            .sorted { $0.key < $1.key }
            .map { ChartData(label: $0.key, value: $0.value) }
    }
    
    private func filterExercises(_ exercises: [Exercise], for period: PeriodStatistics.TimePeriod) -> [Exercise] {
        let now = Date()
        let calendar = Calendar.current
        
        return exercises.filter { exercise in
            switch period {
            case .weekly:
                let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                return exercise.startDate >= sevenDaysAgo && exercise.startDate <= now
                
            case .monthly:
                let components = calendar.dateComponents([.month, .year], from: now)
                let startOfMonth = calendar.date(from: components)!
                let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
                return exercise.startDate >= startOfMonth && exercise.startDate < startOfNextMonth
                
            case .yearly:
                let components = calendar.dateComponents([.year], from: now)
                let startOfYear = calendar.date(from: components)!
                let startOfNextYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
                return exercise.startDate >= startOfYear && exercise.startDate < startOfNextYear
            }
        }
    }
}

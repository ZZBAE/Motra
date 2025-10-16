//
//  WorkoutSaveHelper.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/16/25.
//

import Foundation

class WorkoutSaveHelper {
    static func saveWorkout(
        type: WorkoutType,
        locationManager: LocationManager,
        notes: String? = nil
    ) {
        let coreDataManager = CoreDataManager.shared
        
        // 기본 정보
        let duration = locationManager.stats.elapsedTime
        let distance = locationManager.stats.currentDistance / 1000.0 // 미터를 킬로미터로 변환
        let calories = locationManager.stats.calories
        let pace = distance > 0 ? duration / distance : 0
        
        // ExerciseSession 생성
        let session = coreDataManager.createExerciseSession(
            exerciseType: type.rawValue,
            duration: duration,
            distance: distance,
            calories: calories,
            pace: pace,
            startDate: Date(timeIntervalSinceNow: -duration),
            endDate: Date(),
            notes: notes ?? "운동을 완료했습니다"
        )
        
        // 경로 데이터 저장
        for point in locationManager.route {
            _ = coreDataManager.addDataPoint(
                to: session,
                latitude: point.latitude,
                longitude: point.longitude,
                altitude: point.altitude,
                speed: point.speed >= 0 ? point.speed : 0,
                timestamp: point.timestamp
            )
        }
        
        print("✅ 운동 데이터 저장 완료: \(type.rawValue), \(String(format: "%.2f", distance))km, \(String(format: "%.0f", duration))초")
    }
}

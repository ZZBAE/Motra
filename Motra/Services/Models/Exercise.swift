//
//  Exercise.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/10/25.
//

import Foundation
import CoreLocation

// MARK: - 운동 타입
enum WorkoutType: String, Codable, CaseIterable {
    case running = "러닝"
    case cycling = "사이클"
    case walking = "워킹"
    case hiking = "등산"
    
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .walking: return "figure.walk"
        case .hiking: return "figure.hiking"
        }
    }
}

// MARK: - 경로 포인트
struct RoutePoint: Codable, Identifiable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let timestamp: Date
    let speed: Double
    
    init(location: CLLocation) {
        self.id = UUID()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.timestamp = location.timestamp
        self.speed = location.speed
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - 운동 데이터 (Repository에서 사용)
struct Exercise: Identifiable, Codable {
    let id: UUID
    let exerciseType: String
    let startDate: Date
    let endDate: Date?
    let duration: Double // 초
    let distance: Double // 미터
    let calories: Double
    let pace: Double // 초/km
    let notes: String?
    
    // Core Data에서 변환
    init(session: ExerciseSession) {
        self.id = session.id ?? UUID()
        self.exerciseType = session.exerciseType ?? "운동"
        self.startDate = session.startDate ?? Date()
        self.endDate = session.endDate
        self.duration = session.duration
        self.distance = session.distance
        self.calories = session.calories
        self.pace = session.pace
        self.notes = session.notes
    }
    
    // 직접 생성
    init(
        id: UUID = UUID(),
        exerciseType: String,
        startDate: Date,
        endDate: Date? = nil,
        duration: Double,
        distance: Double,
        calories: Double,
        pace: Double,
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseType = exerciseType
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.distance = distance
        self.calories = calories
        self.pace = pace
        self.notes = notes
    }
    
    // 계산 프로퍼티들
    var distanceInKm: String {
        String(format: "%.2f", distance / 1000.0)
    }
    
    var paceFormatted: String {
        guard pace > 0 else { return "--:--" }
        let minutes = Int(pace / 60)
        let seconds = Int(pace.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - 운동 세션 (실시간 추적용)
struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let type: WorkoutType
    let startDate: Date
    var endDate: Date?
    var route: [RoutePoint]
    var distance: Double // 미터
    var duration: TimeInterval // 초
    var calories: Double
    var averageSpeed: Double // m/s
    var averagePace: Double // 초/km
    
    init(type: WorkoutType) {
        self.id = UUID()
        self.type = type
        self.startDate = Date()
        self.endDate = nil
        self.route = []
        self.distance = 0
        self.duration = 0
        self.calories = 0
        self.averageSpeed = 0
        self.averagePace = 0
    }
    
    var distanceInKm: Double {
        distance / 1000.0
    }
    
    var paceFormatted: String {
        guard averagePace > 0 else { return "--:--" }
        let minutes = Int(averagePace / 60)
        let seconds = Int(averagePace.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - 실시간 통계 (RecordingView에서 사용)
struct WorkoutStats {
    var currentDistance: Double = 0 // 미터
    var currentSpeed: Double = 0 // m/s
    var currentPace: Double = 0 // 초/km
    var elapsedTime: TimeInterval = 0
    var calories: Double = 0
    
    var distanceInKm: String {
        String(format: "%.2f", currentDistance / 1000.0)
    }
    
    var speedInKmh: String {
        String(format: "%.1f", currentSpeed * 3.6)
    }
    
    var paceFormatted: String {
        guard currentPace > 0 else { return "--:--" }
        let minutes = Int(currentPace / 60)
        let seconds = Int(currentPace.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var timeFormatted: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

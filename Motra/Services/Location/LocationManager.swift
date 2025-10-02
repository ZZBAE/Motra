//
//  LocationManager.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isTracking = false
    @Published var route: [RoutePoint] = []
    @Published var stats = WorkoutStats()
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var startTime: Date?
    private var timer: Timer?
    private var lastLocation: CLLocation?
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10미터마다 업데이트
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    /// 위치 권한 요청
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 추적 시작
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        
        isTracking = true
        startTime = Date()
        route.removeAll()
        stats = WorkoutStats()
        lastLocation = nil
        
        locationManager.startUpdatingLocation()
        startTimer()
    }
    
    /// 추적 중지
    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        stopTimer()
    }
    
    /// 추적 일시정지
    func pauseTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        stopTimer()
    }
    
    /// 추적 재개
    func resumeTracking() {
        isTracking = true
        locationManager.startUpdatingLocation()
        startTimer()
    }
    
    /// 현재 세션 데이터 가져오기
    func getCurrentSession(type: WorkoutType) -> WorkoutSession {
        var session = WorkoutSession(type: type)
        session.route = route
        session.distance = stats.currentDistance
        session.duration = stats.elapsedTime
        session.calories = stats.calories
        session.averageSpeed = stats.currentSpeed
        session.averagePace = stats.currentPace
        session.endDate = Date()
        return session
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.stats.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func calculateDistance(from: CLLocation, to: CLLocation) -> Double {
        return from.distance(from: to)
    }
    
    private func calculatePace(distance: Double, time: TimeInterval) -> Double {
        guard distance > 0 else { return 0 }
        // 초/km 계산
        let distanceInKm = distance / 1000.0
        return time / distanceInKm
    }
    
    private func calculateCalories(distance: Double, weight: Double = 70.0) -> Double {
        // 간단한 칼로리 계산 (체중 70kg 기준)
        // 러닝: 약 1 kcal/kg/km
        let distanceInKm = distance / 1000.0
        return distanceInKm * weight
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        
        // 추적 중일 때만 경로 기록
        guard isTracking else { return }
        
        // 경로에 포인트 추가
        let point = RoutePoint(location: location)
        route.append(point)
        
        // 거리 계산
        if let lastLocation = lastLocation {
            let distance = calculateDistance(from: lastLocation, to: location)
            stats.currentDistance += distance
        }
        
        // 속도 및 페이스 계산
        if location.speed >= 0 {
            stats.currentSpeed = location.speed
        }
        
        if stats.elapsedTime > 0 {
            stats.currentPace = calculatePace(
                distance: stats.currentDistance,
                time: stats.elapsedTime
            )
        }
        
        // 칼로리 계산
        stats.calories = calculateCalories(distance: stats.currentDistance)
        
        lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
    }
}

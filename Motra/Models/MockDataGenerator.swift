//
//  MockDataGenerator.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/16/25.
//

import Foundation
import CoreData

class MockDataGenerator {
    static func generateMockData() {
        let manager = CoreDataManager.shared
        
        // 기존 데이터 삭제
        let fetchRequest: NSFetchRequest<ExerciseSession> = ExerciseSession.fetchRequest()
        do {
            let sessions = try manager.context.fetch(fetchRequest)
            sessions.forEach { manager.context.delete($0) }
            try manager.context.save()
        } catch {
            print("기존 데이터 삭제 실패: \(error)")
        }
        
        // 샘플 데이터 1: 달리기 (어제)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let session1 = manager.createExerciseSession(
            exerciseType: "러닝",
            duration: 1800, // 30분
            distance: 5.2,
            calories: 450,
            pace: 5.76,
            startDate: yesterday,
            endDate: Calendar.current.date(byAdding: .second, value: 1800, to: yesterday),
            notes: "공원에서 편한 페이스로 달렸어요"
        )
        
        // session1에 경로 데이터 추가
        addMockDataPoints(to: session1, startDate: yesterday)
        
        // 샘플 데이터 2: 사이클링 (2일 전)
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let session2 = manager.createExerciseSession(
            exerciseType: "사이클링",
            duration: 2700, // 45분
            distance: 18.5,
            calories: 620,
            pace: 2.96,
            startDate: twoDaysAgo,
            endDate: Calendar.current.date(byAdding: .second, value: 2700, to: twoDaysAgo),
            notes: "해안도로 사이클링"
        )
        
        addMockDataPoints(to: session2, startDate: twoDaysAgo)
        
        // 샘플 데이터 3: 조깅 (3일 전)
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let session3 = manager.createExerciseSession(
            exerciseType: "조깅",
            duration: 1200, // 20분
            distance: 3.0,
            calories: 280,
            pace: 6.67,
            startDate: threeDaysAgo,
            endDate: Calendar.current.date(byAdding: .second, value: 1200, to: threeDaysAgo),
            notes: "가벼운 조깅"
        )
        
        addMockDataPoints(to: session3, startDate: threeDaysAgo)
        
        print("✅ 샘플 데이터 생성 완료")
    }
    
    private static func addMockDataPoints(to session: ExerciseSession, startDate: Date) {
        let manager = CoreDataManager.shared
        
        // 서울 중심부 좌표 근처에서 임의의 경로 생성
        let baseLatitude = 37.5665
        let baseLongitude = 126.9780
        
        for i in 0..<10 {
            let timestamp = Calendar.current.date(byAdding: .second, value: i * 180, to: startDate) ?? startDate
            
            // 약간의 임의 변화를 주기 위해 작은 오프셋 추가
            let latOffset = Double.random(in: -0.01...0.01)
            let lonOffset = Double.random(in: -0.01...0.01)
            
            _ = manager.addDataPoint(
                to: session,
                latitude: baseLatitude + latOffset,
                longitude: baseLongitude + lonOffset,
                altitude: Double.random(in: 30...50),
                speed: Double.random(in: 3...8),
                timestamp: timestamp
            )
        }
    }
}

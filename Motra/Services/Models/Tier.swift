//
//  Tier.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/27/25.
//

import SwiftUI

// MARK: - 티어 등급
enum TierGrade: String, CaseIterable, Codable {
    case bronze = "브론즈"
    case silver = "실버"
    case gold = "골드"
    case platinum = "플래티넘"
    case diamond = "다이아"
    case redDiamond = "레드다이아"
    case master = "마스터"
    case grandMaster = "그랜드마스터"
    
    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.0, green: 0.8, blue: 0.8)
        case .diamond: return Color(red: 0.53, green: 0.81, blue: 0.98)
        case .redDiamond: return Color(red: 1.0, green: 0.2, blue: 0.4)
        case .master: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .grandMaster: return Color(red: 1.0, green: 0.5, blue: 0.0)
        }
    }
    
    var icon: String {
        switch self {
        case .bronze: return "shield.fill"
        case .silver: return "shield.fill"
        case .gold: return "shield.fill"
        case .platinum: return "diamond.fill"
        case .diamond: return "diamond.fill"
        case .redDiamond: return "diamond.fill"
        case .master: return "crown.fill"
        case .grandMaster: return "crown.fill"
        }
    }
}

// MARK: - 티어 Division (4 → 1)
enum TierDivision: Int, CaseIterable, Codable {
    case four = 4
    case three = 3
    case two = 2
    case one = 1
    
    var displayName: String {
        return "\(rawValue)"
    }
}

// MARK: - 티어 정보
struct Tier: Equatable, Codable {
    let grade: TierGrade
    let division: TierDivision
    
    var displayName: String {
        "\(grade.rawValue) \(division.displayName)"
    }
    
    var color: Color {
        grade.color
    }
    
    var icon: String {
        grade.icon
    }
}

// MARK: - 티어 진행 상황
struct TierProgress {
    let currentTier: Tier
    let nextTier: Tier?
    let currentDistance: Double      // 미터
    let tierStartDistance: Double    // 현재 티어 시작 거리 (미터)
    let tierEndDistance: Double      // 현재 티어 끝 거리 (미터)
    
    var progressPercentage: Double {
        let tierRange = tierEndDistance - tierStartDistance
        guard tierRange > 0 else { return 1.0 }
        let progress = (currentDistance - tierStartDistance) / tierRange
        return min(max(progress, 0), 1.0)
    }
    
    var remainingDistance: Double {
        max(tierEndDistance - currentDistance, 0)
    }
    
    var remainingDistanceInKm: String {
        String(format: "%.1f", remainingDistance / 1000)
    }
    
    var currentDistanceInKm: String {
        String(format: "%.1f", currentDistance / 1000)
    }
    
    var tierEndDistanceInKm: String {
        String(format: "%.0f", tierEndDistance / 1000)
    }
}

// MARK: - 티어 계산기
struct TierCalculator {
    
    // 티어별 거리 기준 (미터 단위)
    // 각 티어는 4개의 Division으로 나뉨
    private static let tierThresholds: [(grade: TierGrade, startKm: Double, endKm: Double)] = [
        (.bronze, 0, 50),
        (.silver, 50, 150),
        (.gold, 150, 350),
        (.platinum, 350, 700),
        (.diamond, 700, 1200),
        (.redDiamond, 1200, 2000),
        (.master, 2000, 3500),
        (.grandMaster, 3500, 10000)  // 그랜드마스터는 상한이 매우 높음
    ]
    
    /// 누적 거리로 티어 계산
    static func calculateTier(totalDistanceInMeters: Double) -> Tier {
        let distanceInKm = totalDistanceInMeters / 1000
        
        for threshold in tierThresholds {
            if distanceInKm >= threshold.startKm && distanceInKm < threshold.endKm {
                let division = calculateDivision(
                    distance: distanceInKm,
                    tierStart: threshold.startKm,
                    tierEnd: threshold.endKm
                )
                return Tier(grade: threshold.grade, division: division)
            }
        }
        
        // 최고 티어 도달
        return Tier(grade: .grandMaster, division: .one)
    }
    
    /// Division 계산 (4 → 3 → 2 → 1)
    private static func calculateDivision(distance: Double, tierStart: Double, tierEnd: Double) -> TierDivision {
        let tierRange = tierEnd - tierStart
        let progress = (distance - tierStart) / tierRange
        
        switch progress {
        case 0..<0.25: return .four
        case 0.25..<0.5: return .three
        case 0.5..<0.75: return .two
        default: return .one
        }
    }
    
    /// 티어 진행 상황 계산
    static func calculateProgress(totalDistanceInMeters: Double) -> TierProgress {
        let distanceInKm = totalDistanceInMeters / 1000
        let currentTier = calculateTier(totalDistanceInMeters: totalDistanceInMeters)
        
        // 현재 티어의 시작/끝 거리 찾기
        var tierStartKm: Double = 0
        var tierEndKm: Double = 0
        var nextTierGrade: TierGrade? = nil
        
        for (index, threshold) in tierThresholds.enumerated() {
            if threshold.grade == currentTier.grade {
                tierStartKm = threshold.startKm
                tierEndKm = threshold.endKm
                
                // 다음 티어 찾기
                if index + 1 < tierThresholds.count {
                    nextTierGrade = tierThresholds[index + 1].grade
                }
                break
            }
        }
        
        // Division에 따른 세부 범위 계산
        let divisionRange = (tierEndKm - tierStartKm) / 4
        let divisionIndex = 4 - currentTier.division.rawValue  // 4→0, 3→1, 2→2, 1→3
        
        let divisionStartKm = tierStartKm + (Double(divisionIndex) * divisionRange)
        let divisionEndKm = divisionStartKm + divisionRange
        
        // 다음 티어 결정
        let nextTier: Tier?
        if currentTier.division != .one {
            // 같은 등급의 다음 Division
            let nextDivision = TierDivision(rawValue: currentTier.division.rawValue - 1)!
            nextTier = Tier(grade: currentTier.grade, division: nextDivision)
        } else if let nextGrade = nextTierGrade {
            // 다음 등급의 Division 4
            nextTier = Tier(grade: nextGrade, division: .four)
        } else {
            // 최고 티어
            nextTier = nil
        }
        
        return TierProgress(
            currentTier: currentTier,
            nextTier: nextTier,
            currentDistance: totalDistanceInMeters,
            tierStartDistance: divisionStartKm * 1000,
            tierEndDistance: divisionEndKm * 1000
        )
    }
}

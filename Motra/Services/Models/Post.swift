//
//  Post.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/28/25.
//

import Foundation

// MARK: - 게시물
struct Post: Identifiable, Codable {
    let id: UUID
    let authorId: UUID
    var authorNickname: String  // var로 변경 - 프로필 변경 반영
    var authorUsername: String  // var로 변경 - 프로필 변경 반영
    var authorTier: TierData    // var - 현재 티어 반영
    let exerciseId: UUID?       // 연결된 운동 기록 (선택)
    let content: String
    let imageURL: String?
    let visibility: PostVisibility
    let createdAt: Date
    let updatedAt: Date
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    
    // 연결된 운동 요약 정보
    var exerciseSummary: ExerciseSummary?
    
    init(
        id: UUID = UUID(),
        authorId: UUID = UUID(),
        authorNickname: String,
        authorUsername: String,
        authorTier: TierData = TierData(grade: "브론즈", division: 4),
        exerciseId: UUID? = nil,
        content: String,
        imageURL: String? = nil,
        visibility: PostVisibility = .public,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        likeCount: Int = 0,
        commentCount: Int = 0,
        isLiked: Bool = false,
        exerciseSummary: ExerciseSummary? = nil
    ) {
        self.id = id
        self.authorId = authorId
        self.authorNickname = authorNickname
        self.authorUsername = authorUsername
        self.authorTier = authorTier
        self.exerciseId = exerciseId
        self.content = content
        self.imageURL = imageURL
        self.visibility = visibility
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
        self.exerciseSummary = exerciseSummary
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - 게시물 공개 범위
enum PostVisibility: String, Codable, CaseIterable {
    case `public` = "전체 공개"
    case followers = "팔로워 공개"
    case `private` = "나만 보기"
    
    var icon: String {
        switch self {
        case .public: return "globe"
        case .followers: return "person.2"
        case .private: return "lock"
        }
    }
}

// MARK: - 티어 데이터 (Codable용)
struct TierData: Codable, Equatable {
    let grade: String
    let division: Int
    
    init(grade: String, division: Int) {
        self.grade = grade
        self.division = division
    }
    
    init(from tier: Tier) {
        self.grade = tier.grade.rawValue
        self.division = tier.division.rawValue
    }
    
    var toTier: Tier {
        let tierGrade = TierGrade.allCases.first { $0.rawValue == grade } ?? .bronze
        let tierDivision = TierDivision(rawValue: division) ?? .four
        return Tier(grade: tierGrade, division: tierDivision)
    }
    
    var displayName: String {
        "\(grade) \(division)"
    }
}

// MARK: - 운동 요약 (게시물에 포함)
struct ExerciseSummary: Codable {
    let type: String
    let distance: Double  // 미터
    let duration: TimeInterval
    let calories: Double
    let date: Date
    
    init(from exercise: Exercise) {
        self.type = exercise.exerciseType
        self.distance = exercise.distance
        self.duration = exercise.duration
        self.calories = exercise.calories
        self.date = exercise.startDate
    }
    
    init(type: String, distance: Double, duration: TimeInterval, calories: Double, date: Date) {
        self.type = type
        self.distance = distance
        self.duration = duration
        self.calories = calories
        self.date = date
    }
    
    var distanceInKm: String {
        String(format: "%.2f", distance / 1000)
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d시간 %d분", hours, minutes)
        } else {
            return String(format: "%d분", minutes)
        }
    }
    
    var icon: String {
        switch type {
        case "러닝": return "figure.run"
        case "사이클": return "figure.outdoor.cycle"
        case "워킹": return "figure.walk"
        case "등산": return "figure.hiking"
        default: return "figure.run"
        }
    }
}

// MARK: - 댓글
struct Comment: Identifiable, Codable {
    let id: UUID
    let postId: UUID
    let authorId: UUID
    let authorNickname: String
    let authorUsername: String
    let authorTier: TierData
    let content: String
    let createdAt: Date
    var likeCount: Int
    var isLiked: Bool
    
    init(
        id: UUID = UUID(),
        postId: UUID,
        authorId: UUID = UUID(),
        authorNickname: String,
        authorUsername: String,
        authorTier: TierData = TierData(grade: "브론즈", division: 4),
        content: String,
        createdAt: Date = Date(),
        likeCount: Int = 0,
        isLiked: Bool = false
    ) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.authorNickname = authorNickname
        self.authorUsername = authorUsername
        self.authorTier = authorTier
        self.content = content
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.isLiked = isLiked
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - 좋아요
struct Like: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let targetType: LikeTargetType
    let targetId: UUID
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        targetType: LikeTargetType,
        targetId: UUID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.targetType = targetType
        self.targetId = targetId
        self.createdAt = createdAt
    }
}

enum LikeTargetType: String, Codable {
    case post
    case comment
}

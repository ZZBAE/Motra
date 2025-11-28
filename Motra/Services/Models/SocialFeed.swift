//
//  SocialFeed.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/27/25.
//

import Foundation

// MARK: - 소셜 피드 아이템
struct FeedItem: Identifiable {
    let id: UUID
    let user: FeedUser
    let workout: FeedWorkout
    let content: String?
    let createdAt: Date
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    
    init(
        id: UUID = UUID(),
        user: FeedUser,
        workout: FeedWorkout,
        content: String? = nil,
        createdAt: Date = Date(),
        likeCount: Int = 0,
        commentCount: Int = 0,
        isLiked: Bool = false
    ) {
        self.id = id
        self.user = user
        self.workout = workout
        self.content = content
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - 피드 유저
struct FeedUser: Identifiable {
    let id: UUID
    let nickname: String
    let profileImageURL: String?
    let tier: Tier
    
    init(
        id: UUID = UUID(),
        nickname: String,
        profileImageURL: String? = nil,
        tier: Tier = Tier(grade: .bronze, division: .four)
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.tier = tier
    }
}

// MARK: - 피드 운동 정보
struct FeedWorkout {
    let type: String
    let distance: Double      // 미터
    let duration: TimeInterval
    let calories: Double
    
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
        switch type.lowercased() {
        case "running", "러닝", "달리기":
            return "figure.run"
        case "cycling", "사이클링", "자전거":
            return "figure.outdoor.cycle"
        case "walking", "걷기":
            return "figure.walk"
        default:
            return "figure.mixed.cardio"
        }
    }
}

// MARK: - 댓글
struct FeedComment: Identifiable {
    let id: UUID
    let user: FeedUser
    let content: String
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        user: FeedUser,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.user = user
        self.content = content
        self.createdAt = createdAt
    }
}

// MARK: - Mock Data (서버 연동 전 테스트용)
extension FeedItem {
    static let mockItems: [FeedItem] = [
        FeedItem(
            user: FeedUser(
                nickname: "러너김철수",
                tier: Tier(grade: .gold, division: .two)
            ),
            workout: FeedWorkout(
                type: "러닝",
                distance: 10230,
                duration: 3600,
                calories: 650
            ),
            content: "오늘 10km 완주! 🔥 날씨가 좋아서 기분 최고",
            createdAt: Date().addingTimeInterval(-300),
            likeCount: 12,
            commentCount: 3
        ),
        FeedItem(
            user: FeedUser(
                nickname: "싸이클박영희",
                tier: Tier(grade: .platinum, division: .one)
            ),
            workout: FeedWorkout(
                type: "사이클링",
                distance: 35000,
                duration: 5400,
                calories: 890
            ),
            content: "한강 라이딩 완료 🚴 반포대교에서 잠실까지!",
            createdAt: Date().addingTimeInterval(-3600),
            likeCount: 8,
            commentCount: 1
        ),
        FeedItem(
            user: FeedUser(
                nickname: "마라토너이민수",
                tier: Tier(grade: .diamond, division: .three)
            ),
            workout: FeedWorkout(
                type: "러닝",
                distance: 21097,
                duration: 6900,
                calories: 1350
            ),
            content: "하프 마라톤 훈련 완료 💪",
            createdAt: Date().addingTimeInterval(-7200),
            likeCount: 24,
            commentCount: 7
        ),
        FeedItem(
            user: FeedUser(
                nickname: "걷기왕최수진",
                tier: Tier(grade: .silver, division: .one)
            ),
            workout: FeedWorkout(
                type: "걷기",
                distance: 8500,
                duration: 5400,
                calories: 320
            ),
            content: nil,
            createdAt: Date().addingTimeInterval(-14400),
            likeCount: 5,
            commentCount: 0
        )
    ]
}

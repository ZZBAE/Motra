//
//  UserProfile.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/28/25.
//

import Foundation

// MARK: - 유저 프로필
struct UserProfile: Codable {
    var id: UUID
    var nickname: String
    var username: String  // @username
    var bio: String?
    var profileImageURL: String?
    var tier: Tier
    var totalDistance: Double  // 미터
    var joinDate: Date
    var followerCount: Int
    var followingCount: Int
    var postCount: Int
    
    init(
        id: UUID = UUID(),
        nickname: String = "러너",
        username: String = "runner",
        bio: String? = nil,
        profileImageURL: String? = nil,
        tier: Tier = Tier(grade: .bronze, division: .four),
        totalDistance: Double = 0,
        joinDate: Date = Date(),
        followerCount: Int = 0,
        followingCount: Int = 0,
        postCount: Int = 0
    ) {
        self.id = id
        self.nickname = nickname
        self.username = username
        self.bio = bio
        self.profileImageURL = profileImageURL
        self.tier = tier
        self.totalDistance = totalDistance
        self.joinDate = joinDate
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.postCount = postCount
    }
    
    var joinDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: joinDate) + "부터 활동 중"
    }
    
    var totalDistanceInKm: String {
        String(format: "%.1f", totalDistance / 1000)
    }
}

// MARK: - 티어 히스토리 (성장 그래프용)
struct TierHistory: Identifiable {
    let id: UUID
    let tier: Tier
    let achievedAt: Date
    let totalDistance: Double  // 달성 시점의 총 거리
    
    init(
        id: UUID = UUID(),
        tier: Tier,
        achievedAt: Date,
        totalDistance: Double
    ) {
        self.id = id
        self.tier = tier
        self.achievedAt = achievedAt
        self.totalDistance = totalDistance
    }
    
    // 티어를 숫자로 변환 (그래프 Y축용)
    var tierLevel: Int {
        let gradeValue: Int
        switch tier.grade {
        case .bronze: gradeValue = 0
        case .silver: gradeValue = 4
        case .gold: gradeValue = 8
        case .platinum: gradeValue = 12
        case .diamond: gradeValue = 16
        case .redDiamond: gradeValue = 20
        case .master: gradeValue = 24
        case .grandMaster: gradeValue = 28
        }
        
        let divisionValue = 4 - tier.division.rawValue  // 4→0, 3→1, 2→2, 1→3
        return gradeValue + divisionValue
    }
}

// MARK: - 내 게시물
struct MyPost: Identifiable {
    let id: UUID
    let exercise: Exercise?
    let content: String
    let imageURL: String?
    let createdAt: Date
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    
    init(
        id: UUID = UUID(),
        exercise: Exercise? = nil,
        content: String,
        imageURL: String? = nil,
        createdAt: Date = Date(),
        likeCount: Int = 0,
        commentCount: Int = 0,
        isLiked: Bool = false
    ) {
        self.id = id
        self.exercise = exercise
        self.content = content
        self.imageURL = imageURL
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
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: createdAt)
    }
}

// MARK: - 팔로우 관계
struct Follow: Identifiable {
    let id: UUID
    let user: FeedUser
    let followedAt: Date
    var isFollowing: Bool
    
    init(
        id: UUID = UUID(),
        user: FeedUser,
        followedAt: Date = Date(),
        isFollowing: Bool = true
    ) {
        self.id = id
        self.user = user
        self.followedAt = followedAt
        self.isFollowing = isFollowing
    }
}

// MARK: - Mock Data
extension UserProfile {
    static let mock = UserProfile(
        nickname: "나",
        username: "me",
        bio: "매일 달리는 게 목표! 🏃‍♂️",
        tier: Tier(grade: .bronze, division: .four),
        totalDistance: 0,
        joinDate: Calendar.current.date(from: DateComponents(year: 2025, month: 1))!,
        followerCount: 0,
        followingCount: 0,
        postCount: 0
    )
}

extension TierHistory {
    static let mockHistory: [TierHistory] = [
        TierHistory(
            tier: Tier(grade: .bronze, division: .four),
            achievedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!,
            totalDistance: 0
        ),
        TierHistory(
            tier: Tier(grade: .bronze, division: .one),
            achievedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 20))!,
            totalDistance: 40000
        ),
        TierHistory(
            tier: Tier(grade: .silver, division: .three),
            achievedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 10))!,
            totalDistance: 75000
        ),
        TierHistory(
            tier: Tier(grade: .silver, division: .one),
            achievedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 5))!,
            totalDistance: 130000
        ),
        TierHistory(
            tier: Tier(grade: .gold, division: .three),
            achievedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 1))!,
            totalDistance: 200000
        ),
        TierHistory(
            tier: Tier(grade: .gold, division: .two),
            achievedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 15))!,
            totalDistance: 285000
        )
    ]
}

extension MyPost {
    static let mockPosts: [MyPost] = [
        MyPost(
            content: "오늘 10km 완주! 🔥 날씨가 좋아서 기분 최고",
            createdAt: Date().addingTimeInterval(-86400),
            likeCount: 12,
            commentCount: 3
        ),
        MyPost(
            content: "한강 라이딩 완료 🚴 반포대교에서 잠실까지!",
            createdAt: Date().addingTimeInterval(-172800),
            likeCount: 8,
            commentCount: 1
        ),
        MyPost(
            content: "드디어 골드 승급! 💪",
            createdAt: Date().addingTimeInterval(-432000),
            likeCount: 24,
            commentCount: 7
        )
    ]
}

extension Follow {
    static let mockFollowers: [Follow] = [
        Follow(user: FeedUser(nickname: "러너박영희", tier: Tier(grade: .platinum, division: .one))),
        Follow(user: FeedUser(nickname: "마라토너이민수", tier: Tier(grade: .diamond, division: .three))),
        Follow(user: FeedUser(nickname: "걷기왕최수진", tier: Tier(grade: .silver, division: .one)))
    ]
    
    static let mockFollowing: [Follow] = [
        Follow(user: FeedUser(nickname: "싸이클박영희", tier: Tier(grade: .platinum, division: .one))),
        Follow(user: FeedUser(nickname: "마라토너이민수", tier: Tier(grade: .diamond, division: .three)))
    ]
}

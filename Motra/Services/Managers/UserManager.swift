//
//  UserManager.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/10/25.
//

import SwiftUI
import Combine

/// 앱 전체에서 유저 정보를 관리하는 싱글톤 매니저
@MainActor
class UserManager: ObservableObject {
    static let shared = UserManager()
    
    // MARK: - Published Properties
    @Published var currentUser: UserProfile {
        didSet {
            saveToUserDefaults()
        }
    }
    
    // MARK: - Keys
    private let userDefaultsKey = "currentUserProfile"
    
    // MARK: - Init
    private init() {
        // UserDefaults에서 불러오기
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.currentUser = profile
        } else {
            // 기본값
            self.currentUser = UserProfile.mock
        }
    }
    
    // MARK: - Save to UserDefaults
    private func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(nickname: String? = nil, username: String? = nil, bio: String? = nil) {
        if let nickname = nickname {
            currentUser.nickname = nickname
        }
        if let username = username {
            currentUser.username = username
        }
        if let bio = bio {
            currentUser.bio = bio
        }
    }
    
    // MARK: - Update Tier
    func updateTier(_ tier: Tier, totalDistance: Double) {
        currentUser.tier = tier
        currentUser.totalDistance = totalDistance
    }
    
    // MARK: - Update Post Count
    func updatePostCount(_ count: Int) {
        currentUser.postCount = count
    }
    
    // MARK: - Update Follow Counts
    func updateFollowerCount(_ count: Int) {
        currentUser.followerCount = count
    }
    
    func updateFollowingCount(_ count: Int) {
        currentUser.followingCount = count
    }
}

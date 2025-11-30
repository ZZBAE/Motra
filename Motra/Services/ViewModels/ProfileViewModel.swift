//
//  ProfileViewModel.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/28/25.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var profile: UserProfile = UserProfile()
    @Published var tierHistory: [TierHistory] = []
    @Published var myPosts: [Post] = []
    @Published var likedPosts: [Post] = []
    @Published var followers: [Follow] = []
    @Published var following: [Follow] = []
    @Published var selectedTab: ProfileTab = .posts
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let exerciseRepository: ExerciseRepository
    private let postRepository: PostRepository
    
    // MARK: - Tab
    enum ProfileTab {
        case posts
        case liked
    }
    
    // MARK: - Init
    init(
        exerciseRepository: ExerciseRepository = CoreDataExerciseRepository(),
        postRepository: PostRepository = LocalPostRepository()
    ) {
        self.exerciseRepository = exerciseRepository
        self.postRepository = postRepository
        
        Task {
            await loadData()
        }
    }
    
    // MARK: - Load Data
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 운동 기록에서 총 거리 계산
            let exercises = try await exerciseRepository.fetchExercises()
            let totalDistance = exercises.reduce(0) { $0 + $1.distance }
            
            // 티어 계산
            let tier = TierCalculator.calculateTier(totalDistanceInMeters: totalDistance)
            
            // 프로필 업데이트
            profile.totalDistance = totalDistance
            profile.tier = tier
            
            // 프로필 기본 정보 (서버 연동 전)
            profile.nickname = UserProfile.mock.nickname
            profile.username = UserProfile.mock.username
            profile.bio = UserProfile.mock.bio
            profile.followerCount = UserProfile.mock.followerCount
            profile.followingCount = UserProfile.mock.followingCount
            
            // 티어 히스토리 생성
            tierHistory = generateTierHistory(from: exercises)
            
            // 내 게시물 로드 (PostRepository에서)
            let allPosts = try await postRepository.fetchPosts(limit: 100, offset: 0)
            
            // "나" 또는 현재 유저가 작성한 글 필터링 + 현재 티어 적용
            myPosts = allPosts
                .filter { $0.authorNickname == "나" || $0.authorUsername == "me" }
                .map { post in
                    var updatedPost = post
                    updatedPost.authorTier = TierData(
                        grade: tier.grade.rawValue,
                        division: tier.division.rawValue
                    )
                    return updatedPost
                }
            profile.postCount = myPosts.count
            
            // 좋아요한 글 (내 글에는 현재 티어 적용)
            likedPosts = allPosts
                .filter { $0.isLiked }
                .map { post in
                    if post.authorNickname == "나" || post.authorUsername == "me" {
                        var updatedPost = post
                        updatedPost.authorTier = TierData(
                            grade: tier.grade.rawValue,
                            division: tier.division.rawValue
                        )
                        return updatedPost
                    }
                    return post
                }
            
            // 팔로워/팔로잉 (Mock - 서버 연동 전)
            followers = Follow.mockFollowers
            following = Follow.mockFollowing
            
        } catch {
            errorMessage = "데이터 로드 실패: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Generate Tier History from Exercises
    private func generateTierHistory(from exercises: [Exercise]) -> [TierHistory] {
        guard !exercises.isEmpty else {
            return [TierHistory(
                tier: Tier(grade: .bronze, division: .four),
                achievedAt: Date(),
                totalDistance: 0
            )]
        }
        
        // 날짜순 정렬 (오래된 것부터)
        let sortedExercises = exercises.sorted { $0.startDate < $1.startDate }
        
        var history: [TierHistory] = []
        var cumulativeDistance: Double = 0
        var lastTier: Tier? = nil
        
        for exercise in sortedExercises {
            cumulativeDistance += exercise.distance
            let currentTier = TierCalculator.calculateTier(totalDistanceInMeters: cumulativeDistance)
            
            // 티어가 변경되었을 때만 히스토리에 추가
            if lastTier == nil || lastTier != currentTier {
                history.append(TierHistory(
                    tier: currentTier,
                    achievedAt: exercise.startDate,
                    totalDistance: cumulativeDistance
                ))
                lastTier = currentTier
            }
        }
        
        if history.isEmpty {
            history.append(TierHistory(
                tier: Tier(grade: .bronze, division: .four),
                achievedAt: sortedExercises.first?.startDate ?? Date(),
                totalDistance: 0
            ))
        }
        
        return history
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadData()
    }
    
    // MARK: - Actions
    func togglePostLike(_ post: Post) async {
        // myPosts에서 찾기
        if let index = myPosts.firstIndex(where: { $0.id == post.id }) {
            let wasLiked = myPosts[index].isLiked
            
            // Optimistic update
            myPosts[index].isLiked.toggle()
            myPosts[index].likeCount += myPosts[index].isLiked ? 1 : -1
            
            do {
                if wasLiked {
                    try await postRepository.unlikePost(post.id, userId: UUID())
                } else {
                    try await postRepository.likePost(post.id, userId: UUID())
                }
            } catch {
                // Rollback
                myPosts[index].isLiked = wasLiked
                myPosts[index].likeCount += wasLiked ? 1 : -1
            }
        }
        
        // likedPosts에서도 찾기
        if let index = likedPosts.firstIndex(where: { $0.id == post.id }) {
            let wasLiked = likedPosts[index].isLiked
            
            // Optimistic update
            likedPosts[index].isLiked.toggle()
            likedPosts[index].likeCount += likedPosts[index].isLiked ? 1 : -1
            
            do {
                if wasLiked {
                    try await postRepository.unlikePost(post.id, userId: UUID())
                } else {
                    try await postRepository.likePost(post.id, userId: UUID())
                }
            } catch {
                // Rollback
                likedPosts[index].isLiked = wasLiked
                likedPosts[index].likeCount += wasLiked ? 1 : -1
            }
        }
    }
    
    func toggleFollow(_ follow: Follow) {
        if let index = following.firstIndex(where: { $0.id == follow.id }) {
            following[index].isFollowing.toggle()
            
            if !following[index].isFollowing {
                profile.followingCount -= 1
            } else {
                profile.followingCount += 1
            }
        }
    }
}

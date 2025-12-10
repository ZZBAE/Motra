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
    @Published var profile: UserProfile
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
    private let userManager: UserManager
    
    // MARK: - Tab
    enum ProfileTab {
        case posts
        case liked
    }
    
    // MARK: - Init
    init(
        exerciseRepository: ExerciseRepository = CoreDataExerciseRepository(),
        postRepository: PostRepository = LocalPostRepository(),
        userManager: UserManager = .shared
    ) {
        self.exerciseRepository = exerciseRepository
        self.postRepository = postRepository
        self.userManager = userManager
        self.profile = userManager.currentUser
        
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
            
            // UserManager 업데이트
            userManager.updateTier(tier, totalDistance: totalDistance)
            
            // 프로필 동기화
            profile = userManager.currentUser
            
            // 티어 히스토리 생성
            tierHistory = generateTierHistory(from: exercises)
            
            // 내 게시물 로드 (PostRepository에서)
            let allPosts = try await postRepository.fetchPosts(limit: 100, offset: 0)
            
            // 현재 유저 정보
            let currentNickname = profile.nickname
            let currentUsername = profile.username
            
            // "나" 또는 현재 유저가 작성한 글 필터링 + 현재 티어/닉네임 적용
            myPosts = allPosts
                .filter { isMyPost($0) }
                .map { post in
                    var updatedPost = post
                    updatedPost.authorNickname = currentNickname
                    updatedPost.authorUsername = currentUsername
                    updatedPost.authorTier = TierData(
                        grade: tier.grade.rawValue,
                        division: tier.division.rawValue
                    )
                    return updatedPost
                }
            
            userManager.updatePostCount(myPosts.count)
            profile = userManager.currentUser
            
            // 좋아요한 글 (내 글에는 현재 정보 적용)
            likedPosts = allPosts
                .filter { $0.isLiked }
                .map { post in
                    if isMyPost(post) {
                        var updatedPost = post
                        updatedPost.authorNickname = currentNickname
                        updatedPost.authorUsername = currentUsername
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
    
    // MARK: - 내 게시물인지 확인
    private func isMyPost(_ post: Post) -> Bool {
        let currentUser = userManager.currentUser
        return post.authorNickname == currentUser.nickname ||
               post.authorUsername == currentUser.username ||
               post.authorNickname == "나" ||
               post.authorUsername == "me"
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
    
    // MARK: - Update Profile
    func updateProfile(nickname: String, username: String, bio: String?) async {
        // UserManager 업데이트
        userManager.updateProfile(nickname: nickname, username: username, bio: bio)
        
        // 로컬 프로필 동기화
        profile = userManager.currentUser
        
        // 내 게시물 작성자 정보 업데이트
        do {
            // 기존 게시물 가져와서 작성자 정보 업데이트
            let allPosts = try await postRepository.fetchPosts(limit: 100, offset: 0)
            
            for post in allPosts where isMyPost(post) {
                var updatedPost = post
                updatedPost.authorNickname = nickname
                updatedPost.authorUsername = username
                _ = try await postRepository.updatePost(updatedPost)
            }
            
            // 데이터 새로고침
            await loadData()
        } catch {
            errorMessage = "프로필 업데이트 실패: \(error.localizedDescription)"
        }
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
        
        // likedPosts에서 찾기
        if let index = likedPosts.firstIndex(where: { $0.id == post.id }) {
            let wasLiked = likedPosts[index].isLiked
            
            // Optimistic update - 좋아요 상태 토글
            likedPosts[index].isLiked.toggle()
            likedPosts[index].likeCount += likedPosts[index].isLiked ? 1 : -1
            
            do {
                if wasLiked {
                    try await postRepository.unlikePost(post.id, userId: UUID())
                    // 좋아요 취소 시 목록에서 즉시 제거
                    likedPosts.remove(at: index)
                } else {
                    try await postRepository.likePost(post.id, userId: UUID())
                }
            } catch {
                // Rollback
                if wasLiked {
                    // 삭제 실패 시 다시 추가
                    likedPosts.insert(post, at: index)
                }
                if let rollbackIndex = likedPosts.firstIndex(where: { $0.id == post.id }) {
                    likedPosts[rollbackIndex].isLiked = wasLiked
                    likedPosts[rollbackIndex].likeCount += wasLiked ? 1 : -1
                }
            }
        }
    }
    
    func toggleFollow(_ follow: Follow) {
        if let index = following.firstIndex(where: { $0.id == follow.id }) {
            following[index].isFollowing.toggle()
            
            if !following[index].isFollowing {
                userManager.updateFollowingCount(profile.followingCount - 1)
            } else {
                userManager.updateFollowingCount(profile.followingCount + 1)
            }
            profile = userManager.currentUser
        }
    }
}

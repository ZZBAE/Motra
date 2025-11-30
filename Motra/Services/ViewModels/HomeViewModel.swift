//
//  HomeViewModel.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/27/25.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tierProgress: TierProgress?
    @Published var recentExercise: Exercise?
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let exerciseRepository: ExerciseRepository
    private let postRepository: PostRepository
    
    // MARK: - Current User Tier
    private var currentUserTier: Tier?
    
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
            // 운동 기록 가져오기
            let exercises = try await exerciseRepository.fetchExercises()
            
            // 총 누적 거리 계산
            let totalDistance = exercises.reduce(0) { $0 + $1.distance }
            
            // 티어 계산
            tierProgress = TierCalculator.calculateProgress(totalDistanceInMeters: totalDistance)
            currentUserTier = TierCalculator.calculateTier(totalDistanceInMeters: totalDistance)
            
            // 최근 운동
            recentExercise = exercises.first
            
            // 소셜 피드 (PostRepository에서 가져오기)
            var fetchedPosts = try await postRepository.fetchPosts(limit: 3, offset: 0)
            
            // 내 글에는 현재 티어 적용
            fetchedPosts = applyCurrentTierToMyPosts(fetchedPosts)
            posts = fetchedPosts
            
        } catch {
            errorMessage = "데이터 로드 실패: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadData()
    }
    
    // MARK: - Social Actions
    func toggleLike(for post: Post) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        let wasLiked = posts[index].isLiked
        
        // Optimistic update
        posts[index].isLiked.toggle()
        posts[index].likeCount += posts[index].isLiked ? 1 : -1
        
        do {
            if wasLiked {
                try await postRepository.unlikePost(post.id, userId: UUID())
            } else {
                try await postRepository.likePost(post.id, userId: UUID())
            }
        } catch {
            // Rollback on error
            posts[index].isLiked = wasLiked
            posts[index].likeCount += wasLiked ? 1 : -1
        }
    }
    
    // MARK: - Private Helpers
    
    /// 내 글에 현재 티어 적용
    private func applyCurrentTierToMyPosts(_ posts: [Post]) -> [Post] {
        guard let tier = currentUserTier else { return posts }
        
        return posts.map { post in
            // 내 글인 경우 현재 티어로 업데이트
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
    }
}

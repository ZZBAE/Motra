//
//  FeedViewModel.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/28/25.
//

import SwiftUI

@MainActor
class FeedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMorePosts = true
    
    // MARK: - Dependencies
    private let postRepository: PostRepository
    private let exerciseRepository: ExerciseRepository
    
    // MARK: - Current User Tier
    private var currentUserTier: Tier?
    
    // MARK: - Pagination
    private var currentOffset = 0
    private let pageSize = 20
    
    // MARK: - Init
    init(
        postRepository: PostRepository = LocalPostRepository(),
        exerciseRepository: ExerciseRepository = CoreDataExerciseRepository()
    ) {
        self.postRepository = postRepository
        self.exerciseRepository = exerciseRepository
        
        Task {
            await loadPosts()
        }
    }
    
    // MARK: - Load Posts
    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        currentOffset = 0
        
        do {
            // 현재 유저 티어 계산
            await loadCurrentUserTier()
            
            var fetchedPosts = try await postRepository.fetchPosts(limit: pageSize, offset: 0)
            
            // 내 글에는 현재 티어 적용
            fetchedPosts = applyCurrentTierToMyPosts(fetchedPosts)
            
            posts = fetchedPosts
            hasMorePosts = fetchedPosts.count >= pageSize
            currentOffset = fetchedPosts.count
        } catch {
            errorMessage = "피드를 불러오는데 실패했습니다."
        }
        
        isLoading = false
    }
    
    // MARK: - Load More Posts
    func loadMorePosts() async {
        guard !isLoadingMore && hasMorePosts else { return }
        
        isLoadingMore = true
        
        do {
            var fetchedPosts = try await postRepository.fetchPosts(limit: pageSize, offset: currentOffset)
            
            // 내 글에는 현재 티어 적용
            fetchedPosts = applyCurrentTierToMyPosts(fetchedPosts)
            
            posts.append(contentsOf: fetchedPosts)
            hasMorePosts = fetchedPosts.count >= pageSize
            currentOffset += fetchedPosts.count
        } catch {
            // 에러 무시 (더 불러오기 실패)
        }
        
        isLoadingMore = false
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadPosts()
    }
    
    // MARK: - Toggle Like
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
    
    // MARK: - Delete Post
    func deletePost(_ post: Post) async {
        do {
            try await postRepository.deletePost(post)
            posts.removeAll { $0.id == post.id }
        } catch {
            errorMessage = "게시물 삭제에 실패했습니다."
        }
    }
    
    // MARK: - Private Helpers
    
    /// 현재 유저 티어 로드
    private func loadCurrentUserTier() async {
        do {
            let exercises = try await exerciseRepository.fetchExercises()
            let totalDistance = exercises.reduce(0) { $0 + $1.distance }
            currentUserTier = TierCalculator.calculateTier(totalDistanceInMeters: totalDistance)
        } catch {
            currentUserTier = Tier(grade: .bronze, division: .four)
        }
    }
    
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

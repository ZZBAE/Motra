//
//  PostRepository.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/28/25.
//

import Foundation

// MARK: - Post Repository Protocol
protocol PostRepository {
    // 게시물
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post]
    func fetchMyPosts(userId: UUID) async throws -> [Post]
    func fetchPost(by id: UUID) async throws -> Post?
    func createPost(_ post: Post) async throws -> Post
    func updatePost(_ post: Post) async throws -> Post
    func deletePost(_ post: Post) async throws
    
    // 좋아요
    func likePost(_ postId: UUID, userId: UUID) async throws
    func unlikePost(_ postId: UUID, userId: UUID) async throws
    func fetchLikedPosts(userId: UUID) async throws -> [Post]
    
    // 댓글
    func fetchComments(postId: UUID) async throws -> [Comment]
    func createComment(_ comment: Comment) async throws -> Comment
    func deleteComment(_ comment: Comment) async throws
}

// MARK: - Local Post Repository (UserDefaults + Memory)
class LocalPostRepository: PostRepository {
    
    private let userDefaultsKey = "motra_posts"
    private let commentsKey = "motra_comments"
    private let likesKey = "motra_likes"
    
    // 현재 유저 ID (실제로는 인증 시스템에서 가져와야 함)
    private let currentUserId = UUID()
    
    // MARK: - Posts
    
    func fetchPosts(limit: Int = 20, offset: Int = 0) async throws -> [Post] {
        var posts = loadPosts()
        
        // Mock 데이터 추가 (로컬에 데이터가 없을 때)
        if posts.isEmpty {
            posts = Post.mockFeedPosts
            savePosts(posts)
        }
        
        // 최신순 정렬
        posts.sort { $0.createdAt > $1.createdAt }
        
        // 페이지네이션
        let startIndex = min(offset, posts.count)
        let endIndex = min(offset + limit, posts.count)
        
        return Array(posts[startIndex..<endIndex])
    }
    
    func fetchMyPosts(userId: UUID) async throws -> [Post] {
        let posts = loadPosts()
        return posts
            .filter { $0.authorId == userId }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchPost(by id: UUID) async throws -> Post? {
        let posts = loadPosts()
        return posts.first { $0.id == id }
    }
    
    func createPost(_ post: Post) async throws -> Post {
        var posts = loadPosts()
        posts.insert(post, at: 0)
        savePosts(posts)
        return post
    }
    
    func updatePost(_ post: Post) async throws -> Post {
        var posts = loadPosts()
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = post
            savePosts(posts)
        }
        return post
    }
    
    func deletePost(_ post: Post) async throws {
        var posts = loadPosts()
        posts.removeAll { $0.id == post.id }
        savePosts(posts)
        
        // 관련 댓글도 삭제
        var comments = loadComments()
        comments.removeAll { $0.postId == post.id }
        saveComments(comments)
    }
    
    // MARK: - Likes
    
    func likePost(_ postId: UUID, userId: UUID) async throws {
        var posts = loadPosts()
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isLiked = true
            posts[index].likeCount += 1
            savePosts(posts)
        }
        
        // 좋아요 기록 저장
        var likes = loadLikes()
        let like = Like(userId: userId, targetType: .post, targetId: postId)
        likes.append(like)
        saveLikes(likes)
    }
    
    func unlikePost(_ postId: UUID, userId: UUID) async throws {
        var posts = loadPosts()
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isLiked = false
            posts[index].likeCount = max(0, posts[index].likeCount - 1)
            savePosts(posts)
        }
        
        // 좋아요 기록 삭제
        var likes = loadLikes()
        likes.removeAll { $0.userId == userId && $0.targetId == postId }
        saveLikes(likes)
    }
    
    func fetchLikedPosts(userId: UUID) async throws -> [Post] {
        let likes = loadLikes()
        let likedPostIds = likes
            .filter { $0.userId == userId && $0.targetType == .post }
            .map { $0.targetId }
        
        let posts = loadPosts()
        return posts
            .filter { likedPostIds.contains($0.id) }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - Comments
    
    func fetchComments(postId: UUID) async throws -> [Comment] {
        let comments = loadComments()
        return comments
            .filter { $0.postId == postId }
            .sorted { $0.createdAt < $1.createdAt }
    }
    
    func createComment(_ comment: Comment) async throws -> Comment {
        var comments = loadComments()
        comments.append(comment)
        saveComments(comments)
        
        // 게시물 댓글 수 업데이트
        var posts = loadPosts()
        if let index = posts.firstIndex(where: { $0.id == comment.postId }) {
            posts[index].commentCount += 1
            savePosts(posts)
        }
        
        return comment
    }
    
    func deleteComment(_ comment: Comment) async throws {
        var comments = loadComments()
        comments.removeAll { $0.id == comment.id }
        saveComments(comments)
        
        // 게시물 댓글 수 업데이트
        var posts = loadPosts()
        if let index = posts.firstIndex(where: { $0.id == comment.postId }) {
            posts[index].commentCount = max(0, posts[index].commentCount - 1)
            savePosts(posts)
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadPosts() -> [Post] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let posts = try? JSONDecoder().decode([Post].self, from: data) else {
            return []
        }
        return posts
    }
    
    private func savePosts(_ posts: [Post]) {
        if let data = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func loadComments() -> [Comment] {
        guard let data = UserDefaults.standard.data(forKey: commentsKey),
              let comments = try? JSONDecoder().decode([Comment].self, from: data) else {
            return []
        }
        return comments
    }
    
    private func saveComments(_ comments: [Comment]) {
        if let data = try? JSONEncoder().encode(comments) {
            UserDefaults.standard.set(data, forKey: commentsKey)
        }
    }
    
    private func loadLikes() -> [Like] {
        guard let data = UserDefaults.standard.data(forKey: likesKey),
              let likes = try? JSONDecoder().decode([Like].self, from: data) else {
            return []
        }
        return likes
    }
    
    private func saveLikes(_ likes: [Like]) {
        if let data = try? JSONEncoder().encode(likes) {
            UserDefaults.standard.set(data, forKey: likesKey)
        }
    }
}

// MARK: - API Post Repository (서버 연동용 - 추후 구현)
class APIPostRepository: PostRepository {
    
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post] {
        // TODO: API 호출 구현
        fatalError("API 구현 필요")
    }
    
    func fetchMyPosts(userId: UUID) async throws -> [Post] {
        fatalError("API 구현 필요")
    }
    
    func fetchPost(by id: UUID) async throws -> Post? {
        fatalError("API 구현 필요")
    }
    
    func createPost(_ post: Post) async throws -> Post {
        fatalError("API 구현 필요")
    }
    
    func updatePost(_ post: Post) async throws -> Post {
        fatalError("API 구현 필요")
    }
    
    func deletePost(_ post: Post) async throws {
        fatalError("API 구현 필요")
    }
    
    func likePost(_ postId: UUID, userId: UUID) async throws {
        fatalError("API 구현 필요")
    }
    
    func unlikePost(_ postId: UUID, userId: UUID) async throws {
        fatalError("API 구현 필요")
    }
    
    func fetchLikedPosts(userId: UUID) async throws -> [Post] {
        fatalError("API 구현 필요")
    }
    
    func fetchComments(postId: UUID) async throws -> [Comment] {
        fatalError("API 구현 필요")
    }
    
    func createComment(_ comment: Comment) async throws -> Comment {
        fatalError("API 구현 필요")
    }
    
    func deleteComment(_ comment: Comment) async throws {
        fatalError("API 구현 필요")
    }
}

// MARK: - Mock Data
extension Post {
    static let mockFeedPosts: [Post] = [
        Post(
            authorNickname: "러너김철수",
            authorUsername: "runner_kim",
            authorTier: TierData(grade: "골드", division: 2),
            content: "오늘 10km 완주! 🔥 날씨가 좋아서 기분 최고",
            createdAt: Date().addingTimeInterval(-300),
            likeCount: 12,
            commentCount: 3,
            exerciseSummary: ExerciseSummary(
                type: "러닝",
                distance: 10230,
                duration: 3600,
                calories: 650,
                date: Date().addingTimeInterval(-300)
            )
        ),
        Post(
            authorNickname: "싸이클박영희",
            authorUsername: "cycle_park",
            authorTier: TierData(grade: "플래티넘", division: 1),
            content: "한강 라이딩 완료 🚴 반포대교에서 잠실까지!",
            createdAt: Date().addingTimeInterval(-3600),
            likeCount: 8,
            commentCount: 1,
            exerciseSummary: ExerciseSummary(
                type: "사이클",
                distance: 35000,
                duration: 5400,
                calories: 890,
                date: Date().addingTimeInterval(-3600)
            )
        ),
        Post(
            authorNickname: "마라토너이민수",
            authorUsername: "marathon_lee",
            authorTier: TierData(grade: "다이아", division: 3),
            content: "하프 마라톤 훈련 완료 💪 목표는 서브 2!",
            createdAt: Date().addingTimeInterval(-7200),
            likeCount: 24,
            commentCount: 7,
            exerciseSummary: ExerciseSummary(
                type: "러닝",
                distance: 21097,
                duration: 6900,
                calories: 1350,
                date: Date().addingTimeInterval(-7200)
            )
        ),
        Post(
            authorNickname: "걷기왕최수진",
            authorUsername: "walking_choi",
            authorTier: TierData(grade: "실버", division: 1),
            content: "퇴근 후 산책 🌙 오늘도 만보 달성!",
            createdAt: Date().addingTimeInterval(-14400),
            likeCount: 5,
            commentCount: 0,
            exerciseSummary: ExerciseSummary(
                type: "워킹",
                distance: 8500,
                duration: 5400,
                calories: 320,
                date: Date().addingTimeInterval(-14400)
            )
        )
    ]
}

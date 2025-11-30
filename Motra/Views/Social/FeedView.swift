//
//  FeedView.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/28/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var showNewPost = false
    @State private var selectedPost: Post?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView()
                } else if viewModel.posts.isEmpty {
                    emptyFeedView
                } else {
                    feedList
                }
            }
            .navigationTitle("피드")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewPost = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView()
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post, onPostUpdated: { updatedPost in
                    // 업데이트된 게시물 반영
                    if let index = viewModel.posts.firstIndex(where: { $0.id == updatedPost.id }) {
                        viewModel.posts[index] = updatedPost
                    }
                }, onPostDeleted: { deletedPost in
                    viewModel.posts.removeAll { $0.id == deletedPost.id }
                })
            }
        }
    }
    
    // MARK: - 빈 피드
    private var emptyFeedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.5))
            
            Text("아직 게시물이 없어요")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("첫 번째 글을 작성해보세요!")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            
            Button {
                showNewPost = true
            } label: {
                Text("글 작성하기")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - 피드 리스트
    private var feedList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.posts) { post in
                    PostCard(post: post) {
                        Task {
                            await viewModel.toggleLike(for: post)
                        }
                    } onCommentTapped: {
                        selectedPost = post
                    }
                    .onAppear {
                        if post.id == viewModel.posts.last?.id {
                            Task {
                                await viewModel.loadMorePosts()
                            }
                        }
                    }
                }
                
                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
    }
}

// MARK: - 게시물 카드
struct PostCard: View {
    let post: Post
    let onLikeTapped: () -> Void
    let onCommentTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            authorSection
            
            if let exercise = post.exerciseSummary {
                exerciseSection(exercise)
            }
            
            Text(post.content)
                .font(.subheadline)
            
            actionSection
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    private var authorSection: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(post.authorTier.toTier.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "person.fill")
                    .foregroundStyle(post.authorTier.toTier.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(post.authorNickname)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(post.authorTier.grade)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(post.authorTier.toTier.color.opacity(0.2))
                        .foregroundStyle(post.authorTier.toTier.color)
                        .clipShape(Capsule())
                }
                
                HStack(spacing: 4) {
                    Text("@\(post.authorUsername)")
                    Text("·")
                    Text(post.timeAgo)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Menu {
                Button {
                } label: {
                    Label("공유하기", systemImage: "square.and.arrow.up")
                }
                
                Button(role: .destructive) {
                } label: {
                    Label("신고하기", systemImage: "exclamationmark.triangle")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
    }
    
    private func exerciseSection(_ exercise: ExerciseSummary) -> some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: exercise.icon)
                    .foregroundStyle(.blue)
                Text(exercise.type)
                    .fontWeight(.medium)
            }
            
            Label(exercise.distanceInKm + " km", systemImage: "arrow.left.arrow.right")
            Label(exercise.durationFormatted, systemImage: "clock")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var actionSection: some View {
        HStack(spacing: 24) {
            Button(action: onLikeTapped) {
                HStack(spacing: 6) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(post.isLiked ? .red : .secondary)
                    Text("\(post.likeCount)")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
            .buttonStyle(.plain)
            
            Button(action: onCommentTapped) {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                    Text("\(post.commentCount)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Image(systemName: post.visibility.icon)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - 게시물 상세 (댓글)
struct PostDetailView: View {
    @State private var post: Post
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PostDetailViewModel
    @State private var newComment = ""
    @State private var showEditPost = false
    @State private var showDeleteAlert = false
    
    var onPostUpdated: ((Post) -> Void)?
    var onPostDeleted: ((Post) -> Void)?
    
    private var isMyPost: Bool {
        post.authorNickname == "나" || post.authorUsername == "me"
    }
    
    init(post: Post, onPostUpdated: ((Post) -> Void)? = nil, onPostDeleted: ((Post) -> Void)? = nil) {
        self._post = State(initialValue: post)
        self._viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
        self.onPostUpdated = onPostUpdated
        self.onPostDeleted = onPostDeleted
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 원본 게시물
                        postContent
                        
                        // 댓글 섹션
                        commentsSection
                    }
                    .padding()
                }
                
                Divider()
                
                commentInputSection
            }
            .navigationTitle("게시물")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
                
                if isMyPost {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                showEditPost = true
                            } label: {
                                Label("수정하기", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label("삭제하기", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditPost) {
                EditPostView(post: post) { updatedPost in
                    self.post = updatedPost
                    onPostUpdated?(updatedPost)
                }
            }
            .alert("게시물 삭제", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    Task {
                        await deletePost()
                    }
                }
            } message: {
                Text("이 게시물을 삭제하시겠습니까?\n삭제된 게시물은 복구할 수 없습니다.")
            }
        }
    }
    
    // MARK: - 게시물 내용
    private var postContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 작성자 정보
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(post.authorTier.toTier.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "person.fill")
                        .foregroundStyle(post.authorTier.toTier.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(post.authorNickname)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(post.authorTier.grade)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(post.authorTier.toTier.color.opacity(0.2))
                            .foregroundStyle(post.authorTier.toTier.color)
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 4) {
                        Text("@\(post.authorUsername)")
                        Text("·")
                        Text(post.timeAgo)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // 운동 정보
            if let exercise = post.exerciseSummary {
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: exercise.icon)
                            .foregroundStyle(.blue)
                        Text(exercise.type)
                            .fontWeight(.medium)
                    }
                    
                    Label(exercise.distanceInKm + " km", systemImage: "arrow.left.arrow.right")
                    Label(exercise.durationFormatted, systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // 내용
            Text(post.content)
                .font(.subheadline)
            
            // 좋아요/댓글 수
            HStack(spacing: 24) {
                HStack(spacing: 6) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(post.isLiked ? .red : .secondary)
                    Text("\(post.likeCount)")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                    Text("\(post.commentCount)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: post.visibility.icon)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 댓글 섹션
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("댓글 \(viewModel.comments.count)개")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.comments.isEmpty {
                emptyCommentsView
            } else {
                ForEach(viewModel.comments) { comment in
                    CommentRow(comment: comment)
                    Divider().padding(.leading, 54)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var emptyCommentsView: some View {
        VStack(spacing: 8) {
            Text("아직 댓글이 없어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("첫 댓글을 남겨보세요!")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    private var commentInputSection: some View {
        HStack(spacing: 12) {
            TextField("댓글을 입력하세요...", text: $newComment)
                .textFieldStyle(.roundedBorder)
            
            Button {
                Task {
                    await viewModel.addComment(content: newComment)
                    newComment = ""
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(newComment.isEmpty ? .gray : .blue)
            }
            .disabled(newComment.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - 삭제
    private func deletePost() async {
        do {
            try await viewModel.deletePost(post)
            onPostDeleted?(post)
            dismiss()
        } catch {
            // Handle error
        }
    }
}

// MARK: - 게시물 수정 뷰
struct EditPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var content: String
    @State private var selectedVisibility: PostVisibility
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let originalPost: Post
    private let onPostUpdated: (Post) -> Void
    private let postRepository: PostRepository
    
    init(post: Post, onPostUpdated: @escaping (Post) -> Void, postRepository: PostRepository = LocalPostRepository()) {
        self.originalPost = post
        self.onPostUpdated = onPostUpdated
        self.postRepository = postRepository
        self._content = State(initialValue: post.content)
        self._selectedVisibility = State(initialValue: post.visibility)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 내용 입력
                contentSection
                
                Divider()
                
                // 운동 정보 (수정 불가, 표시만)
                if let exercise = originalPost.exerciseSummary {
                    exerciseInfoSection(exercise)
                    Divider()
                }
                
                // 공개 범위 설정
                visibilitySection
                
                Spacer()
            }
            .navigationTitle("게시물 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await updatePost()
                        }
                    }
                    .disabled(content.isEmpty || content == originalPost.content && selectedVisibility == originalPost.visibility)
                    .fontWeight(.semibold)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    // MARK: - 내용 입력 섹션
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $content)
                .frame(minHeight: 150)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            
            Text("\(content.count)/500")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }
    
    // MARK: - 운동 정보 섹션 (읽기 전용)
    private func exerciseInfoSection(_ exercise: ExerciseSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundStyle(.blue)
                Text("연결된 운동")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.type)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 12) {
                        Label(exercise.distanceInKm + " km", systemImage: "arrow.left.arrow.right")
                        Label(exercise.durationFormatted, systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
    
    // MARK: - 공개 범위 섹션
    private var visibilitySection: some View {
        HStack {
            Image(systemName: selectedVisibility.icon)
                .foregroundStyle(.blue)
            
            Text("공개 범위")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("", selection: $selectedVisibility) {
                ForEach(PostVisibility.allCases, id: \.self) { visibility in
                    Text(visibility.rawValue).tag(visibility)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
    }
    
    // MARK: - 게시물 수정
    private func updatePost() async {
        isLoading = true
        
        var updatedPost = originalPost
        updatedPost = Post(
            id: originalPost.id,
            authorId: originalPost.authorId,
            authorNickname: originalPost.authorNickname,
            authorUsername: originalPost.authorUsername,
            authorTier: originalPost.authorTier,
            exerciseId: originalPost.exerciseId,
            content: content,
            imageURL: originalPost.imageURL,
            visibility: selectedVisibility,
            createdAt: originalPost.createdAt,
            updatedAt: Date(),
            likeCount: originalPost.likeCount,
            commentCount: originalPost.commentCount,
            isLiked: originalPost.isLiked,
            exerciseSummary: originalPost.exerciseSummary
        )
        
        do {
            let savedPost = try await postRepository.updatePost(updatedPost)
            onPostUpdated(savedPost)
            dismiss()
        } catch {
            errorMessage = "게시물 수정에 실패했습니다."
        }
        
        isLoading = false
    }
}

// MARK: - 댓글 행
struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(comment.authorTier.toTier.color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "person.fill")
                    .font(.caption)
                    .foregroundStyle(comment.authorTier.toTier.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.authorNickname)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(comment.timeAgo)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Text(comment.content)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - PostDetailViewModel
@MainActor
class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    
    private let post: Post
    private let postRepository: PostRepository
    
    init(post: Post, postRepository: PostRepository = LocalPostRepository()) {
        self.post = post
        self.postRepository = postRepository
        
        Task {
            await loadComments()
        }
    }
    
    func loadComments() async {
        isLoading = true
        
        do {
            comments = try await postRepository.fetchComments(postId: post.id)
        } catch {
            comments = []
        }
        
        isLoading = false
    }
    
    func addComment(content: String) async {
        let comment = Comment(
            postId: post.id,
            authorNickname: "나",
            authorUsername: "me",
            authorTier: TierData(grade: "골드", division: 2),
            content: content
        )
        
        do {
            let newComment = try await postRepository.createComment(comment)
            comments.append(newComment)
        } catch {
            // Handle error
        }
    }
    
    func deletePost(_ post: Post) async throws {
        try await postRepository.deletePost(post)
    }
}

#Preview {
    FeedView()
}

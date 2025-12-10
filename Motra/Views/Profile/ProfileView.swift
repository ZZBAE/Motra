//
//  ProfileView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI
import Charts

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showNewPost = false
    @State private var showFollowers = false
    @State private var showFollowing = false
    @State private var showSettings = false
    @State private var showTierHistory = false
    @State private var selectedPost: Post?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 커스텀 헤더
                    CustomHeaderView(title: "프로필")
                    
                    // 프로필 헤더
                    profileHeader
                    
                    // 게시물 탭
                    postsSection
                    
                    // 설정 메뉴
                    settingsSection
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                Task {
                    await viewModel.refresh()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showEditProfile, onDismiss: {
                // 프로필 편집 후 새로고침
                Task {
                    await viewModel.refresh()
                }
            }) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showNewPost, onDismiss: {
                // 새 글 작성 후 목록 새로고침
                Task {
                    await viewModel.refresh()
                }
            }) {
                NewPostView()
            }
            .sheet(isPresented: $showFollowers) {
                FollowListView(title: "팔로워", follows: viewModel.followers)
            }
            .sheet(isPresented: $showFollowing) {
                FollowListView(title: "팔로잉", follows: viewModel.following)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showTierHistory) {
                TierHistoryView(
                    tierHistory: viewModel.tierHistory,
                    currentTier: viewModel.profile.tier,
                    totalDistance: viewModel.profile.totalDistance
                )
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(
                    post: post,
                    onPostUpdated: { updatedPost in
                        // 수정된 게시물 반영
                        if let index = viewModel.myPosts.firstIndex(where: { $0.id == updatedPost.id }) {
                            viewModel.myPosts[index] = updatedPost
                        }
                        if let index = viewModel.likedPosts.firstIndex(where: { $0.id == updatedPost.id }) {
                            viewModel.likedPosts[index] = updatedPost
                        }
                    },
                    onPostDeleted: { deletedPost in
                        // 삭제된 게시물 제거
                        viewModel.myPosts.removeAll { $0.id == deletedPost.id }
                        viewModel.likedPosts.removeAll { $0.id == deletedPost.id }
                        viewModel.profile.postCount = viewModel.myPosts.count
                    }
                )
            }
        }
    }
    
    // MARK: - 프로필 헤더
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // 프로필 이미지 & 정보
            HStack(spacing: 16) {
                // 프로필 이미지
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [viewModel.profile.tier.color, viewModel.profile.tier.color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 35))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // 닉네임 & 티어
                    HStack(spacing: 8) {
                        Text(viewModel.profile.nickname)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        // 티어 뱃지 (탭 가능)
                        Button {
                            showTierHistory = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.profile.tier.icon)
                                    .font(.caption2)
                                Text(viewModel.profile.tier.displayName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewModel.profile.tier.color.opacity(0.2))
                            .foregroundStyle(viewModel.profile.tier.color)
                            .clipShape(Capsule())
                        }
                    }
                    
                    // @username
                    Text("@\(viewModel.profile.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // 자기소개
                    if let bio = viewModel.profile.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            
            // 팔로워/팔로잉/게시물 카운트
            HStack(spacing: 0) {
                Button {
                    showFollowers = true
                } label: {
                    VStack(spacing: 4) {
                        Text("\(viewModel.profile.followerCount)")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("팔로워")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                
                Divider().frame(height: 30)
                
                Button {
                    showFollowing = true
                } label: {
                    VStack(spacing: 4) {
                        Text("\(viewModel.profile.followingCount)")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("팔로잉")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                
                Divider().frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("\(viewModel.profile.postCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("게시물")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            
            // 버튼들
            HStack(spacing: 12) {
                Button {
                    showEditProfile = true
                } label: {
                    Text("프로필 편집")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                
                Button {
                    showNewPost = true
                } label: {
                    Text("글 작성하기")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 게시물 섹션
    private var postsSection: some View {
        VStack(spacing: 0) {
            // 탭 선택
            HStack(spacing: 0) {
                Button {
                    viewModel.selectedTab = .posts
                } label: {
                    VStack(spacing: 8) {
                        Text("내 게시물")
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedTab == .posts ? .semibold : .regular)
                            .foregroundStyle(viewModel.selectedTab == .posts ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(viewModel.selectedTab == .posts ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                
                Button {
                    viewModel.selectedTab = .liked
                } label: {
                    VStack(spacing: 8) {
                        Text("좋아요한 글")
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedTab == .liked ? .semibold : .regular)
                            .foregroundStyle(viewModel.selectedTab == .liked ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(viewModel.selectedTab == .liked ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Divider()
            
            // 게시물 리스트
            if viewModel.selectedTab == .posts {
                if viewModel.myPosts.isEmpty {
                    emptyPostsPlaceholder
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.myPosts) { post in
                            ProfilePostRow(
                                post: post,
                                onTapped: {
                                    selectedPost = post
                                },
                                onLikeTapped: {
                                    Task {
                                        await viewModel.togglePostLike(post)
                                    }
                                }
                            )
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            } else {
                if viewModel.likedPosts.isEmpty {
                    emptyLikedPlaceholder
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.likedPosts) { post in
                            ProfilePostRow(
                                post: post,
                                onTapped: {
                                    selectedPost = post
                                },
                                onLikeTapped: {
                                    Task {
                                        await viewModel.togglePostLike(post)
                                    }
                                }
                            )
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 빈 게시물 플레이스홀더
    private var emptyPostsPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
            
            Text("아직 게시물이 없어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                showNewPost = true
            } label: {
                Text("첫 글 작성하기")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var emptyLikedPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
            
            Text("좋아요한 글이 없어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - 설정 섹션
    private var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "bell.badge", title: "알림 설정", color: .red) {
                // TODO: 알림 설정
            }
            Divider().padding(.leading, 60)
            
            SettingsRow(icon: "lock.shield", title: "개인정보 보호", color: .blue) {
                // TODO: 개인정보 보호
            }
            Divider().padding(.leading, 60)
            
            SettingsRow(icon: "gearshape", title: "설정", color: .gray) {
                showSettings = true
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

// MARK: - 프로필 게시물 행 (Post 모델 사용)
struct ProfilePostRow: View {
    let post: Post
    let onTapped: () -> Void
    let onLikeTapped: () -> Void
    
    var body: some View {
        Button(action: onTapped) {
            VStack(alignment: .leading, spacing: 8) {
                // 내용
                Text(post.content)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                // 운동 정보 (있는 경우)
                if let exercise = post.exerciseSummary {
                    HStack(spacing: 12) {
                        Label(exercise.distanceInKm + " km", systemImage: exercise.icon)
                        Label(exercise.durationFormatted, systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                // 하단 정보
                HStack {
                    Text(post.timeAgo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        onLikeTapped()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                .foregroundStyle(post.isLiked ? .red : .secondary)
                            Text("\(post.likeCount)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                        Text("\(post.commentCount)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 티어 히스토리 뷰 (시트)
struct TierHistoryView: View {
    let tierHistory: [TierHistory]
    let currentTier: Tier
    let totalDistance: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 현재 티어 카드
                    currentTierCard
                    
                    // 성장 그래프
                    growthChart
                    
                    // 티어 히스토리 리스트
                    historyList
                }
                .padding()
            }
            .navigationTitle("티어 성장 기록")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - 현재 티어 카드
    private var currentTierCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [currentTier.color, currentTier.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: currentTier.icon)
                    .font(.system(size: 45))
                    .foregroundStyle(.white)
            }
            
            Text(currentTier.displayName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(currentTier.color)
            
            Text("총 \(String(format: "%.1f", totalDistance / 1000)) km 달성")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 성장 그래프
    private var growthChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.blue)
                Text("성장 추이")
                    .font(.headline)
            }
            
            if tierHistory.count > 1 {
                Chart(tierHistory) { history in
                    LineMark(
                        x: .value("날짜", history.achievedAt),
                        y: .value("티어", history.tierLevel)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("날짜", history.achievedAt),
                        y: .value("티어", history.tierLevel)
                    )
                    .foregroundStyle(history.tier.color)
                    .symbolSize(60)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let level = value.as(Int.self) {
                                Text(tierNameForLevel(level))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .frame(height: 200)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.5))
                    
                    Text("더 많은 운동을 하면\n성장 그래프가 표시됩니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 히스토리 리스트
    private var historyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("승급 기록")
                .font(.headline)
            
            ForEach(tierHistory.reversed()) { history in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(history.tier.color.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: history.tier.icon)
                            .foregroundStyle(history.tier.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(history.tier.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(history.tier.color)
                        
                        Text(formatDate(history.achievedAt))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", history.totalDistance / 1000)) km")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - Helpers
    private func tierNameForLevel(_ level: Int) -> String {
        let grades: [TierGrade] = [.bronze, .silver, .gold, .platinum, .diamond, .redDiamond, .master, .grandMaster]
        let gradeIndex = level / 4
        
        if gradeIndex < grades.count {
            return grades[gradeIndex].rawValue
        }
        return ""
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}

// MARK: - 설정 행
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                }
                
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

// MARK: - EditProfileView
struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var nickname: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("닉네임", text: $nickname)
                    TextField("사용자명", text: $username)
                    TextField("자기소개", text: $bio)
                }
                
                Section {
                    Text("프로필 변경 시 이전에 작성한 게시물의 작성자 정보도 함께 업데이트됩니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("프로필 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveProfile()
                    }
                    .disabled(nickname.isEmpty || username.isEmpty || isSaving)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // 현재 프로필 정보로 초기화
                nickname = viewModel.profile.nickname
                username = viewModel.profile.username
                bio = viewModel.profile.bio ?? ""
            }
            .overlay {
                if isSaving {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private func saveProfile() {
        isSaving = true
        
        Task {
            await viewModel.updateProfile(
                nickname: nickname,
                username: username,
                bio: bio.isEmpty ? nil : bio
            )
            
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - FollowListView
struct FollowListView: View {
    let title: String
    let follows: [Follow]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if follows.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)
                        Text(title == "팔로워" ? "아직 팔로워가 없어요" : "아직 팔로잉이 없어요")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List(follows) { follow in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(follow.user.tier.color.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "person.fill")
                                    .foregroundStyle(follow.user.tier.color)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(follow.user.nickname)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(follow.user.tier.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("앱 정보") {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("계정") {
                    Button("로그아웃") {
                        // TODO: 로그아웃
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

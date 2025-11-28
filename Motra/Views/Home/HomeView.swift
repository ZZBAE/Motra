//
//  HomeView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showWorkoutTypeSheet = false
    @State private var navigateToRecording = false
    @State private var selectedWorkoutType: WorkoutType = .running
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 환영 메시지
                    welcomeSection
                    
                    // 티어 카드
                    if let tierProgress = viewModel.tierProgress {
                        TierCardView(progress: tierProgress)
                    }
                    
                    // 운동 시작 버튼
                    startWorkoutButton
                    
                    // 소셜 피드
                    socialFeedSection
                }
                .padding()
            }
            .navigationTitle("Motra")
            .background(Color(.systemGroupedBackground))
            .onAppear {
                Task {
                    await viewModel.refresh()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(isPresented: $navigateToRecording) {
                RecordingView(workoutType: selectedWorkoutType)
            }
            .sheet(isPresented: $showWorkoutTypeSheet) {
                WorkoutTypeSelectionSheet(
                    selectedType: $selectedWorkoutType,
                    onStart: {
                        showWorkoutTypeSheet = false
                        navigateToRecording = true
                    }
                )
                .presentationDetents([.height(400)])
            }
        }
    }
    
    // MARK: - 환영 메시지
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("안녕하세요! 🏃‍♂️")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("오늘도 건강한 하루 보내세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 운동 시작 버튼
    private var startWorkoutButton: some View {
        Button {
            showWorkoutTypeSheet = true
        } label: {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                Text("운동 시작하기")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - 소셜 피드 섹션
    private var socialFeedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("소셜 피드")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    // TODO: 전체 피드 보기
                } label: {
                    Text("더보기")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
            
            if viewModel.feedItems.isEmpty {
                emptyFeedPlaceholder
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.feedItems.prefix(3)) { item in
                        FeedItemCard(item: item) {
                            viewModel.toggleLike(for: item)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 빈 피드 플레이스홀더
    private var emptyFeedPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
            
            Text("아직 피드가 없어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("친구를 팔로우하고 운동을 공유해보세요")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

// MARK: - 티어 카드 뷰
struct TierCardView: View {
    let progress: TierProgress
    
    var body: some View {
        VStack(spacing: 16) {
            // 티어 정보
            HStack(spacing: 12) {
                // 티어 아이콘
                ZStack {
                    Circle()
                        .fill(progress.currentTier.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: progress.currentTier.icon)
                        .font(.title)
                        .foregroundStyle(progress.currentTier.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(progress.currentTier.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(progress.currentTier.color)
                    
                    if let nextTier = progress.nextTier {
                        Text("다음: \(nextTier.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("최고 티어 달성! 🎉")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // 총 거리
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(progress.currentDistanceInKm) km")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("총 거리")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 프로그레스 바
            VStack(spacing: 6) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 배경
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        // 진행
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [progress.currentTier.color, progress.currentTier.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress.progressPercentage, height: 12)
                    }
                }
                .frame(height: 12)
                
                // 진행 텍스트
                if progress.nextTier != nil {
                    HStack {
                        Text("\(Int(progress.progressPercentage * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("다음 티어까지 \(progress.remainingDistanceInKm) km")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

// MARK: - 피드 아이템 카드
struct FeedItemCard: View {
    let item: FeedItem
    let onLikeTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 유저 정보
            HStack(spacing: 10) {
                // 프로필 이미지
                ZStack {
                    Circle()
                        .fill(item.user.tier.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "person.fill")
                        .foregroundStyle(item.user.tier.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.user.nickname)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        // 티어 뱃지
                        Text(item.user.tier.grade.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(item.user.tier.color.opacity(0.2))
                            .foregroundStyle(item.user.tier.color)
                            .clipShape(Capsule())
                    }
                    
                    Text(item.timeAgo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 운동 타입 아이콘
                Image(systemName: item.workout.icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
            
            // 운동 정보
            HStack(spacing: 16) {
                Label(item.workout.distanceInKm + " km", systemImage: "arrow.left.arrow.right")
                Label(item.workout.durationFormatted, systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // 내용
            if let content = item.content {
                Text(content)
                    .font(.subheadline)
            }
            
            // 액션 버튼
            HStack(spacing: 20) {
                Button {
                    onLikeTapped()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: item.isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(item.isLiked ? .red : .secondary)
                        Text("\(item.likeCount)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
                
                Button {
                    // TODO: 댓글 보기
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                        Text("\(item.commentCount)")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Workout Type Selection Sheet
struct WorkoutTypeSelectionSheet: View {
    @Binding var selectedType: WorkoutType
    let onStart: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("운동 타입 선택")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        HStack {
                            Image(systemName: type.icon)
                                .font(.title2)
                                .frame(width: 40)
                            
                            Text(type.rawValue)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding()
                        .background(
                            selectedType == type ?
                            Color.blue.opacity(0.1) :
                            Color(.secondarySystemGroupedBackground)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                
                Button {
                    onStart()
                } label: {
                    Text("시작하기")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}

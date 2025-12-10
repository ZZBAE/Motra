//
//  WorkoutDetailView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/17/25.
//

import SwiftUI
import MapKit

struct WorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    
    @State private var linkedPost: Post?
    @State private var isLoadingPost = true
    @State private var showNewPost = false
    @State private var showPostDetail = false
    
    private let postRepository: PostRepository = LocalPostRepository()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 헤더
                headerSection
                
                // 주요 통계
                statsSection
                
                // 메모
                if let notes = exercise.notes, !notes.isEmpty {
                    notesSection(notes)
                }
                
                // 연결된 게시물
                linkedPostSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("운동 상세")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadLinkedPost()
        }
        .sheet(isPresented: $showNewPost, onDismiss: {
            Task {
                await loadLinkedPost()
            }
        }) {
            NewPostView(preselectedExercise: exercise)
        }
        .navigationDestination(isPresented: $showPostDetail) {
            if let post = linkedPost {
                PostDetailView(
                    post: post,
                    onPostUpdated: { updatedPost in
                        linkedPost = updatedPost
                    },
                    onPostDeleted: { _ in
                        linkedPost = nil
                    }
                )
            }
        }
    }
    
    // MARK: - 헤더 섹션
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exerciseType)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(formatDate(exercise.startDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: getIconForExerciseType(exercise.exerciseType))
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 통계 섹션
    private var statsSection: some View {
        VStack(spacing: 16) {
            StatRow(
                icon: "timer",
                label: "시간",
                value: exercise.durationFormatted
            )
            
            Divider()
            
            StatRow(
                icon: "map",
                label: "거리",
                value: exercise.distanceInKm
            )
            
            Divider()
            
            StatRow(
                icon: "speedometer",
                label: "페이스",
                value: exercise.paceFormatted
            )
            
            Divider()
            
            StatRow(
                icon: "flame.fill",
                label: "칼로리",
                value: String(format: "%.0f kcal", exercise.calories)
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 메모 섹션
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("메모")
                .font(.headline)
            
            Text(notes)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 연결된 게시물 섹션
    private var linkedPostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("연결된 게시물")
                .font(.headline)
            
            if isLoadingPost {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if let post = linkedPost {
                // 연결된 게시물 카드
                Button {
                    showPostDetail = true
                } label: {
                    linkedPostCard(post)
                }
                .buttonStyle(.plain)
            } else {
                // 게시물 없음 - 작성하기 버튼
                VStack(spacing: 12) {
                    Image(systemName: "square.and.pencil")
                        .font(.title)
                        .foregroundStyle(.gray)
                    
                    Text("이 운동으로 작성한 글이 없어요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showNewPost = true
                    } label: {
                        Text("글 작성하기")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 연결된 게시물 카드
    private func linkedPostCard(_ post: Post) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(post.content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text("\(post.likeCount)")
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(post.commentCount)")
                }
                
                Spacer()
                
                Text(post.timeAgo)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - 연결된 게시물 로드
    private func loadLinkedPost() async {
        isLoadingPost = true
        
        do {
            let posts = try await postRepository.fetchPosts(limit: 100, offset: 0)
            linkedPost = posts.first { $0.exerciseId == exercise.id }
        } catch {
            linkedPost = nil
        }
        
        isLoadingPost = false
    }
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
        return formatter.string(from: date)
    }
    
    private func getIconForExerciseType(_ type: String) -> String {
        switch type {
        case "러닝":
            return "figure.run.circle.fill"
        case "사이클", "사이클링":
            return "bicycle"
        case "조깅", "워킹":
            return "figure.walk.circle.fill"
        case "등산":
            return "figure.hiking"
        default:
            return "figure.run.circle.fill"
        }
    }
}

// MARK: - Stat Row Component
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(exercise: Exercise(
            id: UUID(),
            exerciseType: "러닝",
            startDate: Date(timeIntervalSinceNow: -1800),
            endDate: Date(),
            duration: 1800,
            distance: 5200,
            calories: 450,
            pace: 346,
            notes: "공원에서 달렸어요"
        ))
    }
}

//
//  ActivityView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

struct ActivityView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 커스텀 헤더
                    HStack {
                        CustomHeaderView(title: "운동 기록")
                        
                        Spacer()
                        
                        Button {
                            Task {
                                await viewModel.fetchExercises()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .foregroundStyle(.blue)
                        }
                        .padding(.trailing)
                    }
                    
                    // 콘텐츠
                    contentView
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await viewModel.fetchExercises()
            }
            .onAppear {
                Task {
                    await viewModel.fetchExercises()
                }
            }
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            VStack {
                Spacer().frame(height: 100)
                ProgressView("데이터 로딩 중...")
                Spacer()
            }
        } else if let errorMessage = viewModel.errorMessage {
            errorView(errorMessage)
        } else if viewModel.exercises.isEmpty {
            emptyStateView
        } else {
            exerciseListView
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("첫 운동을 시작해보세요")
                        .font(.headline)
                    Text("운동을 시작하면 여기에 표시됩니다")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "figure.run.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("--:--")
                        .font(.callout)
                        .fontWeight(.semibold)
                    Text("시간")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("0.0 km")
                        .font(.callout)
                        .fontWeight(.semibold)
                    Text("거리")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Image(systemName: "speedometer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("--:--")
                        .font(.callout)
                        .fontWeight(.semibold)
                    Text("페이스")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - Exercise List
    private var exerciseListView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.exercises, id: \.id) { exercise in
                NavigationLink(destination: WorkoutDetailView(exercise: exercise)) {
                    ExerciseCard(exercise: exercise)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Error View
    private func errorView(_ errorMessage: String) -> some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 50)
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            Text("오류 발생")
                .font(.headline)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("다시 시도") {
                Task {
                    await viewModel.fetchExercises()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Exercise Card Component
struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exerciseType)
                        .font(.headline)
                    Text(formatDate(exercise.startDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: getIconForExerciseType(exercise.exerciseType))
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(exercise.durationFormatted)
                        .font(.callout)
                        .fontWeight(.semibold)
                    Text("시간")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(exercise.distanceInKm)
                        .font(.callout)
                        .fontWeight(.semibold)
                    Text("거리")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Image(systemName: "speedometer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(exercise.paceFormatted)
                        .font(.callout)
                        .fontWeight(.semibold)
                    Text("페이스")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            if let notes = exercise.notes, !notes.isEmpty {
                Divider()
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
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

#Preview {
    ActivityView()
}

//
//  ActivityView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

struct ActivityView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var selectedExercise: ExerciseSession?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if viewModel.exercises.isEmpty {
                        // 운동 기록이 없을 때
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
                    } else {
                        // 운동 기록이 있을 때
                        ForEach(viewModel.exercises, id: \.id) { exercise in
                            NavigationLink(value: exercise) {
                                ExerciseCard(exercise: exercise)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("운동 기록")
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: ExerciseSession.self) { exercise in
                WorkoutDetailView(exercise: exercise)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.fetchExercises()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.fetchExercises()
            }
        }
    }
}

// MARK: - Exercise Card Component
struct ExerciseCard: View {
    let exercise: ExerciseSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exerciseType ?? "운동")
                        .font(.headline)
                    Text(formatDate(exercise.startDate ?? Date()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: getIconForExerciseType(exercise.exerciseType ?? ""))
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatDuration(exercise.duration))
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
                    Text(String(format: "%.2f km", exercise.distance))
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
                    Text(String(format: "%.2f", exercise.pace))
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
    
    private func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
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

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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 헤더
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
                
                // 주요 통계
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
                
                // 메모
                if let notes = exercise.notes, !notes.isEmpty {
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
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("운동 상세")
        .navigationBarTitleDisplayMode(.inline)
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

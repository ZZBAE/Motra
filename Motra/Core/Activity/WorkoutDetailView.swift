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
    let exercise: ExerciseSession
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 헤더
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.exerciseType ?? "운동")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(formatDate(exercise.startDate ?? Date()))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: getIconForExerciseType(exercise.exerciseType ?? ""))
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 지도
                MapView(exercise: exercise)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 주요 통계
                VStack(spacing: 16) {
                    StatRow(
                        icon: "timer",
                        label: "시간",
                        value: formatDuration(exercise.duration)
                    )
                    
                    Divider()
                    
                    StatRow(
                        icon: "map",
                        label: "거리",
                        value: String(format: "%.2f km", exercise.distance)
                    )
                    
                    Divider()
                    
                    StatRow(
                        icon: "speedometer",
                        label: "페이스",
                        value: String(format: "%.2f 분/km", exercise.pace)
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

// MARK: - Map View Component
struct MapView: View {
    let exercise: ExerciseSession
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                // 경로 그리기
                if let firstDataPoint = getCoreDataPoints().first,
                   getCoreDataPoints().count >= 2 {
                    MapPolyline(
                        coordinates: getCoreDataPoints().map {
                            CLLocationCoordinate2D(
                                latitude: $0.latitude,
                                longitude: $0.longitude
                            )
                        }
                    )
                    .stroke(.blue, lineWidth: 3)
                    
                    // 시작점
                    Annotation("시작", coordinate: CLLocationCoordinate2D(
                        latitude: firstDataPoint.latitude,
                        longitude: firstDataPoint.longitude
                    )) {
                        ZStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 16, height: 16)
                            Circle()
                                .stroke(.white, lineWidth: 2)
                                .frame(width: 16, height: 16)
                        }
                    }
                    
                    // 종료점
                    if let lastDataPoint = getCoreDataPoints().last {
                        Annotation("종료", coordinate: CLLocationCoordinate2D(
                            latitude: lastDataPoint.latitude,
                            longitude: lastDataPoint.longitude
                        )) {
                            ZStack {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 16, height: 16)
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
        }
    }
    
    private func getCoreDataPoints() -> [ExerciseDataPoint] {
        let coreDataManager = CoreDataManager.shared
        return coreDataManager.fetchDataPoints(for: exercise)
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(exercise: createSampleExercise())
    }
}

func createSampleExercise() -> ExerciseSession {
    let coreDataManager = CoreDataManager.shared
    return coreDataManager.createExerciseSession(
        exerciseType: "러닝",
        duration: 1800,
        distance: 5.2,
        calories: 450,
        pace: 5.76,
        startDate: Date(timeIntervalSinceNow: -1800),
        endDate: Date(),
        notes: "공원에서 달렸어요"
    )
}

//
//  StatisticsView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedPeriod: PeriodStatistics.TimePeriod = .weekly
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 기간 선택
                    periodPicker
                    
                    // 주요 통계
                    mainStatisticsSection
                    
                    // 차트 영역
                    chartSection
                    
                    // 추가 통계
                    additionalStatisticsSection
                }
                .padding()
            }
            .navigationTitle("통계")
            .background(Color(.systemGroupedBackground))
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }
    
    // MARK: - 기간 선택 Picker
    private var periodPicker: some View {
        Picker("기간", selection: $selectedPeriod) {
            Text("주간").tag(PeriodStatistics.TimePeriod.weekly)
            Text("월간").tag(PeriodStatistics.TimePeriod.monthly)
            Text("연간").tag(PeriodStatistics.TimePeriod.yearly)
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
        .onChange(of: selectedPeriod) { _, newValue in
            Task {
                await viewModel.calculateStatistics(for: newValue)
            }
        }
    }
    
    // MARK: - 주요 통계 섹션
    private var mainStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주요 지표")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    icon: "figure.run",
                    title: "총 거리",
                    value: "\(viewModel.totalDistanceFormatted) km",
                    color: .blue
                )
                StatCard(
                    icon: "clock",
                    title: "총 시간",
                    value: viewModel.totalTimeFormatted,
                    color: .green
                )
                StatCard(
                    icon: "flame.fill",
                    title: "칼로리",
                    value: viewModel.totalCaloriesFormatted,
                    color: .orange
                )
                StatCard(
                    icon: "calendar",
                    title: "운동 횟수",
                    value: "\(viewModel.workoutCount)회",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 차트 섹션
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("거리 추이")
                .font(.headline)
            
            if viewModel.chartData.isEmpty {
                emptyChartPlaceholder
            } else {
                distanceChart
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 거리 차트
    private var distanceChart: some View {
        Chart(viewModel.chartData, id: \.label) { data in
            BarMark(
                x: .value("날짜", data.label),
                y: .value("거리", data.value / 1000) // km 단위로 변환
            )
            .foregroundStyle(Color.blue.gradient)
            .cornerRadius(4)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let km = value.as(Double.self) {
                        Text("\(km, specifier: "%.1f") km")
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .font(.caption2)
                    }
                }
            }
        }
        .frame(height: 200)
    }
    
    // MARK: - 빈 차트 플레이스홀더
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 50))
                .foregroundStyle(.gray.opacity(0.5))
            
            Text("운동 기록이 쌓이면\n차트가 표시됩니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - 추가 통계 섹션
    private var additionalStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("평균 지표")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    icon: "arrow.left.arrow.right",
                    title: "평균 거리",
                    value: "\(viewModel.averageDistanceFormatted) km",
                    color: .cyan
                )
                StatCard(
                    icon: "speedometer",
                    title: "평균 페이스",
                    value: "\(viewModel.averagePaceFormatted) /km",
                    color: .mint
                )
            }
            
            // 운동 타입별 통계
            if !viewModel.workoutsByType.isEmpty {
                workoutTypeSection
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    // MARK: - 운동 타입별 통계
    private var workoutTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("운동 타입별")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            
            ForEach(Array(viewModel.workoutsByType.keys.sorted()), id: \.self) { type in
                HStack {
                    Image(systemName: iconForExerciseType(type))
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    
                    Text(type)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(viewModel.workoutsByType[type] ?? 0)회")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Helper
    private func iconForExerciseType(_ type: String) -> String {
        switch type.lowercased() {
        case "running", "러닝", "달리기":
            return "figure.run"
        case "cycling", "사이클링", "자전거":
            return "figure.outdoor.cycle"
        case "walking", "걷기":
            return "figure.walk"
        default:
            return "figure.mixed.cardio"
        }
    }
}

// MARK: - StatCard
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.callout)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    StatisticsView()
}

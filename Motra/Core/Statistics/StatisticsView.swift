//
//  StatisticsView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

struct StatisticsView: View {
    @State private var selectedPeriod = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 기간 선택
                    Picker("기간", selection: $selectedPeriod) {
                        Text("주간").tag(0)
                        Text("월간").tag(1)
                        Text("연간").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                    
                    // 주요 통계
                    VStack(alignment: .leading, spacing: 12) {
                        Text("주요 지표")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            StatCard(icon: "figure.run", title: "총 거리", value: "0.0 km", color: .blue)
                            StatCard(icon: "clock", title: "총 시간", value: "0:00", color: .green)
                            StatCard(icon: "flame.fill", title: "칼로리", value: "0 kcal", color: .orange)
                            StatCard(icon: "calendar", title: "운동 횟수", value: "0회", color: .purple)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                    
                    // 차트 영역
                    VStack(alignment: .leading, spacing: 12) {
                        Text("거리 추이")
                            .font(.headline)
                        
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
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("통계")
            .background(Color(.systemGroupedBackground))
        }
    }
}

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

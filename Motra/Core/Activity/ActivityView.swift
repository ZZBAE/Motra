//
//  ActivityView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

struct ActivityView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
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
                }
                .padding()
            }
            .navigationTitle("운동 기록")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("새 운동 추가")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ActivityView()
}

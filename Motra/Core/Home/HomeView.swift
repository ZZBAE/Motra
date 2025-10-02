//
//  HomeView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 환영 메시지
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
                    
                    // 운동 시작 버튼
                    Button {
                        print("운동 시작!")
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
                    
                    // 오늘의 목표
                    VStack(alignment: .leading, spacing: 12) {
                        Text("오늘의 목표")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                    Text("칼로리")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text("0/500 kcal")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "figure.walk")
                                        .foregroundStyle(.green)
                                    Text("거리")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text("0/5 km")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                    
                    // 최근 운동
                    VStack(alignment: .leading, spacing: 12) {
                        Text("최근 운동")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "figure.run.circle")
                                .font(.system(size: 50))
                                .foregroundStyle(.gray)
                            
                            Text("아직 운동 기록이 없어요")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("Motra")
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    HomeView()
}

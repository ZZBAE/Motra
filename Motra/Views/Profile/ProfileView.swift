//
//  ProfileView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 프로필 헤더
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.white)
                        }
                        
                        Text("러너")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("2025년 1월부터 활동 중")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            print("프로필 편집")
                        } label: {
                            Text("프로필 편집")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                    
                    // 월간 활동 요약
                    VStack(alignment: .leading, spacing: 12) {
                        Text("이번 달 활동")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Image(systemName: "figure.run")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text("0")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("운동 횟수")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider().frame(height: 40)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "map")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text("0.0 km")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("총 거리")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider().frame(height: 40)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text("0h")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("총 시간")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                    
                    // 설정 메뉴
                    VStack(spacing: 0) {
                        SettingsRow(icon: "target", title: "목표 설정", color: .orange)
                        Divider().padding(.leading, 60)
                        SettingsRow(icon: "bell.badge", title: "알림 설정", color: .red)
                        Divider().padding(.leading, 60)
                        SettingsRow(icon: "person.2", title: "친구 관리", color: .green)
                        Divider().padding(.leading, 60)
                        SettingsRow(icon: "lock.shield", title: "개인정보 보호", color: .blue)
                        Divider().padding(.leading, 60)
                        SettingsRow(icon: "gearshape", title: "설정", color: .gray)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("프로필")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button {
            print("\(title) 선택")
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                }
                
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
}

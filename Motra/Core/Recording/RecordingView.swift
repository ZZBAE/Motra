//
//  RecordingView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI
import MapKit

struct RecordingView: View {
    @StateObject private var locationManager = LocationManager()
    @Environment(\.dismiss) private var dismiss
    
    let workoutType: WorkoutType
    @State private var isPaused = false
    @State private var showStopAlert = false
    
    var body: some View {
        ZStack {
            // 배경색
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 지도 영역
                mapView
                    .frame(height: 300)
                
                // 통계 영역
                statsSection
                
                Spacer()
                
                // 컨트롤 버튼
                controlButtons
                    .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showStopAlert = true
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear {
            locationManager.startTracking()
        }
        .alert("운동 종료", isPresented: $showStopAlert) {
            Button("취소", role: .cancel) { }
            Button("종료", role: .destructive) {
                locationManager.stopTracking()
                // TODO: 운동 데이터 저장
                dismiss()
            }
        } message: {
            Text("운동을 종료하시겠습니까?")
        }
    }
    
    // MARK: - Map View
    private var mapView: some View {
        Map(position: .constant(.automatic)) {
            // 현재 위치 마커
            if let location = locationManager.currentLocation {
                Annotation("현재 위치", coordinate: location.coordinate) {
                    ZStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            
            // 경로 그리기
            if locationManager.route.count >= 2 {
                MapPolyline(coordinates: locationManager.route.map { $0.coordinate })
                    .stroke(.blue, lineWidth: 4)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 20) {
            // 운동 타입
            HStack {
                Image(systemName: workoutType.icon)
                Text(workoutType.rawValue)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.top, 20)
            
            // 메인 통계 (거리)
            VStack(spacing: 4) {
                Text(locationManager.stats.distanceInKm)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("킬로미터")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.vertical, 10)
            
            // 추가 통계
            HStack(spacing: 40) {
                StatItem(
                    icon: "timer",
                    value: locationManager.stats.timeFormatted,
                    label: "시간"
                )
                
                StatItem(
                    icon: "speedometer",
                    value: locationManager.stats.paceFormatted,
                    label: "페이스 (분/km)"
                )
                
                StatItem(
                    icon: "flame.fill",
                    value: String(format: "%.0f", locationManager.stats.calories),
                    label: "칼로리"
                )
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 40) {
            // 일시정지/재개 버튼
            Button {
                if isPaused {
                    locationManager.resumeTracking()
                } else {
                    locationManager.pauseTracking()
                }
                isPaused.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }
            }
            
            // 종료 버튼
            Button {
                showStopAlert = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "stop.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - Stat Item Component
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

#Preview {
    NavigationStack {
        RecordingView(workoutType: .running)
    }
}

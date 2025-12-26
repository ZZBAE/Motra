//
//  MotraApp.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

@main
struct MoTraApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch authViewModel.authState {
                case .unknown:
                    // 인증 상태 확인 중
                    splashView
                    
                case .signedOut:
                    // 로그인 필요
                    LoginView(authViewModel: authViewModel)
                    
                case .signedIn:
                    // 메인 화면
                    MainTabView()
                        .environmentObject(locationManager)
                        .environmentObject(authViewModel)
                        .onAppear {
                            locationManager.requestPermission()
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authViewModel.authState)
        }
    }
    
    // MARK: - Splash View
    private var splashView: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "figure.run.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue.gradient)
                
                ProgressView()
            }
        }
    }
}

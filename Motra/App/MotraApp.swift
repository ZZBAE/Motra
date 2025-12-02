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
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(locationManager)
                .onAppear {
                    // 앱 시작 시 위치 권한 요청
                    locationManager.requestPermission()
                }
        }
    }
}

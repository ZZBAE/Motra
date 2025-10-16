//
//  MotraApp.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

@main
struct MoTraApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    // 앱 시작 시 샘플 데이터 생성
                    MockDataGenerator.generateMockData()
                }
        }
    }
}

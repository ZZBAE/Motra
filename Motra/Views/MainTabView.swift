//
//  MainTabView.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/3/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("홈", systemImage: "house.fill")
                    }
                    .tag(0)
                
                ActivityView()
                    .tabItem {
                        Label("운동", systemImage: "figure.run")
                    }
                    .tag(1)
                
                StatisticsView()
                    .tabItem {
                        Label("통계", systemImage: "chart.bar.fill")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Label("프로필", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .tint(.blue)
        }
    }
}

#Preview {
    MainTabView()
}

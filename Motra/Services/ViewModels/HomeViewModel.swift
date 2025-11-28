//
//  HomeViewModel.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/27/25.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tierProgress: TierProgress?
    @Published var recentExercise: Exercise?
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let exerciseRepository: ExerciseRepository
    
    // MARK: - Init
    init(exerciseRepository: ExerciseRepository = CoreDataExerciseRepository()) {
        self.exerciseRepository = exerciseRepository
        
        Task {
            await loadData()
        }
    }
    
    // MARK: - Load Data
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 운동 기록 가져오기
            let exercises = try await exerciseRepository.fetchExercises()
            
            // 총 누적 거리 계산
            let totalDistance = exercises.reduce(0) { $0 + $1.distance }
            
            // 티어 계산
            tierProgress = TierCalculator.calculateProgress(totalDistanceInMeters: totalDistance)
            
            // 최근 운동
            recentExercise = exercises.first
            
            // 소셜 피드 (현재는 Mock 데이터)
            feedItems = FeedItem.mockItems
            
        } catch {
            errorMessage = "데이터 로드 실패: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadData()
    }
    
    // MARK: - Social Actions
    func toggleLike(for item: FeedItem) {
        guard let index = feedItems.firstIndex(where: { $0.id == item.id }) else { return }
        
        feedItems[index].isLiked.toggle()
        feedItems[index].likeCount += feedItems[index].isLiked ? 1 : -1
        
        // TODO: 서버에 좋아요 상태 동기화
    }
}

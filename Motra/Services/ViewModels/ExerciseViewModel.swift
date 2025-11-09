//
//  ExerciseViewModel.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/16/25.
//
import SwiftUI

class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: ExerciseRepository
    
    init(repository: ExerciseRepository = CoreDataExerciseRepository()) {
        self.repository = repository
        Task {
            await fetchExercises()
        }
    }
    
    @MainActor
    func fetchExercises() async {
        isLoading = true
        errorMessage = nil
        
        do {
            exercises = try await repository.fetchExercises()
        } catch {
            errorMessage = "데이터 불러오기 실패: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteExercise(_ exercise: Exercise) async {
        do {
            try await repository.deleteExercise(exercise)
            await fetchExercises()
        } catch {
            errorMessage = "운동 기록 삭제 실패: \(error.localizedDescription)"
        }
    }
}

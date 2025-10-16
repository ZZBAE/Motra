//
//  ExerciseViewModel.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/16/25.
//
import SwiftUI
import CoreData

class ExerciseViewModel: ObservableObject {
    @Published var exercises: [ExerciseSession] = []
    
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        fetchExercises()
    }
    
    func fetchExercises() {
        exercises = coreDataManager.fetchAllExerciseSessions()
    }
    
    func deleteExercise(_ session: ExerciseSession) {
        coreDataManager.deleteExerciseSession(session)
        fetchExercises()
    }
}

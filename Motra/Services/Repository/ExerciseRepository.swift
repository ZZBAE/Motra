//
//  ExerciseRepository.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/10/25.
//

import Foundation
import CoreData

protocol ExerciseRepository {
    func fetchExercises() async throws -> [Exercise]
    func saveExercise(_ exercise: Exercise) async throws
    func deleteExercise(_ exercise: Exercise) async throws
}

// MARK: - Core Data Repository
class CoreDataExerciseRepository: ExerciseRepository {
    private let manager: CoreDataManager
    
    init(manager: CoreDataManager = .shared) {
        self.manager = manager
    }
    
    func fetchExercises() async throws -> [Exercise] {
        let request = ExerciseSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseSession.startDate, ascending: false)]
        
        do {
            let sessions = try manager.context.fetch(request)
            return sessions.map { Exercise(session: $0) }
        } catch {
            throw RepositoryError.fetchError
        }
    }
    
    func saveExercise(_ exercise: Exercise) async throws {
        let session = ExerciseSession(context: manager.context)
        session.id = exercise.id
        session.exerciseType = exercise.exerciseType
        session.duration = exercise.duration
        session.distance = exercise.distance
        session.calories = exercise.calories
        session.pace = exercise.pace
        session.startDate = exercise.startDate
        session.endDate = exercise.endDate
        session.notes = exercise.notes
        
        try manager.save()
    }
    
    func deleteExercise(_ exercise: Exercise) async throws {
        let request = ExerciseSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", exercise.id as CVarArg)
        
        do {
            let sessions = try manager.context.fetch(request)
            if let session = sessions.first {
                manager.context.delete(session)
                try manager.save()
            }
        } catch {
            throw RepositoryError.deleteError
        }
    }
}

// MARK: - API Repository (나중에 구현)
class APIExerciseRepository: ExerciseRepository {
    func fetchExercises() async throws -> [Exercise] {
        // API 호출 구현
        fatalError("API 구현 필요")
    }
    
    func saveExercise(_ exercise: Exercise) async throws {
        // API 호출 구현
        fatalError("API 구현 필요")
    }
    
    func deleteExercise(_ exercise: Exercise) async throws {
        // API 호출 구현
        fatalError("API 구현 필요")
    }
}

// MARK: - Errors
enum RepositoryError: Error {
    case fetchError
    case saveError
    case deleteError
}

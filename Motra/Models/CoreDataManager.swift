//
//  Untitled.swift
//  Motra
//
//  Created by Jaeeun Byun on 10/16/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Motra")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data 로딩 실패: \(error), \(error.userInfo)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    // MARK: - ExerciseSession CRUD
    
    func createExerciseSession(
        exerciseType: String,
        duration: Double,
        distance: Double,
        calories: Double,
        pace: Double,
        startDate: Date = Date(),
        endDate: Date? = nil,
        notes: String? = nil
    ) -> ExerciseSession {
        let session = ExerciseSession(context: context)
        session.id = UUID()
        session.exerciseType = exerciseType
        session.duration = duration
        session.distance = distance
        session.calories = calories
        session.pace = pace
        session.startDate = startDate
        session.endDate = endDate
        session.notes = notes
        
        save()
        return session
    }
    
    func fetchAllExerciseSessions() -> [ExerciseSession] {
        let request: NSFetchRequest<ExerciseSession> = ExerciseSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseSession.startDate, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("운동 세션 조회 실패: \(error)")
            return []
        }
    }
    
    func fetchExerciseSession(by id: UUID) -> ExerciseSession? {
        let request: NSFetchRequest<ExerciseSession> = ExerciseSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try context.fetch(request).first
        } catch {
            print("운동 세션 조회 실패: \(error)")
            return nil
        }
    }
    
    func deleteExerciseSession(_ session: ExerciseSession) {
        context.delete(session)
        save()
    }
    
    // MARK: - ExerciseDataPoint CRUD
    
    func addDataPoint(
        to session: ExerciseSession,
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil,
        speed: Double,
        timestamp: Date = Date()
    ) -> ExerciseDataPoint {
        let dataPoint = ExerciseDataPoint(context: context)
        dataPoint.id = UUID()
        dataPoint.latitude = latitude
        dataPoint.longitude = longitude
        dataPoint.altitude = altitude ?? 0
        dataPoint.speed = speed
        dataPoint.timestamp = timestamp
        dataPoint.session = session
        
        save()
        return dataPoint
    }
    
    func fetchDataPoints(for session: ExerciseSession) -> [ExerciseDataPoint] {
        let request: NSFetchRequest<ExerciseDataPoint> = ExerciseDataPoint.fetchRequest()
        request.predicate = NSPredicate(format: "session == %@", session)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseDataPoint.timestamp, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("데이터 포인트 조회 실패: \(error)")
            return []
        }
    }
    
    // MARK: - Save
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Core Data 저장 실패: \(error)")
        }
    }
}

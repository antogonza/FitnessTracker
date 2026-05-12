import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID = UUID()
    var name: String = ""
    var creationDate: Date = Date.now
    
    var defaultRestBetweenSets: Int = 90
    var defaultRestBetweenExercises: Int = 120
    
    // Relaciones opcionales para CloudKit
    @Relationship(deleteRule: .cascade, inverse: \Exercise.routine)
    var exercises: [Exercise]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Session.routine)
    var sessions: [Session]? = []
    
    // Relación inversa con el plan semanal
    @Relationship(inverse: \WeeklySchedule.routine)
    var weeklySchedules: [WeeklySchedule]? = []
    
    init(id: UUID = UUID(), name: String, creationDate: Date = .now, defaultRestBetweenSets: Int = 90, defaultRestBetweenExercises: Int = 120) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.defaultRestBetweenSets = defaultRestBetweenSets
        self.defaultRestBetweenExercises = defaultRestBetweenExercises
    }
}

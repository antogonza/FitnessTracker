import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID = UUID()
    var weight: Double = 0.0
    var reps: Int = 0
    var completedAt: Date = Date.now
    
    var exercise: Exercise?
    var session: Session?
    
    init(id: UUID = UUID(), weight: Double, reps: Int, completedAt: Date = .now, exercise: Exercise? = nil, session: Session? = nil) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.completedAt = completedAt
        self.exercise = exercise
        self.session = session
    }
}

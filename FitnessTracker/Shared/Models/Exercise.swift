import Foundation
import SwiftData

enum ExerciseCategory: String, Codable, CaseIterable {
    case push = "Empuje"
    case pull = "Tirón"
    case legs = "Pierna"
    case core = "Core"
    case other = "Otro"
}

@Model
final class Exercise {
    var id: UUID = UUID()
    var name: String = ""
    var category: ExerciseCategory = ExerciseCategory.other
    var order: Int = 0
    var targetSets: Int = 3
    var targetReps: String = "8-12"
    var targetRPE: Double = 8.0
    
    var restBetweenSets: Int? = nil
    var restBetweenExercises: Int? = nil
    
    var routine: Routine?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet]? = []
    
    init(id: UUID = UUID(), name: String, category: ExerciseCategory = .other, order: Int, targetSets: Int = 3, targetReps: String = "8-12", targetRPE: Double = 8.0, restBetweenSets: Int? = nil, restBetweenExercises: Int? = nil, routine: Routine? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.order = order
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetRPE = targetRPE
        self.restBetweenSets = restBetweenSets
        self.restBetweenExercises = restBetweenExercises
        self.routine = routine
    }
}

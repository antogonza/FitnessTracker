import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID = UUID()
    var name: String = ""
    var order: Int = 0
    
    var routine: Routine?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet]? = []
    
    init(id: UUID = UUID(), name: String, order: Int, routine: Routine? = nil) {
        self.id = id
        self.name = name
        self.order = order
        self.routine = routine
    }
}

import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID = UUID()
    var startTime: Date = Date.now
    var endTime: Date?
    
    var routine: Routine?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.session)
    var sets: [WorkoutSet]? = []
    
    init(id: UUID = UUID(), startTime: Date = .now, endTime: Date? = nil, routine: Routine? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.routine = routine
    }
}

import Foundation
import SwiftData

enum SetType: String, Codable, CaseIterable {
    case normal = "Normal"
    case warmup = "Calentamiento"
    case failure = "Fallo"
    case drop = "Drop Set"
    
    var icon: String {
        switch self {
        case .normal: return "n.circle"
        case .warmup: return "w.circle"
        case .failure: return "f.circle"
        case .drop: return "d.circle"
        }
    }
}

@Model
final class WorkoutSet {
    var id: UUID = UUID()
    var weight: Double = 0.0
    var reps: Int = 0
    var typeRaw: String = SetType.normal.rawValue
    var completedAt: Date = Date.now
    
    var exercise: Exercise?
    var session: Session?
    
    var type: SetType {
        get { SetType(rawValue: typeRaw) ?? .normal }
        set { typeRaw = newValue.rawValue }
    }
    
    init(id: UUID = UUID(), weight: Double, reps: Int, type: SetType = .normal, completedAt: Date = .now, exercise: Exercise? = nil, session: Session? = nil) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.typeRaw = type.rawValue
        self.completedAt = completedAt
        self.exercise = exercise
        self.session = session
    }
}

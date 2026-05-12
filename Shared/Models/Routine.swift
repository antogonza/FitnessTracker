import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID = UUID()
    var name: String = ""
    var creationDate: Date = Date.now
    
    // Las relaciones deben ser opcionales para que CloudKit pueda sincronizar correctamente
    @Relationship(deleteRule: .cascade, inverse: \Exercise.routine)
    var exercises: [Exercise]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Session.routine)
    var sessions: [Session]? = []
    
    init(id: UUID = UUID(), name: String, creationDate: Date = .now) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
    }
}

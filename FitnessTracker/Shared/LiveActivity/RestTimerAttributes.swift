import ActivityKit
import Foundation

/// Define la estructura de datos de la Live Activity del temporizador de descanso.
/// - `ContentState`: valores que cambian en tiempo real (tiempo restante, total)
/// - Atributos estáticos: datos que no cambian durante la Activity (nombre del ejercicio)
struct RestTimerAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        /// Fecha exacta en la que expira el timer (más precisa que un contador)
        var endDate: Date
        /// Duración total del descanso en segundos
        var totalDuration: TimeInterval
        /// Nombre del próximo ejercicio a realizar
        var nextExerciseName: String
    }

    /// Nombre de la rutina (estático, no cambia)
    var routineName: String
}

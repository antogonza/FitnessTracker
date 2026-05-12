import ActivityKit
import Foundation

/// Gestiona el ciclo de vida completo de la Live Activity del temporizador de descanso.
/// Solo se usa desde el target de iOS.
@MainActor
class LiveActivityManager {

    static let shared = LiveActivityManager()

    private var currentActivity: Activity<RestTimerAttributes>?

    private init() {}

    // MARK: - Iniciar

    func start(routineName: String, nextExercise: String, duration: TimeInterval) {
        // Nos aseguramos de no tener ninguna activa ya
        endAll()

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivity] Las Live Activities no están habilitadas en este dispositivo.")
            return
        }

        let attributes = RestTimerAttributes(routineName: routineName)
        let state = RestTimerAttributes.ContentState(
            endDate: Date.now.addingTimeInterval(duration),
            totalDuration: duration,
            nextExerciseName: nextExercise
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: Date.now.addingTimeInterval(duration + 5)),
                pushType: nil
            )
            currentActivity = activity
            print("[LiveActivity] Iniciada con ID: \(activity.id)")
        } catch {
            print("[LiveActivity] Error al iniciar: \(error.localizedDescription)")
        }
    }

    // MARK: - Actualizar (ej. al añadir +30s)

    func update(nextExercise: String, duration: TimeInterval, endDate: Date) {
        guard let activity = currentActivity else { return }

        let newState = RestTimerAttributes.ContentState(
            endDate: endDate,
            totalDuration: duration,
            nextExerciseName: nextExercise
        )

        Task {
            await activity.update(
                ActivityContent(state: newState, staleDate: endDate.addingTimeInterval(5))
            )
        }
    }

    // MARK: - Finalizar

    func end() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            print("[LiveActivity] Finalizada.")
        }
    }

    func endAll() {
        Task {
            for activity in Activity<RestTimerAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            currentActivity = nil
        }
    }
}

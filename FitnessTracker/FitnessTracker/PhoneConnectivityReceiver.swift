import Foundation
import WatchConnectivity

/// Recibe mensajes del Apple Watch en el iPhone y los traduce en
/// acciones sobre el LiveActivityManager (iniciar/actualizar/finalizar).
class PhoneConnectivityReceiver: NSObject, WCSessionDelegate {

    static let shared = PhoneConnectivityReceiver()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("[PhoneConnectivity] Error de activación: \(error.localizedDescription)")
        } else {
            print("[PhoneConnectivity] Sesión activada: \(activationState.rawValue)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let action = message["action"] as? String else { return }

        Task { @MainActor in
            switch action {
            case "timerStart":
                let routineName = message["routineName"] as? String ?? "Entrenamiento"
                let nextExercise = message["nextExercise"] as? String ?? "Siguiente serie"
                let duration = message["duration"] as? TimeInterval ?? 90
                LiveActivityManager.shared.start(
                    routineName: routineName,
                    nextExercise: nextExercise,
                    duration: duration
                )

            case "timerUpdate":
                let nextExercise = message["nextExercise"] as? String ?? "Siguiente serie"
                let duration = message["duration"] as? TimeInterval ?? 90
                let endTimestamp = message["endDate"] as? TimeInterval ?? Date.now.addingTimeInterval(duration).timeIntervalSince1970
                let endDate = Date(timeIntervalSince1970: endTimestamp)
                LiveActivityManager.shared.update(
                    nextExercise: nextExercise,
                    duration: duration,
                    endDate: endDate
                )

            case "timerEnd":
                LiveActivityManager.shared.end()

            default:
                print("[PhoneConnectivity] Acción desconocida: \(action)")
            }
        }
    }
}

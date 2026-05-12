import Foundation
import WatchConnectivity

/// Gestiona el envío de mensajes desde el Apple Watch al iPhone.
/// El Watch no puede controlar Live Activities directamente, así que
/// le delega esa responsabilidad al iPhone via WatchConnectivity.
class WatchToPhoneConnector: NSObject, WCSessionDelegate {

    static let shared = WatchToPhoneConnector()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Mensajes al iPhone

    /// Notifica al iPhone que debe INICIAR una Live Activity
    func sendTimerStarted(routineName: String, nextExercise: String, duration: TimeInterval) {
        guard WCSession.default.isReachable else { return }
        let message: [String: Any] = [
            "action": "timerStart",
            "routineName": routineName,
            "nextExercise": nextExercise,
            "duration": duration,
            "endDate": Date.now.addingTimeInterval(duration).timeIntervalSince1970
        ]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("[WatchConnectivity] Error enviando timerStart: \(error.localizedDescription)")
        }
    }

    /// Notifica al iPhone que debe FINALIZAR la Live Activity
    func sendTimerEnded() {
        guard WCSession.default.isReachable else { return }
        let message: [String: Any] = ["action": "timerEnd"]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("[WatchConnectivity] Error enviando timerEnd: \(error.localizedDescription)")
        }
    }

    /// Notifica al iPhone que se añadieron segundos (ej. +30s)
    func sendTimerUpdated(nextExercise: String, duration: TimeInterval, endDate: Date) {
        guard WCSession.default.isReachable else { return }
        let message: [String: Any] = [
            "action": "timerUpdate",
            "nextExercise": nextExercise,
            "duration": duration,
            "endDate": endDate.timeIntervalSince1970
        ]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("[WatchConnectivity] Error enviando timerUpdate: \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("[WatchConnectivity] Error de activación: \(error.localizedDescription)")
        }
    }
}

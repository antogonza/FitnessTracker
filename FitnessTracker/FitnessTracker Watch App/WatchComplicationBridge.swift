import Foundation
import WidgetKit

/// Escribe/lee los datos de la complicación de watchOS.
/// Usa UserDefaults con el App Group del Watch para que la extensión de
/// complicación pueda leerlos sin acceso a SwiftData.
struct WatchComplicationBridge {

    static let suiteID = "group.com.antogonza.FitnessTracker.watch"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteID) ?? .standard
    }

    private enum Key {
        static let streak      = "wc_streak"
        static let todayRoutine = "wc_today_routine"
        static let lastWorkout  = "wc_last_workout"
    }

    // MARK: - Escritura (llamada desde la Watch App)

    static func update(streak: Int, todayRoutine: String?, lastWorkoutDate: Date?) {
        defaults.set(streak, forKey: Key.streak)
        defaults.set(todayRoutine ?? "", forKey: Key.todayRoutine)
        if let date = lastWorkoutDate {
            defaults.set(date.timeIntervalSince1970, forKey: Key.lastWorkout)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Lectura (llamada desde la extensión de complicación)

    static func readStreak() -> Int {
        defaults.integer(forKey: Key.streak)
    }

    static func readTodayRoutine() -> String {
        defaults.string(forKey: Key.todayRoutine) ?? ""
    }

    static func readLastWorkoutDate() -> Date? {
        let ts = defaults.double(forKey: Key.lastWorkout)
        return ts > 0 ? Date(timeIntervalSince1970: ts) : nil
    }

    static func readSnapshot() -> WatchComplicationSnapshot {
        WatchComplicationSnapshot(
            streak: readStreak(),
            todayRoutine: readTodayRoutine(),
            lastWorkoutDate: readLastWorkoutDate()
        )
    }
}

// MARK: - Snapshot de datos

struct WatchComplicationSnapshot {
    let streak: Int
    let todayRoutine: String
    let lastWorkoutDate: Date?

    var hasWorkoutToday: Bool {
        guard let date = lastWorkoutDate else { return false }
        return Calendar.current.isDateInToday(date)
    }

    static var placeholder: WatchComplicationSnapshot {
        WatchComplicationSnapshot(streak: 5, todayRoutine: "Día de Empuje", lastWorkoutDate: nil)
    }
}

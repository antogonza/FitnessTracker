import Foundation
import WidgetKit

/// Puente de datos entre la app principal y los Widgets/Extensions.
/// Usa UserDefaults con el App Group compartido para persistir métricas clave.
///
/// REQUISITO: Ambos targets (FitnessTracker e FitnessTrackerWidgets)
/// deben tener el mismo App Group activado en Signing & Capabilities:
/// "group.com.antogonza.FitnessTracker"
struct WidgetDataBridge {

    static let appGroupID = "group.com.antogonza.FitnessTracker"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    // MARK: - Claves

    private enum Key {
        static let totalSessions   = "widget_totalSessions"
        static let totalVolume     = "widget_totalVolume"
        static let currentStreak   = "widget_currentStreak"
        static let lastWorkoutDate = "widget_lastWorkoutDate"
        static let lastRoutineName = "widget_lastRoutineName"
    }

    // MARK: - Escritura (llamada desde la app iOS)

    static func update(totalSessions: Int,
                       totalVolume: Double,
                       currentStreak: Int,
                       lastWorkoutDate: Date?,
                       lastRoutineName: String) {
        defaults.set(totalSessions,   forKey: Key.totalSessions)
        defaults.set(totalVolume,     forKey: Key.totalVolume)
        defaults.set(currentStreak,   forKey: Key.currentStreak)
        defaults.set(lastRoutineName, forKey: Key.lastRoutineName)
        if let date = lastWorkoutDate {
            defaults.set(date.timeIntervalSince1970, forKey: Key.lastWorkoutDate)
        }

        // Notifica a WidgetKit que debe recargar los timelines
        #if os(iOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    // MARK: - Lectura (llamada desde el Widget Extension)

    static func read() -> WidgetSnapshot {
        let totalSessions   = defaults.integer(forKey: Key.totalSessions)
        let totalVolume     = defaults.double(forKey: Key.totalVolume)
        let currentStreak   = defaults.integer(forKey: Key.currentStreak)
        let lastRoutineName = defaults.string(forKey: Key.lastRoutineName) ?? "—"
        let timestamp       = defaults.double(forKey: Key.lastWorkoutDate)
        let lastWorkoutDate = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil

        return WidgetSnapshot(
            totalSessions: totalSessions,
            totalVolume: totalVolume,
            currentStreak: currentStreak,
            lastWorkoutDate: lastWorkoutDate,
            lastRoutineName: lastRoutineName
        )
    }
}

// MARK: - Snapshot de datos para el Widget

struct WidgetSnapshot {
    let totalSessions: Int
    let totalVolume: Double
    let currentStreak: Int
    let lastWorkoutDate: Date?
    let lastRoutineName: String

    static var placeholder: WidgetSnapshot {
        WidgetSnapshot(
            totalSessions: 24,
            totalVolume: 18_540,
            currentStreak: 5,
            lastWorkoutDate: Calendar.current.date(byAdding: .day, value: -1, to: .now),
            lastRoutineName: "Día de Empuje"
        )
    }

    var formattedVolume: String {
        if totalVolume >= 1000 {
            return String(format: "%.1f t", totalVolume / 1000)
        }
        return String(format: "%.0f kg", totalVolume)
    }

    var lastWorkoutRelative: String {
        guard let date = lastWorkoutDate else { return "Sin datos" }
        if Calendar.current.isDateInToday(date) { return "Hoy" }
        if Calendar.current.isDateInYesterday(date) { return "Ayer" }
        let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
        return "Hace \(days) días"
    }
}

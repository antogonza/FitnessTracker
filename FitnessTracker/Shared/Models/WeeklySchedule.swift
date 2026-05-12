import Foundation
import SwiftData

/// Modelo para programar qué rutina toca cada día de la semana.
@Model
class WeeklySchedule {
    var weekday: Int = 0      // 1 = domingo, 2 = lunes, ..., 7 = sábado
    var routine: Routine?

    init(weekday: Int, routine: Routine? = nil) {
        self.weekday = weekday
        self.routine = routine
    }

    // MARK: - Helpers estáticos

    static var todayWeekday: Int {
        Calendar.current.component(.weekday, from: Date())
    }

    static let weekdaysStartingMonday = [2, 3, 4, 5, 6, 7, 1]

    static func dayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.weekdaySymbols[weekday - 1].capitalized
    }

    static func shortDayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.shortWeekdaySymbols[weekday - 1].uppercased()
    }
}

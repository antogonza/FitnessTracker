import SwiftData
import Foundation
import WidgetKit

/// Calcula las métricas clave a partir del ModelContext y las persiste
/// en el App Group para que el Widget las lea.
@MainActor
public struct WidgetDataUpdater {

    public static func updateWidgetData(modelContext: ModelContext) {
        do {
            // Todas las sesiones completadas
            let sessionDescriptor = FetchDescriptor<Session>(
                predicate: #Predicate<Session> { $0.endTime != nil },
                sortBy: [SortDescriptor(\.startTime, order: .reverse)]
            )
            let sessions = (try? modelContext.fetch(sessionDescriptor)) ?? []

            // Todas las series
            let sets = (try? modelContext.fetch(FetchDescriptor<WorkoutSet>())) ?? []

            let totalSessions   = sessions.count
            let totalVolume     = sets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            let lastSession     = sessions.first
            let lastRoutineName = lastSession?.routine?.name ?? "—"
            let lastWorkoutDate = lastSession?.startTime

            // Calcular racha actual (días consecutivos con al menos una sesión)
            let streak = calculateStreak(from: sessions)

            WidgetDataBridge.update(
                totalSessions: totalSessions,
                totalVolume: totalVolume,
                currentStreak: streak,
                lastWorkoutDate: lastWorkoutDate,
                lastRoutineName: lastRoutineName
            )
        }
    }

    // MARK: - Cálculo de racha

    private static func calculateStreak(from sessions: [Session]) -> Int {
        let calendar = Calendar.current

        // Obtener días únicos con sesión completada, ordenados descendente
        let trainingDays = Set(sessions.compactMap { session -> Date? in
            guard let _ = session.endTime else { return nil }
            return calendar.startOfDay(for: session.startTime)
        }).sorted(by: >)

        guard !trainingDays.isEmpty else { return 0 }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        for day in trainingDays {
            if day == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if day < checkDate {
                break // Hay un hueco, se rompe la racha
            }
        }

        return streak
    }
}

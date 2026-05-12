import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct FitnessProvider: TimelineProvider {

    func placeholder(in context: Context) -> FitnessEntry {
        FitnessEntry(date: .now, data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (FitnessEntry) -> Void) {
        completion(FitnessEntry(date: .now, data: WidgetDataBridge.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FitnessEntry>) -> Void) {
        let data  = WidgetDataBridge.read()
        let entry = FitnessEntry(date: .now, data: data)
        // Se actualiza cada 2 horas o cuando la app llame a reloadAllTimelines()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Entry

struct FitnessEntry: TimelineEntry {
    let date: Date
    let data: WidgetSnapshot
}

// MARK: - Small Widget View

struct FitnessSmallWidgetView: View {
    let data: WidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
                Text("FitnessTracker")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Racha
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(data.currentStreak)")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.orange)
                    Text("🔥")
                        .font(.title2)
                }
                Text("días seguidos")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Último entreno
            VStack(alignment: .leading, spacing: 1) {
                Text(data.lastRoutineName)
                    .font(.caption.bold())
                    .lineLimit(1)
                Text(data.lastWorkoutRelative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

// MARK: - Medium Widget View

struct FitnessMediumWidgetView: View {
    let data: WidgetSnapshot

    var body: some View {
        HStack(spacing: 0) {

            // Columna izquierda — Racha y último entreno
            VStack(alignment: .leading, spacing: 8) {
                Label("FitnessTracker", systemImage: "dumbbell.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .labelStyle(.titleAndIcon)

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(data.currentStreak)")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(.orange)
                        Text("🔥")
                            .font(.title)
                    }
                    Text("días seguidos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(data.lastRoutineName)
                        .font(.caption.bold())
                        .lineLimit(1)
                    Text(data.lastWorkoutRelative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .padding(.vertical, 10)

            // Columna derecha — Stats
            VStack(spacing: 0) {
                StatCell(
                    icon: "figure.strengthtraining.traditional",
                    color: .blue,
                    value: "\(data.totalSessions)",
                    label: "sesiones"
                )

                Divider()

                StatCell(
                    icon: "scalemass.fill",
                    color: .green,
                    value: data.formattedVolume,
                    label: "volumen"
                )
            }
            .frame(maxWidth: 130)
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

// MARK: - Componente auxiliar

struct StatCell: View {
    let icon: String
    let color: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            Text(value)
                .font(.system(.title3, design: .rounded).bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Widget Definition

struct FitnessTrackerWidgets: Widget {
    let kind: String = "FitnessTrackerWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FitnessProvider()) { entry in
            FitnessWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FitnessTracker")
        .description("Tu racha, volumen total y último entrenamiento.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry View (dispatcher por tamaño)

struct FitnessWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: FitnessEntry

    var body: some View {
        switch family {
        case .systemSmall:
            FitnessSmallWidgetView(data: entry.data)
        case .systemMedium:
            FitnessMediumWidgetView(data: entry.data)
        default:
            FitnessSmallWidgetView(data: entry.data)
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    FitnessTrackerWidgets()
} timeline: {
    FitnessEntry(date: .now, data: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    FitnessTrackerWidgets()
} timeline: {
    FitnessEntry(date: .now, data: .placeholder)
}

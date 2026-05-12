import WidgetKit
import SwiftUI

struct ComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> ()) {
        let entry = ComplicationEntry(date: Date(), data: WatchComplicationBridge.readSnapshot())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = ComplicationEntry(date: Date(), data: WatchComplicationBridge.readSnapshot())
        
        // Actualizar cada hora para asegurar que el cambio de día se refleje
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct ComplicationEntry: TimelineEntry {
    let date: Date
    let data: WatchComplicationSnapshot
}

struct FitnessTrackerWatchWidgetsEntryView : View {
    var entry: ComplicationProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularComplication(data: entry.data)
        case .accessoryCorner:
            CornerComplication(data: entry.data)
        case .accessoryRectangular:
            RectangularComplication(data: entry.data)
        default:
            CircularComplication(data: entry.data)
        }
    }
}

// MARK: - Diseños por tipo de complicación

struct CircularComplication: View {
    let data: WatchComplicationSnapshot
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -2) {
                Text("\(data.streak)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                Text("🔥")
                    .font(.system(size: 10))
            }
        }
        .containerBackground(for: .widget) { Color.black }
    }
}

struct CornerComplication: View {
    let data: WatchComplicationSnapshot
    
    var body: some View {
        ZStack {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 12))
                .foregroundStyle(.orange)
                .widgetLabel {
                    Text("\(data.streak) días 🔥")
                }
        }
        .containerBackground(for: .widget) { Color.black }
    }
}

struct RectangularComplication: View {
    let data: WatchComplicationSnapshot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.orange)
                Text("Fitness")
                    .font(.caption2.bold())
                Spacer()
                Text("\(data.streak) 🔥")
                    .font(.caption2.bold())
            }
            
            if !data.todayRoutine.isEmpty {
                Text(data.todayRoutine)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
            } else {
                Text("Descanso")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            
            Text(data.hasWorkoutToday ? "Completado ✅" : "Pendiente ⏳")
                .font(.system(size: 10))
                .foregroundStyle(data.hasWorkoutToday ? .green : .secondary)
        }
        .containerBackground(for: .widget) { Color.black }
    }
}

struct FitnessTrackerWatchWidgets: Widget {
    let kind: String = "FitnessTrackerWatchWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplicationProvider()) { entry in
            FitnessTrackerWatchWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Estado Fitness")
        .description("Muestra tu racha y entrenamiento del día.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular])
    }
}

#Preview(as: .accessoryRectangular) {
    FitnessTrackerWatchWidgets()
} timeline: {
    ComplicationEntry(date: .now, data: .placeholder)
}

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Principal

struct RestTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            // Vista de pantalla de bloqueo y banner de notificación
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Vista expandida (al mantener pulsada la Dynamic Island)
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.attributes.routineName)
                            .font(.caption2)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "dumbbell.fill")
                            .foregroundStyle(.orange)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.title2.monospacedDigit().bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundStyle(.green)
                        Text("Siguiente: \(context.state.nextExerciseName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                // Vista compacta izquierda (píldora pequeña)
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
            } compactTrailing: {
                // Vista compacta derecha — el contador en tiempo real
                Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(.white)
                    .frame(width: 40)
            } minimal: {
                // Vista mínima cuando hay varias Activities activas
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            }
            .keylineTint(.orange)
        }
    }
}

// MARK: - UI de Pantalla de Bloqueo

struct LockScreenView: View {
    let context: ActivityViewContext<RestTimerAttributes>

    var progress: Double {
        let elapsed = context.state.endDate.timeIntervalSinceNow
        let clamped = max(0, min(elapsed, context.state.totalDuration))
        return clamped / context.state.totalDuration
    }

    var body: some View {
        HStack(spacing: 16) {
            // Ícono y nombre de rutina
            VStack(alignment: .leading, spacing: 4) {
                Label(context.attributes.routineName, systemImage: "dumbbell.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .lineLimit(1)

                Text("Descansando...")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Siguiente: \(context.state.nextExerciseName)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Temporizador circular
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: progress)

                Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                    .font(.system(.title3, design: .monospaced).bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 72, height: 72)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.85))
        )
    }
}

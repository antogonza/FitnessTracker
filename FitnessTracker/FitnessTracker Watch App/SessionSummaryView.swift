import SwiftUI
import SwiftData

struct SessionSummaryView: View {
    @Environment(\.modelContext) private var modelContext
    
    let session: Session
    let onFinish: () -> Void
    
    var totalVolume: Double {
        session.sets?.reduce(0) { $0 + ($1.weight * Double($1.reps)) } ?? 0
    }
    
    var duration: TimeInterval {
        let end = session.endTime ?? Date.now
        return end.timeIntervalSince(session.startTime)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: "flag.checkered.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, options: .nonRepeating)
                
                Text("¡Buen trabajo!")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    SummaryRow(icon: "clock.fill", color: .blue, title: "Tiempo", value: formatDuration(duration))
                    SummaryRow(icon: "dumbbell.fill", color: .orange, title: "Volumen", value: "\(String(format: "%.1f", totalVolume)) kg")
                    SummaryRow(icon: "list.number", color: .purple, title: "Series", value: "\(session.sets?.count ?? 0)")
                }
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
                
                Button(action: {
                    let now = Date.now
                    session.endTime = now
                    
                    // Guardado forzado y notificación al sistema
                    do {
                        try modelContext.save()
                        // Notificamos al bridge de complicaciones (Fase 17)
                        WidgetDataUpdater.updateWidgetData(modelContext: modelContext)
                        print("✅ Sesión finalizada y guardada: \(now)")
                    } catch {
                        print("❌ Error al guardar sesión: \(error)")
                    }
                    
                    onFinish()
                }) {
                    Text("Finalizar")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SummaryRow: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.system(.footnote, design: .rounded))
    }
}

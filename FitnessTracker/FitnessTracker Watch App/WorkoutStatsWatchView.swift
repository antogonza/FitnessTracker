import SwiftUI
import SwiftData

struct WorkoutStatsWatchView: View {
    let session: Session
    @EnvironmentObject var workoutManager: WorkoutManager
    
    private var totalVolume: Double {
        let allSets = session.sets ?? []
        return allSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(Theme.primary)
                    Text("ESTADÍSTICAS")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Theme.primary)
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Timer principal
                VStack(spacing: 2) {
                    Text("TIEMPO TOTAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    TimelineView(.periodic(from: .now, by: 1.0)) { context in
                        Text(formatDuration(from: session.startTime, to: context.date))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(white: 0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Grid de métricas
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    StatBox(
                        title: "KILOS",
                        value: String(format: "%.0f", totalVolume),
                        unit: "KG",
                        icon: "scalemass.fill",
                        color: .orange
                    )
                    
                    StatBox(
                        title: "CALORÍAS",
                        value: String(format: "%.0f", workoutManager.activeEnergy),
                        unit: "KCAL",
                        icon: "flame.fill",
                        color: .red
                    )
                    
                    StatBox(
                        title: "PULSACIONES",
                        value: String(format: "%.0f", workoutManager.heartRate),
                        unit: "BPM",
                        icon: "heart.fill",
                        color: .pink
                    )
                    
                    StatBox(
                        title: "SERIES",
                        value: "\(session.sets?.count ?? 0)",
                        unit: "SETS",
                        icon: "list.bullet.indent",
                        color: .blue
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

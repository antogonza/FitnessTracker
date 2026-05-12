import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.startTime, order: .reverse) private var sessions: [Session]
    @Query private var sets: [WorkoutSet]
    @Query private var exercises: [Exercise]
    
    // Métricas globales
    private var totalSessions: Int {
        sessions.filter { $0.endTime != nil }.count
    }
    
    private var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    // Datos para el gráfico de distribución de rutinas
    private var routineDistribution: [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for session in sessions where session.endTime != nil {
            if let name = session.routine?.name {
                counts[name, default: 0] += 1
            }
        }
        return counts.map { (name: $0.key, count: $0.value) }.sorted(by: { $0.count > $1.count })
    }
    
    // Ejercicios agrupados por categoría
    private var exercisesByCategory: [(category: ExerciseCategory, exercises: [String])] {
        var grouped: [ExerciseCategory: Set<String>] = [:]
        for exercise in exercises {
            grouped[exercise.category, default: []].insert(exercise.name)
        }
        return grouped.map { (category: $0.key, exercises: Array($0.value).sorted()) }
            .sorted(by: { $0.category.rawValue < $1.category.rawValue })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Tarjetas de Métricas
                    HStack(spacing: 15) {
                        MetricCard(
                            title: "Entrenos",
                            value: "\(totalSessions)",
                            icon: "figure.run",
                            color: .blue
                        )
                        MetricCard(
                            title: "Volumen (kg)",
                            value: String(format: "%.0f", totalVolume),
                            icon: "scalemass",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Gráfico de Distribución (Donut)
                    if !routineDistribution.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Distribución de Rutinas")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(routineDistribution, id: \.name) { item in
                                    SectorMark(
                                        angle: .value("Entrenamientos", item.count),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 1.5
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(by: .value("Rutina", item.name))
                                }
                            }
                            .frame(height: 250)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Lista de Récords y Progreso por Categoría
                    VStack(alignment: .leading) {
                        Text("Récords y Progreso")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(exercisesByCategory, id: \.category.rawValue) { group in
                            VStack(alignment: .leading, spacing: 0) {
                                Text(group.category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 10)
                                    .padding(.horizontal)
                                    .padding(.bottom, 4)
                                
                                VStack(spacing: 0) {
                                    ForEach(group.exercises, id: \.self) { exerciseName in
                                        NavigationLink(destination: ExerciseProgressView(exerciseName: exerciseName)) {
                                            HStack {
                                                Text(exerciseName)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.secondary)
                                                    .font(.caption)
                                            }
                                            .padding()
                                        }
                                        if exerciseName != group.exercises.last {
                                            Divider().padding(.leading)
                                        }
                                    }
                                }
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                // Espera brevemente para dar tiempo a CloudKit a sincronizar
                try? await Task.sleep(nanoseconds: 800_000_000)
            }
            .navigationTitle("Estadísticas")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(.preview)
}

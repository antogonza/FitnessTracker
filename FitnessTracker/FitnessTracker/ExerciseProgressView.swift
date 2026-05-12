import SwiftUI
import SwiftData
import Charts

struct ExerciseProgressView: View {
    let exerciseName: String
    
    @Query(sort: \WorkoutSet.completedAt) private var allSets: [WorkoutSet]
    
    private var sets: [WorkoutSet] {
        allSets.filter { $0.exercise?.name == exerciseName }
    }
    
    private var maxWeight: Double {
        sets.map { $0.weight }.max() ?? 0
    }
    
    // Agrupa las series por día para mostrar el progreso del peso máximo de ese día
    private var chartData: [(date: Date, maxWeight: Double)] {
        var dict: [Date: Double] = [:]
        let calendar = Calendar.current
        for set in sets {
            let day = calendar.startOfDay(for: set.completedAt)
            let currentMax = dict[day] ?? 0
            if set.weight > currentMax {
                dict[day] = set.weight
            }
        }
        return dict.map { (date: $0.key, maxWeight: $0.value) }.sorted(by: { $0.date < $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Tarjeta de Récord Personal (PR)
                VStack {
                    Text("Récord Personal (Máx Peso)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", maxWeight)) kg")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Gráfica de evolución
                if chartData.count > 1 {
                    VStack(alignment: .leading) {
                        Text("Evolución de Peso Máximo")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        Chart {
                            ForEach(chartData, id: \.date) { item in
                                LineMark(
                                    x: .value("Fecha", item.date),
                                    y: .value("Peso", item.maxWeight)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(Color.green)
                                .symbol(Circle())
                                
                                AreaMark(
                                    x: .value("Fecha", item.date),
                                    y: .value("Peso", item.maxWeight)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                        }
                        .frame(height: 250)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(format: .dateTime.day().month())
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
                    Text("Sigue entrenando para ver tu evolución gráfica (mínimo 2 sesiones en días distintos).")
                        .foregroundColor(.secondary)
                        .padding()
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(exerciseName)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

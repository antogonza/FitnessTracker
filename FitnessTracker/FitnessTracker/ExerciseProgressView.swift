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
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Tarjeta de Récord Personal (PR)
                    VStack(spacing: 8) {
                        Text("RÉCORD PERSONAL")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(String(format: "%.1f", maxWeight))")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(Theme.successGradient)
                            Text("kg")
                                .font(.system(.title3, design: .rounded).bold())
                                .foregroundStyle(Theme.success)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Theme.glassBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Theme.success.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Gráfica de evolución
                    VStack(alignment: .leading, spacing: 20) {
                        Text("EVOLUCIÓN")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        if chartData.count > 1 {
                            Chart {
                                ForEach(chartData, id: \.date) { item in
                                    LineMark(
                                        x: .value("Fecha", item.date),
                                        y: .value("Peso", item.maxWeight)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Theme.successGradient)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .symbol {
                                        Circle()
                                            .fill(Theme.success)
                                            .frame(width: 8, height: 8)
                                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                    }
                                    
                                    AreaMark(
                                        x: .value("Fecha", item.date),
                                        y: .value("Peso", item.maxWeight)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Theme.success.opacity(0.2), Color.clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                }
                            }
                            .frame(height: 240)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(Color.white.opacity(0.1))
                                    AxisValueLabel(format: .dateTime.day().month(), centered: true)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(Color.white.opacity(0.1))
                                    AxisValueLabel()
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Theme.primary.opacity(0.3))
                                Text("Sigue entrenando para ver tu evolución gráfica.")
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    }
                    .padding()
                    .background(Theme.glassBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
    }
}


import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.startTime, order: .reverse) private var sessions: [Session]
    @Query private var exercises: [Exercise]
    @Query private var allSets: [WorkoutSet]
    
    // Cálculos de datos
    private var totalEntrenos: Int {
        sessions.filter { $0.endTime != nil }.count
    }
    
    private var entrenosEsteMes: Int {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return sessions.filter { ($0.startTime ?? Date()) > monthAgo && $0.endTime != nil }.count
    }
    
    private var volumenTotalK: String {
        let total = allSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        return String(format: "%.1fk", total / 1000.0)
    }
    
    private var consistencia: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyCount = sessions.filter { ($0.startTime ?? Date()) > weekAgo && $0.endTime != nil }.count
        let ratio = Double(weeklyCount) / 4.0
        return min(max(ratio, 0.2), 0.95)
    }

    private var routineStats: [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for session in sessions where session.endTime != nil {
            if let category = session.routine?.category {
                counts[category, default: 0] += 1
            }
        }
        let result = counts.map { (name: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
            .prefix(5)
        return Array(result)
    }

    private var prsByCategory: [(category: ExerciseCategory, prs: [PersonalRecord])] {
        var result: [ExerciseCategory: [PersonalRecord]] = [:]
        
        // Agrupamos por nombre único para encontrar el PR real
        let groupedByExercise = Dictionary(grouping: allSets, by: { $0.exercise?.name ?? "Unknown" })
        
        for (name, sets) in groupedByExercise {
            if let bestSet = sets.max(by: { $0.weight < $1.weight }),
               let exercise = bestSet.exercise {
                let pr = PersonalRecord(name: name, weight: bestSet.weight, reps: bestSet.reps)
                result[exercise.category, default: []].append(pr)
            }
        }
        
        return ExerciseCategory.allCases.compactMap { cat in
            guard let list = result[cat], !list.isEmpty else { return nil }
            return (category: cat, prs: list.sorted(by: { $0.weight > $1.weight }))
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text("FITNESSTRACKER")
                        .font(.system(size: 14, weight: .black))
                        .tracking(2)
                        .foregroundStyle(Theme.primary)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(Color(white: 0.08))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Tarjetas Principales
                        VStack(spacing: 16) {
                            StatCard(
                                title: "TOTAL ENTRENOS",
                                value: "\(totalEntrenos)",
                                subValue: "+\(entrenosEsteMes) este mes",
                                icon: "arrow.up.right.circle.fill",
                                iconColor: .orange,
                                valueColor: .orange
                            )
                            
                            StatCard(
                                title: "VOLUMEN (KG)",
                                value: volumenTotalK,
                                subValue: "Nuevo récord semanal",
                                icon: "chart.bar.fill",
                                iconColor: .cyan,
                                valueColor: .cyan
                            )
                            
                            StatCard(
                                title: "CONSISTENCIA",
                                content: AnyView(
                                    CircularProgressView(progress: consistencia)
                                ),
                                icon: "bolt.fill",
                                iconColor: .blue
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Distribución de Rutinas
                        if !routineStats.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Distribución de Rutinas")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                
                                HStack {
                                    Chart {
                                        ForEach(routineStats, id: \.name) { item in
                                            SectorMark(
                                                angle: .value("Count", item.count),
                                                innerRadius: .ratio(0.7),
                                                angularInset: 2
                                            )
                                            .foregroundStyle(by: .value("Name", item.name))
                                            .cornerRadius(4)
                                        }
                                    }
                                    .chartLegend(.hidden)
                                    .frame(width: 160, height: 160)
                                    .overlay {
                                        VStack(spacing: 2) {
                                            Text("VARIEDAD")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.6))
                                            Text("Alta")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(routineStats.indices, id: \.self) { i in
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(chartColor(for: i))
                                                    .frame(width: 8, height: 8)
                                                Text(routineStats[i].name)
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(.white.opacity(0.7))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color(white: 0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                        }
                        
                        // Hero Image Section
                        ZStack(alignment: .bottomLeading) {
                            Image("gym_hero_dark")
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .overlay(
                                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top)
                                )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Supérate hoy.")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white)
                                Text("Has superado tus marcas en 4 ejercicios esta semana. Mantén el ritmo.")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineLimit(2)
                            }
                            .padding()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                        
                        // Récords Personales
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Récords Personales")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal)
                            
                            ForEach(prsByCategory, id: \.category) { section in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: iconForCategory(section.category))
                                            .foregroundStyle(colorForCategory(section.category))
                                        Text(section.category.rawValue.uppercased())
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundStyle(colorForCategory(section.category))
                                    }
                                    .padding(.horizontal)
                                    
                                    VStack(spacing: 12) {
                                        ForEach(section.prs) { pr in
                                            HStack {
                                                Text(pr.name)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundStyle(.white)
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .trailing, spacing: 2) {
                                                    Text("\(Int(pr.weight)) kg")
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundStyle(colorForCategory(section.category))
                                                    Text("\(pr.reps) REPS")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundStyle(.white.opacity(0.4))
                                                }
                                            }
                                            .padding()
                                            .background(Color(white: 0.08))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.bottom, 16)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
    }
    
    private func iconForCategory(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .push: return "bolt.fill"
        case .pull: return "figure.back.workout"
        case .legs: return "hexagon.fill"
        default: return "star.fill"
        }
    }
    
    private func colorForCategory(_ cat: ExerciseCategory) -> Color {
        switch cat {
        case .push: return .orange
        case .pull: return .cyan
        case .legs: return .blue
        default: return .white
        }
    }
    
    private func chartColor(for index: Int) -> Color {
        let colors: [Color] = [.orange, .cyan, .blue, .purple, .pink]
        return colors[index % colors.count]
    }
}

struct StatCard: View {
    let title: String
    var value: String? = nil
    var subValue: String? = nil
    var content: AnyView? = nil
    let icon: String
    let iconColor: Color
    var valueColor: Color = .white
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 40) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                
                if let val = value {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(val)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(valueColor)
                        if let sub = subValue {
                            Text(sub)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                } else if let view = content {
                    view
                }
            }
            
            Spacer()
            
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.system(size: 20))
        }
        .padding(24)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [.orange, .red], center: .center),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 80, height: 80)
    }
}

struct PersonalRecord: Identifiable {
    let id = UUID()
    let name: String
    let weight: Double
    let reps: Int
}

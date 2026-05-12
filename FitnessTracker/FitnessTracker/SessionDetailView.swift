import SwiftUI
import SwiftData

struct SessionDetailView: View {
    let session: Session
    
    // Agrupamos las series por ejercicio
    var groupedSets: [(Exercise, [WorkoutSet])] {
        guard let sets = session.sets else { return [] }
        
        let grouped = Dictionary(grouping: sets) { $0.exercise }
        // Eliminamos los nil y ordenamos
        let validGroups = grouped.compactMap { (key, value) -> (Exercise, [WorkoutSet])? in
            guard let exercise = key else { return nil }
            return (exercise, value.sorted(by: { $0.completedAt < $1.completedAt }))
        }
        
        return validGroups.sorted(by: { $0.0.order < $1.0.order })
    }
    
    var totalVolume: Double {
        session.sets?.reduce(0) { $0 + ($1.weight * Double($1.reps)) } ?? 0
    }
    
    var body: some View {
        List {
            Section("Resumen") {
                HStack {
                    Text("Inicio")
                    Spacer()
                    Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Fin")
                    Spacer()
                    Text(session.endTime?.formatted(date: .abbreviated, time: .shortened) ?? "En progreso")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Volumen total")
                    Spacer()
                    Text("\(String(format: "%.1f", totalVolume)) kg")
                        .foregroundColor(.secondary)
                }
            }
            
            ForEach(groupedSets, id: \.0.id) { exercise, sets in
                Section(exercise.name) {
                    ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            Text("Serie \(index + 1)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(String(format: "%.1f", set.weight)) kg × \(set.reps)")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .navigationTitle(session.routine?.name ?? "Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

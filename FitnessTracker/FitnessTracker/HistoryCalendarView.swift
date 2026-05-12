import SwiftUI
import SwiftData

struct HistoryCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.startTime, order: .reverse) private var sessions: [Session]
    
    @State private var selectedDate: Date = Date()
    @State private var sessionToDelete: Session?
    @State private var showDeleteConfirmation = false
    
    // Filtramos las sesiones del día seleccionado
    var sessionsForSelectedDate: [Session] {
        sessions.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
    }
    
    // Opcional: Para marcar en el calendario los días con entreno
    // Se puede usar un decorador en iOS 16+, pero DatePicker graphical ya es suficientemente visual.
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Selecciona una fecha",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Divider()
                
                List {
                    if sessionsForSelectedDate.isEmpty {
                        Text("No hay entrenamientos este día.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(sessionsForSelectedDate) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                VStack(alignment: .leading) {
                                    Text(session.routine?.name ?? "Rutina eliminada")
                                        .font(.headline)
                                    Text("\(session.startTime.formatted(date: .omitted, time: .shortened)) - \(session.endTime?.formatted(date: .omitted, time: .shortened) ?? "En progreso")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    sessionToDelete = session
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    try? modelContext.save()
                }
            }
            .navigationTitle("Historial")
            .onAppear {
                WidgetDataUpdater.updateWidgetData(modelContext: modelContext)
                if sessions.isEmpty {
                    #if targetEnvironment(simulator)
                    generateMockData()
                    #endif
                }
            }
            .alert("¿Eliminar entrenamiento?", isPresented: $showDeleteConfirmation) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    if let session = sessionToDelete {
                        modelContext.delete(session)
                        try? modelContext.save()
                        WidgetDataUpdater.updateWidgetData(modelContext: modelContext)
                    }
                }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }
    
    private func generateMockData() {
        let routine1 = Routine(name: "Día de Empuje")
        let routine2 = Routine(name: "Día de Tirón")
        let routine3 = Routine(name: "Día de Pierna")
        
        modelContext.insert(routine1)
        modelContext.insert(routine2)
        modelContext.insert(routine3)
        
        let ex1 = Exercise(name: "Press Banca", order: 0, targetSets: 4, routine: routine1)
        let ex2 = Exercise(name: "Press Inclinado", order: 1, targetSets: 3, routine: routine1)
        
        let ex3 = Exercise(name: "Dominadas", order: 0, targetSets: 4, routine: routine2)
        let ex4 = Exercise(name: "Remo en barra", order: 1, targetSets: 3, routine: routine2)
        
        let ex5 = Exercise(name: "Sentadillas", order: 0, targetSets: 4, routine: routine3)
        let ex6 = Exercise(name: "Prensa", order: 1, targetSets: 3, routine: routine3)
        
        // Sesión hace 3 días (Empuje)
        let date1 = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let s1 = Session(startTime: date1, endTime: date1.addingTimeInterval(3600), routine: routine1)
        modelContext.insert(s1)
        modelContext.insert(WorkoutSet(weight: 80, reps: 8, completedAt: date1.addingTimeInterval(600), exercise: ex1, session: s1))
        modelContext.insert(WorkoutSet(weight: 80, reps: 7, completedAt: date1.addingTimeInterval(720), exercise: ex1, session: s1))
        modelContext.insert(WorkoutSet(weight: 60, reps: 10, completedAt: date1.addingTimeInterval(1200), exercise: ex2, session: s1))
        
        // Sesión hace 1 día (Tirón)
        let date2 = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let s2 = Session(startTime: date2, endTime: date2.addingTimeInterval(4200), routine: routine2)
        modelContext.insert(s2)
        modelContext.insert(WorkoutSet(weight: 0, reps: 12, completedAt: date2.addingTimeInterval(500), exercise: ex3, session: s2))
        modelContext.insert(WorkoutSet(weight: 70, reps: 10, completedAt: date2.addingTimeInterval(1500), exercise: ex4, session: s2))
        
        // Sesión de hoy (Pierna)
        let date3 = Date()
        let s3 = Session(startTime: date3.addingTimeInterval(-3000), endTime: date3, routine: routine3)
        modelContext.insert(s3)
        modelContext.insert(WorkoutSet(weight: 100, reps: 8, completedAt: date3.addingTimeInterval(-2000), exercise: ex5, session: s3))
        modelContext.insert(WorkoutSet(weight: 150, reps: 12, completedAt: date3.addingTimeInterval(-1000), exercise: ex6, session: s3))
        
        try? modelContext.save()
    }
}

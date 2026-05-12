import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.creationDate, order: .reverse) private var routines: [Routine]
    @Query(sort: \Session.startTime, order: .reverse) private var sessions: [Session]
    
    @State private var showingAddRoutine = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Pestaña de Rutinas
            NavigationStack {
                List {
                    ForEach(routines) { routine in
                        NavigationLink {
                            RoutineEditView(routine: routine)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(routine.name)
                                    .font(.headline)
                                Text("\(routine.exercises?.count ?? 0) ejercicios")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteRoutines)
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    // Forzamos una pequeña espera para dar tiempo a CloudKit a sincronizar
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    WidgetDataUpdater.updateWidgetData(modelContext: modelContext)
                }
                .navigationTitle("Mis Rutinas")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: { showingAddRoutine = true }) {
                            Label("Añadir Rutina", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddRoutine) {
                    NavigationStack {
                        RoutineEditView(routine: nil)
                    }
                }
            }
            .tabItem {
                Label("Rutinas", systemImage: "dumbbell.fill")
            }
            .tag(0)
            
            // Pestaña de Plan Semanal
            WeeklyScheduleView()
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }
                .tag(1)
            
            // Pestaña de Historial
            HistoryCalendarView()
                .tabItem {
                    Label("Historial", systemImage: "clock.fill")
                }
                .tag(2)
            
            // Pestaña de Estadísticas
            StatisticsView()
                .tabItem {
                    Label("Progreso", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)
            
            // Pestaña de Calculadora de Discos (Fase 15)
            PlateCalculatorView()
                .tabItem {
                    Label("Discos", systemImage: "circle.grid.3x3.fill")
                }
                .tag(4)
        }
        .onAppear {
            // Actualizar widget al abrir
            WidgetDataUpdater.updateWidgetData(modelContext: modelContext)
        }
    }
    
    private func deleteRoutines(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(routines[index])
            }
            try? modelContext.save()
            WidgetDataUpdater.updateWidgetData(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(.preview)
}

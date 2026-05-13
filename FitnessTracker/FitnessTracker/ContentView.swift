import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.creationDate, order: .reverse) private var routines: [Routine]
    @Query(sort: \Session.startTime, order: .reverse) private var sessions: [Session]
    
    @State private var showingAddRoutine = false
    @State private var selectedTab = 0
    @State private var selectedCategory = "Todas"
    
    private let categories = ["Todas", "Empuje", "Tirón", "Pierna", "Core", "Cardio", "Cuerpo Completo", "Otros"]
    
    private var filteredRoutines: [Routine] {
        if selectedCategory == "Todas" {
            return routines
        } else {
            return routines.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Pestaña de Rutinas
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header block con el título de la app
                        header
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                // Sección de título "Tus Rutinas"
                                titleSection
                                
                                // Filtros de Categoría
                                categoryFilterBar
                                
                                // Lista vertical de Rutinas
                                routineListSection
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
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
            
            // Pestaña de Calculadora de Discos
            PlateCalculatorView()
                .tabItem {
                    Label("Discos", systemImage: "circle.grid.3x3.fill")
                }
                .tag(4)
        }
        .onAppear {
            WidgetDataUpdater.updateWidgetData(modelContext: modelContext)
        }
        .accentColor(.cyan)
    }
    
    // MARK: - View Components
    
    private var header: some View {
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
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tus Rutinas")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Selecciona un plan de entrenamiento para ver los detalles y comenzar tu sesión.")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.primaryGradient.opacity(selectedCategory == category ? 1.0 : 0.05))
                            .foregroundStyle(selectedCategory == category ? .black : Theme.primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Theme.primary.opacity(0.2), lineWidth: selectedCategory == category ? 0 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var routineListSection: some View {
        VStack(spacing: 20) {
            ForEach(filteredRoutines) { routine in
                NavigationLink {
                    RoutineEditView(routine: routine)
                } label: {
                    RoutineCard(routine: routine)
                }
                .buttonStyle(.plain)
            }
            
            if selectedCategory == "Todas" {
                // Botón para añadir nueva rutina con borde discontinuo
                Button(action: { showingAddRoutine = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 32))
                            .foregroundStyle(Theme.primary)
                        
                        Text("Crear Nueva Rutina")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Theme.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
                .padding(.bottom, 20)
            } else if filteredRoutines.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.2))
                    Text("No hay rutinas en esta categoría")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            }
        }
        .padding(.horizontal)
    }
}

struct RoutineCard: View {
    let routine: Routine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Imagen contenida con ratio 16:9
            ZStack {
                Rectangle()
                    .fill(Color(white: 0.12))
                    .aspectRatio(16/9, contentMode: .fit)
                
                Image(getHeroImageName(for: routine.category))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .layoutPriority(-1) // Permite que el Rectangle mande en el tamaño
            }
            .aspectRatio(16/9, contentMode: .fit)
            .overlay(
                LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .top)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(routine.category.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(Capsule())
                
                Text(routine.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primary)
                
                HStack(spacing: 16) {
                    Label {
                        Text("\(routine.exercises?.count ?? 0) EJERCICIOS")
                            .font(.system(size: 11, weight: .bold))
                    } icon: {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 10))
                    }
                    
                    Label {
                        Text("75 MIN")
                            .font(.system(size: 11, weight: .bold))
                    } icon: {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                    }
                }
                .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func getHeroImageName(for category: String) -> String {
        switch category {
        case "Empuje": return "routine_push_hero"
        case "Tirón": return "routine_pull_hero"
        case "Pierna": return "routine_legs_hero"
        case "Core": return "routine_core_hero"
        case "Cardio": return "routine_cardio_hero"
        case "Cuerpo Completo": return "routine_fullbody_hero"
        default: return "routine_other_hero"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(.preview)
}

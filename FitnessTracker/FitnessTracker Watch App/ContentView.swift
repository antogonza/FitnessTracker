import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Routine.creationDate, order: .reverse) private var routines: [Routine]
    @Query(sort: \WeeklySchedule.weekday) private var schedules: [WeeklySchedule]
    @Query(sort: \Session.startTime, order: .reverse) private var allSessions: [Session]
    
    @EnvironmentObject private var workoutManager: WorkoutManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAllRoutines = false

    // MARK: - Lógica Inteligente
    
    private var todaySession: Session? {
        allSessions.first { session in
            Calendar.current.isDateInToday(session.startTime) && session.endTime != nil
        }
    }
    
    private var todayRoutine: Routine? {
        let today = WeeklySchedule.todayWeekday
        return schedules.first { $0.weekday == today }?.routine
    }
    
    private var streak: Int {
        calculateStreak(from: allSessions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let session = todaySession {
                        // ESTADO: Entrenamiento ya completado hoy
                        completedTodayCard(session: session)
                    } else if let routine = todayRoutine {
                        // ESTADO: Rutina sugerida para hoy
                        suggestedRoutineCard(routine: routine)
                    } else {
                        // ESTADO: Día de descanso o sin plan
                        restDayCard
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .navigationTitle("Fitness")
            .sheet(isPresented: $showAllRoutines) {
                AllRoutinesSheet(routines: routines)
            }
        }
        .onAppear {
            workoutManager.requestAuthorization()
            updateComplication()
        }
    }
    
    // MARK: - Subviews Premium
    
    private func completedTodayCard(session: Session) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Theme.successGradient)
                Text("TRABAJO HECHO")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.1), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: 1.0)
                    .stroke(Theme.successGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .green.opacity(0.3), radius: 4)
                
                VStack(spacing: -2) {
                    Text("\(streak)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("DÍAS")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(width: 80, height: 80)
            
            VStack(spacing: 2) {
                Text(session.routine?.name ?? "Entrenamiento")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(1)
            }
            
            Button {
                showAllRoutines = true
            } label: {
                Text("VER MÁS")
                    .font(.system(size: 10, weight: .black))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            .controlSize(.small)
        }
        .padding()
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func suggestedRoutineCard(routine: Routine) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Imagen de fondo con categoría
            ZStack(alignment: .topLeading) {
                Image(getHeroImageName(for: routine.category))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 80)
                    .clipped()
                    .overlay(
                        LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.category.uppercased())
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.cyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.cyan.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Text("HOY TOCA")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(routine.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .lineLimit(1)
                
                NavigationLink {
                    SessionPagingView(routine: routine)
                } label: {
                    HStack {
                        Text("EMPEZAR")
                            .font(.system(size: 11, weight: .black))
                        Spacer()
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
                
                Button("Otras rutinas") {
                    showAllRoutines = true
                }
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.4))
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(10)
        }
        .background(Color(white: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var restDayCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.secondaryGradient)
            }
            
            VStack(spacing: 2) {
                Text("Día de Descanso")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text("Recupera para progresar")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Button {
                showAllRoutines = true
            } label: {
                Text("ENTRENAR ALGO")
                    .font(.system(size: 11, weight: .black))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .padding()
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func updateComplication() {
        let lastWorkoutDate = allSessions.first?.startTime
        WatchComplicationBridge.update(
            streak: streak,
            todayRoutine: todayRoutine?.name,
            lastWorkoutDate: lastWorkoutDate
        )
    }

    private func calculateStreak(from sessions: [Session]) -> Int {
        let calendar = Calendar.current
        let completedSessions = sessions.filter { $0.endTime != nil }
        let trainingDays = Set(completedSessions.map { calendar.startOfDay(for: $0.startTime) }).sorted(by: >)
        guard !trainingDays.isEmpty else { return 0 }
        var currentStreak = 0
        var checkDate = calendar.startOfDay(for: Date())
        if trainingDays.first != checkDate {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        for day in trainingDays {
            if day == checkDate {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if day < checkDate {
                break
            }
        }
        return currentStreak
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

struct AllRoutinesSheet: View {
    let routines: [Routine]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(routines) { routine in
                        NavigationLink {
                            SessionPagingView(routine: routine)
                        } label: {
                            RoutineWatchCard(routine: routine)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Rutinas")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

struct RoutineWatchCard: View {
    let routine: Routine
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(getHeroImageName(for: routine.category))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 70)
                .clipped()
                .overlay(
                    LinearGradient(colors: [.black.opacity(0.9), .black.opacity(0.2)], startPoint: .bottom, endPoint: .top)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.category.uppercased())
                    .font(.system(size: 7, weight: .black))
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.cyan.opacity(0.2))
                    .clipShape(Capsule())
                
                Text(routine.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
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

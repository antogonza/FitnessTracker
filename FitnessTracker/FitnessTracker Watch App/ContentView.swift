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
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Theme.successGradient)
                                Text("TRABAJO HECHO")
                                    .font(.system(.caption2, design: .rounded).bold())
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.green.opacity(0.1), lineWidth: 10)
                                Circle()
                                    .trim(from: 0, to: 1.0)
                                    .stroke(Theme.successGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: .green.opacity(0.3), radius: 4)
                                
                                VStack(spacing: -2) {
                                    Text("\(streak)")
                                        .font(.system(size: 38, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text("DÍAS")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .frame(width: 100, height: 100)
                            
                            VStack(spacing: 2) {
                                Text("Completado hoy:")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.6))
                                Text(session.routine?.name ?? "Entrenamiento")
                                    .font(.system(.footnote, design: .rounded).bold())
                                    .lineLimit(1)
                            }
                            
                            Button {
                                showAllRoutines = true
                            } label: {
                                Text("Ver más rutinas")
                                    .font(.system(.caption2, design: .rounded).bold())
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)
                            .controlSize(.small)
                        }
                        .fitnessCard()
                    } else if let routine = todayRoutine {
                        // ESTADO: Rutina sugerida para hoy
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("SUGERENCIA")
                                    .font(.system(.caption2, design: .rounded).bold())
                                    .foregroundStyle(.orange)
                                Spacer()
                                HStack(spacing: 2) {
                                    Text("\(streak)")
                                        .font(.system(.caption2, design: .rounded).bold())
                                    Text("🔥")
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(routine.name)
                                    .font(.system(.title3, design: .rounded).bold())
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("\(routine.exercises?.count ?? 0) ejercicios")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            
                            NavigationLink {
                                SessionPagingView(routine: routine)
                            } label: {
                                HStack {
                                    Text("Empezar")
                                        .font(.system(.body, design: .rounded).bold())
                                    Spacer()
                                    Image(systemName: "play.fill")
                                }
                                .padding(.horizontal, 4)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            
                            Button("Elegir otra rutina...") {
                                showAllRoutines = true
                            }
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .fitnessCard()
                    } else {
                        // ESTADO: Día de descanso o sin plan
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "moon.zzz.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Theme.secondaryGradient)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Día de Descanso")
                                    .font(.system(.headline, design: .rounded))
                                Text("La recuperación es clave para el progreso")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button {
                                showAllRoutines = true
                            } label: {
                                Text("Entrenar algo hoy")
                                    .font(.system(.body, design: .rounded).bold())
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                        .fitnessCard()
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
        
        let trainingDays = Set(completedSessions.map { 
            calendar.startOfDay(for: $0.startTime) 
        }).sorted(by: >)
        
        guard !trainingDays.isEmpty else { return 0 }
        
        var currentStreak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Si no ha entrenado hoy, comprobamos si entrenó ayer para ver si la racha sigue viva
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
}

struct AllRoutinesSheet: View {
    let routines: [Routine]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(routines) { routine in
                NavigationLink {
                    SessionPagingView(routine: routine)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(routine.name)
                            .font(.system(.headline, design: .rounded))
                        Text("\(routine.exercises?.count ?? 0) ejercicios")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Theme.glassBackground.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)))
            }
            .listStyle(.carousel)
            .navigationTitle("Rutinas")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}


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
                VStack(spacing: 12) {
                    if let session = todaySession {
                        // ESTADO: Entrenamiento ya completado hoy
                        VStack(spacing: 8) {
                            Text("¡TRABAJO HECHO!")
                                .font(.caption2.bold())
                                .foregroundStyle(.green)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.green.opacity(0.2), lineWidth: 8)
                                Circle()
                                    .trim(from: 0, to: 1.0)
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 0) {
                                    Text("\(streak)")
                                        .font(.system(size: 34, weight: .black, design: .rounded))
                                    Text("DÍAS 🔥")
                                        .font(.system(size: 10, weight: .bold))
                                }
                            }
                            .frame(width: 100, height: 100)
                            .padding(.vertical, 5)
                            
                            Text("Has completado:")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(session.routine?.name ?? "Entrenamiento")
                                .font(.caption.bold())
                                .lineLimit(1)
                            
                            Button {
                                showAllRoutines = true
                            } label: {
                                Text("Ver más rutinas")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.orange)
                            .padding(.top, 5)
                        }
                        .padding()
                    } else if let routine = todayRoutine {
                        // ESTADO: Rutina sugerida para hoy
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("SUGERENCIA DE HOY")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.orange)
                                Spacer()
                                Text("\(streak) 🔥")
                                    .font(.caption2.bold())
                            }
                            
                            Text(routine.name)
                                .font(.title3.bold())
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            NavigationLink {
                                SessionPagingView(routine: routine)
                            } label: {
                                Label("Empezar", systemImage: "play.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            
                            Button("Elegir otra rutina...") {
                                showAllRoutines = true
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        // ESTADO: Día de descanso o sin plan
                        VStack(spacing: 12) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.blue)
                            
                            VStack(spacing: 4) {
                                Text("Día de Descanso")
                                    .font(.headline)
                                Text("La recuperación es parte del entrenamiento.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button {
                                showAllRoutines = true
                            } label: {
                                Text("Entrenar algo hoy")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
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
                    VStack(alignment: .leading) {
                        Text(routine.name)
                            .font(.headline)
                        Text("\(routine.exercises?.count ?? 0) ejercicios")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Rutinas")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

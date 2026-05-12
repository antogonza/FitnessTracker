import SwiftUI
import SwiftData

struct ActiveExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    
    let exercise: Exercise
    let session: Session
    let index: Int
    let total: Int
    let onExerciseComplete: () -> Void
    
    @Binding var weight: Double
    @State private var reps: Int = 10
    @State private var currentSetIndex: Int = 0
    @State private var showPRCelebration = false
    
    @State private var lastWeight: Double = 0
    @State private var lastReps: Int = 0
    
    @EnvironmentObject private var timerManager: TimerManager
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    @Query private var allSessions: [Session]
    @Query private var allSets: [WorkoutSet]
    
    private var personalRecord: Double {
        allSets.filter { $0.exercise?.name == exercise.name }
            .map { $0.weight }
            .max() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // ENCABEZADO DINÁMICO
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(exercise.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                    
                    Text("SERIE \(currentSetIndex + 1) / \(exercise.targetSets)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if timerManager.isRunning {
                    Text(timerManager.timeString)
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15).cornerRadius(8))
                }
            }
            .padding(.horizontal, 10)
            
            // CARD DE PESO (USANDO CORONA)
            VStack(spacing: 2) {
                HStack {
                    Text("PESO")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.green)
                    Spacer()
                    Text("Ant: \(String(format: "%.1f", lastWeight))kg")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                
                Text(String(format: "%.1f", weight))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.3), lineWidth: 1))
                    .focusable()
                    .digitalCrownRotation($weight, from: 0, through: 500, by: 0.5, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
            }
            .padding(.horizontal, 6)
            
            // CARD DE REPETICIONES (BOTONES TÁCTILES GIGANTES - INFALIBLE)
            VStack(spacing: 2) {
                HStack {
                    Text("REPS")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.blue)
                    Spacer()
                    Text("Ant: \(lastReps)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                
                HStack(spacing: 0) {
                    Button(action: { if reps > 1 { reps -= 1; WKInterfaceDevice.current().play(.click) } }) {
                        Image(systemName: "minus")
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.1))
                    }
                    .buttonStyle(.plain)
                    
                    Text("\(reps)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .frame(width: 50)
                        .frame(maxHeight: .infinity)
                        .background(Color.white.opacity(0.05))
                    
                    Button(action: { reps += 1; WKInterfaceDevice.current().play(.click) }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.1))
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 50)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 6)
            
            // BOTÓN DE ACCIÓN DINÁMICO
            Button(action: saveSet) {
                Text(currentSetIndex >= exercise.targetSets ? "COMPLETADO" : "SERIE \(currentSetIndex + 1) / \(exercise.targetSets)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(currentSetIndex >= exercise.targetSets ? Color.gray.opacity(0.3) : Color.green)
                    .foregroundColor(currentSetIndex >= exercise.targetSets ? .secondary : .black)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(currentSetIndex >= exercise.targetSets)
            .padding(.horizontal, 6)
            .padding(.bottom, 2)
        }
        .onAppear(perform: setupInitialValues)
        .overlay {
            if showPRCelebration {
                PRCelebrationOverlay()
            }
        }
    }
    
    private func setupInitialValues() {
        currentSetIndex = session.sets?.filter({ $0.exercise?.name == exercise.name }).count ?? 0
        
        let routineSessions = allSessions
            .filter { $0.routine?.name == session.routine?.name && $0.startTime < session.startTime }
            .sorted(by: { $0.startTime > $1.startTime })
        
        if let lastSession = routineSessions.first {
            let lastExerciseSets = allSets.filter { $0.session?.id == lastSession.id && $0.exercise?.name == exercise.name }
                .sorted(by: { $0.completedAt < $1.completedAt })
            
            if currentSetIndex < lastExerciseSets.count {
                let prevSet = lastExerciseSets[currentSetIndex]
                lastWeight = prevSet.weight
                lastReps = prevSet.reps
            } else if let fallback = lastExerciseSets.last {
                lastWeight = fallback.weight
                lastReps = fallback.reps
            }
        }
        
        reps = lastReps > 0 ? lastReps : 10
    }
    
    private func saveSet() {
        if weight > personalRecord && personalRecord > 0 {
            showPRCelebration = true
            WKInterfaceDevice.current().play(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showPRCelebration = false
            }
        } else {
            WKInterfaceDevice.current().play(.click)
        }
        
        let newSet = WorkoutSet(weight: weight, reps: reps, exercise: exercise, session: session)
        modelContext.insert(newSet)
        
        timerManager.nextExerciseName = exercise.name
        timerManager.startTimer(duration: 90)
        
        currentSetIndex += 1
        if currentSetIndex >= exercise.targetSets {
            onExerciseComplete()
        } else {
            updateLastValues()
        }
        
        try? modelContext.save()
    }
    
    private func updateLastValues() {
        let routineSessions = allSessions
            .filter { $0.routine?.name == session.routine?.name && $0.startTime < session.startTime }
            .sorted(by: { $0.startTime > $1.startTime })
        
        if let lastSession = routineSessions.first {
            let lastExerciseSets = allSets.filter { $0.session?.id == lastSession.id && $0.exercise?.name == exercise.name }
                .sorted(by: { $0.completedAt < $1.completedAt })
            
            if currentSetIndex < lastExerciseSets.count {
                let prevSet = lastExerciseSets[currentSetIndex]
                lastWeight = prevSet.weight
                lastReps = prevSet.reps
            }
        }
    }
}

struct PRCelebrationOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack {
                Text("🎉")
                    .font(.system(size: 60))
                Text("¡NUEVO RÉCORD!")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.yellow)
                Text("Has superado tu marca personal")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

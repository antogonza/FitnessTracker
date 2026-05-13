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
        VStack(spacing: 8) {
            // ENCABEZADO DINÁMICO
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(exercise.name)
                        .font(.system(.footnote, design: .rounded).bold())
                        .foregroundStyle(Theme.primaryGradient)
                        .lineLimit(1)
                    
                    Text("SERIE \(currentSetIndex + 1) / \(exercise.targetSets)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                if timerManager.isRunning {
                    Text(timerManager.timeString)
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1).clipShape(Capsule()))
                }
            }
            .padding(.horizontal, 8)
            
            // CARD DE PESO (USANDO CORONA)
            VStack(spacing: 4) {
                HStack {
                    Label("PESO", systemImage: "scalemass.fill")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(.green)
                    Spacer()
                    if lastWeight > 0 {
                        Text("Anterior: \(String(format: "%.1f", lastWeight))kg")
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 10)
                
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.innerCornerRadius, style: .continuous)
                        .fill(LinearGradient(colors: [Color.green.opacity(0.15), Color.green.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.innerCornerRadius, style: .continuous)
                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                        )
                    
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(String(format: "%.1f", weight))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                        Text("kg")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .frame(height: 54)
                .focusable()
                .digitalCrownRotation($weight, from: 0, through: 500, by: 0.5, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
            }
            .padding(.horizontal, 4)
            
            // CARD DE REPETICIONES
            VStack(spacing: 4) {
                HStack {
                    Label("REPS", systemImage: "repeat")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(.blue)
                    Spacer()
                    if lastReps > 0 {
                        Text("Anterior: \(lastReps)")
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 10)
                
                HStack(spacing: 0) {
                    Button(action: { if reps > 1 { reps -= 1; WKInterfaceDevice.current().play(.click) } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.05))
                    }
                    .buttonStyle(.plain)
                    
                    Text("\(reps)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .frame(width: 50)
                        .frame(maxHeight: .infinity)
                        .background(Color.white.opacity(0.02))
                        .contentTransition(.numericText())
                    
                    Button(action: { reps += 1; WKInterfaceDevice.current().play(.click) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.05))
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 54)
                .clipShape(RoundedRectangle(cornerRadius: Theme.innerCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.innerCornerRadius, style: .continuous)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(.horizontal, 4)
            
            // BOTÓN DE ACCIÓN DINÁMICO
            Button(action: saveSet) {
                Text(currentSetIndex >= exercise.targetSets ? "COMPLETADO" : "TERMINAR SERIE")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background {
                        if currentSetIndex >= exercise.targetSets {
                            Color.gray.opacity(0.2)
                        } else {
                            Theme.successGradient
                        }
                    }
                    .foregroundColor(currentSetIndex >= exercise.targetSets ? .secondary : .black)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.innerCornerRadius, style: .continuous))
                    .shadow(color: (currentSetIndex >= exercise.targetSets ? Color.clear : Color.green.opacity(0.3)), radius: 4)
            }
            .buttonStyle(.plain)
            .disabled(currentSetIndex >= exercise.targetSets)
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 2)
        .onAppear(perform: setupInitialValues)
        .overlay {
            if showPRCelebration {
                PRCelebrationOverlay()
                    .transition(.opacity.combined(with: .scale))
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
        withAnimation(.spring()) {
            if weight > personalRecord && personalRecord > 0 {
                showPRCelebration = true
                WKInterfaceDevice.current().play(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showPRCelebration = false
                    }
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
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.primaryGradient)
                        .frame(width: 70, height: 70)
                        .blur(radius: 20)
                        .opacity(0.6)
                    
                    Text("🏆")
                        .font(.system(size: 50))
                }
                
                VStack(spacing: 2) {
                    Text("NUEVO RÉCORD")
                        .font(.system(.headline, design: .rounded).bold())
                        .foregroundStyle(.yellow)
                    
                    Text("¡Has superado tu mejor marca!")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .fitnessCard()
        }
    }
}


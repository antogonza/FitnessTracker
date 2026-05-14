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
            // ENCABEZADO PREMIUM
            ZStack(alignment: .leading) {
                // Imagen de categoría muy sutil al fondo
                Image(getHeroImageName(for: session.routine?.category ?? "Otros"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 34)
                    .clipped()
                    .opacity(0.15)
                    .overlay(
                        LinearGradient(colors: [.black, .clear], startPoint: .trailing, endPoint: .leading)
                    )
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: -2) {
                        Text(exercise.name.uppercased())
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.primary)
                            .lineLimit(1)
                        
                        Text("SERIE \(currentSetIndex + 1) / \(exercise.targetSets)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    if timerManager.isRunning {
                        Text(timerManager.timeString)
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundStyle(.cyan)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.cyan.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 4)
            
            // CARD DE PESO (USANDO CORONA)
            VStack(spacing: 4) {
                HStack {
                    Label("PESO", systemImage: "scalemass.fill")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Theme.primary)
                    Spacer()
                    if lastWeight > 0 {
                        Text("Ant: \(String(format: "%.1f", lastWeight))kg")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 10)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(white: 0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Theme.primary.opacity(0.2), lineWidth: 1)
                        )
                    
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(String(format: "%.1f", weight))
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .contentTransition(.numericText())
                            .foregroundStyle(.white)
                        Text("kg")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.primary.opacity(0.8))
                    }
                }
                .frame(height: 52)
                .focusable()
                .digitalCrownRotation($weight, from: 0, through: 500, by: 0.5, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
            }
            .padding(.horizontal, 4)
            
            // CARD DE REPETICIONES
            VStack(spacing: 4) {
                HStack {
                    Label("REPS", systemImage: "repeat")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.cyan)
                    Spacer()
                    if lastReps > 0 {
                        Text("Ant: \(lastReps)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 10)
                
                HStack(spacing: 0) {
                    Button(action: { if reps > 1 { reps -= 1; WKInterfaceDevice.current().play(.click) } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.05))
                    }
                    .buttonStyle(.plain)
                    
                    Text("\(reps)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .frame(width: 45)
                        .frame(maxHeight: .infinity)
                        .background(Color.white.opacity(0.02))
                        .contentTransition(.numericText())
                    
                    Button(action: { reps += 1; WKInterfaceDevice.current().play(.click) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.05))
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(.horizontal, 4)
            
            // BOTÓN DE ACCIÓN PREMIUM
            Button(action: saveSet) {
                Text(currentSetIndex >= exercise.targetSets ? "COMPLETADO" : "SIGUIENTE SERIE")
                    .font(.system(size: 13, weight: .black))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background {
                        if currentSetIndex >= exercise.targetSets {
                            Color.gray.opacity(0.2)
                        } else {
                            Theme.primaryGradient
                        }
                    }
                    .foregroundColor(currentSetIndex >= exercise.targetSets ? .secondary : .black)
                    .clipShape(Capsule())
                    .shadow(color: (currentSetIndex >= exercise.targetSets ? Color.clear : Theme.primary.opacity(0.3)), radius: 4)
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
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.yellow)
                    
                    Text("¡Has superado tu mejor marca!")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(Color(white: 0.1).clipShape(RoundedRectangle(cornerRadius: 20)))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

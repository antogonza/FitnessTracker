import SwiftUI
import SwiftData

struct SessionPagingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let routine: Routine
    @State private var session: Session?
    @State private var selection: Int = 0
    @State private var horizontalSelection: Int = 0
    @State private var activeWeight: Double = 0 // Peso compartido
    
    @StateObject private var timerManager = TimerManager()
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    @Query private var allSets: [WorkoutSet]
    
    var body: some View {
        Group {
            if let session = session {
                TabView(selection: $horizontalSelection) {
                    
                    // PÁGINA -1: ESTADÍSTICAS
                    WorkoutStatsWatchView(session: session)
                        .tag(-1)
                    
                    // PÁGINA 0: ENTRENAMIENTO
                    TabView(selection: $selection) {
                        if let exercises = routine.exercises?.sorted(by: { $0.order < $1.order }) {
                            ForEach(exercises.indices, id: \.self) { index in
                                ActiveExerciseView(
                                    exercise: exercises[index],
                                    session: session,
                                    index: index,
                                    total: exercises.count,
                                    onExerciseComplete: {
                                        withAnimation {
                                            let totalExercises = routine.exercises?.count ?? 0
                                            selection = min(selection + 1, totalExercises)
                                        }
                                    },
                                    weight: $activeWeight
                                )
                                .tag(index)
                            }
                        }
                        
                        SessionSummaryView(session: session) {
                            workoutManager.endWorkout()
                            dismiss()
                        }
                        .tag((routine.exercises?.count ?? 0))
                    }
                    .tabViewStyle(.verticalPage)
                    .tag(0)
                    .onChange(of: selection) { _, _ in
                        updateActiveWeightForCurrentExercise()
                    }
                    
                    // PÁGINA 1: CALCULADORA
                    PlateCalculatorWatchView(targetWeight: $activeWeight)
                        .tag(1)
                }
                .tabViewStyle(.page)
                .environmentObject(timerManager)
                .sheet(isPresented: $timerManager.showFullScreenTimer) {
                    RestTimerView()
                        .environmentObject(timerManager)
                }
            } else {
                ProgressView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if session == nil {
                let newSession = Session(startTime: .now, routine: routine)
                modelContext.insert(newSession)
                self.session = newSession
                workoutManager.startWorkout()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    updateActiveWeightForCurrentExercise()
                }
            }
        }
    }
    
    private func updateActiveWeightForCurrentExercise() {
        guard let exercises = routine.exercises?.sorted(by: { $0.order < $1.order }),
              selection < exercises.count else { return }
        
        let currentExercise = exercises[selection]
        let lastSet = allSets.filter({ $0.exercise?.name == currentExercise.name }).last
        activeWeight = lastSet?.weight ?? 0
    }
}

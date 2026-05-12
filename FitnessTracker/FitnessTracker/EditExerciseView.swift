import SwiftUI
import SwiftData

struct EditExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var exercise: Exercise
    
    @State private var useCustomRest: Bool
    @State private var restBetweenSets: Int
    @State private var restBetweenExercises: Int
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._useCustomRest = State(initialValue: exercise.restBetweenSets != nil || exercise.restBetweenExercises != nil)
        self._restBetweenSets = State(initialValue: exercise.restBetweenSets ?? exercise.routine?.defaultRestBetweenSets ?? 90)
        self._restBetweenExercises = State(initialValue: exercise.restBetweenExercises ?? exercise.routine?.defaultRestBetweenExercises ?? 120)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Configuración del Ejercicio") {
                    TextField("Nombre del ejercicio", text: $exercise.name)
                        .submitLabel(.done)
                    Picker("Categoría", selection: $exercise.category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    Stepper("Series: \(exercise.targetSets)", value: $exercise.targetSets, in: 1...10)
                }
                
                Section("Descansos (Opcional)") {
                    Toggle("Usar descansos personalizados", isOn: $useCustomRest)
                    
                    if useCustomRest {
                        Stepper("Entre series: \(restBetweenSets)s", value: $restBetweenSets, in: 0...300, step: 15)
                        Stepper("Al terminar ejercicio: \(restBetweenExercises)s", value: $restBetweenExercises, in: 0...300, step: 15)
                    }
                }
            }
            .navigationTitle("Editar Ejercicio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if useCustomRest {
                            exercise.restBetweenSets = restBetweenSets
                            exercise.restBetweenExercises = restBetweenExercises
                        } else {
                            exercise.restBetweenSets = nil
                            exercise.restBetweenExercises = nil
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

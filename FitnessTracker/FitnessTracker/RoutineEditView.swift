import SwiftUI
import SwiftData

struct RoutineEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var routine: Routine
    let isNew: Bool
    
    @State private var showingAddExercise = false
    @State private var editingExercise: Exercise? = nil
    
    init(routine: Routine?) {
        if let routine = routine {
            self.routine = routine
            self.isNew = false
        } else {
            self.routine = Routine(name: "")
            self.isNew = true
        }
    }
    
    var body: some View {
        Form {
            Section("Configuración General") {
                TextField("Nombre de la Rutina", text: $routine.name)
                
                Stepper("Descanso entre series: \(routine.defaultRestBetweenSets)s", value: $routine.defaultRestBetweenSets, in: 0...300, step: 15)
                Stepper("Descanso entre ejercicios: \(routine.defaultRestBetweenExercises)s", value: $routine.defaultRestBetweenExercises, in: 0...300, step: 15)
            }
            
            Section("Ejercicios") {
                if let exercises = routine.exercises?.sorted(by: { $0.order < $1.order }) {
                    List {
                        ForEach(exercises) { exercise in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                    Text("\(exercise.targetSets) series")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingExercise = exercise
                            }
                        }
                        .onDelete(perform: deleteExercises)
                        .onMove(perform: moveExercises)
                    }
                }
                
                Button(action: {
                    showingAddExercise = true
                }) {
                    Label("Añadir Ejercicio", systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle(isNew ? "Nueva Rutina" : "Editar Rutina")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isNew {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    if isNew {
                        modelContext.insert(routine)
                    }
                    try? modelContext.save()
                    dismiss()
                }
                .disabled(routine.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView(routine: routine)
        }
        .sheet(item: $editingExercise) { exercise in
            EditExerciseView(exercise: exercise)
        }
    }
    
    private func deleteExercises(offsets: IndexSet) {
        guard let exercises = routine.exercises?.sorted(by: { $0.order < $1.order }) else { return }
        for index in offsets {
            let exercise = exercises[index]
            routine.exercises?.removeAll(where: { $0.id == exercise.id })
            modelContext.delete(exercise)
        }
        updateExerciseOrders()
    }
    
    private func moveExercises(from source: IndexSet, to destination: Int) {
        guard var exercises = routine.exercises?.sorted(by: { $0.order < $1.order }) else { return }
        exercises.move(fromOffsets: source, toOffset: destination)
        
        routine.exercises = exercises
        updateExerciseOrders()
    }
    
    private func updateExerciseOrders() {
        guard let exercises = routine.exercises else { return }
        for (index, exercise) in exercises.enumerated() {
            exercise.order = index
        }
    }
}

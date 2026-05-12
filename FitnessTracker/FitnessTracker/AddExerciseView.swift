import SwiftUI

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    var routine: Routine

    @State private var exerciseName: String = ""
    @State private var category: ExerciseCategory = .other
    @State private var targetSets: Int = 3

    @State private var useCustomRest: Bool = false
    @State private var restBetweenSets: Int = 90
    @State private var restBetweenExercises: Int = 120

    @State private var showCatalog: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Selección de ejercicio
                Section {
                    // Botón que abre el catálogo
                    Button {
                        showCatalog = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exerciseName.isEmpty ? "Seleccionar del catálogo" : exerciseName)
                                    .foregroundStyle(exerciseName.isEmpty ? .secondary : .primary)
                                    .font(.body)
                                if !exerciseName.isEmpty {
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)

                    // TextField para nombre manual (si el usuario quiere escribirlo)
                    TextField("O escribe el nombre manualmente", text: $exerciseName)
                        .submitLabel(.done)

                    Picker("Categoría", selection: $category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                } header: {
                    Text("Ejercicio")
                } footer: {
                    Text("Selecciona del catálogo o escribe el nombre directamente.")
                }

                // MARK: Series
                Section("Configuración") {
                    Stepper("Series: \(targetSets)", value: $targetSets, in: 1...10)
                }

                // MARK: Descansos
                Section("Descansos (Opcional)") {
                    Toggle("Usar descansos personalizados", isOn: $useCustomRest)

                    if useCustomRest {
                        Stepper("Entre series: \(restBetweenSets)s", value: $restBetweenSets, in: 0...300, step: 15)
                        Stepper("Al terminar ejercicio: \(restBetweenExercises)s", value: $restBetweenExercises, in: 0...300, step: 15)
                    }
                }
            }
            .navigationTitle("Añadir Ejercicio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Añadir") { saveExercise() }
                        .disabled(exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showCatalog) {
                ExerciseCatalogPickerView(
                    selectedName: $exerciseName,
                    selectedCategory: $category
                )
            }
        }
        .onAppear {
            restBetweenSets = routine.defaultRestBetweenSets
            restBetweenExercises = routine.defaultRestBetweenExercises
        }
    }

    private func saveExercise() {
        let name = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let order = routine.exercises?.count ?? 0
        let newExercise = Exercise(
            name: name,
            category: category,
            order: order,
            targetSets: targetSets,
            restBetweenSets: useCustomRest ? restBetweenSets : nil,
            restBetweenExercises: useCustomRest ? restBetweenExercises : nil,
            routine: routine
        )

        if routine.exercises == nil { routine.exercises = [] }
        routine.exercises?.append(newExercise)

        dismiss()
    }
}

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var routine: Routine
    var exerciseToEdit: Exercise?
    
    @State private var exerciseName: String = ""
    @State private var selectedCategory: ExerciseCategory? = nil
    @State private var targetSets: Int = 3
    @State private var targetReps: String = "8-12"
    @State private var targetRPE: Double = 8.0
    @State private var showCatalog = false

    @State private var useCustomRest: Bool = false
    @State private var restBetweenSets: Int = 150 // 02:30 in seconds
    
    // Preset rest times in seconds
    let restPresets = [30, 60, 90, 150, 180]

    init(routine: Routine, exerciseToEdit: Exercise? = nil) {
        self.routine = routine
        self.exerciseToEdit = exerciseToEdit
        
        // Inicializamos los estados en el init para que coincidan con el ejercicio a editar
        if let ex = exerciseToEdit {
            _exerciseName = State(initialValue: ex.name)
            _selectedCategory = State(initialValue: ex.category)
            _targetSets = State(initialValue: ex.targetSets)
            _targetReps = State(initialValue: ex.targetReps)
            _targetRPE = State(initialValue: ex.targetRPE)
            
            if let rest = ex.restBetweenSets {
                _useCustomRest = State(initialValue: true)
                _restBetweenSets = State(initialValue: rest)
            } else {
                _useCustomRest = State(initialValue: false)
                _restBetweenSets = State(initialValue: 150)
            }
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barra de navegación personalizada
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    Text(exerciseToEdit == nil ? "NUEVO EJERCICIO" : "EDITAR EJERCICIO")
                        .font(.system(size: 14, weight: .black))
                        .tracking(2)
                        .foregroundStyle(Theme.primary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(white: 0.08))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Botón para abrir el catálogo
                        Button(action: { showCatalog = true }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.white.opacity(0.8))
                                Text("Seleccionar del catálogo...")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.8))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .padding()
                            .background(Color(white: 0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Card Personalizar Ejercicio
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Personalizar Ejercicio")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 255/255, green: 200/255, blue: 180/255))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NOMBRE DEL EJERCICIO")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                
                                TextField("", text: $exerciseName, prompt: Text("Ej. Press Militar con mancuerna").foregroundStyle(.white.opacity(0.7)))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(Color(white: 0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CATEGORÍA")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                
                                Menu {
                                    ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                                        Button(action: { selectedCategory = cat }) {
                                            Text(cat.rawValue)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedCategory?.rawValue ?? "Seleccionar grupo muscular")
                                            .font(.system(size: 16))
                                            .foregroundStyle(selectedCategory == nil ? .white.opacity(0.7) : .white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(white: 0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        
                        // Card Configuración
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Configuración")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 255/255, green: 200/255, blue: 180/255))
                            
                            // Series Stepper
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Series")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("Número de sets efectivos")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Button(action: { if targetSets > 1 { targetSets -= 1 } }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 14, weight: .bold))
                                            .frame(width: 44, height: 44)
                                            .background(Color(white: 0.15))
                                            .foregroundStyle(.white)
                                    }
                                    
                                    Text("\(targetSets)")
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.white)
                                        .frame(width: 50, height: 44)
                                        .background(Color(white: 0.1))
                                    
                                    Button(action: { targetSets += 1 }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .bold))
                                            .frame(width: 44, height: 44)
                                            .background(Color.cyan)
                                            .foregroundStyle(.black)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }

                            // Reps Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Repeticiones")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                TextField("", text: $targetReps, prompt: Text("Ej: 8-12").foregroundStyle(.white.opacity(0.4)))
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(Color(white: 0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            }

                            // RPE Stepper
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("RPE Objetivo")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("Esfuerzo percibido (1-10)")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Button(action: { if targetRPE > 1 { targetRPE -= 0.5 } }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 14, weight: .bold))
                                            .frame(width: 44, height: 44)
                                            .background(Color(white: 0.15))
                                            .foregroundStyle(.white)
                                    }
                                    
                                    Text(String(format: "%.1f", targetRPE))
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.white)
                                        .frame(width: 60, height: 44)
                                        .background(Color(white: 0.1))
                                    
                                    Button(action: { if targetRPE < 10 { targetRPE += 0.5 } }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .bold))
                                            .frame(width: 44, height: 44)
                                            .background(Color.cyan)
                                            .foregroundStyle(.black)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            
                            // Descanso Toggle
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Descanso Personalizado")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("Temporizador entre series")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    Toggle("", isOn: $useCustomRest)
                                        .tint(Theme.primary)
                                        .labelsHidden()
                                }
                                
                                if useCustomRest {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                                            Text(formatTime(restBetweenSets))
                                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                                .foregroundStyle(.cyan)
                                            Text("MINUTOS")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.4))
                                        }
                                        
                                        HStack(spacing: 8) {
                                            ForEach(restPresets, id: \.self) { seconds in
                                                Button(action: { restBetweenSets = seconds }) {
                                                    Text(formatTimeShort(seconds))
                                                        .font(.system(size: 13, weight: .bold))
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 40)
                                                        .background(restBetweenSets == seconds ? Color.cyan.opacity(0.2) : Color(white: 0.12))
                                                        .foregroundStyle(restBetweenSets == seconds ? .cyan : .white.opacity(0.6))
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(restBetweenSets == seconds ? Color.cyan : Color.clear, lineWidth: 1)
                                                        )
                                                }
                                            }
                                        }
                                    }
                                    .transition(.opacity)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .padding(.bottom, 120)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                Button(action: saveExercise) {
                    Text(exerciseToEdit == nil ? "AÑADIR EJERCICIO" : "GUARDAR CAMBIOS")
                        .font(.system(size: 16, weight: .black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.primaryGradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding()
                        .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.bottom, 10)
                .background(
                    LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)
                        .frame(height: 120)
                )
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showCatalog) {
            NavigationStack {
                ExerciseCatalogPickerView(
                    selectedName: $exerciseName,
                    selectedCategory: $selectedCategory,
                    onSelection: {}
                )
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func formatTimeShort(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if secs == 0 {
            return "\(mins):00"
        } else {
            return "\(mins):\(secs)"
        }
    }

    private func saveExercise() {
        let name = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        if let ex = exerciseToEdit {
            // Editando existente
            ex.name = name
            ex.category = selectedCategory ?? .other
            ex.targetSets = targetSets
            ex.targetReps = targetReps
            ex.targetRPE = targetRPE
            ex.restBetweenSets = useCustomRest ? restBetweenSets : nil
            try? modelContext.save()
        } else {
            // Creando nuevo
            let order = routine.exercises?.count ?? 0
            let newExercise = Exercise(
                name: name,
                category: selectedCategory ?? .other,
                order: order,
                targetSets: targetSets,
                targetReps: targetReps,
                targetRPE: targetRPE,
                restBetweenSets: useCustomRest ? restBetweenSets : nil,
                routine: routine
            )

            if routine.exercises == nil { routine.exercises = [] }
            routine.exercises?.append(newExercise)
        }

        dismiss()
    }
}

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
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                editHeader
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        RoutineInfoSection(routine: routine)
                        
                        RestConfigSection(routine: routine)
                        
                        RoutineExercisesSection(
                            routine: routine,
                            onAdd: { showingAddExercise = true },
                            onEdit: { editingExercise = $0 }
                        )
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddExercise) {
            NavigationStack {
                AddExerciseView(routine: routine)
            }
        }
        .sheet(item: $editingExercise) { exercise in
            NavigationStack {
                AddExerciseView(routine: routine, exerciseToEdit: exercise)
            }
        }
    }
    
    private var editHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            Text(isNew ? "NUEVA RUTINA" : "EDITAR RUTINA")
                .font(.system(size: 14, weight: .black))
                .tracking(2)
                .foregroundStyle(Theme.primary)
            
            Spacer()
            
            Button(action: {
                if isNew {
                    modelContext.insert(routine)
                }
                try? modelContext.save()
                dismiss()
            }) {
                Text("GUARDAR")
                    .font(.system(size: 12, weight: .black))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.primaryGradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .disabled(routine.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(white: 0.08))
    }
}

// MARK: - Componentes Secundarios

struct RoutineInfoSection: View {
    @Bindable var routine: Routine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("NOMBRE DE LA RUTINA")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.leading, 4)
                
                TextField("", text: $routine.name, prompt: Text("Rutina de Empuje").foregroundStyle(.white.opacity(0.7)))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color(white: 0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .padding(.horizontal)
            .padding(.top, 24)
            
            CategorySelector(selectedCategory: $routine.category)
                .padding(.horizontal)
        }
    }
}

struct CategorySelector: View {
    @Binding var selectedCategory: String
    private let categories = ["Empuje", "Tirón", "Pierna", "Core", "Cardio", "Cuerpo Completo", "Otros"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CATEGORÍA")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        CategoryButton(category: cat, isSelected: selectedCategory == cat) {
                            selectedCategory = cat
                        }
                    }
                }
            }
            .padding()
            .background(Color(white: 0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct CategoryButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.uppercased())
                .font(.system(size: 11, weight: .black))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Theme.primaryGradient.opacity(isSelected ? 1.0 : 0.05))
                .foregroundStyle(isSelected ? .black : Theme.primary)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.primary.opacity(0.2), lineWidth: isSelected ? 0 : 1))
        }
    }
}

struct RestConfigSection: View {
    @Bindable var routine: Routine
    
    var body: some View {
        VStack(spacing: 24) {
            RestConfigCard(
                title: "DESCANSO ENTRE SERIES",
                value: .init(get: { Double(routine.defaultRestBetweenSets) }, set: { routine.defaultRestBetweenSets = Int($0) }),
                range: 0...300,
                step: 15
            )
            
            RestConfigCard(
                title: "DESCANSO ENTRE EJERCICIOS",
                value: .init(get: { Double(routine.defaultRestBetweenExercises) }, set: { routine.defaultRestBetweenExercises = Int($0) }),
                range: 0...600,
                step: 30
            )
        }
        .padding(.horizontal)
    }
}

struct RoutineExercisesSection: View {
    let routine: Routine
    let onAdd: () -> Void
    let onEdit: (Exercise) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ejercicios")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Button(action: onAdd) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("AÑADIR")
                    }
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.cyan)
                }
            }
            
            VStack(spacing: 12) {
                let exercises = routine.exercises?.sorted(by: { $0.order < $1.order }) ?? []
                if exercises.isEmpty {
                    EmptyExercisesView()
                } else {
                    ForEach(exercises) { exercise in
                        ExerciseEditCard(exercise: exercise) {
                            onEdit(exercise)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
}

struct EmptyExercisesView: View {
    var body: some View {
        Text("No hay ejercicios añadidos")
            .font(.system(size: 14))
            .foregroundStyle(.white.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(Color(white: 0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct RestConfigCard: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .foregroundStyle(Theme.primary)
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(Int(value))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("SEGUNDOS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 8)
            }
            
            Slider(value: $value, in: range, step: step)
                .accentColor(Theme.primary)
        }
        .padding(20)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct ExerciseEditCard: View {
    let exercise: Exercise
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Theme.primary).frame(width: 28, height: 28)
                        Text("\(exercise.order + 1)").font(.system(size: 12, weight: .black)).foregroundStyle(.black)
                    }
                    Text(exercise.name).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "line.3.horizontal").font(.system(size: 14, weight: .bold)).foregroundStyle(.white.opacity(0.3))
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                
                HStack(spacing: 0) {
                    MetricItem(label: "SERIES", value: "\(exercise.targetSets)")
                    Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                    MetricItem(label: "REPS", value: exercise.targetReps)
                    Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                    MetricItem(label: "RPE", value: String(format: "%.1g", exercise.targetRPE))
                }
                .frame(height: 60).background(Color(white: 0.12))
            }
            .background(Color(white: 0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct MetricItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label).font(.system(size: 9, weight: .bold)).foregroundStyle(.white.opacity(0.4))
            Text(value).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

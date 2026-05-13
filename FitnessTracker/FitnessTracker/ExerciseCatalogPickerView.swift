import SwiftUI

struct ExerciseCatalogPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedName: String
    @Binding var selectedCategory: ExerciseCategory?
    var onSelection: () -> Void

    @State private var searchText: String = ""
    @State private var selectedFilter: ExerciseCategory? = nil

    private var filtered: [CatalogExercise] {
        let base = selectedFilter == nil
            ? ExerciseCatalog.all
            : ExerciseCatalog.all.filter { $0.category == selectedFilter }

        if searchText.isEmpty { return base }
        return base.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.muscleGroup.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var grouped: [(key: ExerciseCategory, value: [CatalogExercise])] {
        let groups = Dictionary(grouping: filtered, by: \.category)
        return ExerciseCategory.allCases
            .compactMap { cat in groups[cat].map { (key: cat, value: $0) } }
    }

    var body: some View {
        ZStack {
            Color(white: 0.05).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Cabecera - ESTRUCTURA COPIADA DE RoutineEditView
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancelar")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(white: 0.15))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    Text("Seleccionar Ejercicio")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
        
                }
                .padding(.horizontal)
                .padding(.vertical, 12) // Exactamente como RoutineEditView
                .background(Color(white: 0.08))
                
                // Chips de Categoría
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        PickerChip(title: "Todos", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            PickerChip(title: cat.rawValue, isSelected: selectedFilter == cat) {
                                selectedFilter = cat
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                
                if filtered.isEmpty && !searchText.isEmpty {
                    // Estado Vacío / Añadir personalizado
                    VStack(spacing: 24) {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.3))
                        
                        VStack(spacing: 8) {
                            Text("No se encontraron resultados")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("Puedes usar este nombre para un ejercicio personalizado")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            selectedName = searchText
                            selectedCategory = selectedFilter ?? .other
                            onSelection()
                            dismiss()
                        }) {
                            Text("Usar \"\(searchText)\"")
                                .font(.system(size: 16, weight: .bold))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Theme.primaryGradient)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .padding()
                } else {
                    // Lista de ejercicios
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(grouped, id: \.key) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Header de Sección
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.up.right.circle.fill")
                                            .foregroundStyle(.orange)
                                            .font(.system(size: 20))
                                        Text(group.key.rawValue)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(.orange)
                                    }
                                    .padding(.horizontal)
                                    
                                    // Items
                                    VStack(spacing: 0) {
                                        ForEach(group.value) { exercise in
                                            Button(action: {
                                                selectedName = exercise.name
                                                selectedCategory = exercise.category
                                                onSelection()
                                                dismiss()
                                            }) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(exercise.name)
                                                            .font(.system(size: 16, weight: .medium))
                                                            .foregroundStyle(.cyan)
                                                        Text(exercise.muscleGroup)
                                                            .font(.system(size: 12))
                                                            .foregroundStyle(.cyan.opacity(0.6))
                                                    }
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundStyle(.white.opacity(0.2))
                                                }
                                                .padding(.vertical, 16)
                                                .padding(.horizontal)
                                                .background(Color.clear)
                                            }
                                            
                                            if exercise != group.value.last {
                                                Divider()
                                                    .background(Color.white.opacity(0.1))
                                                    .padding(.leading)
                                            }
                                        }
                                    }
                                    .background(Color(white: 0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 120)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Buscador en la parte inferior
                VStack(spacing: 0) {
                    LinearGradient(colors: [.clear, Color(white: 0.05).opacity(0.8), Color(white: 0.05)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 40)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.7))
                        TextField("", text: $searchText, prompt: Text("Buscar ejercicio o músculo...").foregroundStyle(.white.opacity(0.7)))
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(Color(white: 0.15))
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .background(Color(white: 0.05))
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct PickerChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(white: 0.15))
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
    }
}

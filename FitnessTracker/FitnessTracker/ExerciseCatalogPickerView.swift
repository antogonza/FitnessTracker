import SwiftUI

struct ExerciseCatalogPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedName: String
    @Binding var selectedCategory: ExerciseCategory

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
        NavigationStack {
            VStack(spacing: 0) {

                // Filtros de categoría
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "Todos", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            FilterChip(title: cat.rawValue, isSelected: selectedFilter == cat) {
                                selectedFilter = selectedFilter == cat ? nil : cat
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(UIColor.secondarySystemBackground))

                // Lista de ejercicios
                if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No se encontraron ejercicios")
                            .font(.headline)
                        Text("Puedes introducir el nombre manualmente")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button("Usar \"\(searchText)\"") {
                            selectedName = searchText
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(grouped, id: \.key) { group in
                            Section(header: CategoryHeader(category: group.key)) {
                                ForEach(group.value) { exercise in
                                    Button {
                                        selectedName = exercise.name
                                        selectedCategory = exercise.category
                                        dismiss()
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(exercise.name)
                                                    .font(.body)
                                                    .foregroundStyle(.primary)
                                                Text(exercise.muscleGroup)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Seleccionar Ejercicio")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar ejercicio o músculo...")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Componentes auxiliares

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(UIColor.tertiarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color(UIColor.separator), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

struct CategoryHeader: View {
    let category: ExerciseCategory

    var icon: String {
        switch category {
        case .push:  return "arrow.up.forward.circle.fill"
        case .pull:  return "arrow.down.backward.circle.fill"
        case .legs:  return "figure.run.circle.fill"
        case .core:  return "circle.grid.cross.fill"
        case .other: return "star.circle.fill"
        }
    }

    var color: Color {
        switch category {
        case .push:  return .orange
        case .pull:  return .blue
        case .legs:  return .green
        case .core:  return .purple
        case .other: return .gray
        }
    }

    var body: some View {
        Label(category.rawValue, systemImage: icon)
            .foregroundStyle(color)
            .font(.subheadline.bold())
    }
}

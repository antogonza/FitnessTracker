import SwiftUI
import SwiftData

struct WeeklyScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklySchedule.weekday) private var schedules: [WeeklySchedule]
    @Query(sort: \Routine.creationDate, order: .reverse) private var routines: [Routine]

    var body: some View {
        NavigationStack {
            Group {
                if routines.isEmpty {
                    ContentUnavailableView(
                        "Sin rutinas",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Crea rutinas primero para poder asignarlas a los días de la semana.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(WeeklySchedule.weekdaysStartingMonday, id: \.self) { weekday in
                                DayScheduleRow(
                                    weekday: weekday,
                                    schedule: scheduleFor(weekday),
                                    routines: routines,
                                    onSelect: { routine in
                                        assignRoutine(routine, to: weekday)
                                    },
                                    onClear: {
                                        clearRoutine(from: weekday)
                                    }
                                )
                            }
                        } header: {
                            Text("Arrastra o selecciona la rutina para cada día")
                                .textCase(nil)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Plan Semanal")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func scheduleFor(_ weekday: Int) -> WeeklySchedule? {
        schedules.first { $0.weekday == weekday }
    }

    private func assignRoutine(_ routine: Routine?, to weekday: Int) {
        if let existing = scheduleFor(weekday) {
            existing.routine = routine
        } else {
            let entry = WeeklySchedule(weekday: weekday, routine: routine)
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }

    private func clearRoutine(from weekday: Int) {
        assignRoutine(nil, to: weekday)
    }
}

struct DayScheduleRow: View {
    let weekday: Int
    let schedule: WeeklySchedule?
    let routines: [Routine]
    let onSelect: (Routine?) -> Void
    let onClear: () -> Void

    @State private var showPicker = false

    private var isToday: Bool { weekday == WeeklySchedule.todayWeekday }
    private var assignedRoutine: Routine? { schedule?.routine }

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(WeeklySchedule.shortDayName(for: weekday))
                    .font(.caption2.bold())
                    .foregroundStyle(isToday ? .white : .secondary)
            }
            .frame(width: 40, height: 40)
            .background(isToday ? Color.accentColor : Color.gray.opacity(0.1))
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                if let routine = assignedRoutine {
                    Text(routine.name)
                        .font(.body.bold())
                    Text("\(routine.exercises?.count ?? 0) ejercicios")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Descanso")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                showPicker = true
            } label: {
                Image(systemName: assignedRoutine == nil ? "plus.circle" : "pencil.circle")
                    .font(.title2)
                    .foregroundStyle(assignedRoutine == nil ? Color.accentColor : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { showPicker = true }
        .sheet(isPresented: $showPicker) {
            RoutinePickerSheet(
                routines: routines,
                selected: assignedRoutine,
                dayName: WeeklySchedule.dayName(for: weekday),
                onSelect: { routine in
                    onSelect(routine)
                    showPicker = false
                },
                onClear: {
                    onClear()
                    showPicker = false
                }
            )
        }
    }
}

struct RoutinePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let routines: [Routine]
    let selected: Routine?
    let dayName: String
    let onSelect: (Routine) -> Void
    let onClear: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Button {
                    onClear()
                } label: {
                    HStack {
                        Label("Descanso", systemImage: "moon.zzz.fill")
                            .foregroundStyle(.secondary)
                        Spacer()
                        if selected == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
                .foregroundStyle(.primary)

                Section("Rutinas") {
                    ForEach(routines) { routine in
                        Button {
                            onSelect(routine)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(routine.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text("\(routine.exercises?.count ?? 0) ejercicios")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selected?.id == routine.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(dayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}

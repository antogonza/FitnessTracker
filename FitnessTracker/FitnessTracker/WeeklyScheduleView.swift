import SwiftUI
import SwiftData

struct WeeklyScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklySchedule.weekday) private var schedules: [WeeklySchedule]
    @Query(sort: \Routine.creationDate, order: .reverse) private var routines: [Routine]
    
    @State private var showingRoutinePicker = false
    @State private var selectedWeekday: Int? = nil

    private var todayWeekday: Int {
        Calendar.current.component(.weekday, from: Date())
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text("FITNESSTRACKER")
                        .font(.system(size: 14, weight: .black))
                        .tracking(2)
                        .foregroundStyle(Theme.primary)
                    Spacer()
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(white: 0.08))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly Plan")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white)
                            Text("Sigue tu ritmo de entrenamiento semanal.")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        VStack(spacing: 16) {
                            ForEach(WeeklySchedule.weekdaysStartingMonday, id: \.self) { weekday in
                                let schedule = schedules.first { $0.weekday == weekday }
                                DayPlanCard(
                                    weekday: weekday,
                                    routine: schedule?.routine,
                                    isToday: weekday == todayWeekday,
                                    onTap: {
                                        selectedWeekday = weekday
                                        showingRoutinePicker = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Hero Image Section at bottom
                        ZStack(alignment: .bottomLeading) {
                            Image("gym_consistency_hero")
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                                .frame(height: 180)
                                .clipped()
                                .overlay(
                                    LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .bottom, endPoint: .top)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("El dolor es momentáneo. La gloria será eterna.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                                Text("El cuerpo lo aguanta todo. Es la mente la que me manda y el corazón el que tira.")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.cyan)
                            }
                            .padding()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showingRoutinePicker) {
            if let weekday = selectedWeekday {
                RoutinePickerSheet(
                    routines: routines,
                    selected: schedules.first { $0.weekday == weekday }?.routine,
                    dayName: WeeklySchedule.dayName(for: weekday),
                    onSelect: { routine in
                        assignRoutine(routine, to: weekday)
                    },
                    onClear: {
                        clearRoutine(from: weekday)
                    }
                )
            }
        }
    }

    private func assignRoutine(_ routine: Routine?, to weekday: Int) {
        if let existing = schedules.first(where: { $0.weekday == weekday }) {
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

struct DayPlanCard: View {
    let weekday: Int
    let routine: Routine?
    let isToday: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(WeeklySchedule.dayName(for: weekday).uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isToday ? Color.orange : .white.opacity(0.4))
                    
                    if let routine = routine {
                        Text(routine.category.uppercased())
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(.cyan)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.cyan.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text(routine.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text(weekday == 1 || weekday == 5 ? "Descanso Activo" : "Recuperación")
                            .font(.system(size: 16, weight: .medium))
                            .italic()
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(routine == nil ? Color.cyan.opacity(0.1) : (isToday ? Color.orange : Color.white.opacity(0.05)))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: routine == nil ? "moon.fill" : "dumbbell.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(routine == nil ? Color.cyan : (isToday ? Color.white : Color.orange))
                        }
                    
                    if isToday {
                        Text("HOY")
                            .font(.system(size: 8, weight: .black))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())
                            .offset(x: 10, y: -5)
                    }
                }
            }
            .padding()
            .background(Color(white: 0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isToday ? Color.orange.opacity(0.5) : (routine == nil ? Color.white.opacity(0.05) : Color.clear), 
                            style: StrokeStyle(lineWidth: 1, dash: routine == nil && !isToday ? [5] : []))
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
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Opción de Descanso
                        Button(action: {
                            onClear()
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "moon.zzz.fill")
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                
                                Text("Descanso")
                                    .font(.system(.body, design: .rounded).bold())
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                if selected == nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding()
                            .background(Color(white: 0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        
                        // Lista de Rutinas
                        VStack(alignment: .leading, spacing: 12) {
                            Text("MIS RUTINAS")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.horizontal, 8)
                            
                            VStack(spacing: 1) {
                                ForEach(routines) { routine in
                                    Button(action: {
                                        onSelect(routine)
                                        dismiss()
                                    }) {
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(Theme.primary.opacity(0.1))
                                                    .frame(width: 44, height: 44)
                                                Image(systemName: "figure.strengthtraining.functional")
                                                    .foregroundStyle(Theme.primary)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(routine.name)
                                                    .font(.system(.body, design: .rounded).bold())
                                                    .foregroundStyle(.white)
                                                Text("\(routine.exercises?.count ?? 0) ejercicios")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(.white.opacity(0.6))
                                            }
                                            
                                            Spacer()
                                            
                                            if selected?.id == routine.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.green)
                                            }
                                        }
                                        .padding()
                                        .background(Color(white: 0.05))
                                    }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(dayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
}

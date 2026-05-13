import SwiftUI
import SwiftData

struct HistoryCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.startTime, order: .reverse) private var sessions: [Session]
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    
    private let calendar = Calendar.current
    
    // Sesiones del mes actual para el resumen y el calendario
    private var sessionsForMonth: [Session] {
        sessions.filter { calendar.isDate($0.startTime, equalTo: currentMonth, toGranularity: .month) }
    }
    
    // Sesiones del día seleccionado
    private var sessionsForSelectedDate: [Session] {
        sessions.filter { calendar.isDate($0.startTime, inSameDayAs: selectedDate) }
    }
    
    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d 'de' MMMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: selectedDate)
    }
    
    private var monthlyVolumeK: String {
        let total = sessionsForMonth.reduce(0.0) { sum, session in
            let sessionSets = session.sets ?? []
            return sum + sessionSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        }
        return String(format: "%.0fk", total / 1000.0)
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
                .padding(.vertical, 12)
                .background(Color(white: 0.08))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Historial")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Tus progresos y consistencia.")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Calendario Premium
                        VStack(spacing: 20) {
                            HStack {
                                Text(monthYearString(from: currentMonth))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                HStack(spacing: 20) {
                                    Button(action: { changeMonth(by: -1) }) {
                                        Image(systemName: "chevron.left")
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                    Button(action: { changeMonth(by: 1) }) {
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                }
                            }
                            
                            // Días de la semana
                            HStack {
                                ForEach(["L", "M", "M", "J", "V", "S", "D"], id: \.self) { day in
                                    Text(day)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            // Rejilla de días
                            let days = daysInMonth(for: currentMonth)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                                ForEach(days, id: \.self) { date in
                                    if let date = date {
                                        VStack(spacing: 4) {
                                            Text("\(calendar.component(.day, from: date))")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(isSameDay(date, selectedDate) ? Theme.primary : .white)
                                            
                                            // Puntos de sesión
                                            let daySessions = sessionsForMonth.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
                                            HStack(spacing: 2) {
                                                ForEach(daySessions.prefix(2)) { session in
                                                    Circle()
                                                        .fill(session.routine?.name.contains("Cardio") == true ? Color.cyan : Color.orange)
                                                        .frame(width: 4, height: 4)
                                                }
                                            }
                                            .frame(height: 4)
                                        }
                                        .onTapGesture { selectedDate = date }
                                    } else {
                                        Color.clear.frame(height: 30)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                        
                        // Sesiones del día seleccionado
                        if !sessionsForSelectedDate.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("SESIONES DEL \(selectedDateString.uppercased())")
                                    .font(.system(size: 12, weight: .black))
                                    .tracking(1)
                                    .foregroundStyle(Theme.primary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    ForEach(sessionsForSelectedDate) { session in
                                        NavigationLink(destination: SessionDetailView(session: session)) {
                                            SessionHistoryCard(session: session)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Sesiones Recientes
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SESIONES RECIENTES")
                                .font(.system(size: 12, weight: .black))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.4))
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(sessions.prefix(3)) { session in
                                    NavigationLink(destination: SessionDetailView(session: session)) {
                                        SessionHistoryCard(session: session)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Resumen Mensual Hero
                        ZStack(alignment: .bottomLeading) {
                            Image("gym_history_summary_hero")
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                                .frame(height: 180)
                                .clipped()
                                .overlay(
                                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top)
                                )
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Resumen Mensual")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 32) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(sessionsForMonth.count)")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(.cyan)
                                        Text("SESIONES")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundStyle(.white.opacity(0.4))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(monthlyVolumeK)
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(.orange)
                                        Text("KG MOVIDOS")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundStyle(.white.opacity(0.4))
                                    }
                                }
                            }
                            .padding(20)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date).capitalized
    }
    
    private func daysInMonth(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { return [] }
        
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (weekday + 5) % 7 // Ajuste para que Lunes sea 0
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
}

struct SessionHistoryCard: View {
    let session: Session
    
    private var totalVolume: Double {
        let sessionSets = session.sets ?? []
        return sessionSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    private var durationString: String {
        guard let end = session.endTime else { return "En progreso" }
        let diff = Int(end.timeIntervalSince(session.startTime)) / 60
        return "\(diff) min"
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: session.routine?.name.contains("Cardio") == true ? "figure.run" : "dumbbell.fill")
                    .foregroundStyle(session.routine?.name.contains("Cardio") == true ? .orange : .cyan)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let category = session.routine?.category {
                    Text(category.uppercased())
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.cyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.cyan.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Text(session.routine?.name ?? "Entrenamiento")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                HStack(spacing: 4) {
                    Text(session.startTime.formatted(date: .omitted, time: .shortened))
                        .foregroundStyle(.cyan)
                    if let endTime = session.endTime {
                        Text("-")
                            .foregroundStyle(.white.opacity(0.2))
                        Text(endTime.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(.cyan)
                    }
                    Text("•")
                        .foregroundStyle(.white.opacity(0.2))
                    Text(durationString)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .font(.system(size: 13, weight: .medium))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f kg", totalVolume))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.orange)
                Text("VOLUMEN TOTAL")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding()
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

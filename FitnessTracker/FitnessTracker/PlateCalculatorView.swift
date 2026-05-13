import SwiftUI
import SwiftData

// MARK: - Modelo de datos de resultado (no persistente)
struct PlateResult: Identifiable {
    let id = UUID()
    let weight: Double
    let count: Int
}

// MARK: - Algoritmo de cálculo
struct PlateCalculator {
    // Eliminado el disco de 25kg, el máximo es 20kg
    static let availablePlates: [Double] = [20, 15, 10, 5, 2.5, 1.25]
    
    static func calculate(targetWeight: Double, barWeight: Double) -> [PlateResult]? {
        guard targetWeight >= barWeight else { return nil }
        var remaining = (targetWeight - barWeight) / 2.0
        var result: [PlateResult] = []

        for plate in availablePlates {
            let count = Int(remaining / plate)
            if count > 0 {
                result.append(PlateResult(weight: plate, count: count))
                remaining -= Double(count) * plate
                remaining = (remaining * 1000).rounded() / 1000
            }
        }
        return remaining < 0.001 ? result : nil
    }
}

// MARK: - Componentes Visuales
struct BarPlateView: View {
    let weight: Double
    
    var color: Color {
        switch weight {
        case 20: return .red
        case 15: return .orange
        case 10: return .blue
        case 5:  return .green
        case 2.5: return .blue.opacity(0.6)
        default: return .gray
        }
    }
    
    var height: CGFloat {
        switch weight {
        case 20: return 80
        case 15: return 70
        case 10: return 60
        case 5:  return 50
        case 2.5: return 40
        default: return 30
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(color.opacity(0.5), lineWidth: 1)
                    .blur(radius: 2)
            )
            .shadow(color: color.opacity(0.5), radius: 4)
    }
}

struct BarbellPreview: View {
    let plates: [PlateResult]
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [Color(white: 0.2), Color(white: 0.1)], startPoint: .top, endPoint: .bottom))
                .frame(width: 280, height: 4)
            
            HStack(spacing: 60) {
                HStack(spacing: 2) {
                    ForEach(plates.reversed()) { plate in
                        ForEach(0..<plate.count, id: \.self) { _ in
                            BarPlateView(weight: plate.weight)
                        }
                    }
                }
                
                HStack(spacing: 2) {
                    ForEach(plates) { plate in
                        ForEach(0..<plate.count, id: \.self) { _ in
                            BarPlateView(weight: plate.weight)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Vista Principal
struct PlateCalculatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bar.weight, order: .reverse) private var bars: [Bar]
    
    @State private var targetWeight: Double = 60.0
    @State private var selectedBarWeight: Double = 20.0
    @State private var isEditMode = false
    @State private var showingAddBar = false
    
    // Vuelve el paso de 2.5kg
    private let step: Double = 2.5
    
    private var plates: [PlateResult] {
        PlateCalculator.calculate(targetWeight: targetWeight, barWeight: selectedBarWeight) ?? []
    }
    
    private var weightPerSide: Double {
        max(0, (targetWeight - selectedBarWeight) / 2.0)
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
                    VStack(spacing: 32) {
                        // 1. Visualización
                        VStack(spacing: 12) {
                            BarbellPreview(plates: plates)
                                .frame(height: 120)
                            
                            Text("VISTA PREVIA DE CARGA")
                                .font(.system(size: 10, weight: .black))
                                .tracking(1)
                                .foregroundStyle(Color.orange.opacity(0.8))
                            
                            Rectangle()
                                .fill(Color.orange.opacity(0.3))
                                .frame(width: 40, height: 1)
                        }
                        .padding(.top, 20)
                        
                        // 2. Slider de Barras
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("TIPO DE BARRA")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(.white.opacity(0.4))
                                Spacer()
                                if isEditMode {
                                    Button("Listo") {
                                        withAnimation(.spring()) { isEditMode = false }
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Theme.primary)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(bars) { bar in
                                        BarButton(
                                            bar: bar,
                                            isSelected: selectedBarWeight == (bar.weight ?? 0.0),
                                            isEditMode: isEditMode,
                                            onSelect: { selectedBarWeight = (bar.weight ?? 0.0) },
                                            onDelete: { deleteBar(bar) },
                                            onLongPress: { withAnimation(.spring()) { isEditMode = true } }
                                        )
                                    }
                                    
                                    // Botón añadir
                                    if !isEditMode {
                                        Button(action: { showingAddBar = true }) {
                                            VStack {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(Theme.primary)
                                                Text("AÑADIR")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundStyle(.white.opacity(0.4))
                                            }
                                            .frame(width: 100, height: 80)
                                            .background(Color(white: 0.05))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.05), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                            )
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // 3. Objetivo Total (con decimales)
                        VStack(spacing: 16) {
                            Text("OBJETIVO TOTAL")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(.white.opacity(0.4))
                            
                            HStack(spacing: 30) {
                                Button(action: { if targetWeight > selectedBarWeight { targetWeight -= step } }) {
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 2)
                                        .frame(width: 64, height: 64)
                                        .overlay(Image(systemName: "minus").font(.title2).foregroundStyle(.orange))
                                }
                                
                                HStack(alignment: .bottom, spacing: 4) {
                                    Text(String(format: "%.1f", targetWeight))
                                        .font(.system(size: 54, weight: .black))
                                        .foregroundStyle(.white)
                                        .monospacedDigit()
                                    Text("KG")
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundStyle(.orange)
                                        .padding(.bottom, 10)
                                }
                                
                                Button(action: { targetWeight += step }) {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 64, height: 64)
                                        .overlay(Image(systemName: "plus").font(.title2.bold()).foregroundStyle(.white))
                                        .shadow(color: Color.orange.opacity(0.3), radius: 15)
                                }
                            }
                            
                            // 4. Slider de Peso
                            VStack(spacing: 8) {
                                Slider(value: $targetWeight, in: selectedBarWeight...300, step: 2.5)
                                    .tint(.orange)
                                    .padding(.horizontal, 40)
                                    .onChange(of: targetWeight) { old, newValue in
                                        // Asegurar que el valor siempre sea múltiplo de 2.5 respecto a la barra
                                        let offset = (newValue - selectedBarWeight)
                                        let snappedOffset = (offset / 2.5).rounded() * 2.5
                                        targetWeight = selectedBarWeight + snappedOffset
                                        
                                        // Feedback háptico ligero
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }
                                
                                HStack {
                                    Text("\(Int(selectedBarWeight)) kg")
                                    Spacer()
                                    Text("300 kg")
                                }
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white.opacity(0.3))
                                .padding(.horizontal, 40)
                            }
                        }
                        
                        // 5. Discos por lado
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("DISCOS POR LADO (\(weightPerSide.formatted()) KG)")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(.white.opacity(0.4))
                                Spacer()
                                Text("TOTAL: \(targetWeight.formatted()) KG")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(.orange)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(plates) { plate in
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .stroke(plateColor(plate.weight).opacity(0.3), lineWidth: 2)
                                                .frame(width: 48, height: 48)
                                            Text(String(format: "%.1f", plate.weight))
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(plateColor(plate.weight))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(plateName(plate.weight))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.white)
                                            Text(plateCategory(plate.weight))
                                                .font(.system(size: 10, weight: .black))
                                                .foregroundStyle(.white.opacity(0.2))
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(alignment: .bottom, spacing: 2) {
                                            Text("x\(plate.count)")
                                                .font(.system(size: 24, weight: .black))
                                                .foregroundStyle(.orange)
                                            Text("unid.")
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundStyle(.white.opacity(0.4))
                                                .padding(.bottom, 4)
                                        }
                                    }
                                    .padding()
                                    .background(Color(white: 0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Button(action: { targetWeight = 20; selectedBarWeight = 20 }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("RESETEAR CALCULADORA")
                            }
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color(white: 0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddBar) {
            AddBarSheet()
        }
    }
    
    private func deleteBar(_ bar: Bar) {
        modelContext.delete(bar)
        try? modelContext.save()
    }
    
    private func plateColor(_ weight: Double) -> Color {
        switch weight {
        case 20: return .red
        case 10: return .blue
        case 5:  return .green
        case 2.5: return .blue.opacity(0.8)
        default: return .orange
        }
    }
    
    private func plateName(_ weight: Double) -> String {
        switch weight {
        case 20: return "Disco Rojo"
        case 10: return "Disco Azul"
        case 5:  return "Disco Verde"
        case 2.5: return "Disco Azul"
        default: return "Disco Estándar"
        }
    }
    
    private func plateCategory(_ weight: Double) -> String {
        switch weight {
        default: return "ESTÁNDAR"
        }
    }
}

// MARK: - Subviews
struct BarButton: View {
    let bar: Bar
    let isSelected: Bool
    let isEditMode: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onLongPress: () -> Void
    
    @State private var wiggle = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                Text("\(String(format: "%.1f", bar.weight ?? 0.0)) KG")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isSelected ? Color.orange : .white)
                Text(bar.type ?? "ESTÁNDAR")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(width: 100, height: 80)
            .background(Color(white: 0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .rotationEffect(.degrees(isEditMode ? (wiggle ? 1.5 : -1.5) : 0))
            .onTapGesture {
                if !isEditMode { onSelect() }
            }
            .onLongPressGesture {
                onLongPress()
            }
            .onAppear {
                updateAnimation()
            }
            .onChange(of: isEditMode) { old, newValue in
                updateAnimation()
            }
            
            if isEditMode {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .red)
                        .font(.system(size: 22))
                        .offset(x: 5, y: -5)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func updateAnimation() {
        if isEditMode {
            withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) {
                wiggle = true
            }
        } else {
            wiggle = false
        }
    }
}

struct AddBarSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight = 20.0
    @State private var name = ""
    @State private var type = "ESTÁNDAR"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PESO DE LA BARRA")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white.opacity(0.4))
                        
                        HStack {
                            TextField("0.0", value: $weight, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                            Text("KG")
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(.orange)
                        }
                        .padding()
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TIPO / ETIQUETA")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white.opacity(0.4))
                        
                        TextField("Ej: Olímpica, EZ, Smith...", text: $type)
                            .padding()
                            .background(Color(white: 0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }
                    
                    Button(action: save) {
                        Text("GUARDAR BARRA")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Nueva Barra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
    
    private func save() {
        let bar = Bar(weight: weight, name: "\(weight) KG", type: type.uppercased())
        modelContext.insert(bar)
        try? modelContext.save()
        dismiss()
    }
}

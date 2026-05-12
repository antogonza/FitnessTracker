import SwiftUI

// MARK: - Modelo de datos

struct PlateResult: Identifiable {
    let id = UUID()
    let weight: Double  // peso de cada disco
    let count: Int      // cuántos discos de este tipo por lado
}

// MARK: - Calculadora de discos (algoritmo greedy)

struct PlateCalculator {
    /// Discos disponibles por lado, de mayor a menor
    static let availablePlates: [Double] = [20, 15, 10, 5, 2.5, 1.25]
    
    /// Pesos de barra más comunes
    static let barWeights: [Double] = [20, 15, 10, 7.5]
    static func barLabel(_ weight: Double) -> String {
        switch weight {
        case 20:   return "20 kg — Olímpica (hombre)"
        case 15:   return "15 kg — Olímpica (mujer)"
        case 10:   return "10 kg — Técnica"
        case 7.5:  return "7.5 kg — Curl/EZ"
        default:   return "\(weight) kg"
        }
    }

    /// Calcula los discos a colocar en CADA LADO de la barra para el peso objetivo.
    /// Devuelve nil si el peso es menor que la barra o si no se puede alcanzar exactamente.
    static func calculate(targetWeight: Double, barWeight: Double) -> [PlateResult]? {
        guard targetWeight >= barWeight else { return nil }
        var remaining = (targetWeight - barWeight) / 2.0
        var result: [PlateResult] = []

        for plate in availablePlates {
            let count = Int(remaining / plate)
            if count > 0 {
                result.append(PlateResult(weight: plate, count: count))
                remaining -= Double(count) * plate
                remaining = (remaining * 1000).rounded() / 1000 // evitar errores de float
            }
        }

        // Si queda algún residuo (el peso no es alcanzable exactamente), devolvemos nil
        return remaining < 0.001 ? result : nil
    }
}

// MARK: - Vista del disco (dibujado con SwiftUI)

struct PlateView: View {
    let weight: Double
    let isSmall: Bool // true para la versión compacta en la barra

    var plateColor: Color {
        switch weight {
        case 20:   return Color(red: 0.85, green: 0.15, blue: 0.15) // Rojo
        case 15:   return Color(red: 0.95, green: 0.60, blue: 0.10) // Naranja
        case 10:   return Color(red: 0.20, green: 0.45, blue: 0.85) // Azul
        case 5:    return Color(red: 0.15, green: 0.65, blue: 0.30) // Verde
        case 2.5:  return Color(red: 0.85, green: 0.85, blue: 0.10) // Amarillo
        default:   return Color(UIColor.systemGray3)                  // Gris (1.25)
        }
    }

    var plateHeight: CGFloat {
        if isSmall {
            switch weight {
            case 20:   return 64
            case 15:   return 56
            case 10:   return 48
            case 5:    return 38
            case 2.5:  return 30
            default:   return 24 // 1.25
            }
        } else {
            return 36
        }
    }

    var plateWidth: CGFloat { isSmall ? 18 : 44 }

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(plateColor)
            .frame(width: plateWidth, height: plateHeight)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(plateColor.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: plateColor.opacity(0.4), radius: 3, x: 1, y: 2)
    }
}

// MARK: - Visualización de la barra

struct BarbellView: View {
    let plates: [PlateResult]

    var body: some View {
        HStack(spacing: 0) {
            // Extremo izquierdo
            barEndCap()

            // Discos izquierdos (el más pesado más alejado del centro)
            HStack(spacing: 2) {
                ForEach(plates) { plate in
                    ForEach(0..<plate.count, id: \.self) { _ in
                        PlateView(weight: plate.weight, isSmall: true)
                    }
                }
            }

            // Barra central
            Rectangle()
                .fill(Color(UIColor.systemGray4))
                .frame(width: 80, height: 10)

            // Discos derechos (espejo)
            HStack(spacing: 2) {
                ForEach(plates.reversed()) { plate in
                    ForEach(0..<plate.count, id: \.self) { _ in
                        PlateView(weight: plate.weight, isSmall: true)
                    }
                }
            }

            // Extremo derecho
            barEndCap()
        }
    }

    @ViewBuilder
    private func barEndCap() -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(UIColor.systemGray3))
            .frame(width: 14, height: 18)
    }
}

// MARK: - Vista principal

struct PlateCalculatorView: View {
    @State private var targetWeight: Double = 60.0
    @State private var selectedBarWeight: Double = 20.0
    private let step: Double = 2.5
    private let minWeight: Double = 20.0
    private let maxWeight: Double = 300.0

    private var plates: [PlateResult]? {
        PlateCalculator.calculate(targetWeight: targetWeight, barWeight: selectedBarWeight)
    }

    private var weightPerSide: Double {
        max(0, (targetWeight - selectedBarWeight)) / 2.0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Selector de peso
                    VStack(spacing: 8) {
                        Text("Peso objetivo")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 20) {
                            Button {
                                if targetWeight - step >= minWeight {
                                    targetWeight -= step
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.orange)
                            }
                            .buttonStyle(.plain)

                            Text(String(format: "%.1f kg", targetWeight))
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .animation(.none, value: targetWeight)
                                .frame(minWidth: 150)

                            Button {
                                if targetWeight + step <= maxWeight {
                                    targetWeight += step
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.orange)
                            }
                            .buttonStyle(.plain)
                        }

                        Slider(value: $targetWeight, in: minWeight...maxWeight, step: step)
                            .accentColor(.orange)
                            .padding(.horizontal)

                        HStack {
                            Text("Barra: \(String(format: "%.4g", selectedBarWeight)) kg")
                            Spacer()
                            Text("Por lado: \(String(format: "%.4g", weightPerSide)) kg")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        
                        // Selector de tipo de barra
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tipo de barra")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            Picker("Barra", selection: $selectedBarWeight) {
                                ForEach(PlateCalculator.barWeights, id: \.self) { w in
                                    Text(PlateCalculator.barLabel(w)).tag(w)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            .onChange(of: selectedBarWeight) { _, newBar in
                                // Si el peso objetivo queda por debajo de la barra, lo ajustamos
                                if targetWeight < newBar {
                                    targetWeight = newBar
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // MARK: Visualización gráfica de la barra
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vista de la barra")
                            .font(.headline)
                            .padding(.horizontal)

                        if let plates = plates {
                            ScrollView(.horizontal, showsIndicators: false) {
                                BarbellView(plates: plates)
                                    .padding(.vertical, 20)
                                    .padding(.horizontal)
                            }
                            .frame(height: 110)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                Text(targetWeight < selectedBarWeight
                                     ? "El peso mínimo es la barra (\(String(format: "%.4g", selectedBarWeight)) kg)"
                                     : "Peso no alcanzable con discos estándar")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }

                    // MARK: Lista de discos por lado
                    if let plates = plates, !plates.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Discos por lado")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.bottom, 8)

                            VStack(spacing: 0) {
                                ForEach(plates) { plate in
                                    HStack(spacing: 14) {
                                        PlateView(weight: plate.weight, isSmall: false)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(String(format: "%.4g", plate.weight)) kg")
                                                .font(.headline)
                                            Text(plateName(plate.weight))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Text("× \(plate.count)")
                                            .font(.title2.bold())
                                            .foregroundStyle(.primary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)

                                    if plate.id != plates.last?.id {
                                        Divider().padding(.leading, 76)
                                    }
                                }
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Calculadora de Discos")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    private func plateName(_ weight: Double) -> String {
        switch weight {
        case 20:  return "Disco olímpico rojo"
        case 15:  return "Disco olímpico naranja"
        case 10:  return "Disco olímpico azul"
        case 5:   return "Disco olímpico verde"
        case 2.5: return "Disco olímpico amarillo"
        default:  return "Disco olímpico gris"
        }
    }
}

#Preview {
    PlateCalculatorView()
}

import SwiftUI

struct PlateCalculatorWatchView: View {
    @Binding var targetWeight: Double
    @State private var barWeight: Double = 20.0
    
    init(targetWeight: Binding<Double>) {
        self._targetWeight = targetWeight
    }
    
    // Algoritmo simple para el Watch
    private var plates: [(weight: Double, count: Int)] {
        let available: [Double] = [20, 15, 10, 5, 2.5, 1.25]
        var remaining = (targetWeight - barWeight) / 2.0
        var result: [(Double, Int)] = []
        
        for p in available {
            let count = Int(remaining / p)
            if count > 0 {
                result.append((p, count))
                remaining -= Double(count) * p
                remaining = (remaining * 100).rounded() / 100
            }
        }
        return result
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Selector de peso con Digital Crown
                VStack {
                    Text("PESO TOTAL")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("\(String(format: "%.1f", targetWeight)) kg")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                        .focusable()
                        .digitalCrownRotation($targetWeight, from: barWeight, through: 300, by: 2.5, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
                }
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                
                // Selector de barra (mini)
                HStack {
                    Button("10kg") { barWeight = 10 }.buttonStyle(.bordered).tint(barWeight == 10 ? .blue : .gray)
                    Button("15kg") { barWeight = 15 }.buttonStyle(.bordered).tint(barWeight == 15 ? .blue : .gray)
                    Button("20kg") { barWeight = 20 }.buttonStyle(.bordered).tint(barWeight == 20 ? .blue : .gray)
                }
                .font(.caption2)
                
                Divider()
                
                // Resultado de discos
                if plates.isEmpty {
                    Text("Solo la barra")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DISCOS POR LADO")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        ForEach(plates, id: \.weight) { plate in
                            HStack {
                                Circle()
                                    .fill(plateColor(plate.weight))
                                    .frame(width: 8, height: 8)
                                
                                Text("\(String(format: "%.4g", plate.weight)) kg")
                                    .font(.system(.body, design: .rounded))
                                
                                Spacer()
                                
                                Text("x\(plate.count)")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.orange)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Calculadora")
    }
    
    private func plateColor(_ w: Double) -> Color {
        switch w {
        case 20: return .red
        case 15: return .orange
        case 10: return .blue
        case 5: return .green
        case 2.5: return .yellow
        default: return .gray
        }
    }
}

#Preview {
    PlateCalculatorWatchView(targetWeight: .constant(60.0))
}

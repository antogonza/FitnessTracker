import SwiftUI

struct PlateCalculatorWatchView: View {
    @Binding var targetWeight: Double
    @State private var barWeight: Double = 20.0
    
    init(targetWeight: Binding<Double>) {
        self._targetWeight = targetWeight
    }
    
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
                VStack(spacing: 2) {
                    Text("PESO OBJETIVO")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Text("\(String(format: "%.1f", targetWeight)) KG")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.primary)
                        .focusable()
                        .digitalCrownRotation($targetWeight, from: barWeight, through: 500, by: 2.5, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(white: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Selector de barra (Estilo premium)
                VStack(alignment: .leading, spacing: 4) {
                    Text("BARRA")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                    
                    HStack(spacing: 4) {
                        barButton(weight: 10)
                        barButton(weight: 15)
                        barButton(weight: 20)
                    }
                }
                
                // Resultado de discos
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("DISCOS POR LADO")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Image(systemName: "circle.grid.3x3.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.primary)
                    }
                    
                    if plates.isEmpty {
                        Text("SOLO LA BARRA")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.primary.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)
                    } else {
                        VStack(spacing: 6) {
                            ForEach(plates, id: \.weight) { plate in
                                HStack {
                                    Circle()
                                        .fill(plateColor(plate.weight))
                                        .frame(width: 6, height: 6)
                                    
                                    Text("\(String(format: "%.1f", plate.weight)) kg")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Text("x\(plate.count)")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(Theme.primary)
                                }
                                .padding(8)
                                .background(Color(white: 0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding(10)
                .background(Color(white: 0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .navigationTitle("Discos")
    }
    
    private func barButton(weight: Double) -> some View {
        Button {
            barWeight = weight
            WKInterfaceDevice.current().play(.click)
        } label: {
            Text("\(Int(weight))KG")
                .font(.system(size: 10, weight: .black))
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background {
                    if barWeight == weight {
                        Theme.primaryGradient
                    } else {
                        Color.white.opacity(0.05)
                    }
                }
                .foregroundStyle(barWeight == weight ? .black : .white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
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

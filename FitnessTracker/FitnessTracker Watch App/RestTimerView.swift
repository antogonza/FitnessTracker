import SwiftUI
import WatchKit

struct RestTimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var progress: Double {
        max(0, timerManager.timeRemaining / timerManager.totalDuration)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    timerManager.showFullScreenTimer = false
                }) {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.top, 4)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            ZStack {
                // Anillo de fondo
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                // Anillo de progreso animado
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear(duration: 0.1), value: progress)
                
                // Texto de tiempo
                Text(timerManager.timeString)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 10)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    timerManager.skipTimer()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .tint(.red)
                
                Button(action: {
                    timerManager.addTime(30)
                }) {
                    Text("+30s")
                        .font(.body)
                        .fontWeight(.bold)
                }
                .tint(.gray)
            }
            .padding(.bottom, 8)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

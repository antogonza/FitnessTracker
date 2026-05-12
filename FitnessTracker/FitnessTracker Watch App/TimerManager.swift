import SwiftUI
import Combine
import Combine
import WatchKit
import UserNotifications

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var showFullScreenTimer = false
    @Published var targetDate: Date = .now
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 90
    
    /// Contexto para la Live Activity (se rellena antes de llamar a startTimer)
    var routineName: String = "Entrenamiento"
    var nextExerciseName: String = "Siguiente serie"
    
    var timer: AnyCancellable?
    var onTimerFinished: (() -> Void)?
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        _ = WatchToPhoneConnector.shared // Activa la sesión WC al iniciar
    }
    
    var timeString: String {
        let minutes = Int(max(0, ceil(timeRemaining))) / 60
        let seconds = Int(max(0, ceil(timeRemaining))) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func startTimer(duration: TimeInterval = 90) {
        self.totalDuration = duration
        self.targetDate = Date.now.addingTimeInterval(duration)
        self.timeRemaining = duration
        self.isRunning = true
        self.showFullScreenTimer = true
        
        scheduleNotification(remaining: duration)
        
        // Notificar al iPhone para que inicie la Live Activity
        WatchToPhoneConnector.shared.sendTimerStarted(
            routineName: routineName,
            nextExercise: nextExerciseName,
            duration: duration
        )
        
        timer?.cancel()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }
    }
    
    func addTime(_ seconds: TimeInterval) {
        targetDate = targetDate.addingTimeInterval(seconds)
        totalDuration += seconds
        
        let remaining = targetDate.timeIntervalSince(Date.now)
        scheduleNotification(remaining: remaining)
        
        // Notificar al iPhone del nuevo tiempo
        WatchToPhoneConnector.shared.sendTimerUpdated(
            nextExercise: nextExerciseName,
            duration: totalDuration,
            endDate: targetDate
        )
        
        update()
    }
    
    func skipTimer() {
        stopTimer(finishedNaturally: false)
    }
    
    func stopTimer(finishedNaturally: Bool) {
        timer?.cancel()
        timer = nil
        isRunning = false
        showFullScreenTimer = false
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RestTimerNotification"])
        
        // Notificar al iPhone para que cierre la Live Activity
        WatchToPhoneConnector.shared.sendTimerEnded()
        
        if finishedNaturally {
            WKInterfaceDevice.current().play(.notification)
            onTimerFinished?()
        }
    }
    
    private func update() {
        let remaining = targetDate.timeIntervalSince(Date.now)
        
        if Int(ceil(timeRemaining)) != Int(ceil(remaining)) {
            let secondsLeft = Int(ceil(remaining))
            if secondsLeft > 0 && secondsLeft <= 5 {
                // Vibración a los 5 segundos en lugar de a los 3
                WKInterfaceDevice.current().play(.click)
            }
        }
        
        timeRemaining = remaining
        
        if remaining <= 0 {
            stopTimer(finishedNaturally: true)
        }
    }
    
    private func scheduleNotification(remaining: TimeInterval) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RestTimerNotification"])
        
        guard remaining > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "¡Descanso terminado!"
        content.body = "A por la siguiente serie."
        content.sound = UNNotificationSound.default
        
        // Requiere watchOS para vibrar en background
        content.categoryIdentifier = "TimerCategory"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remaining, repeats: false)
        let request = UNNotificationRequest(identifier: "RestTimerNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

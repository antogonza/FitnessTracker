//
//  FitnessTrackerApp.swift
//  FitnessTracker Watch App
//
//  Created by Antonio González Rodríguez on 6/5/26.
//

import SwiftUI
import SwiftData

@main
struct FitnessTracker_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
        }
        #if targetEnvironment(simulator)
        .modelContainer(.preview) // Carga los mocks que creamos en la Fase 1
        #else
        .modelContainer(.shared)
        #endif
    }
}

//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by Antonio González Rodríguez on 6/5/26.
//

import SwiftUI
import SwiftData

@main
struct FitnessTrackerApp: App {

    // Activa el receptor WatchConnectivity al lanzar la app
    private let connectivityReceiver = PhoneConnectivityReceiver.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(.shared)
    }
}

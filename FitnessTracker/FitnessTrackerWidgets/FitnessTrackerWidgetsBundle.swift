//
//  FitnessTrackerWidgetsBundle.swift
//  FitnessTrackerWidgets
//
//  Created by Antonio González Rodríguez on 7/5/26.
//

import WidgetKit
import SwiftUI

@main
struct FitnessTrackerWidgetsBundle: WidgetBundle {
    var body: some Widget {
        FitnessTrackerWidgets()
        FitnessTrackerWidgetsControl()
        RestTimerLiveActivity()
    }
}

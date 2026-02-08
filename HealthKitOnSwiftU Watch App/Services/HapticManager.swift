//
//  HapticManager.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import Foundation
import WatchKit

/// Manages haptic feedback for the app
class HapticManager {
    
    // MARK: - Singleton
    
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Haptic Feedback Methods
    
    /// Play a simple tap feedback
    func tap() {
        WKInterfaceDevice.current().play(.click)
    }
    
    /// Play success feedback (goal reached, etc.)
    func success() {
        WKInterfaceDevice.current().play(.success)
    }
    
    /// Play notification feedback
    func notification() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    /// Play start feedback (beginning monitoring)
    func start() {
        WKInterfaceDevice.current().play(.start)
    }
    
    /// Play stop feedback (stopping monitoring)
    func stop() {
        WKInterfaceDevice.current().play(.stop)
    }
    
    /// Play directional up feedback (entering higher zone)
    func zoneUp() {
        WKInterfaceDevice.current().play(.directionUp)
    }
    
    /// Play directional down feedback (entering lower zone)
    func zoneDown() {
        WKInterfaceDevice.current().play(.directionDown)
    }
    
    /// Play feedback for zone change
    func zoneChanged(from oldZone: HeartRateZone, to newZone: HeartRateZone) {
        // Determine if going up or down in intensity
        let zones = HeartRateZone.allCases
        guard let oldIndex = zones.firstIndex(of: oldZone),
              let newIndex = zones.firstIndex(of: newZone) else {
            return
        }
        
        if newIndex > oldIndex {
            // Moving to higher intensity zone
            zoneUp()
        } else {
            // Moving to lower intensity zone
            zoneDown()
        }
    }
    
    /// Play warning feedback (peak zone, etc.)
    func warning() {
        WKInterfaceDevice.current().play(.failure)
    }
}


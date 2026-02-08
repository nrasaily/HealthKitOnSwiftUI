//
//  HeartRateZone.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import SwiftUI

/// Heart rate training zones based on percentage of max heart rate
enum HeartRateZone: String, CaseIterable {
    case rest = "Rest"
    case fatBurn = "Fat Burn"
    case cardio = "Cardio"
    case peak = "Peak"
    
    /// Color associated with each zone
    var color: Color {
        switch self {
        case .rest:
            return .green
        case .fatBurn:
            return .yellow
        case .cardio:
            return .orange
        case .peak:
            return .red
        }
    }
    
    /// Icon for each zone
    var icon: String {
        switch self {
        case .rest:
            return "figure.stand"
        case .fatBurn:
            return "flame"
        case .cardio:
            return "figure.run"
        case .peak:
            return "bolt.heart.fill"
        }
    }
    
    /// Description of the zone
    var description: String {
        switch self {
        case .rest:
            return "Recovery zone"
        case .fatBurn:
            return "Light exercise"
        case .cardio:
            return "Moderate intensity"
        case .peak:
            return "Maximum effort"
        }
    }
    
    /// Calculate zone based on current BPM and user's max heart rate
    /// Default max HR formula: 220 - age (we'll use 190 as default for ~30 year old)
    static func zone(for bpm: Double, maxHeartRate: Double = 190) -> HeartRateZone {
        let percentage = bpm / maxHeartRate * 100
        
        switch percentage {
        case 0..<60:
            return .rest
        case 60..<70:
            return .fatBurn
        case 70..<85:
            return .cardio
        default:
            return .peak
        }
    }
    
    /// Get percentage range for this zone
    var percentageRange: String {
        switch self {
        case .rest:
            return "50-60%"
        case .fatBurn:
            return "60-70%"
        case .cardio:
            return "70-85%"
        case .peak:
            return "85-100%"
        }
    }
}

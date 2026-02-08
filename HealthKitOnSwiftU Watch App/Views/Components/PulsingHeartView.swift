//
//  PulsingHeartView.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import SwiftUI

/// An animated heart that pulses based on heart rate
struct PulsingHeartView: View {
    let heartRate: Double
    let zone: HeartRateZone
    
    @State private var isPulsing = false
    
    /// Calculate animation duration based on heart rate
    /// Higher heart rate = faster pulse
    private var pulseDuration: Double {
        guard heartRate > 0 else { return 1.0 }
        // Convert BPM to seconds per beat
        return 60.0 / heartRate
    }
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 60))
            .foregroundStyle(zone.color)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .animation(
                .easeInOut(duration: pulseDuration / 2)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
            .onChange(of: heartRate) { _, _ in
                // Reset animation when heart rate changes significantly
                isPulsing = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPulsing = true
                }
            }
    }
}

/// A smaller pulsing heart for list items or compact displays
struct SmallPulsingHeartView: View {
    let zone: HeartRateZone
    @State private var isPulsing = false
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundStyle(zone.color)
            .scaleEffect(isPulsing ? 1.15 : 1.0)
            .animation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        PulsingHeartView(heartRate: 72, zone: .rest)
        PulsingHeartView(heartRate: 120, zone: .cardio)
        PulsingHeartView(heartRate: 170, zone: .peak)
    }
}


//
//  HeartRateView.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import SwiftUI

/// Main view displaying the current heart rate
struct HeartRateView: View {
    @ObservedObject var viewModel: HeartRateViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Pulsing heart animation
                PulsingHeartView(
                    heartRate: viewModel.currentHeartRate,
                    zone: viewModel.currentZone
                )
                .padding(.top, 8)
                
                // Current BPM display
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(viewModel.formattedHeartRate)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(viewModel.currentZone.color)
                    
                    Text("BPM")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                // Zone badge
                ZoneBadgeView(zone: viewModel.currentZone)
                
                // Last updated time
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Updated \(lastUpdated, style: .relative) ago")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Start/Stop button
                Button(action: {
                    viewModel.toggleMonitoring()
                }) {
                    HStack {
                        Image(systemName: viewModel.isMonitoring ? "stop.fill" : "play.fill")
                        Text(viewModel.isMonitoring ? "Stop" : "Start")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isMonitoring ? .red : .green)
                .padding(.top, 8)
                
                // Error message if any
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .navigationTitle("Heart Rate")
    }
}

#Preview {
    let viewModel = HeartRateViewModel()
    return HeartRateView(viewModel: viewModel)
}


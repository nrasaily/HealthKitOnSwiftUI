//
//  ZonesInfoView.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import SwiftUI

/// View explaining heart rate zones
struct ZonesInfoView: View {
    @ObservedObject var viewModel: HeartRateViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Current zone highlight
                if viewModel.currentHeartRate > 0 {
                    CurrentZoneCard(zone: viewModel.currentZone, bpm: viewModel.currentHeartRate)
                }
                
                // All zones list
                ForEach(HeartRateZone.allCases, id: \.self) { zone in
                    ZoneRow(
                        zone: zone,
                        maxHeartRate: viewModel.maxHeartRate,
                        isCurrentZone: zone == viewModel.currentZone && viewModel.currentHeartRate > 0
                    )
                }
                
                // Max HR info
                VStack(spacing: 4) {
                    Text("Based on max HR: \(Int(viewModel.maxHeartRate)) BPM")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Formula: 220 - age")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("HR Zones")
    }
}

/// Card showing the current zone
struct CurrentZoneCard: View {
    let zone: HeartRateZone
    let bpm: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                SmallPulsingHeartView(zone: zone)
                Text("Current Zone")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(zone.rawValue)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(zone.color)
            
            Text("\(Int(bpm)) BPM")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(zone.color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// A row showing zone information
struct ZoneRow: View {
    let zone: HeartRateZone
    let maxHeartRate: Double
    let isCurrentZone: Bool
    
    /// Calculate BPM range for this zone
    private var bpmRange: String {
        let ranges: [(HeartRateZone, Double, Double)] = [
            (.rest, 0.50, 0.60),
            (.fatBurn, 0.60, 0.70),
            (.cardio, 0.70, 0.85),
            (.peak, 0.85, 1.0)
        ]
        
        guard let range = ranges.first(where: { $0.0 == zone }) else {
            return ""
        }
        
        let low = Int(maxHeartRate * range.1)
        let high = Int(maxHeartRate * range.2)
        return "\(low)-\(high)"
    }
    
    var body: some View {
        HStack {
            // Zone color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(zone.color)
                .frame(width: 4)
            
            // Zone icon
            Image(systemName: zone.icon)
                .foregroundStyle(zone.color)
                .frame(width: 24)
            
            // Zone info
            VStack(alignment: .leading, spacing: 2) {
                Text(zone.rawValue)
                    .font(.caption)
                    .fontWeight(isCurrentZone ? .bold : .regular)
                Text(zone.percentageRange)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // BPM range
            Text(bpmRange)
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isCurrentZone ? zone.color.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ZonesInfoView(viewModel: HeartRateViewModel())
}


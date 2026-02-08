//
//  ZoneBadgeView.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import SwiftUI

/// A badge showing the current heart rate zone
struct ZoneBadgeView: View {
    let zone: HeartRateZone
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: zone.icon)
                .font(.caption2)
            Text(zone.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(zone.color.opacity(0.2))
        .foregroundStyle(zone.color)
        .clipShape(Capsule())
    }
}

/// A larger zone indicator with description
struct ZoneIndicatorView: View {
    let zone: HeartRateZone
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: zone.icon)
                    .font(.title3)
                Text(zone.rawValue)
                    .font(.headline)
            }
            .foregroundStyle(zone.color)
            
            Text(zone.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(zone.color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach(HeartRateZone.allCases, id: \.self) { zone in
            ZoneBadgeView(zone: zone)
        }
        
        Divider()
        
        ZoneIndicatorView(zone: .cardio)
    }
}


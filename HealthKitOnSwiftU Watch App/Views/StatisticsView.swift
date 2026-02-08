//
//  StatisticsView.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import SwiftUI

/// View displaying session statistics
struct StatisticsView: View {
    @ObservedObject var viewModel: HeartRateViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Session header
                if viewModel.isMonitoring {
                    HStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        Text("Recording")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(viewModel.formattedDuration)
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .padding(.horizontal)
                }
                
                // Statistics cards
                VStack(spacing: 12) {
                    StatCard(
                        title: "Average",
                        value: "\(Int(viewModel.averageHeartRate))",
                        unit: "BPM",
                        icon: "heart.text.square",
                        color: .cyan
                    )
                    
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Min",
                            value: "\(Int(viewModel.minHeartRate))",
                            unit: "BPM",
                            icon: "arrow.down.heart",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Max",
                            value: "\(Int(viewModel.maxSessionHeartRate))",
                            unit: "BPM",
                            icon: "arrow.up.heart",
                            color: .red
                        )
                    }
                }
                .padding(.horizontal)
                
                // Sample count
                if !viewModel.sessionSamples.isEmpty {
                    Text("\(viewModel.sessionSamples.count) samples collected")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Empty state
                if viewModel.sessionSamples.isEmpty && !viewModel.isMonitoring {
                    VStack(spacing: 8) {
                        Image(systemName: "heart.slash")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No data yet")
                            .font(.headline)
                        Text("Start monitoring to collect heart rate data")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Statistics")
    }
}

/// A card displaying a single statistic
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatisticsView(viewModel: HeartRateViewModel())
}


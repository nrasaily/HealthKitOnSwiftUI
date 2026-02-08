//
//  ContentView.swift
//  HealthKitOnSwiftU Watch App
//
//  Created by Nar Rasaily on 2/8/26.
//

import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {
    @StateObject private var viewModel = HeartRateViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        if viewModel.isAuthorized {
            // Main app interface with tabs
            TabView(selection: $selectedTab) {
                // Heart Rate Tab
                HeartRateView(viewModel: viewModel)
                    .tag(0)
                
                // Statistics Tab
                StatisticsView(viewModel: viewModel)
                    .tag(1)
                
                // Zones Info Tab
                ZonesInfoView(viewModel: viewModel)
                    .tag(2)
            }
            .tabViewStyle(.verticalPage)
        } else {
            // Authorization request view
            AuthorizationView(viewModel: viewModel)
        }
    }
}

/// View shown when HealthKit authorization is needed
struct AuthorizationView: View {
    @ObservedObject var viewModel: HeartRateViewModel
    @State private var isRequesting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.red)
                
                // Title
                Text("Heart Rate Monitor")
                    .font(.headline)
                
                // Description
                Text("This app needs access to your heart rate data to display real-time health metrics.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                // HealthKit availability check
                if !viewModel.isHealthKitAvailable {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("HealthKit is not available on this device")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Authorize button
                    Button(action: {
                        requestAuthorization()
                    }) {
                        HStack {
                            if isRequesting {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Image(systemName: "checkmark.shield")
                                Text("Authorize")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(isRequesting)
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
    }
    
    private func requestAuthorization() {
        isRequesting = true
        Task {
            await viewModel.requestAuthorization()
            isRequesting = false
        }
    }
}

#Preview {
    ContentView()
}

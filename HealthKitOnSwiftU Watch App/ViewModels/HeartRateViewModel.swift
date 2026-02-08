//
//  HeartRateViewModel.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel managing heart rate data and business logic
@MainActor
class HeartRateViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current heart rate in BPM
    @Published var currentHeartRate: Double = 0
    
    /// Current heart rate zone
    @Published var currentZone: HeartRateZone = .rest
    
    /// Whether we're currently monitoring
    @Published var isMonitoring: Bool = false
    
    /// Whether authorization has been requested
    @Published var isAuthorized: Bool = false
    
    /// Whether HealthKit is available
    @Published var isHealthKitAvailable: Bool = false
    
    /// Error message to display
    @Published var errorMessage: String?
    
    /// Last update timestamp
    @Published var lastUpdated: Date?
    
    /// All heart rate samples collected during this session
    @Published var sessionSamples: [HeartRateSample] = []
    
    /// User's max heart rate (220 - age, default assumes ~30 years old)
    @Published var maxHeartRate: Double = 190
    
    // MARK: - Computed Properties
    
    /// Minimum heart rate in current session
    var minHeartRate: Double {
        sessionSamples.map(\.bpm).min() ?? 0
    }
    
    /// Maximum heart rate in current session
    var maxSessionHeartRate: Double {
        sessionSamples.map(\.bpm).max() ?? 0
    }
    
    /// Average heart rate in current session
    var averageHeartRate: Double {
        guard !sessionSamples.isEmpty else { return 0 }
        let sum = sessionSamples.reduce(0) { $0 + $1.bpm }
        return sum / Double(sessionSamples.count)
    }
    
    /// Formatted current heart rate
    var formattedHeartRate: String {
        "\(Int(currentHeartRate))"
    }
    
    /// Session duration
    var sessionDuration: TimeInterval {
        guard let first = sessionSamples.last?.timestamp,
              let last = sessionSamples.first?.timestamp else {
            return 0
        }
        return last.timeIntervalSince(first)
    }
    
    /// Formatted session duration
    var formattedDuration: String {
        let minutes = Int(sessionDuration) / 60
        let seconds = Int(sessionDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Private Properties
    
    private let healthKitManager = HealthKitManager.shared
    private let hapticManager = HapticManager.shared
    private var previousZone: HeartRateZone?
    
    // MARK: - Initialization
    
    init() {
        isHealthKitAvailable = healthKitManager.isHealthKitAvailable
    }
    
    // MARK: - Public Methods
    
    /// Request HealthKit authorization
    func requestAuthorization() async {
        guard isHealthKitAvailable else {
            errorMessage = "HealthKit is not available on this device"
            return
        }
        
        do {
            try await healthKitManager.requestAuthorization()
            isAuthorized = true
            hapticManager.success()
        } catch {
            errorMessage = "Authorization failed: \(error.localizedDescription)"
            isAuthorized = false
        }
    }
    
    /// Start monitoring heart rate
    func startMonitoring() {
        guard isHealthKitAvailable else {
            errorMessage = "HealthKit is not available"
            return
        }
        
        // Clear previous session data
        sessionSamples.removeAll()
        previousZone = nil
        errorMessage = nil
        
        isMonitoring = true
        hapticManager.start()
        
        healthKitManager.startHeartRateMonitoring { [weak self] samples in
            Task { @MainActor in
                self?.handleNewSamples(samples)
            }
        }
    }
    
    /// Stop monitoring heart rate
    func stopMonitoring() {
        healthKitManager.stopHeartRateMonitoring()
        isMonitoring = false
        hapticManager.stop()
    }
    
    /// Toggle monitoring state
    func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }
    
    /// Fetch the latest heart rate (one-time fetch)
    func fetchLatestHeartRate() async {
        do {
            if let sample = try await healthKitManager.fetchLatestHeartRate() {
                currentHeartRate = sample.bpm
                lastUpdated = sample.timestamp
                updateZone()
            }
        } catch {
            errorMessage = "Failed to fetch heart rate: \(error.localizedDescription)"
        }
    }
    
    /// Update max heart rate based on user's age
    func updateMaxHeartRate(age: Int) {
        maxHeartRate = Double(220 - age)
    }
    
    // MARK: - Private Methods
    
    /// Handle new heart rate samples from monitoring
    private func handleNewSamples(_ samples: [HeartRateSample]) {
        // Add samples to session
        sessionSamples.insert(contentsOf: samples, at: 0)
        
        // Update current heart rate with most recent
        if let latestSample = samples.first {
            currentHeartRate = latestSample.bpm
            lastUpdated = latestSample.timestamp
            updateZone()
        }
    }
    
    /// Update the current heart rate zone
    private func updateZone() {
        let newZone = HeartRateZone.zone(for: currentHeartRate, maxHeartRate: maxHeartRate)
        
        // Check if zone changed
        if let previousZone = previousZone, previousZone != newZone {
            hapticManager.zoneChanged(from: previousZone, to: newZone)
            
            // Extra warning for peak zone
            if newZone == .peak {
                hapticManager.warning()
            }
        }
        
        previousZone = currentZone
        currentZone = newZone
    }
}


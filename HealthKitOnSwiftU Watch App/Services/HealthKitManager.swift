//
//  HealthKitManager.swift
//  HealthKitOnSwiftU
//
//  Created by Nar Rasaily on 2/8/26.
//

import Foundation
import HealthKit

/// Manages all HealthKit operations for heart rate monitoring
class HealthKitManager {
    
    // MARK: - Properties
    
    /// Shared singleton instance
    static let shared = HealthKitManager()
    
    /// The HealthKit store - our interface to HealthKit
    let healthStore = HKHealthStore()
    
    /// The heart rate quantity type
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    /// Unit for heart rate (beats per minute)
    let heartRateUnit = HKUnit(from: "count/min")
    
    /// Currently running heart rate query
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Availability Check
    
    /// Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Authorization
    
    /// Request authorization to read heart rate data
    func requestAuthorization() async throws {
        // Define the types we want to read
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        // We're only reading, not writing
        let typesToWrite: Set<HKSampleType> = []
        
        // Request authorization
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }
    
    /// Check if we have authorization to read heart rate
    /// Note: This only tells us if we've asked, not if user allowed
    func checkAuthorizationStatus() -> HKAuthorizationStatus {
        healthStore.authorizationStatus(for: heartRateType)
    }
    
    // MARK: - Fetching Data
    
    /// Fetch the most recent heart rate sample
    func fetchLatestHeartRate() async throws -> HeartRateSample? {
        return try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
            
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let bpm = sample.quantity.doubleValue(for: self.heartRateUnit)
                let heartRateSample = HeartRateSample(bpm: bpm, timestamp: sample.startDate)
                continuation.resume(returning: heartRateSample)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Fetch heart rate samples from the last hour
    func fetchRecentHeartRates(hours: Int = 1) async throws -> [HeartRateSample] {
        return try await withCheckedThrowingContinuation { continuation in
            let startDate = Calendar.current.date(byAdding: .hour, value: -hours, to: Date())!
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: Date(),
                options: .strictStartDate
            )
            
            let sortDescriptor = NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
            
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let heartRateSamples = (samples as? [HKQuantitySample])?.map { sample in
                    HeartRateSample(
                        bpm: sample.quantity.doubleValue(for: self.heartRateUnit),
                        timestamp: sample.startDate
                    )
                } ?? []
                
                continuation.resume(returning: heartRateSamples)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Real-Time Monitoring
    
    /// Start monitoring heart rate in real-time
    /// - Parameter onUpdate: Closure called when new heart rate data arrives
    func startHeartRateMonitoring(onUpdate: @escaping ([HeartRateSample]) -> Void) {
        // Stop any existing query
        stopHeartRateMonitoring()
        
        // Create anchored object query for real-time updates
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
            self.processHeartRateSamples(samples, onUpdate: onUpdate)
        }
        
        // Set up the update handler for continuous monitoring
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
            self.processHeartRateSamples(samples, onUpdate: onUpdate)
        }
        
        // Store reference and execute
        heartRateQuery = query
        healthStore.execute(query)
    }
    
    /// Stop monitoring heart rate
    func stopHeartRateMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }
    
    // MARK: - Private Helpers
    
    /// Process heart rate samples and convert to our model
    private func processHeartRateSamples(_ samples: [HKSample]?, onUpdate: @escaping ([HeartRateSample]) -> Void) {
        guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else {
            return
        }
        
        let heartRateSamples = quantitySamples.map { sample in
            HeartRateSample(
                bpm: sample.quantity.doubleValue(for: heartRateUnit),
                timestamp: sample.startDate
            )
        }
        
        // Call update handler on main thread
        DispatchQueue.main.async {
            onUpdate(heartRateSamples)
        }
    }
}


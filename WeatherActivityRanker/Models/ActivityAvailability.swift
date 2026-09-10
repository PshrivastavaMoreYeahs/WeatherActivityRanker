////
//  ActivityAvailability.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import Foundation

nonisolated struct ActivityAvailability: Equatable, Sendable {
    let isAvailable: Bool
    let reason: String?

    static let available = ActivityAvailability(isAvailable: true, reason: nil)

    static func unavailable(reason: String) -> ActivityAvailability {
        ActivityAvailability(isAvailable: false, reason: reason)
    }
}

nonisolated struct ActivityAvailabilitySet: Equatable, Sendable {
    let skiing: ActivityAvailability
    let surfing: ActivityAvailability
    let outdoorSightseeing: ActivityAvailability
    let indoorSightseeing: ActivityAvailability

    static let allAvailable = ActivityAvailabilitySet(
        skiing: .available,
        surfing: .available,
        outdoorSightseeing: .available,
        indoorSightseeing: .available
    )

    func availability(for activity: ActivityType) -> ActivityAvailability {
        switch activity {
        case .skiing:
            return skiing
        case .surfing:
            return surfing
        case .outdoorSightseeing:
            return outdoorSightseeing
        case .indoorSightseeing:
            return indoorSightseeing
        }
    }
}
